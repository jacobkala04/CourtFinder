require("dotenv").config();
const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");
const path = require("path");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, "../frontend")));

const JWT_SECRET = process.env.JWT_SECRET || "courtfinder_jwt_secret_2024";
const SALT_ROUNDS = 10;

const dbConfig = {
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD ?? "@Omar2004",
  database: process.env.DB_NAME || "CourtFinder",
};

const db = mysql.createConnection({
  host: dbConfig.host,
  user: dbConfig.user,
  password: dbConfig.password,
  database: dbConfig.database,
});

db.connect((err) => {
  if (err) {
    console.error("Failed to connect to CourtFinder database:", err.message);
    console.error("Database config:", {
      host: dbConfig.host,
      user: dbConfig.user,
      database: dbConfig.database,
      passwordSet: dbConfig.password.length > 0,
    });
    console.error(
      "Override with DB_HOST, DB_USER, DB_PASSWORD, and DB_NAME if needed.",
    );
    process.exit(1);
  }
  console.log("Connected to CourtFinder database successfully");

  // Auto-create OrganizerRequest table if it doesn't exist
  db.query(
    `CREATE TABLE IF NOT EXISTS OrganizerRequest (
      RequestID int NOT NULL AUTO_INCREMENT,
      PlayerID  int NOT NULL,
      Message   varchar(500) DEFAULT NULL,
      Status    varchar(50)  DEFAULT 'Pending',
      Timestamp datetime     DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (RequestID),
      KEY PlayerID (PlayerID),
      CONSTRAINT organizerrequest_ibfk_1
        FOREIGN KEY (PlayerID) REFERENCES Player (PlayerID)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4`,
    (err2) => {
      if (err2)
        console.error(
          "Warning: could not create OrganizerRequest table:",
          err2.message,
        );
      else console.log("OrganizerRequest table ready");
    },
  );
});

// ── Auth helpers ────────────────────────────────────────────────────────────

function requireAuth(req, res, next) {
  const auth = req.headers.authorization;
  if (!auth || !auth.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Not authenticated" });
  }
  try {
    req.user = jwt.verify(auth.slice(7), JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ error: "Invalid or expired token" });
  }
}

function requireModerator(req, res, next) {
  if (!req.user || !req.user.isModerator) {
    return res.status(403).json({ error: "Moderators only" });
  }
  next();
}

function buildToken(u) {
  return jwt.sign(
    {
      userID: u.UserID,
      username: u.Username,
      playerID: u.PlayerID || null,
      organizerID: u.OrganizerID || null,
      moderatorID: u.ModeratorID || null,
      isModerator: !!u.ModeratorID,
    },
    JWT_SECRET,
    { expiresIn: "7d" },
  );
}

function formatUser(u) {
  return {
    userID: u.UserID,
    username: u.Username,
    playerID: u.PlayerID || null,
    organizerID: u.OrganizerID || null,
    moderatorID: u.ModeratorID || null,
    isModerator: !!u.ModeratorID,
  };
}

// ── Auth routes ─────────────────────────────────────────────────────────────

app.post("/api/auth/signup", async (req, res) => {
  const { username, email, password, phone } = req.body;
  if (!username || !email || !password) {
    return res
      .status(400)
      .json({ error: "Username, email, and password are required" });
  }
  try {
    const hash = await bcrypt.hash(password, SALT_ROUNDS);
    db.query(
      "INSERT INTO User (Username, Email, Password, Phone) VALUES (?, ?, ?, ?)",
      [username, email, hash, phone || null],
      (err, result) => {
        if (err) {
          if (err.code === "ER_DUP_ENTRY") {
            return res
              .status(409)
              .json({ error: "Username or email already taken" });
          }
          return res.status(500).json({ error: err.message });
        }
        const row = {
          UserID: result.insertId,
          Username: username,
          PlayerID: null,
          OrganizerID: null,
          ModeratorID: null,
        };
        res.json({ token: buildToken(row), user: formatUser(row) });
      },
    );
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post("/api/auth/login", (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res
      .status(400)
      .json({ error: "Username and password are required" });
  }

  db.query(
    `SELECT u.UserID, u.Username, u.Password,
            p.PlayerID, go.OrganizerID, m.ModeratorID
     FROM User u
     LEFT JOIN Player       p  ON p.UserID  = u.UserID
     LEFT JOIN GameOrganizer go ON go.UserID = u.UserID
     LEFT JOIN Moderator    m  ON m.UserID  = u.UserID
     WHERE u.Username = ?`,
    [username],
    async (err, rows) => {
      if (err) return res.status(500).json({ error: err.message });
      if (!rows.length)
        return res.status(401).json({ error: "Invalid username or password" });

      const user = rows[0];

      // Try bcrypt first; fall back to plaintext for legacy seed accounts
      let match = false;
      try {
        match = await bcrypt.compare(password, user.Password);
      } catch {
        match = false;
      }

      if (!match && password === user.Password) {
        // Upgrade legacy plaintext password to bcrypt on first login
        match = true;
        const hash = await bcrypt.hash(password, SALT_ROUNDS);
        db.query("UPDATE User SET Password = ? WHERE UserID = ?", [
          hash,
          user.UserID,
        ]);
      }

      if (!match)
        return res.status(401).json({ error: "Invalid username or password" });

      res.json({ token: buildToken(user), user: formatUser(user) });
    },
  );
});

app.get("/api/auth/me", requireAuth, (req, res) => {
  db.query(
    `SELECT u.UserID, u.Username,
            p.PlayerID, go.OrganizerID, m.ModeratorID
     FROM User u
     LEFT JOIN Player       p  ON p.UserID  = u.UserID
     LEFT JOIN GameOrganizer go ON go.UserID = u.UserID
     LEFT JOIN Moderator    m  ON m.UserID  = u.UserID
     WHERE u.UserID = ?`,
    [req.user.userID],
    (err, rows) => {
      if (err) return res.status(500).json({ error: err.message });
      if (!rows.length)
        return res.status(404).json({ error: "User not found" });
      res.json(formatUser(rows[0]));
    },
  );
});

app.post("/api/auth/complete-profile", requireAuth, (req, res) => {
  if (req.user.playerID) {
    return res.status(400).json({ error: "Player profile already exists" });
  }
  const { skillLevel, position } = req.body;
  db.query(
    "INSERT INTO Player (UserID, SkillLevel, Position, GamesPlayed) VALUES (?, ?, ?, 0)",
    [req.user.userID, skillLevel || null, position || null],
    (err, result) => {
      if (err) return res.status(500).json({ error: err.message });
      const row = {
        UserID: req.user.userID,
        Username: req.user.username,
        PlayerID: result.insertId,
        OrganizerID: req.user.organizerID,
        ModeratorID: req.user.moderatorID,
      };
      res.json({
        success: true,
        token: buildToken(row),
        playerID: result.insertId,
      });
    },
  );
});

app.post("/api/auth/change-password", requireAuth, async (req, res) => {
  const { currentPassword, newPassword } = req.body;
  if (!currentPassword || !newPassword) {
    return res
      .status(400)
      .json({ error: "Current and new passwords are required" });
  }
  db.query(
    "SELECT Password FROM User WHERE UserID = ?",
    [req.user.userID],
    async (err, rows) => {
      if (err) return res.status(500).json({ error: err.message });
      if (!rows.length)
        return res.status(404).json({ error: "User not found" });

      let match = false;
      try {
        match = await bcrypt.compare(currentPassword, rows[0].Password);
      } catch {
        match = false;
      }
      if (!match && currentPassword === rows[0].Password) match = true;

      if (!match)
        return res.status(401).json({ error: "Current password is incorrect" });

      const hash = await bcrypt.hash(newPassword, SALT_ROUNDS);
      db.query(
        "UPDATE User SET Password = ? WHERE UserID = ?",
        [hash, req.user.userID],
        (err2) => {
          if (err2) return res.status(500).json({ error: err2.message });
          res.json({ success: true });
        },
      );
    },
  );
});

// ── Organizer request routes ─────────────────────────────────────────────────

// Player submits a request to become a game organizer
app.post("/api/organizer-requests", requireAuth, (req, res) => {
  if (!req.user.playerID) {
    return res
      .status(400)
      .json({ error: "Complete your player profile first" });
  }
  if (req.user.organizerID) {
    return res.status(400).json({ error: "You are already a game organizer" });
  }

  db.query(
    'SELECT RequestID FROM OrganizerRequest WHERE PlayerID = ? AND Status = "Pending"',
    [req.user.playerID],
    (err, existing) => {
      if (err) return res.status(500).json({ error: err.message });
      if (existing.length) {
        return res
          .status(409)
          .json({ error: "You already have a pending organizer request" });
      }
      db.query(
        "INSERT INTO OrganizerRequest (PlayerID, Message) VALUES (?, ?)",
        [req.user.playerID, req.body.message || null],
        (err2, result) => {
          if (err2) return res.status(500).json({ error: err2.message });
          res.json({ success: true, insertId: result.insertId });
        },
      );
    },
  );
});

// Player checks their own organizer request status
app.get("/api/organizer-requests/mine", requireAuth, (req, res) => {
  if (!req.user.playerID) return res.json(null);
  db.query(
    "SELECT * FROM OrganizerRequest WHERE PlayerID = ? ORDER BY Timestamp DESC LIMIT 1",
    [req.user.playerID],
    (err, rows) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(rows[0] || null);
    },
  );
});

// Moderator lists all organizer requests
app.get(
  "/api/organizer-requests",
  requireAuth,
  requireModerator,
  (req, res) => {
    db.query(
      `SELECT orq.RequestID, orq.PlayerID, orq.Message, orq.Status, orq.Timestamp,
            u.Username
     FROM OrganizerRequest orq
     JOIN Player p ON orq.PlayerID = p.PlayerID
     JOIN User   u ON p.UserID     = u.UserID
     ORDER BY orq.Timestamp DESC`,
      (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
      },
    );
  },
);

// Moderator approves or denies a request
app.put(
  "/api/organizer-requests/:id",
  requireAuth,
  requireModerator,
  (req, res) => {
    const { status } = req.body;
    if (!["Approved", "Denied"].includes(status)) {
      return res
        .status(400)
        .json({ error: "Status must be Approved or Denied" });
    }

    db.query(
      `SELECT orq.PlayerID, p.UserID
     FROM OrganizerRequest orq
     JOIN Player p ON orq.PlayerID = p.PlayerID
     WHERE orq.RequestID = ?`,
      [req.params.id],
      (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        if (!rows.length)
          return res.status(404).json({ error: "Request not found" });

        db.query(
          "UPDATE OrganizerRequest SET Status = ? WHERE RequestID = ?",
          [status, req.params.id],
          (err2) => {
            if (err2) return res.status(500).json({ error: err2.message });

            if (status === "Approved") {
              // INSERT IGNORE handles the case where the user is already an organizer
              db.query(
                "INSERT IGNORE INTO GameOrganizer (UserID, GamesHosted) VALUES (?, 0)",
                [rows[0].UserID],
                (err3) => {
                  if (err3)
                    return res.status(500).json({ error: err3.message });
                  res.json({ success: true });
                },
              );
            } else {
              res.json({ success: true });
            }
          },
        );
      },
    );
  },
);

// ── Admin routes (moderator only) ────────────────────────────────────────────

app.get("/api/admin/reports", requireAuth, requireModerator, (req, res) => {
  db.query(
    `SELECT ur.ReportID, ur.Description, ur.Status, ur.Timestamp,
            reporter.Username AS ReporterName,
            reported.Username AS ReportedName
     FROM UserReport ur
     JOIN Player rp       ON ur.ReporterID = rp.PlayerID
     JOIN User   reporter ON rp.UserID     = reporter.UserID
     JOIN User   reported ON ur.ReportedID = reported.UserID
     ORDER BY ur.Timestamp DESC`,
    (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results);
    },
  );
});

app.put("/api/admin/reports/:id", requireAuth, requireModerator, (req, res) => {
  const { status } = req.body;
  if (!["Pending", "Resolved", "Dismissed"].includes(status)) {
    return res.status(400).json({ error: "Invalid status" });
  }
  db.query(
    "UPDATE UserReport SET Status = ? WHERE ReportID = ?",
    [status, req.params.id],
    (err, result) => {
      if (err) return res.status(500).json({ error: err.message });
      if (result.affectedRows === 0)
        return res.status(404).json({ error: "Report not found" });
      res.json({ success: true });
    },
  );
});

// Moderator promotes a user to moderator role
app.post("/api/admin/moderators", requireAuth, requireModerator, (req, res) => {
  const { userID } = req.body;
  if (!userID) return res.status(400).json({ error: "userID is required" });

  // Verify the target user exists
  db.query(
    "SELECT UserID FROM User WHERE UserID = ?",
    [userID],
    (err, rows) => {
      if (err) return res.status(500).json({ error: err.message });
      if (!rows.length)
        return res.status(404).json({ error: "User not found" });

      // INSERT IGNORE so promoting an existing moderator is a no-op
      db.query(
        "INSERT IGNORE INTO Moderator (UserID, AccessLevel) VALUES (?, 'Junior')",
        [userID],
        (err2) => {
          if (err2) return res.status(500).json({ error: err2.message });
          res.json({ success: true });
        },
      );
    },
  );
});

// ── Browse endpoints (enriched JOINs for the frontend) ───────────────────────

app.get("/api/browse/sessions", (req, res) => {
  db.query(
    `SELECT bs.SessionID, bs.OrganizerID, bs.DateTime, bs.SkillRequired,
            bs.Capacity, bs.Duration, bs.GameFormat, bs.Status,
            COALESCE(bc.Name,     'Unknown Court') AS CourtName,
            COALESCE(bc.Location, '')              AS Location,
            COALESCE(u.Username,  'Unknown')       AS OrganizerName
     FROM BasketballSession bs
     LEFT JOIN BasketballCourt  bc ON bs.CourtID    = bc.CourtID
     LEFT JOIN GameOrganizer    go ON bs.OrganizerID = go.OrganizerID
     LEFT JOIN User              u ON go.UserID      = u.UserID
     ORDER BY bs.DateTime ASC`,
    (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results);
    },
  );
});

app.get("/api/browse/players", (req, res) => {
  db.query(
    `SELECT p.PlayerID, p.UserID, u.Username, p.SkillLevel, p.Position, p.GamesPlayed
     FROM Player p
     JOIN User u ON p.UserID = u.UserID`,
    (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results);
    },
  );
});

app.get("/api/browse/requests/:playerId", (req, res) => {
  db.query(
    `SELECT jr.RequestID, jr.Status, jr.Message, jr.Timestamp,
            bs.GameFormat, bs.DateTime, bs.Status AS SessionStatus,
            bc.Name AS CourtName
     FROM JoinRequest jr
     JOIN BasketballSession bs ON jr.SessionID = bs.SessionID
     JOIN BasketballCourt   bc ON bs.CourtID   = bc.CourtID
     WHERE jr.PlayerID = ?
     ORDER BY jr.Timestamp DESC`,
    [req.params.playerId],
    (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results);
    },
  );
});

// ── Generic CRUD ─────────────────────────────────────────────────────────────

const tableKeys = {
  User: "UserID",
  Player: "PlayerID",
  GameOrganizer: "OrganizerID",
  Moderator: "ModeratorID",
  BasketballCourt: "CourtID",
  BasketballSession: "SessionID",
  JoinRequest: "RequestID",
  Notification: "NotifID",
  PlayerRating: "RatingID",
  GameFeedback: "FeedbackID",
  UserReport: "ReportID",
};

function validateTable(req, res, next) {
  if (!tableKeys[req.params.table]) {
    return res
      .status(400)
      .json({ error: `Unknown table: ${req.params.table}` });
  }
  next();
}

app.get("/api/:table", validateTable, (req, res) => {
  // Never expose password hashes through the generic endpoint
  const cols =
    req.params.table === "User" ? "UserID, Username, Email, Phone" : "*";
  db.query(`SELECT ${cols} FROM \`${req.params.table}\``, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

app.post("/api/:table", requireAuth, validateTable, (req, res) => {
  const table = req.params.table;
  const pk = tableKeys[table];
  const data = { ...req.body };
  delete data[pk];
  if (table === "User") delete data.Password; // password changes go through /api/auth/change-password

  if (Object.keys(data).length === 0) {
    return res.status(400).json({ error: "No fields provided" });
  }

  const cols = Object.keys(data)
    .map((c) => `\`${c}\``)
    .join(", ");
  const placeholders = Object.keys(data)
    .map(() => "?")
    .join(", ");

  db.query(
    `INSERT INTO \`${table}\` (${cols}) VALUES (${placeholders})`,
    Object.values(data),
    (err, result) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ success: true, insertId: result.insertId });
    },
  );
});

app.put("/api/:table/:id", requireAuth, validateTable, (req, res) => {
  const table = req.params.table;
  const pk = tableKeys[table];
  const data = { ...req.body };
  delete data[pk];
  if (table === "User") delete data.Password;

  if (Object.keys(data).length === 0) {
    return res.status(400).json({ error: "No fields provided" });
  }

  const setClause = Object.keys(data)
    .map((c) => `\`${c}\` = ?`)
    .join(", ");

  db.query(
    `UPDATE \`${table}\` SET ${setClause} WHERE \`${pk}\` = ?`,
    [...Object.values(data), req.params.id],
    (err, result) => {
      if (err) return res.status(500).json({ error: err.message });
      if (result.affectedRows === 0)
        return res.status(404).json({ error: "Record not found" });
      res.json({ success: true });
    },
  );
});

app.delete("/api/:table/:id", requireAuth, validateTable, (req, res) => {
  const table = req.params.table;
  const pk = tableKeys[table];

  db.query(
    `DELETE FROM \`${table}\` WHERE \`${pk}\` = ?`,
    [req.params.id],
    (err, result) => {
      if (err) return res.status(500).json({ error: err.message });
      if (result.affectedRows === 0)
        return res.status(404).json({ error: "Record not found" });
      res.json({ success: true });
    },
  );
});

const PORT = 3001;
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});

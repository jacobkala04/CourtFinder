const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD ?? '',
    database: process.env.DB_NAME || 'CourtFinder'
};

const db = mysql.createConnection({
    host: dbConfig.host,
    user: dbConfig.user,
    password: dbConfig.password,
    database: dbConfig.database
});

db.connect((err) => {
    if (err) {
        console.error('Failed to connect to CourtFinder database:', err.message);
        console.error('Database config:', {
            host: dbConfig.host,
            user: dbConfig.user,
            database: dbConfig.database,
            passwordSet: dbConfig.password.length > 0
        });
        console.error('Override with DB_HOST, DB_USER, DB_PASSWORD, and DB_NAME if needed.');
        process.exit(1);
    }
    console.log('Connected to CourtFinder database successfully');
});

const tableKeys = {
    User: 'UserID',
    Player: 'PlayerID',
    GameOrganizer: 'OrganizerID',
    Moderator: 'ModeratorID',
    BasketballCourt: 'CourtID',
    BasketballSession: 'SessionID',
    JoinRequest: 'RequestID',
    Notification: 'NotifID',
    PlayerRating: 'RatingID',
    GameFeedback: 'FeedbackID',
    UserReport: 'ReportID'
};

// ── Browse endpoints (enriched JOINs for the frontend) ─────────────────────

// Sessions with court name, location, and organizer username
app.get('/api/browse/sessions', (req, res) => {
    db.query(`
        SELECT bs.SessionID, bs.OrganizerID, bs.DateTime, bs.SkillRequired,
               bs.Capacity, bs.Duration, bs.GameFormat, bs.Status,
               COALESCE(bc.Name, 'Unknown Court') AS CourtName,
               COALESCE(bc.Location, '') AS Location,
               COALESCE(u.Username, 'Unknown') AS OrganizerName
        FROM BasketballSession bs
        LEFT JOIN BasketballCourt bc ON bs.CourtID = bc.CourtID
        LEFT JOIN GameOrganizer go ON bs.OrganizerID = go.OrganizerID
        LEFT JOIN User u ON go.UserID = u.UserID
        ORDER BY bs.DateTime ASC
    `, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// Players with their usernames and UserID (needed for FK inserts)
app.get('/api/browse/players', (req, res) => {
    db.query(`
        SELECT p.PlayerID, p.UserID, u.Username, p.SkillLevel, p.Position, p.GamesPlayed
        FROM Player p
        JOIN User u ON p.UserID = u.UserID
    `, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// Join requests for a specific player, enriched with session + court info
app.get('/api/browse/requests/:playerId', (req, res) => {
    db.query(`
        SELECT jr.RequestID, jr.Status, jr.Message, jr.Timestamp,
               bs.GameFormat, bs.DateTime, bs.Status AS SessionStatus,
               bc.Name AS CourtName
        FROM JoinRequest jr
        JOIN BasketballSession bs ON jr.SessionID = bs.SessionID
        JOIN BasketballCourt bc ON bs.CourtID = bc.CourtID
        WHERE jr.PlayerID = ?
        ORDER BY jr.Timestamp DESC
    `, [req.params.playerId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// ── Generic CRUD ────────────────────────────────────────────────────────────

function validateTable(req, res, next) {
    if (!tableKeys[req.params.table]) {
        return res.status(400).json({ error: `Unknown table: ${req.params.table}` });
    }
    next();
}

app.get('/api/:table', validateTable, (req, res) => {
    db.query(`SELECT * FROM \`${req.params.table}\``, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.post('/api/:table', validateTable, (req, res) => {
    const table = req.params.table;
    const pk = tableKeys[table];
    const data = { ...req.body };
    delete data[pk];

    if (Object.keys(data).length === 0) {
        return res.status(400).json({ error: 'No fields provided' });
    }

    const cols = Object.keys(data).map(c => `\`${c}\``).join(', ');
    const placeholders = Object.keys(data).map(() => '?').join(', ');

    db.query(
        `INSERT INTO \`${table}\` (${cols}) VALUES (${placeholders})`,
        Object.values(data),
        (err, result) => {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ success: true, insertId: result.insertId });
        }
    );
});

app.put('/api/:table/:id', validateTable, (req, res) => {
    const table = req.params.table;
    const pk = tableKeys[table];
    const data = { ...req.body };
    delete data[pk];

    if (Object.keys(data).length === 0) {
        return res.status(400).json({ error: 'No fields provided' });
    }

    const setClause = Object.keys(data).map(c => `\`${c}\` = ?`).join(', ');

    db.query(
        `UPDATE \`${table}\` SET ${setClause} WHERE \`${pk}\` = ?`,
        [...Object.values(data), req.params.id],
        (err, result) => {
            if (err) return res.status(500).json({ error: err.message });
            if (result.affectedRows === 0) return res.status(404).json({ error: 'Record not found' });
            res.json({ success: true });
        }
    );
});

app.delete('/api/:table/:id', validateTable, (req, res) => {
    const table = req.params.table;
    const pk = tableKeys[table];

    db.query(
        `DELETE FROM \`${table}\` WHERE \`${pk}\` = ?`,
        [req.params.id],
        (err, result) => {
            if (err) return res.status(500).json({ error: err.message });
            if (result.affectedRows === 0) return res.status(404).json({ error: 'Record not found' });
            res.json({ success: true });
        }
    );
});

const PORT = 3001;
app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});

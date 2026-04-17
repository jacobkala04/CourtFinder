## Setup

### 1. Clone the repo

```bash
git clone https://github.com/jacobkala04/CourtFinder.git
cd CourtFinder
```

### 2. Set up the database

```bash
mysql -u root -p -e "CREATE DATABASE CourtFinder;"
mysql -u root -p CourtFinder < db/courtfinder.sql
```

The `OrganizerRequest` table is created automatically on first server startup.

### 3. Configure database credentials

The server reads credentials from environment variables. Set `DB_PASSWORD` to your MySQL root password:

```bash
# Windows
set DB_PASSWORD=yourpassword

# Mac/Linux
export DB_PASSWORD=yourpassword
```

Or create a `.env` file in `backend/` (already gitignored):

```
DB_PASSWORD=yourpassword
```

### 4. Install dependencies and run

```bash
cd backend
# npm install express mysql2 cors dotenv
npm install
node server.js
```

App runs at http://localhost:3001

### Default accounts (seed data)

| Username | Password | Role                             |
| -------- | -------- | -------------------------------- |
| john     | pass1    | Player, Organizer, **Moderator** |
| ana      | pass2    | Player, Organizer, **Moderator** |
| tom      | pass6    | Player only                      |

Moderators have access to the Admin Panel. Passwords are upgraded to bcrypt on first login.

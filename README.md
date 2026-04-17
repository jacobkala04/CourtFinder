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

### 3. Configure environment

Create `backend/.env` with your MySQL password:

```
DB_PASSWORD=your_password_here
```

### 4. Install dependencies and run

```bash
cd backend
npm install express mysql2 cors dotenv
node server.js
```

App runs at http://localhost:3001

## Setup

### 1. Clone the repo

```bash
git clone https://github.com/jacobkala04/CourtFinder.git
cd CourtFinder
```

### 2. Set up the database

```bash
mysql -u root -p -e "CREATE DATABASE CourtFinder;"
mysql -u root -p CourtFinder < courtfinder-app/courtfinder.sql
```

### 3. Install dependencies and run

```bash
cd courtfinder-app
npm install express mysql2 cors
node server.js
```

App runs at http://localhost:3001

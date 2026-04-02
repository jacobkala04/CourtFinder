# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CourtFinder is a user-facing basketball session finder. Players browse open games at local courts, request to join sessions, manage their requests, update their profile, leave post-game feedback, rate other players, and report bad actors. There is no real auth — a "Playing as" dropdown at the top simulates a logged-in player.

## How to Run

```bash
cd courtfinder-app
npm install express mysql2 cors
node server.js
```

App runs at `http://localhost:3001`. Terminal prints `Connected to CourtFinder database successfully` on startup.

## File Structure

```
courtfinder-app/
├── server.js        # Express backend + API routes
├── package.json
└── public/
    └── index.html   # Entire frontend (HTML + CSS + JS in one file)
```

## Architecture

**Backend (`server.js`):** Two layers of routes:
1. **Generic CRUD** — `GET/POST/PUT/DELETE /api/:table` and `/api/:table/:id` handle all 11 tables dynamically. Table names are validated against `tableKeys` to prevent injection.
2. **Browse endpoints** — enriched JOIN queries for display: `/api/browse/sessions`, `/api/browse/players`, `/api/browse/requests/:playerId`. These return human-readable data (court names, usernames) rather than raw IDs.

**Frontend (`public/index.html`):** Single-page app with a tab bar. Five tabs each handle a distinct user action. App state (`currentPlayer`, `players`, `sessions`, `courts`) is loaded once at init and reused across tabs. Status messages auto-dismiss after 4 seconds (important — recorded for demo video).

## Tab Structure

| Tab | Primary DB operations |
|---|---|
| Find Games | SELECT (browse sessions + courts), INSERT JoinRequest |
| Courts | SELECT BasketballCourt |
| My Requests | SELECT JoinRequest (enriched), DELETE JoinRequest |
| My Profile | SELECT Player, UPDATE Player |
| Feedback & Rate | INSERT GameFeedback, INSERT PlayerRating, INSERT UserReport |

## Browse Endpoints

```
GET /api/browse/sessions       → BasketballSession JOIN BasketballCourt JOIN GameOrganizer JOIN User
GET /api/browse/players        → Player JOIN User  (includes UserID for FK use)
GET /api/browse/requests/:pid  → JoinRequest JOIN BasketballSession JOIN BasketballCourt WHERE PlayerID = pid
```

## Database

MySQL 8.0, database `CourtFinder`, user `root`, host `localhost`. **Never drop or recreate tables.**

### Table → Primary Key

| Table | PK |
|---|---|
| User | UserID |
| Player | PlayerID |
| GameOrganizer | OrganizerID |
| Moderator | ModeratorID |
| BasketballCourt | CourtID |
| BasketballSession | SessionID |
| JoinRequest | RequestID |
| Notification | NotifID |
| PlayerRating | RatingID |
| GameFeedback | FeedbackID |
| UserReport | ReportID |

### FK dependencies (relevant for inserts)

- JoinRequest → Player, BasketballSession, GameOrganizer
- PlayerRating → Player (RaterID), **User** (RatedID, not PlayerID), BasketballSession
- GameFeedback → Player, BasketballSession
- UserReport → Player (ReporterID), User (ReportedID), Moderator (auto-assigned, use first available)

## Constraints

- No TypeScript, no build tools, no React
- No authentication — player context is simulated via dropdown
- Keep code simple and readable for a class project demo

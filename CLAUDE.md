# BiPolarMonitor — CLAUDE.md

## Overview

Mood/health monitoring app. Flutter mobile frontend + Python FastAPI backend + NAS deployment. Uses OpenFace for facial emotion analysis (ML layer). Backend runs on NAS via Docker Compose behind Caddy + Cloudflare Tunnel.

## Structure

```
flutter/
  bipolar_monitor/         # Flutter app (iOS + Android)
    lib/
      app.dart
      core/
      features/
      shared/

backend/
  api/                     # Python FastAPI
    main.py
    models/
    middleware/
    config.py
    database.py            # SQLAlchemy
    requirements.txt
    Dockerfile
  ml/                      # ML models (emotion analysis)
  openface/                # OpenFace integration

nas/
  docker-compose.yml       # Full NAS stack
  Caddyfile
  cloudflared/
  static/                  # Static assets
  docs/
```

## Flutter App

```bash
cd flutter/bipolar_monitor
flutter pub get
flutter run
flutter build apk
flutter build ios
```

## Backend

```bash
cd backend/api
pip install -r requirements.txt

# Local dev
uvicorn main:app --reload --port 8000

# NAS deploy
docker compose -f nas/docker-compose.yml up -d
```

## NAS Stack

Runs on NAS via Docker Compose. Caddy handles HTTPS + reverse proxy. Cloudflare Tunnel exposes the service.

```bash
# From nas/
docker compose up -d
docker compose logs -f
```

## Conventions

- Backend: FastAPI + SQLAlchemy (Alembic migrations in `backend/api/alembic/`)
- Auth: check middleware/ for auth strategy
- Flutter: Provider or standard setState (check lib/core/ for state management)

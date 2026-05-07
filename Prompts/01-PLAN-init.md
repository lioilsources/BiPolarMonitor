# BipolarMonitor — Implementační plán (init)

> Verze: 1.0 | Datum: 2026-05-07 | Stav: Fáze 1 hotova

---

## Architektura

```
Flutter (iOS/Android)
  │ HTTPS multipart upload + JWT
  ▼
Cloudflare Tunnel → Caddy (:8080)
  │
  ▼
DGX Spark — docker-compose
  ├── api (FastAPI :8000)   ← auth, measurements, dialog, user
  └── ml  (FastAPI :8001)   ← Whisper + openSMILE + MediaPipe + scoring
        │
        └── interní LAN → NAS (Ubuntu)
              ├── PostgreSQL 16 (:5432)
              └── MinIO (:9000)
```

**Klíčové rozhodnutí oproti původnímu plánu:**
- Backend: **FastAPI** (ne Go)
- Recording prompt: **BladeRunner dialog** (5 otázek × 3 varianty), ne čtení básně
- Recording: kontinuální video+audio, per-question timings jako metadata → ML segmentuje

---

## Stav implementace

### ✅ Hotovo (Fáze 1)

#### FastAPI Backend (`backend/api/`)
- [x] `config.py` — pydantic-settings, `.env`
- [x] `database.py` — asyncpg + SQLAlchemy async engine
- [x] `models/user.py` — User, RefreshToken, UserBaseline
- [x] `models/measurement.py` — Measurement, MeasurementScore
- [x] `middleware/auth_middleware.py` — JWT create/verify, bcrypt, `get_current_user`
- [x] `services/storage_service.py` — MinIO upload/download/delete/presign
- [x] `services/ml_client.py` — async HTTP trigger do ML service
- [x] `routers/auth.py` — POST /register, /login, /refresh (token rotace)
- [x] `routers/dialog.py` — GET /dialog/next (rotační algoritmus Q1–Q5, varianty A/B/C)
- [x] `routers/measurements.py` — POST /upload, GET /, GET /:id, DELETE /:id
- [x] `routers/user.py` — GET/PUT /profile, POST /enroll-speaker, DELETE /data (GDPR)
- [x] `main.py` — FastAPI app, CORS, lifespan (auto-create tables)
- [x] `Dockerfile`
- [x] `requirements.txt`

#### ML Service (`backend/ml/`)
- [x] `pipeline/audio_analyzer.py` — Whisper (word timestamps), openSMILE eGeMAPS, speech rate, pause analysis, per-question segmentace, energy profile
- [x] `pipeline/video_analyzer.py` — MediaPipe Face Mesh: EAR blink, mouth, brow, head pose
- [x] `pipeline/cohesion.py` — `paraphrase-multilingual-mpnet-base-v2`: Q-A cohesion, internal cohesion
- [x] `pipeline/scoring.py` — z-score dimenze, composite, flag detection, trend, rolling baseline update (weighted, 30 měření)
- [x] `main.py` — FastAPI, background pipeline, MinIO download, PostgreSQL write-back
- [x] `Dockerfile` (pytorch/pytorch CUDA base)
- [x] `requirements.txt`

#### Deployment (`backend/`)
- [x] `docker-compose.yml` — api + ml (nvidia runtime) + caddy
- [x] `Caddyfile` — reverse proxy, 200MB upload limit, security headers

#### NAS (`nas/`)
- [x] `docker-compose.yml` — PostgreSQL 16 + MinIO + pg backup (cron 3am)
- [x] `init.sql` — cleanup_old_media() funkce
- [x] `.env.example`

#### Flutter App (`flutter/bipolar_monitor/`)
- [x] `pubspec.yaml` — všechny závislosti
- [x] `main.dart` + `app.dart` — ProviderScope, MaterialApp.router, dark theme
- [x] `core/constants/app_colors.dart` — paleta (tmavá modročerná + šalvěj + meruňka)
- [x] `core/constants/app_typography.dart` — DM Serif Display + DM Sans + JetBrains Mono
- [x] `core/constants/api_constants.dart`
- [x] `core/storage/secure_storage.dart` — flutter_secure_storage, iOS Keychain / Android Keystore
- [x] `core/network/api_client.dart` — Dio + AuthInterceptor (JWT auto-refresh) + RetryInterceptor
- [x] `features/auth/domain/user_model.dart`
- [x] `features/auth/data/auth_repository.dart`
- [x] `features/auth/presentation/auth_provider.dart` — StateNotifier, init check
- [x] `features/auth/presentation/login_screen.dart`
- [x] `features/record/domain/measurement_model.dart` — DialogQuestion, DialogSession, QuestionTiming
- [x] `features/record/presentation/dialog_widget.dart` — **BladeRunner UI**: 5 otázek sekvenčně, fade animace, dimension chip, progress dots, timing tracking
- [x] `features/record/presentation/record_provider.dart` — biometric → load dialog → countdown → recording → upload
- [x] `features/record/presentation/record_screen.dart` — kamera preview + dialog widget + upload progress
- [x] `features/dashboard/presentation/dashboard_provider.dart`
- [x] `features/dashboard/presentation/dashboard_screen.dart` — score ring + trend chart + record CTA + crisis button
- [x] `features/dashboard/presentation/score_ring_widget.dart` — obloukový arc progress (CustomPainter)
- [x] `features/dashboard/presentation/trend_chart_widget.dart` — fl_chart LineChart, 14 dní
- [x] `shared/widgets/app_button.dart`
- [x] `shared/widgets/crisis_button.dart` — 3 krizová čísla CZ, bottom sheet
- [x] `shared/router/app_router.dart` — go_router, redirect guard

---

### ✅ Hotovo (Fáze 2)

#### Flutter
- [x] `features/auth/presentation/register_screen.dart` — age gate, disclaimer checkbox
- [x] `features/onboarding/onboarding_screen.dart` — 3 stránky (PageView + dots)
- [x] `features/onboarding/enrollment_screen.dart` — 3 věty, PulseDot recording, embedding flow
- [x] `features/history/presentation/history_screen.dart` — lazy load, pull-to-refresh, infinite scroll
- [x] `features/history/presentation/measurement_card.dart` — Dismissible swipe-delete, score badge, flag chips, trend icon
- [x] `features/history/presentation/measurement_detail_screen.dart` — RadarChart (5D), score breakdown bars, per-question dialog, flag tiles, notes
- [x] `features/history/presentation/history_provider.dart` — paginated StateNotifier + detail FutureProvider
- [x] `features/settings/presentation/settings_screen.dart` — profil, reminder switch+time picker, notifikace, export, smazat vše, disclaimer
- [x] `features/record/data/offline_queue.dart` — Workmanager + exponential backoff (5/15/60/240/1440 min)
- [x] `core/storage/local_database.dart` — Drift SQLite (LocalMeasurements, LocalScores, LocalUserProfile + settings)
- [x] `core/notifications/notification_service.dart` — FCM + flutter_local_notifications, 2 channels, no sound
- [x] `features/record/data/speaker_verifier.dart` — cosine similarity, soft warning (threshold 0.75)
- [x] Router rozšířen o /register, /onboarding, /enrollment, /history, /measurement/:id, /settings

#### Backend / ML
- [x] `alembic/` — env.py, script.mako, migration 0001 (všechny tabulky + fcm_tokens)
- [x] `ml/pipeline/speaker.py` — Whisper encoder embedding, cosine similarity, verify_speaker
- [x] `ml/routers/speaker_router.py` — POST /ml/speaker-enroll, /speaker-verify, /speaker-embedding
- [x] ML pipeline — speaker verification integrována (výsledek uložen do measurements)
- [x] `api/services/fcm_service.py` — Firebase Admin SDK, send_analysis_complete, send_deviation_alert
- [x] `api/routers/push.py` — POST /push/register-token, /push/analysis-complete (webhook)
- [x] `api/tasks/retention.py` — async loop, daily cleanup starých MinIO objektů
- [x] ML main.py — FCM webhook callback po dokončení pipeline
- [x] `cloudflared/bipolar-tunnel.yml` + `install.sh`

### ⬜ Zbývá (Fáze 3 — polish)
- [ ] OpenFace sidecar — přidat AU-based facial analysis (MediaPipe je MVP proxy)
- [ ] Settings — skutečný export JSON (volání API + file save)
- [ ] Settings — skutečné DELETE /user/data volání
- [ ] `local_database.g.dart` — spustit `dart run build_runner build`
- [ ] Firebase projekty — přidat `google-services.json` (Android) a `GoogleService-Info.plist` (iOS)
- [ ] Certificate pinning (prod)
- [ ] Accessibility — font scaling, contrast mode
- [ ] Haptic feedback — countdown, upload done

---

## Data flow — jeden záznam

```
1. App: local_auth (Face ID / fingerprint)
2. App: GET /api/v1/dialog/next → DialogSession (5 otázek s variantami)
3. App: 3s countdown
4. App: start video (CameraController) + audio (AudioRecorder, 16kHz WAV)
5. Uživatel: odpovídá na 5 otázek sekvenčně, app trackuje timings (start/end per otázka)
6. App: POST /api/v1/measurements/upload
         multipart: video.mp4 + audio.wav + questions_used + question_timings + metadata
7. API: uloží do PostgreSQL + MinIO, trigger ML (async)
8. ML:  stáhne z MinIO → Whisper → segmentace per otázka → openSMILE → MediaPipe →
        sentence-transformers → z-score → composite → baseline update → write DB
9. API: (TODO) FCM push notification
10. App: zobrazí composite score + trend na Dashboard
```

---

## Dialog protokol — přehled

| Otázka | Dimenze | Cílí na |
|--------|---------|---------|
| Q1 (A/B/C) | Orientace v přítomnosti | Speech rate, energie, latence |
| Q2 (A/B/C) | Abstraktní asociace | Koheze, valence, délka |
| Q3 (A/B/C) | Kognitivní zátěž | Tempo, dokončení, plynulost |
| Q4 (A/B/C) | Emoční valence | Délka odpovědi, sentiment, vyhýbání |
| Q5 (A/B/C) | Uzavření, budoucnost | Orientace budoucností, energie |

**Rotace:** argmin(last_used) per otázka; Q4 min gap 21 dní; stejná kombinace min gap 60 dní.

---

## Scoring dimenze

| Dimenze | Zdroj | Váha |
|---------|-------|------|
| speech_rate | Whisper WPM | 0.18 |
| pause_ratio | Whisper timestamps | 0.12 |
| voice_energy | openSMILE loudness | 0.15 |
| f0_range | openSMILE GeMAPS | 0.10 |
| response_length | Whisper word count | 0.15 |
| cohesion | sentence-transformers | 0.12 |
| facial_affect | MediaPipe engagement proxy | 0.10 |
| negative_affect | MediaPipe blink deviation | 0.08 |

**Composite** = weighted sum z-scores. Pozitivní = zvýšení oproti baseline (energie/aktivace).

---

## Bezpečnost

| Oblast | Řešení |
|--------|--------|
| Transport | HTTPS (Cloudflare + Caddy) |
| Auth tokeny | JWT HS256, refresh rotace, flutter_secure_storage |
| Biometrie | local_auth → Secure Enclave, server nikdy nevidí |
| Media | MinIO SSE, smazáno po 30 dnech |
| GDPR | DELETE /user/data — okamžité, bez podmínek |
| Speaker data | Pouze float vector, ne raw audio |
| NAS | Nikdy internet-exposed, pouze interní LAN |

---

## Závislosti — klíčové verze

**Python (backend/ml):** FastAPI 0.111, SQLAlchemy 2.0 async, asyncpg 0.29, opensmile 2.5, openai-whisper 20231117, sentence-transformers 3.0, mediapipe 0.10, minio 7.2

**Flutter:** flutter_riverpod 2.5, go_router 14.2, dio 5.4, drift 2.18, camera 0.11, record 5.1, local_auth 2.2, fl_chart 0.68, firebase_messaging 15.1

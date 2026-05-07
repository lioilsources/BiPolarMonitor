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

### ⬜ Zbývá (Fáze 2)

#### Flutter
- [ ] `features/auth/presentation/register_screen.dart`
- [ ] `features/onboarding/` — 3 obrazovky + disclaimer screen
- [ ] `features/onboarding/enrollment_screen.dart` — speaker embedding (3 věty, enrollment flow)
- [ ] `features/history/presentation/history_screen.dart` — lazy list, swipe-to-delete
- [ ] `features/history/presentation/measurement_card.dart` — datum, composite badge, flagy jako čipy
- [ ] `features/history/presentation/measurement_detail_screen.dart` — radar chart (5 dimenzí), přepis, poznámka
- [ ] `features/settings/presentation/settings_screen.dart` — délka záznamu, notifikace, jazyk, export, smazat vše
- [ ] `features/record/data/offline_queue.dart` — workmanager, exponential backoff, SQLite pending
- [ ] `core/storage/local_database.dart` — Drift SQLite (Measurements, Scores, UserProfile)
- [ ] Push notifikace — FCM + flutter_local_notifications (analýza hotova, daily reminder, >2.5σ alert)
- [ ] Speaker verification — lokální cosine similarity při uploadu (warning, ne hard block)
- [ ] Krizové tlačítko — přidat na Record screen (zatím jen Dashboard)

#### Backend / ML
- [ ] Alembic migrace — verzovatelné DB schéma
- [ ] Speaker enrollment endpoint — výpočet embeddingu na ML service (nyní ukládá jen raw vektor z klienta)
- [ ] Speaker verification v ML pipeline — porovnat s user baseline při analýze
- [ ] OpenFace sidecar — přidat AU-based facial analysis (MediaPipe je MVP proxy)
- [ ] Cloudflare Tunnel konfigurace (`cloudflared-bipolar.yml`)
- [ ] FCM webhook — ML service → API → push notification po dokončení analýzy
- [ ] Media retention cron — denní cleanup starých souborů z MinIO

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

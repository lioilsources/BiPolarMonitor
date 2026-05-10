# BipolarMonitor — Phase 4 Implementation Plan

> Verze: 1.0 | Datum: 2026-05-10 | Stav: Hotovo

---

## Cíl fáze 4

Uživatelský zážitek a identita: vylepšení dashboardu, FCM deep linking, rozpoznání obličeje (ArcFace), PDF report pro lékaře, API rate limiting.

---

## Implementované soubory

### Flutter

| Soubor | Co bylo přidáno |
|--------|----------------|
| `lib/features/dashboard/presentation/dashboard_provider.dart` | `TrendPeriod` enum (week/month/quarter); `trendPeriodProvider`; `DashboardData` rozšířen o `streak`, `daysSinceLast`, `periodAvgComposite`; `dashboardProvider` refaktorován na `FutureProvider.autoDispose` s period param; `_computeStreak()` |
| `lib/features/dashboard/presentation/trend_chart_widget.dart` | Přepsán na `ConsumerWidget`; `_PeriodSelector` (7d/30d/90d); barevné tečky per hodnota; dashed 2.5σ threshold lines; axis date labels |
| `lib/features/dashboard/presentation/dashboard_screen.dart` | `_DeviationBanner` (>2.5σ); `_RecordingNudge` (>3 dny); `_StatsRow` (streak + period avg); plnohodnotné `_RecentCard` s datem, skóre, tap → `/measurement/:id`; odstraněny placeholder třídy |
| `lib/features/onboarding/face_enrollment_screen.dart` | **Nový soubor** — 3-shot kamera capture (přímý + 2 náklony); `_IntroView`, `_CapturingView`, `_ProcessingView`, `_DoneView`, `_ErrorView`; POST `/ml/face-enroll` + POST `/user/enroll-face` |
| `lib/core/notifications/notification_service.dart` | `NotificationService.onTap` callback (static); cold start via `getInitialMessage()`; `onMessageOpenedApp` → `_routeFromMessage()`; local notification tap → `_onNotificationTap()` s payload parsing; measurement deep link |
| `lib/shared/router/app_router.dart` | `GlobalKey<NavigatorState>` (`_routerKey`); route `/face-enrollment`; `NotificationService.onTap` wiring; `_ContextExt.let()` helper |
| `lib/features/settings/presentation/settings_screen.dart` | "Rozpoznání obličeje" tile → `/face-enrollment`; `_downloadPdfReport()` přes `ApiClient.downloadBytes()` + `Share.shareXFiles()` |
| `lib/core/network/api_client.dart` | `downloadBytes(path)` pro binary download (ResponseType.bytes) |
| `lib/features/auth/domain/user_model.dart` | `hasFaceEmbedding` field; bezpečné `as bool? ?? false` parsování |

### Backend — API (`backend/api/`)

| Soubor | Co bylo přidáno |
|--------|----------------|
| `models/user.py` | `face_embedding = Column(Text, nullable=True)` |
| `models/measurement.py` | `face_verified = Column(Boolean)`, `face_similarity = Column(Float)` |
| `routers/user.py` | `FaceEnrollmentRequest`; `POST /user/enroll-face`; `has_face_embedding` v `ProfileResponse` + `get_profile()` |
| `routers/measurements.py` | `GET /measurements/report` — PDF via reportlab (A4, tabulka měření, trend summary, disclaimer); `@limiter.limit("5/hour")` na upload; `from rate_limit import limiter` |
| `routers/auth.py` | `@limiter.limit("10/minute")` na `/register` a `/login`; `from rate_limit import limiter` |
| `rate_limit.py` | **Nový soubor** — `Limiter(key_func=get_remote_address)` v samostatném modulu (prevence circular importu) |
| `main.py` | `app.state.limiter = limiter`; `RateLimitExceeded` exception handler; `from rate_limit import limiter` |
| `requirements.txt` | `reportlab==4.2.2`, `slowapi==0.1.9` |
| `alembic/versions/0002_face_verification.py` | **Nová migrace** — `face_embedding TEXT` → users; `face_verified BOOLEAN`, `face_similarity FLOAT` → measurements; downgrade reverz |

### Backend — ML (`backend/ml/`)

| Soubor | Co bylo přidáno |
|--------|----------------|
| `pipeline/face_embedder.py` | **Nový soubor** — `extract_face_embedding()` (DeepFace + ArcFace); `average_face_embeddings()` (mean + L2-normalize); `cosine_similarity()`; `verify_face()` → `{verified, similarity}`; `extract_frame()` (cv2, temp JPG) |
| `routers/face_router.py` | **Nový soubor** — `POST /ml/face-enroll` (procesy image paths → embedding, 422 pokud žádný valid); `POST /ml/face-verify` (frame na 2s, porovnání) |
| `main.py` | Import `face_router`; `app.include_router(face_router)`; v `_run_pipeline()`: fetch `face_embedding` z users, `extract_frame()` → `verify_face()`, write `face_verified` + `face_similarity` do DB |
| `requirements.txt` | `deepface==0.0.93` |

---

## Architektura — face verification flow

```
Enrollment (jednou):
  FaceEnrollmentScreen
    ├── camera.takePicture() × 3 (přímý + 2 náklony)
    ├── POST /ml/face-enroll  {image_paths: [...]}
    │     └── DeepFace.represent(ArcFace) per snímek
    │         → average_face_embeddings() → L2-normalize
    │         ← {embedding: [512 floatů], enrolled_from: 3}
    └── POST /user/enroll-face  {embedding: [...]}
          └── users.face_embedding = JSON

Per measurement (automaticky v ML pipeline):
  _run_pipeline()
    ├── SELECT face_embedding FROM users
    ├── extract_frame(video_local, second=2.0) → temp JPG
    ├── verify_face(frame, stored_embedding)
    │     └── DeepFace.represent() → cosine_similarity()
    │         threshold: 0.68 (ArcFace cosine distance)
    └── UPDATE measurements SET face_verified=?, face_similarity=?
```

---

## Architektura — FCM deep link flow

```
Notification (FCM):
  {type: "analysis_complete", measurement_id: "uuid", ...}

  Cold start (app terminated):
    FirebaseMessaging.instance.getInitialMessage()
      → _routeFromMessage() → onTap('/measurement/uuid')
      → router.push('/measurement/uuid')

  Background → foreground (app backgrounded):
    FirebaseMessaging.onMessageOpenedApp
      → _routeFromMessage() → onTap('/measurement/uuid')

  Local notification tap (any state):
    _onNotificationTap(payload) → parse measurement_id
      → onTap('/measurement/uuid')

  Foreground (app active):
    _onForegroundMessage() → _showLocalNotification()
    (uživatel musí kliknout na notifikaci)
```

---

## Dashboard upgrade — přehled widgetů

```
DashboardScreen
  ├── _DeviationBanner        (todayDeviation.abs() > 2.5σ → warning banner)
  ├── _RecordingNudge         (daysSinceLast > 3 → "povídat?" reminder)
  ├── _StatsRow               (streak chip + period avg chip)
  ├── ScoreRingWidget         (poslední composite)
  ├── TrendChartWidget        (period selector + chart + threshold lines)
  ├── _RecordButton           (CTA)
  └── _RecentCard × 5        (tap → /measurement/:id, s skóre + datem)
```

---

## Rate limiting — přehled

| Endpoint | Limit | Rationale |
|----------|-------|-----------|
| `POST /auth/register` | 10/min | brute-force ochrana registrace |
| `POST /auth/login` | 10/min | brute-force ochrana přihlášení |
| `POST /measurements/upload` | 5/hour | zamezení spamu nahrávek |

Klíč: IP adresa (`get_remote_address`). Limiter v `rate_limit.py` (standalone modul, bez circular import).

---

## PDF report — obsah

```
BipolarMonitor — Wellness Report
<jméno> | <date_from> – <date_to>
─────────────────────────────────
Measurement Summary (tabulka):
  Datum | Trvání (s) | Composite Z-score | Flagy

Trend Analysis:
  Average composite z-score: X.XX
  Total measurements: N
  Overall trend: Stable / Improving / Worsening

─────────────────────────────────
This is a wellness tracking report, not a medical diagnosis.
```

---

## Co NENÍ v Phase 4 (future work)

- Fine-tuned model na AVEC datasetu (vyžaduje IRB / dataset licenci)
- Pasivní monitoring (akcelerometr, screen time) — vyžaduje HealthKit/Google Fit integrace
- Psychiatrist admin view (emotional_avoidance flag, raw AU, full face AU per frame)
- Face embedding enrollment z video frame místo statických fotek
- Multi-face detection warning (více osob v záběru)
- PDF lokalizace do češtiny (reportlab font embedding pro UTF-8)

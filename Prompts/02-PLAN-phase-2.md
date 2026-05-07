# BipolarMonitor — Fáze 2

> Commit: f293ba8 | Datum: 2026-05-07 | Stav: ✅ Hotovo

---

## Co bylo implementováno

### Flutter (+19 souborů)

#### Auth
- `features/auth/presentation/register_screen.dart`
  - Age gate (18+) — checkbox, nelze odeslat bez potvrzení
  - Disclaimer checkbox — wellness, ne diagnostika
  - Po registraci redirect na `/onboarding`

#### Onboarding
- `features/onboarding/onboarding_screen.dart`
  - PageView, 3 stránky: Uvítání → Jak funguje → Data & disclaimer
  - Animované tečky, plynulý přechod
- `features/onboarding/enrollment_screen.dart`
  - 3 enrollment věty (speaker embedding baseline)
  - PulseDot animace při nahrávání
  - Volání ML service `/ml/speaker-enroll` → embedding → `/user/enroll-speaker`
  - Skip možnost (enrollment lze nastavit kdykoli v Settings)
  - Error state s retry

#### History
- `features/history/presentation/history_provider.dart`
  - `HistoryNotifier` — paginated StateNotifier (20 záznamů/stránka)
  - `measurementDetailProvider` — FutureProvider.family per measurement_id
  - `MeasurementSummary` + `MeasurementDetail` modely
- `features/history/presentation/history_screen.dart`
  - Infinite scroll (načte další stránku při 200px od konce)
  - Pull-to-refresh
  - Empty state
- `features/history/presentation/measurement_card.dart`
  - `Dismissible` swipe-to-delete s potvrzovacím dialogem
  - `_ScoreBadge` — barevný kruh se z-score
  - `_FlagChip` — přátelský text (ne diagnostické termíny)
  - `_TrendIcon` — trending_up/down/flat
- `features/history/presentation/measurement_detail_screen.dart`
  - `RadarChart` (fl_chart) — 5 dimenzí: Tempo, Energie, Délka, Soustředění, Výraz
  - `_ScoreBreakdown` — horizontální z-score bary pro každou dimenzi
  - `_PerQuestionView` — přepis + WPM + počet slov per otázka
  - `_FlagTile` — přátelský text + ikona pro každý flag
  - Editovatelná poznámka (TextField)

#### Settings
- `features/settings/presentation/settings_screen.dart`
  - Profil: jméno, email, počet měření, link na re-enrollment
  - Nahrávání: speaker verification toggle
  - Notifikace: denní reminder toggle + time picker, analysis notifications toggle
  - Data: export (TODO volání API), smazat vše (s double-confirm dialogem)
  - O aplikaci: disclaimer dialog, verze

#### Core — Storage
- `core/storage/local_database.dart` — Drift SQLite
  - `LocalMeasurements` — offline queue, retry count, next_retry_at
  - `LocalScores` — lokální cache výsledků
  - `LocalUserProfile` — settings (reminder hour/min, duration, language, toggles, onboarding flag)
  - Helper metody: getPendingUploads, markUploaded, incrementRetry, upsertMeasurement, deleteMeasurement
  - `localDbProvider` Riverpod provider

#### Core — Notifications
- `core/notifications/notification_service.dart`
  - FCM + flutter_local_notifications
  - 2 Android kanály: `bipolar_analysis` (default importance) + `bipolar_reminder` (low, silent)
  - Background handler (top-level `@pragma('vm:entry-point')`)
  - `getFcmToken()` pro registraci na API
  - Žádný zvuk — mental health app

#### Record
- `features/record/data/speaker_verifier.dart`
  - `cosineSimilarity()` — lokální výpočet
  - `verify()` — volá ML service, porovná s uloženým embeddingem
  - `kSpeakerSimilarityThreshold = 0.75` — soft warning, nikdy hard block
- `features/record/data/offline_queue.dart`
  - Workmanager `callbackDispatcher` (top-level)
  - Periodic task každou hodinu (NetworkType.connected constraint)
  - Exponential backoff: 5 → 15 → 60 → 240 → 1440 min
  - Max 5 pokusů, pak vzdá
  - Cleanup temp souborů po úspěšném uploadu

#### Router
- Nové routes: `/register`, `/onboarding`, `/enrollment`, `/history`, `/measurement/:id`, `/settings`
- `_RouterNotifier extends ChangeNotifier` — GoRouter refreshListenable napojený na auth stav

---

### Backend — API (+4 soubory, 2 modifikace)

#### Alembic migrace
- `alembic.ini` + `alembic/env.py` + `alembic/script.py.mako`
- `alembic/versions/0001_initial_schema.py` — všechny tabulky:
  - `users`, `refresh_tokens`, `user_baselines`
  - `measurements`, `measurement_scores`
  - `fcm_tokens` (nová — pro push notifikace)

#### FCM Push
- `services/fcm_service.py` — Firebase Admin SDK
  - `send_analysis_complete()` — neutrální formulace výsledku
  - `send_deviation_alert()` — pro odchylku >2.5σ
  - Compose body: mapuje flag → lidsky čitelný text (bez diagnostických termínů)
  - Graceful degradace pokud GOOGLE_APPLICATION_CREDENTIALS není nastaveno
- `routers/push.py`
  - `POST /push/register-token` — uloží FCM token uživatele
  - `POST /push/analysis-complete` — interní webhook z ML service (ML_WEBHOOK_SECRET)

#### Media Retention
- `tasks/retention.py`
  - `cleanup_old_media()` — smaže MinIO objekty pro analyzovaná měření starší než MEDIA_RETENTION_DAYS
  - `run_retention_loop()` — async background task, běží každých 24h
  - Spouštěno z `main.py` lifespan jako `asyncio.create_task`

#### main.py update
- Import + mount push_router
- `asyncio.create_task(run_retention_loop(...))` v lifespan
- Cancel task při shutdown

---

### ML Service (+3 soubory, 1 modifikace)

#### Speaker pipeline
- `pipeline/speaker.py`
  - `extract_speaker_embedding()` — Whisper encoder (base model) → mean-pool → L2-normalize
  - `average_embeddings()` — průměr enrollment vektorů
  - `cosine_similarity()` — numpy implementace
  - `verify_speaker()` — porovná audio s uloženým embeddingem, vrátí similarity + verified
- `routers/speaker_router.py`
  - `POST /ml/speaker-enroll` — více audio paths → averaged embedding
  - `POST /ml/speaker-verify` — audio vs. stored embedding
  - `POST /ml/speaker-embedding` — single embedding (pro Flutter verifier)
  - `_resolve_path()` — MinIO download pokud path není lokální soubor
- `routers/__init__.py`

#### ML Pipeline update (`main.py`)
- Načte `speaker_embedding` z tabulky `users` před analýzou
- `verify_speaker()` → uloží `speaker_verified` + `speaker_similarity` do measurements
- Baseline update podmíněn na `speaker_verified is not False`
- FCM webhook callback po dokončení pipeline (`POST /api/v1/push/analysis-complete`)
- Webhook selhání neblokuje pipeline (try/except pass)

---

### Deployment (+2 soubory)

- `cloudflared/bipolar-tunnel.yml` — Cloudflare Tunnel ingress config
- `cloudflared/install.sh` — krok za krokem instalace na Ubuntu (DGX Spark)

---

## Závislosti přidány

**Python (api):** `firebase-admin==6.5.0`

**Flutter:** `url_launcher ^6.2.5`, `intl ^0.19.0`, `http ^1.2.1`

---

## Co je potřeba udělat ručně po deployi

```bash
# 1. Drift code generation (Flutter)
cd flutter/bipolar_monitor
dart run build_runner build --delete-conflicting-outputs

# 2. Firebase project setup
# - Vytvořit Firebase projekt na console.firebase.google.com
# - Přidat Android app (package: com.ol1n.bipolar_monitor)
# - Stáhnout google-services.json → flutter/bipolar_monitor/android/app/
# - Přidat iOS app → stáhnout GoogleService-Info.plist → flutter/bipolar_monitor/ios/Runner/

# 3. Firebase service account (pro backend FCM)
# - Firebase Console → Project settings → Service accounts → Generate new private key
# - Uložit jako /run/secrets/firebase-service-account.json na DGX Spark

# 4. Alembic migrace na NAS PostgreSQL
cd backend/api
DATABASE_URL=postgresql+asyncpg://bipolar:PASSWORD@192.168.x.x:5432/bipolar \
  alembic upgrade head

# 5. Cloudflare Tunnel
# - Vytvořit tunnel na dash.cloudflare.com nebo via CLI
# - Doplnit <TUNNEL_ID> do backend/cloudflared/bipolar-tunnel.yml
# - bash backend/cloudflared/install.sh

# 6. ML_WEBHOOK_SECRET
# - Nastavit stejnou hodnotu v backend/.env (API) i docker-compose.yml (ML service)
```

---

## Fáze 3 — Co zbývá (polish)

- [ ] OpenFace sidecar — AU-based facial analysis (MediaPipe je MVP proxy)
- [ ] Settings — skutečný export JSON (volání API + FileSaver/Share)
- [ ] Settings — skutečné volání DELETE /user/data před odhlášením
- [ ] `local_database.g.dart` — `dart run build_runner build`
- [ ] Firebase config soubory (viz výše)
- [ ] Certificate pinning pro prod (Dio TrustManager)
- [ ] Haptic feedback — countdown ticks, upload done
- [ ] Accessibility — font scaling, contrast mode
- [ ] Shared element transitions mezi History → Detail
- [ ] Enrollment re-trigger ze Settings (link existuje, screen existuje)
- [ ] Background fetch iOS (background_fetch plugin pro offline queue na iOS)

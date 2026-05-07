# Phase 3 — Polish, Accessibility, Security & OpenFace

## Cíl

Dokončení produkční kvality: haptika, accessibility, TLS pinning, Hero animace, export dat, iOS background fetch, OpenFace sidecar.

---

## Implementované soubory

### Flutter

| Soubor | Co bylo přidáno |
|--------|----------------|
| `pubspec.yaml` | `share_plus ^9.0.0`, `background_fetch ^1.2.1` |
| `lib/main.dart` | `ProviderContainer` + `UncontrolledProviderScope`; inicializace `NotificationService` a `OfflineQueue` před `runApp` |
| `lib/app.dart` | `MediaQuery.withClampedTextScaling(min:1.0, max:2.0)`; `highContrastTheme: AppTheme.highContrast` |
| `lib/core/constants/app_theme.dart` | `AppTheme.dark`, `AppTheme.highContrast`, `_buildTextTheme(highContrast)` |
| `lib/core/utils/haptics.dart` | `Haptics.tick()`, `.light()`, `.medium()`, `.heavy()` |
| `lib/core/network/certificate_pinning.dart` | `applyPinning(dio)` přes `IOHttpClientAdapter`, `badCertificateCallback`, SHA-256 fingerprint (release-only) |
| `lib/core/network/api_client.dart` | `if (!kDebugMode && !kIsWeb) applyPinning(_dio)` |
| `lib/features/record/presentation/record_screen.dart` | `Haptics.tick()` na každý countdown tick; `Haptics.medium()` při startu nahrávání; `Haptics.light()` po dokončení uploadu; `Haptics.heavy()` při chybě |
| `lib/features/settings/presentation/settings_screen.dart` | Export dat: `GET /user/export` → JSON soubor → `Share.shareXFiles()`; GDPR delete: `DELETE /user/data` → logout |
| `lib/features/history/presentation/measurement_card.dart` | `Hero(tag: 'score_badge_\${id}')` okolo `_ScoreBadge` |
| `lib/features/history/presentation/measurement_detail_screen.dart` | Matching `Hero(tag: 'score_badge_\${detail.id}')` v headeru; přidána lokální `_ScoreBadge` třída |
| `lib/features/record/data/offline_queue.dart` | iOS: `BackgroundFetch.configure()` + `BackgroundFetch.registerHeadlessTask()`; headless callback `backgroundFetchHeadlessTask` |
| `flutter/bipolar_monitor/firebase/SETUP.md` | Instrukce pro umístění `google-services.json` a `GoogleService-Info.plist` |
| `flutter/setup.sh` | `flutter pub get` + `dart run build_runner build --delete-conflicting-outputs` |

### Backend

| Soubor | Co bylo přidáno |
|--------|----------------|
| `backend/api/routers/user.py` | `GET /user/export` — GDPR export všech měření a skóre jako JSON |
| `backend/openface/Dockerfile` | Build OpenFace z Ubuntu 22.04, stáhne modely, instaluje FastAPI wrapper |
| `backend/openface/main.py` | `POST /analyze` — spustí `FeatureExtraction`, parsuje CSV, vrátí AU means, pose, gaze, blink rate, valence proxy |
| `backend/openface/requirements.txt` | `fastapi`, `uvicorn`, `python-multipart`, `httpx` |
| `backend/ml/pipeline/video_analyzer.py` | `_try_openface()` async HTTP call na sidecar; `_openface_to_features()` převod; `analyze_video()` zůstává jako MediaPipe fallback |
| `backend/ml/main.py` | Volá `_try_openface()` před `analyze_video()`; používá OpenFace výsledek pokud je dostupný |
| `backend/docker-compose.yml` | Přidána `openface` service (port 8002, healthcheck); ML service `depends_on: openface`; `OPENFACE_URL` env var |

---

## Architektura — video analýza

```
ML service (_run_pipeline)
  │
  ├── _try_openface(video_path) ──► OpenFace sidecar :8002
  │       ↓ OK                          POST /analyze
  │   _openface_to_features()           - FeatureExtraction binary
  │                                     - AU intensities (r=regression)
  │       ↓ fail / timeout              - head pose (Rx, Ry, Rz)
  └── analyze_video() [MediaPipe]       - gaze angles
          - FaceMesh 478 landmarks      - blink rate
          - EAR blink detection         - valence proxy (AU12-AU15)
          - mouth openness
          - brow height
          - head pose proxy
```

---

## iOS Background Fetch flow

```
BackgroundFetch (OS-triggered, min 60 min interval)
  │
  ├── App running: fetch callback → OfflineQueue.processQueue()
  │                                      → upload pending measurements
  │
  └── App terminated: backgroundFetchHeadlessTask (headless, @pragma vm:entry-point)
                           → LocalDatabase.getPendingUploads()
                           → BackgroundFetch.finish(taskId)
```

---

## Bezpečnost

- **TLS cert pinning**: SHA-256 fingerprint Cloudflare cert, kontrolován v `badCertificateCallback`, aktivní pouze v release (`!kDebugMode && !kIsWeb`)
- **JWT**: access 15 min + refresh 30 dní s rotací (Phase 1)
- **flutter_secure_storage**: iOS Keychain / Android Keystore (Phase 1)
- **firebase config**: `google-services.json` a `GoogleService-Info.plist` jsou v `.gitignore`

---

## Accessibility

- `MediaQuery.withClampedTextScaling(min: 1.0, max: 2.0)` — respektuje systémové nastavení, limituje přetečení layoutu
- `AppTheme.highContrast` — silnější kontrast textu (`Colors.white`), světlejší mint a warm accent
- `MaterialApp.router` s `highContrastTheme` — systém vybírá téma automaticky

---

## Co NENÍ v Phase 3 (možné future work)

- Skutečný SHA-256 fingerprint Cloudflare cert (zatím placeholder `_pinnedSha256`)
- Workmanager callback plný upload bez Riverpod DI (aktuálně jen ping DB, skutečný upload při otevření app)
- OpenFace negative_affect dimension (vyžaduje AVEC dataset trénink)
- Psychiatrist/admin view (emotional_avoidance flag, raw AU data)

# BipolarMonitor — Kompletní plán aplikace

> Verze 1.0 | Autor: Ol1n + Claude | Datum: 2026-05

---

## 1. Přehled architektury

```
┌─────────────────────────────────────────────────────────┐
│                   Flutter App (iOS/Android)              │
│  Camera + Mic → záznam (30s video + audio) → upload     │
│  Lokální SQLite (history, user profile, scores)         │
└──────────────────────────┬──────────────────────────────┘
                           │ HTTPS multipart upload
                           │ Bearer token (JWT)
                           ▼
┌─────────────────────────────────────────────────────────┐
│           Cloudflare Tunnel → Caddy (DGX Spark)         │
│                  bipolar.ol1n.com                        │
└──────────────────────────┬──────────────────────────────┘
                           │
              ┌────────────┴───────────┐
              ▼                        ▼
   ┌──────────────────┐    ┌──────────────────────┐
   │  Go API Backend  │    │  Python ML Service   │
   │  (auth, users,   │    │  (audio + video      │
   │   SQLite, jobs)  │    │   inference pipeline) │
   └──────────────────┘    └──────────────────────┘
              │                        │
              └──────────┬─────────────┘
                         ▼
              ┌──────────────────────┐
              │   NAS (Ubuntu)       │
              │   PostgreSQL         │
              │   Raw media storage  │
              │   (18TB RAID 10)     │
              └──────────────────────┘
```

---

## 2. Komponenty a odpovědnosti

### 2.1 Flutter App

| Vrstva | Detail |
|--------|--------|
| **Recording** | `camera` plugin — přední kamera 30 fps, `record` plugin — mono 16kHz WAV |
| **Upload** | `dio` multipart POST, retry při selhání, queue offline |
| **Auth** | Email/password → JWT (access 15min + refresh 30d), uloženo v `flutter_secure_storage` |
| **Lokální DB** | `drift` (SQLite) — tabulky `measurements`, `scores`, `user` |
| **UI flow** | Onboarding → Home dashboard → Record → History → Settings |

**Lokální tabulky:**
```sql
CREATE TABLE measurements (
  id TEXT PRIMARY KEY,
  recorded_at INTEGER,
  uploaded INTEGER DEFAULT 0,
  score_energy REAL,
  score_mood REAL,
  score_speech_rate REAL,
  score_composite REAL,
  notes TEXT
);
```

### 2.2 Go API Backend

```
/api/v1/auth/register
/api/v1/auth/login
/api/v1/auth/refresh
/api/v1/measurements/upload   POST multipart
/api/v1/measurements/         GET (history)
/api/v1/measurements/:id      GET (single result)
/api/v1/user/profile          GET/PUT
```

- **Auth:** JWT (golang-jwt/jwt), bcrypt hesla, refresh token rotace
- **DB:** SQLite pro DGX (dev) → PostgreSQL na NAS (prod)
- **Job queue:** po úspěšném uploadu pošle job do Python ML service přes Redis nebo HTTP async
- **Storage:** raw media uloží na NAS přes NFS mount nebo S3-compatible (MinIO na NASu)

### 2.3 Python ML Inference Service

```python
POST /analyze
{
  "measurement_id": "uuid",
  "video_path": "/data/media/uuid.mp4",
  "audio_path": "/data/media/uuid.wav"
}

Response:
{
  "scores": {
    "energy": 0.72,
    "mood_valence": 0.61,
    "speech_rate_zscore": 1.4,
    "facial_affect": 0.55,
    "composite": 0.65
  },
  "flags": ["elevated_speech_rate"],
  "baseline_deviation": 0.3
}
```

### 2.4 NAS (Ubuntu, data layer)

- **PostgreSQL 16** — users, measurements, scores, baselines
- **MinIO** — S3-compatible storage pro raw media
- **Přístup:** DGX Spark → NAS přes interní síť (ne přes internet)

---

## 3. ML Modely — co nasadit na DGX Spark

### 3.1 Audio analýza

#### openSMILE (primární)
```bash
pip install opensmile
```
- Extrahuje 88 featur: tempo řeči, pauzy, energie, F0 (základní frekvence hlasu)
- **GeMAPS feature set** — standardizovaný pro klinický výzkum
- Rychlý, CPU-only, žádný GPU overhead

```python
import opensmile
smile = opensmile.Smile(
    feature_set=opensmile.FeatureSet.eGeMAPS,
    feature_level=opensmile.FeatureLevel.Functionals,
)
features = smile.process_file("audio.wav")
```

#### Whisper (transkripce + timing)
```bash
pip install openai-whisper
```
- Model: `whisper-large-v3` na DGX Sparku
- Z word timestamps → speech rate (slova/minuta), délka pauz, disfluence count
- Detekce jazyka (multilingvální — CZ funguje dobře)

#### wav2vec 2.0 (volitelné rozšíření)
- `facebook/wav2vec2-large-xlsr-53-czech` pro české embeddingy
- Fine-tuneable pro afektivní klasifikaci

### 3.2 Video / facial analýza

#### OpenFace 2.0
```bash
# Docker image je nejjednodušší cesta
docker pull algebr/openface
```
- Action Units (AU): AU12 (úsměv), AU4 (svraštění obočí), AU17 (stres)
- Gaze direction, head pose
- Výstup: CSV per frame → aggregace (mean, std, range) pro skóre

#### MediaPipe Face Landmarker (alternativa, lehčí)
```python
pip install mediapipe
# 478 face landmarks, micro-expression tracking
# Běží real-time na ARM64 ✓
```

### 3.3 Scoring pipeline

```
Audio WAV → openSMILE → GeMAPS features (88)
          → Whisper   → speech_rate, pause_ratio
          
Video MP4 → OpenFace  → AU aktivace (mean/std/range)
          
Features (all) → Normalizace (z-score vůči user baseline)
               → Composite score (vážený průměr)
               → Porovnání s osobním trendem (rolling 14d)
               → Flagging (>2σ odchylka od průměru)
```

**Composite score výpočet:**
```python
weights = {
    "speech_rate_zscore": 0.25,
    "pause_ratio_zscore": 0.15,
    "voice_energy_zscore": 0.20,
    "facial_affect_zscore": 0.25,
    "gemaps_f0_range_zscore": 0.15,
}
composite = sum(features[k] * w for k, w in weights.items())
```

---

## 4. Autentifikace osoby

### 4.1 Základní přístup (doporučeno pro MVP)

**Email + heslo + JWT** — standardní, dostatečné pro wellness app.

```
Registrace: email + heslo (bcrypt, cost 12) → uložení do DB
Login: → access token (15min) + refresh token (30d, HTTP-only cookie)
Upload: Authorization: Bearer <access_token>
```

### 4.2 Biometrická autentifikace v telefonu

**Flutter: `local_auth` plugin**
- Face ID / Touch ID / fingerprint
- Odemkne app PŘED nahráváním → zamezí nahrávání za jinou osobu
- Klíč zůstane lokálně v Secure Enclave — server o tom neví

```dart
final didAuth = await auth.authenticate(
  localizedReason: 'Ověřte totožnost před nahráváním',
  options: const AuthenticationOptions(biometricOnly: true),
);
```

### 4.3 Voice/face identity verification (pokročilé, volitelné)

Problém: zajistit, že nahrává vždy stejná osoba.

**Varianta A — Speaker embedding**
- Whisper / wav2vec embeddingy → porovnání s enrollment audio (cosine similarity)
- Enrollment při registraci: uživatel přečte 3 věty
- Threshold: cosine sim > 0.85 → přijato

**Varianta B — Face embedding**
- `facenet-pytorch` nebo `deepface` (ArcFace model)
- Enrollment foto při registraci → comparison při každém nahrávání
- Threshold: distance < 0.4 → přijato

**Doporučení pro MVP:** Kombinace `local_auth` (biometrie telefonu) + speaker embedding. Face embedding přidej ve v2.

---

## 5. Docker Compose — DGX Spark

```yaml
# /opt/bipolar-monitor/docker-compose.yml
version: "3.9"

services:
  api:
    build: ./api
    container_name: bipolar_api
    restart: unless-stopped
    environment:
      - DB_PATH=/data/bipolar.db
      - ML_SERVICE_URL=http://ml:8001
      - JWT_SECRET=${JWT_SECRET}
      - MINIO_ENDPOINT=${MINIO_ENDPOINT}
      - MINIO_ACCESS_KEY=${MINIO_ACCESS_KEY}
      - MINIO_SECRET_KEY=${MINIO_SECRET_KEY}
    volumes:
      - bipolar_data:/data
    networks:
      - bipolar_net
    expose:
      - "8000"

  ml:
    build: ./ml
    container_name: bipolar_ml
    restart: unless-stopped
    runtime: nvidia
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
      - MINIO_ENDPOINT=${MINIO_ENDPOINT}
    volumes:
      - model_cache:/root/.cache
      - bipolar_data:/data
    networks:
      - bipolar_net
    expose:
      - "8001"
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]

  # OpenFace jako sidecar
  openface:
    image: algebr/openface:latest
    container_name: bipolar_openface
    volumes:
      - bipolar_data:/data
    networks:
      - bipolar_net
    expose:
      - "8002"

volumes:
  bipolar_data:
  model_cache:

networks:
  bipolar_net:
    external: false
```

---

## 6. Caddyfile — DGX Spark

```caddyfile
# /opt/caddy/Caddyfile

bipolar.ol1n.com {
    # Cloudflare Zero Trust auth (service token pro app)
    # Nebo public endpoint s JWT auth v API

    reverse_proxy /api/* bipolar_api:8000 {
        header_up X-Real-IP {remote_host}
        # Max upload size pro video (100MB)
    }

    # Zvýšení limitu pro media upload
    request_body {
        max_size 100MB
    }

    header {
        Strict-Transport-Security "max-age=31536000"
        X-Content-Type-Options "nosniff"
    }

    log {
        output file /var/log/caddy/bipolar.log
    }
}
```

---

## 7. Cloudflare Tunnel

```yaml
# /etc/cloudflared/bipolar-tunnel.yml
tunnel: <TUNNEL_ID>
credentials-file: /etc/cloudflared/bipolar-creds.json

ingress:
  - hostname: bipolar.ol1n.com
    service: http://localhost:8080  # Caddy
  - service: http_status:404
```

```bash
# Systemd service
sudo cloudflared service install
sudo systemctl enable --now cloudflared-bipolar
```

**Cloudflare Access policy:**
- Aplikace v PlayStore jsou public users → **JWT auth v samotném API** (ne CF Access)
- CF Access použij jen pro admin dashboard / monitoring endpointy

---

## 8. NAS deployment (PostgreSQL + MinIO)

```yaml
# Na NAS Ubuntu: /opt/bipolar-data/docker-compose.yml
version: "3.9"

services:
  postgres:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      - POSTGRES_DB=bipolar
      - POSTGRES_USER=bipolar
      - POSTGRES_PASSWORD=${PG_PASSWORD}
    volumes:
      - pg_data:/var/lib/postgresql/data
    ports:
      - "127.0.0.1:5432:5432"  # pouze lokální síť

  minio:
    image: minio/minio
    restart: unless-stopped
    command: server /data --console-address ":9001"
    environment:
      - MINIO_ROOT_USER=${MINIO_USER}
      - MINIO_ROOT_PASSWORD=${MINIO_PASS}
    volumes:
      - minio_data:/data
    ports:
      - "127.0.0.1:9000:9000"
      - "127.0.0.1:9001:9001"

volumes:
  pg_data:
  minio_data:
```

**DGX Spark → NAS konektivita:**
- Interní LAN, statické IP
- DGX API service se připojuje na `192.168.x.x:5432` (Postgres) a `9000` (MinIO)
- **Nikdy přes internet** — NAS není exponován přes Cloudflare Tunnel

---

## 9. Flutter App — struktura

```
lib/
├── main.dart
├── app/
│   ├── router.dart          # go_router
│   └── theme.dart
├── features/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── auth_repository.dart
│   ├── record/
│   │   ├── record_screen.dart    # kamera + poem prompt
│   │   ├── upload_service.dart
│   │   └── biometric_guard.dart
│   ├── history/
│   │   ├── history_screen.dart
│   │   └── trend_chart.dart     # fl_chart
│   └── dashboard/
│       └── dashboard_screen.dart
├── data/
│   ├── database.dart        # drift/SQLite
│   ├── api_client.dart      # dio
│   └── models/
└── core/
    ├── secure_storage.dart
    └── offline_queue.dart
```

**Klíčové závislosti:**
```yaml
dependencies:
  camera: ^0.11.0
  record: ^5.0.0
  dio: ^5.0.0
  drift: ^2.0.0
  flutter_secure_storage: ^9.0.0
  local_auth: ^2.0.0
  fl_chart: ^0.66.0
  go_router: ^14.0.0
```

---

## 10. Data flow — jeden measurement cyklus

```
1. User otevře app → local_auth (Face ID / fingerprint)
2. App zobrazí báseň k přečtení (prompt z API nebo lokální pool)
3. 3s countdown → nahrávání 30s video+audio
4. Soubory se uloží lokálně do temp
5. POST /api/v1/measurements/upload (multipart: video, audio, metadata)
6. Go API:
   a. Uloží metadata do SQLite/PG
   b. Uloží soubory do MinIO
   c. Pošle job do ML service: POST /analyze {measurement_id}
7. ML service (async):
   a. Stáhne soubory z MinIO
   b. openSMILE → audio features
   c. Whisper → speech rate, pauses
   d. OpenFace → AU features
   e. Composite scoring + baseline comparison
   f. Výsledek uloží do DB
   g. Webhook zpět do Go API
8. Go API → push notification (FCM) nebo polling odpověď
9. Flutter app zobrazí skóre + trend graf
10. Lokální SQLite se aktualizuje s výsledkem
```

---

## 11. Scoring — výstup do aplikace

```json
{
  "measurement_id": "uuid",
  "recorded_at": "2026-05-07T14:30:00Z",
  "scores": {
    "energy": 0.72,
    "mood_valence": 0.61,
    "speech_rate": 142,
    "speech_rate_zscore": 1.4,
    "composite": 0.65
  },
  "baseline": {
    "composite_mean": 0.52,
    "composite_std": 0.08,
    "deviation_sigma": 1.6
  },
  "flags": ["elevated_speech_rate", "high_energy"],
  "trend": "increasing_3d"
}
```

**UI zobrazení:**
- Kruh s kompozitním skóre (0–1 škála, barevná)
- Sparkline trend posledních 14 dní
- Flagy jako čitelné upozornění ("Tvoje tempo řeči je dnes nadprůměrné")
- **Nikdy** diagnostické termíny — pouze neutrální popis odchylek

---

## 12. Bezpečnost a compliance

| Oblast | Řešení |
|--------|--------|
| **Transport** | HTTPS everywhere (Caddy + Cloudflare) |
| **Auth** | JWT RS256, bcrypt cost 12 |
| **Media** | MinIO server-side encryption (SSE-S3) |
| **GDPR** | Právo na smazání, export dat, minimalizace |
| **Biometrie** | Pouze lokálně v telefonu (Secure Enclave), server nikdy nevidí biometrická data |
| **Medical claims** | Zero — vše je "wellness tracking", žádná diagnostika |
| **Retention** | Raw media smazáno po zpracování (configurable, default 30d) |

---

## 13. Fáze vývoje

### MVP (2–3 měsíce)
- [ ] Flutter app: auth, record, upload, lokální history
- [ ] Go API: základní endpointy, JWT, SQLite
- [ ] ML service: openSMILE + Whisper scoring
- [ ] Docker Compose na DGX Spark
- [ ] Caddy + Cloudflare Tunnel

### v1.0 (další 2 měsíce)
- [ ] OpenFace video analýza
- [ ] PostgreSQL na NAS + MinIO
- [ ] Baseline kalibrace (personal z-score po 7+ měřeních)
- [ ] Trend grafy v aplikaci
- [ ] Push notifikace (FCM)
- [ ] Speaker embedding identity verification

### v2.0 (volitelné)
- [ ] Face embedding identity verification
- [ ] Pasivní monitoring (akcelerometr, screen time)
- [ ] Export PDF report pro lékaře
- [ ] Fine-tuned model na AVEC datasetu
- [ ] Spolupráce s psychiatrickou klinikou → IRB/etická komise

---

## 14. Play Store strategie

**Kategorie:** Health & Fitness (ne Medical)

**Co lze říkat:**
- "Sledujte svůj hlasový a vizuální projev v čase"
- "Osobní wellness deník s AI analýzou"
- "Trend monitoring nálady a energie"

**Co nelze říkat:**
- "Detekuje bipolární poruchu"
- "Diagnostický nástroj"
- "Nahrazuje péči lékaře"

**Povinný disclaimer v app:**
> Tato aplikace je wellness nástroj a není určena k diagnostice, léčbě ani prevenci jakéhokoli onemocnění. Pokud máte zdravotní potíže, kontaktujte svého lékaře.

**Doporučení:** Konzultace s psychiatrem nebo klinickým psychologem ještě před spuštěním — ideálně formou "advisory board" role. Dodá kredibilitu a pomůže s bezpečným UX designem.

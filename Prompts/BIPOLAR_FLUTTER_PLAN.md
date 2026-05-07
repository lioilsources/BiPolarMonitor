# BipolarMonitor — Flutter App Plán

> Verze 1.0 | Platforma: iOS + Android | Stav: Pre-development

---

## 1. Design filozofie

### Tón a estetika
Aplikace je pro lidi, kteří procházejí těžkým obdobím. Design musí být:
- **Klidný, ne klinický** — žádné nemocniční bílé, žádné alarmující červené
- **Teplý minimalizmus** — hodně negativního prostoru, organické tvary, tlumené barvy
- **Důvěryhodný** — konzistentní, předvídatelný, bez překvapení

### Barevná paleta
```dart
// AppColors
static const background   = Color(0xFF0F1117);  // velmi tmavá modročerná
static const surface      = Color(0xFF1A1D26);  // karta/panel
static const surfaceAlt   = Color(0xFF222636);  // alternativní plocha
static const accent       = Color(0xFF7EB8A4);  // tlumená šalvějová zelená
static const accentWarm   = Color(0xFFE8A87C);  // teplá meruňková (upozornění)
static const textPrimary  = Color(0xFFE8E9F0);  // skoro bílá
static const textSecondary= Color(0xFF8A8FA8);  // šedofialová
static const elevated     = Color(0xFF4A7C68);  // stmavená šalvěj (aktivní stavy)
```

### Typografie
```dart
// Pár: DM Serif Display (nadpisy) + DM Sans (tělo)
// Google Fonts: google_fonts: ^6.0.0
static final heading = GoogleFonts.dmSerifDisplay(
  fontSize: 28, color: AppColors.textPrimary, height: 1.2,
);
static final body = GoogleFonts.dmSans(
  fontSize: 16, color: AppColors.textSecondary, height: 1.5,
);
static final mono = GoogleFonts.jetBrainsMono(
  fontSize: 13, color: AppColors.accent,
);
```

### UI principy
- Zaoblené karty s `BorderRadius.circular(20)`
- Subtilní `BackdropFilter` blur efekty (glassmorphism)
- Animace: `duration: 400ms, curve: Curves.easeOutCubic`
- Score vizualizace: plynulé obloukové progress bary
- **Žádné** agresivní barvy pro skóre — jen intenzita šalvěje

---

## 2. Architektura

### State management: Riverpod 2.x

```
lib/
├── main.dart
├── app.dart                        # MaterialApp, router init
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── api_constants.dart
│   ├── errors/
│   │   ├── app_exception.dart
│   │   └── error_handler.dart
│   ├── network/
│   │   ├── api_client.dart         # Dio + interceptors
│   │   └── auth_interceptor.dart
│   ├── storage/
│   │   ├── secure_storage.dart     # flutter_secure_storage
│   │   └── local_database.dart    # Drift
│   └── utils/
│       ├── date_formatter.dart
│       └── score_formatter.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart
│   │   │   └── auth_api.dart
│   │   ├── domain/
│   │   │   └── user_model.dart
│   │   └── presentation/
│   │       ├── login_screen.dart
│   │       ├── register_screen.dart
│   │       └── auth_provider.dart
│   │
│   ├── onboarding/
│   │   ├── onboarding_screen.dart
│   │   └── enrollment_screen.dart  # speaker embedding registrace
│   │
│   ├── dashboard/
│   │   ├── data/
│   │   │   └── dashboard_repository.dart
│   │   └── presentation/
│   │       ├── dashboard_screen.dart
│   │       ├── score_ring_widget.dart
│   │       ├── trend_chart_widget.dart
│   │       └── dashboard_provider.dart
│   │
│   ├── record/
│   │   ├── data/
│   │   │   ├── upload_repository.dart
│   │   │   └── offline_queue.dart
│   │   ├── domain/
│   │   │   └── measurement_model.dart
│   │   └── presentation/
│   │       ├── record_screen.dart
│   │       ├── poem_prompt_widget.dart
│   │       ├── countdown_widget.dart
│   │       ├── recording_widget.dart
│   │       └── record_provider.dart
│   │
│   ├── history/
│   │   └── presentation/
│   │       ├── history_screen.dart
│   │       ├── measurement_card.dart
│   │       └── history_provider.dart
│   │
│   └── settings/
│       └── presentation/
│           ├── settings_screen.dart
│           └── profile_screen.dart
│
└── shared/
    ├── widgets/
    │   ├── app_button.dart
    │   ├── app_card.dart
    │   ├── arc_progress.dart
    │   ├── score_badge.dart
    │   └── loading_shimmer.dart
    └── router/
        └── app_router.dart         # go_router
```

---

## 3. Databáze — Drift (SQLite)

```dart
// lib/core/storage/local_database.dart

@DriftDatabase(tables: [Measurements, Scores, PoemPrompts, UserProfile])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

// Tabulky
class Measurements extends Table {
  TextColumn get id => text()();                        // UUID
  DateTimeColumn get recordedAt => dateTime()();
  IntColumn get durationSeconds => integer()();
  BoolColumn get uploaded => boolean().withDefault(const Constant(false))();
  BoolColumn get analyzed => boolean().withDefault(const Constant(false))();
  TextColumn get localVideoPath => text().nullable()();
  TextColumn get localAudioPath => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Scores extends Table {
  TextColumn get measurementId => text().references(Measurements, #id)();
  RealColumn get energy => real().nullable()();
  RealColumn get moodValence => real().nullable()();
  RealColumn get speechRate => real().nullable()();
  RealColumn get speechRateZscore => real().nullable()();
  RealColumn get facialAffect => real().nullable()();
  RealColumn get composite => real().nullable()();
  RealColumn get baselineDeviation => real().nullable()();
  TextColumn get flags => text().nullable()();         // JSON array string
  TextColumn get trend => text().nullable()();
  DateTimeColumn get analyzedAt => dateTime().nullable()();
}

class PoemPrompts extends Table {
  TextColumn get id => text()();
  TextColumn get text => text()();
  TextColumn get author => text()();
  TextColumn get language => text().withDefault(const Constant('cs'))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

class UserProfile extends Table {
  TextColumn get userId => text()();
  TextColumn get displayName => text()();
  TextColumn get email => text()();
  TextColumn get speakerEmbedding => text().nullable()();  // JSON float array
  DateTimeColumn get enrolledAt => dateTime().nullable()();
  IntColumn get totalMeasurements => integer().withDefault(const Constant(0))();
}
```

---

## 4. API Client

```dart
// lib/core/network/api_client.dart

class ApiClient {
  late final Dio _dio;
  static const _baseUrl = 'https://bipolar.ol1n.com/api/v1';

  ApiClient(Ref ref) {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(minutes: 3), // upload videa
    ));

    _dio.interceptors.addAll([
      AuthInterceptor(ref),
      LogInterceptor(requestBody: false, responseBody: false),
      RetryInterceptor(dio: _dio, retries: 3),
    ]);
  }

  // Upload measurement
  Future<String> uploadMeasurement({
    required String measurementId,
    required File videoFile,
    required File audioFile,
    required String notes,
    required ProgressCallback onProgress,
  }) async {
    final formData = FormData.fromMap({
      'measurement_id': measurementId,
      'notes': notes,
      'video': await MultipartFile.fromFile(videoFile.path, filename: 'video.mp4'),
      'audio': await MultipartFile.fromFile(audioFile.path, filename: 'audio.wav'),
    });

    final response = await _dio.post(
      '/measurements/upload',
      data: formData,
      onSendProgress: onProgress,
    );

    return response.data['measurement_id'];
  }

  // Poll pro výsledky (dokud ML service neskončí)
  Future<ScoreModel?> getScore(String measurementId) async {
    final response = await _dio.get('/measurements/$measurementId');
    if (response.data['analyzed'] == true) {
      return ScoreModel.fromJson(response.data['scores']);
    }
    return null;
  }
}

// Auth interceptor — automatické přidání JWT + refresh
class AuthInterceptor extends Interceptor {
  final Ref _ref;
  AuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _ref.read(secureStorageProvider).getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Pokus o refresh
      final refreshed = await _ref.read(authProvider.notifier).refreshToken();
      if (refreshed) {
        // Opakuj původní request
        final cloned = await _ref.read(apiClientProvider).retry(err.requestOptions);
        return handler.resolve(cloned);
      }
      // Refresh selhal → logout
      _ref.read(authProvider.notifier).logout();
    }
    handler.next(err);
  }
}
```

---

## 5. Screens — detailní popis

### 5.1 Splash + Auth flow

```
SplashScreen (500ms)
  ├── Token existuje + valid → DashboardScreen
  ├── Token existuje + expired → RefreshToken → DashboardScreen
  └── Žádný token → OnboardingScreen (první spuštění) | LoginScreen
```

### 5.2 Onboarding (jen při první instalaci)

**3 obrazovky:**
1. **Uvítání** — "Ahoj. Tato app ti pomůže sledovat, jak se mění tvůj hlas a výraz v čase."
2. **Jak to funguje** — ilustrace: kamera → analýza → trend
3. **Disclaimer + souhlas** — jasný text, uživatel musí aktivně zaškrtnout

**Enrollment screen** (po registraci):
- Uživatel přečte 3 věty (speaker embedding baseline)
- Ukládá se pouze embedding vektor, ne raw audio
- Progress indikátor: "1/3", "2/3", "3/3"

### 5.3 Dashboard Screen

```dart
// Hlavní layout
Scaffold(
  backgroundColor: AppColors.background,
  body: CustomScrollView(
    slivers: [
      // Přizpůsobený AppBar s pozdravem a dnem
      SliverAppBar(
        expandedHeight: 120,
        flexibleSpace: FlexibleSpaceBar(
          title: Text('Dobrý den, ${user.name}'),
          background: _DashboardHeader(),
        ),
      ),

      SliverPadding(
        padding: EdgeInsets.all(20),
        sliver: SliverList(
          delegate: SliverChildListDelegate([

            // Hlavní score ring — dnes
            _TodayScoreCard(),         // obloukový progress, composite score
            SizedBox(height: 16),

            // Trend posledních 14 dní
            _TrendChart(),             // fl_chart LineChart
            SizedBox(height: 16),

            // Rychlá akce
            _RecordButton(),           // velké CTA

            // Poslední 3 měření
            _RecentMeasurements(),
          ]),
        ),
      ),
    ],
  ),
)
```

**Score Ring Widget:**
```dart
class ScoreRingWidget extends StatefulWidget {
  final double score;        // 0.0 – 1.0
  final double? deviation;   // sigma odchylka od baseline

  // Vizuál: tenký obloukový progress 270°
  // Barva: lerp mezi accent (nízké) a accentWarm (vysoké)
  // Střed: velké číslo + popis ("Energie dnes")
  // Pod ringem: malý text "±X.Xσ od tvého průměru"
}
```

### 5.4 Record Screen

**Flow:**
```
RecordScreen
  │
  ├── Biometric check (local_auth)
  │     └── Neúspěch → dialog "Nelze ověřit totožnost"
  │
  ├── PoemPromptWidget
  │     ├── Načte prompt z lokální DB (nebo API)
  │     └── Zobrazí báseň s přiměřenou velikostí písma
  │
  ├── CountdownWidget (3-2-1)
  │     └── Pulzující kruh, zvukový klik (haptic)
  │
  ├── RecordingWidget (30 sekund)
  │     ├── Live preview kamera (přední)
  │     ├── Animovaný waveform (audio level)
  │     ├── Progress bar (čas)
  │     └── Tlačítko "Zastavit dříve" (min. 15s)
  │
  └── UploadWidget
        ├── Speaker similarity check (lokální, ~200ms)
        │     └── Nízká podobnost → "Jsme si jistí, že nahráváš ty?" + pokračovat / opakovat
        ├── POST na API (progress bar)
        └── Redirect na Dashboard (výsledky přijdou push notifikací)
```

```dart
// record_provider.dart
enum RecordState { idle, countdown, recording, processing, uploading, done, error }

@riverpod
class RecordNotifier extends _$RecordNotifier {
  @override
  RecordState build() => RecordState.idle;

  Future<void> startFlow() async {
    // 1. Biometrie
    final auth = await ref.read(localAuthProvider).authenticate();
    if (!auth) return;

    // 2. Countdown
    state = RecordState.countdown;
    await Future.delayed(const Duration(seconds: 3));

    // 3. Nahrávání
    state = RecordState.recording;
    final recorder = ref.read(recorderProvider);
    await recorder.start();
    await Future.delayed(const Duration(seconds: 30));

    // 4. Zpracování (speaker check)
    state = RecordState.processing;
    final result = await recorder.stop();
    final similarity = await ref.read(speakerVerifierProvider)
        .verify(result.audioPath);

    if (similarity < 0.75) {
      // Upozornění — ale nevynucuj odmítnutí
      ref.read(lowSimilarityAlertProvider.notifier).show(similarity);
    }

    // 5. Upload
    state = RecordState.uploading;
    await ref.read(uploadRepositoryProvider)
        .upload(result.videoPath, result.audioPath);

    state = RecordState.done;
  }
}
```

### 5.5 History Screen

```dart
// Lazy-loaded seznam měření
// Každá karta zobrazuje:
//  - Datum + čas
//  - Composite score (barevný badge)
//  - Flagy jako čipy (elevated_speech_rate → "Tempo řeči ↑")
//  - Trend ikona (↑↓→)

class MeasurementCard extends StatelessWidget {
  // Tap → MeasurementDetailScreen
  // Swipe right → smazat (s potvrzovacím dialogem)
}

class MeasurementDetailScreen extends StatelessWidget {
  // Detailní breakdown všech sub-scores
  // Radar chart (5 dimenzí)
  // Přepis textu (Whisper output)
  // Poznámka uživatele (editovatelná)
}
```

### 5.6 Settings Screen

```
Settings
├── Profil
│   ├── Jméno, email
│   └── Změna hesla
├── Nahrávání
│   ├── Délka nahrávky (15s / 30s / 45s)
│   ├── Jazyk promtů (CS / EN)
│   └── Speaker verification (zapnout/vypnout)
├── Notifikace
│   ├── Připomínky nahrávat (čas, frekvence)
│   └── Push při hotové analýze
├── Data
│   ├── Export (JSON / PDF)
│   ├── Smazat vše
│   └── Stažení dat (GDPR)
└── O aplikaci
    ├── Disclaimer (full text)
    ├── Verze
    └── Kontakt na podporu
```

---

## 6. Offline podpora

```dart
// lib/features/record/data/offline_queue.dart

// Měření uložena lokálně → upload při obnovení sítě
class OfflineQueue {
  // Sleduje connectivity: connectivity_plus
  // Pokud upload selže → uloží do tabulky pending_uploads v SQLite
  // Background retry: workmanager (Android) / background_fetch (iOS)

  Future<void> processQueue() async {
    final pending = await db.getPendingMeasurements();
    for (final m in pending) {
      try {
        await apiClient.uploadMeasurement(...);
        await db.markUploaded(m.id);
      } catch (e) {
        // Exponential backoff, max 3 pokusy
        await db.incrementRetryCount(m.id);
      }
    }
  }
}
```

---

## 7. Notifikace

```dart
// FCM (firebase_messaging) + local notifications (flutter_local_notifications)

// Typy notifikací:
// 1. "Analýza dokončena" — po zpracování ML service
//    Payload: { measurement_id, composite_score }
//    Tap → otevře MeasurementDetailScreen
//
// 2. "Čas na nahrávku" — daily reminder
//    Nastavitelný čas v Settings
//    Tap → RecordScreen
//
// 3. "Výrazná změna oproti průměru" — pokud deviation > 2.5σ
//    Neutrální formulace: "Dnes se tvůj projev liší od tvého průměru"
//    Nikdy ne alarmující tón

// Krizové tlačítko — vždy dostupné v dashboardu
// Malá ikona dole → "Potřebuji pomoc" → kontakty na krizové linky (CZ)
//   - Linka bezpečí: 116 111
//   - Centrum krizové intervence: 284 016 666
```

---

## 8. Poem Prompts

```dart
// Lokální pool básní (50+ při instalaci), doplňovaný z API
// Kritéria výběru:
//   - Délka: 8–15 řádků (30s čtení ~130–150 slov)
//   - Jazyk: primárně CS, volitelně EN
//   - Tón: neutrální, ne depresivní ani euforické téma
//   - Autoři: Neruda, Seifert, Mácha, Erben, Hrubín...

class PoemPrompt {
  final String id;
  final String text;
  final String author;
  final String title;
  final String language;
}

// Algoritmus výběru:
//   - Nedávno nepoužitý (posledních 7 dní vyloučit)
//   - Rotace round-robin
//   - Uživatel může báseň "obnovit" (jiná báseň, ale to se loguje)
```

---

## 9. pubspec.yaml

```yaml
name: bipolar_monitor
description: Wellness mood tracking app
publish_to: none
version: 1.0.0+1

environment:
  sdk: ">=3.3.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^14.2.0

  # Networking
  dio: ^5.4.3
  dio_smart_retry: ^6.0.0

  # Storage
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.24
  flutter_secure_storage: ^9.2.2
  path_provider: ^2.1.3

  # Camera & Recording
  camera: ^0.11.0+2
  record: ^5.1.2
  permission_handler: ^11.3.1

  # Auth
  local_auth: ^2.2.0

  # UI & Fonts
  google_fonts: ^6.2.1
  fl_chart: ^0.68.0
  shimmer: ^3.0.0
  lottie: ^3.1.2          # animace loading stavů

  # Notifications
  firebase_core: ^3.3.0
  firebase_messaging: ^15.1.0
  flutter_local_notifications: ^17.2.2

  # Connectivity & Background
  connectivity_plus: ^6.0.3
  workmanager: ^0.5.2

  # Utils
  uuid: ^4.4.2
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.11
  riverpod_generator: ^2.4.3
  drift_dev: ^2.18.0
  flutter_lints: ^4.0.0
  mocktail: ^1.0.4
```

---

## 10. Testovací strategie

```
test/
├── unit/
│   ├── score_formatter_test.dart    # výpočet composite score
│   ├── auth_repository_test.dart    # JWT refresh logika
│   └── offline_queue_test.dart      # retry mechanismus
├── widget/
│   ├── score_ring_test.dart         # vizualizace score
│   ├── record_screen_test.dart      # flow nahrávání
│   └── trend_chart_test.dart        # prázdný stav, data
└── integration/
    └── record_upload_flow_test.dart # end-to-end mock
```

---

## 11. Fáze vývoje

### Fáze 1 — MVP (6–8 týdnů)
- [x] Projekt setup (Riverpod, Drift, go_router)
- [ ] Auth: login, register, JWT refresh
- [ ] Onboarding: 3 obrazovky + disclaimer
- [ ] Record screen: kamera + audio + local_auth
- [ ] Upload: Dio multipart + offline queue
- [ ] Dashboard: composite score + posledních 5 měření
- [ ] History: seznam + základní karta

### Fáze 2 — Rozšíření (4–6 týdnů)
- [ ] Trend chart (14 dní, fl_chart)
- [ ] Speaker embedding enrollment + verification
- [ ] Push notifikace (FCM)
- [ ] Measurement detail screen + radar chart
- [ ] Poem prompt rotace (lokální pool)
- [ ] Settings: notifikace, jazyk, export

### Fáze 3 — Polish (2–4 týdny)
- [ ] Animace přechodů (shared element transitions)
- [ ] Glassmorphism karty
- [ ] Haptic feedback (countddown, upload done)
- [ ] Accessibility (font scaling, contrast mode)
- [ ] Dark/light mode (dark jako default)
- [ ] Krizové tlačítko — vždy viditelné

---

## 12. Bezpečnostní checklist

| Oblast | Řešení |
|--------|--------|
| Tokeny | `flutter_secure_storage` (iOS Keychain, Android Keystore) |
| Biometrie | `local_auth` → Secure Enclave, server to nikdy nevidí |
| Media soubory | Temp adresář → smazány po úspěšném uploadu |
| Síť | Certificate pinning (prod), HTTPS only |
| Uživatelská data | Žádné trackování, žádná analytika bez souhlasu |
| GDPR | Export + smazání dat na vyžádání (max 30 dní) |
| Děti | Věkový gate při registraci (18+) |

---

## 13. Krizový UX — speciální pozornost

```dart
// Krizové tlačítko — floating, vždy viditelné na Dashboard + Record

class CrisisButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showCrisisSheet(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accentWarm.withOpacity(0.4)),
        ),
        child: Row(children: [
          Icon(Icons.favorite_border, color: AppColors.accentWarm, size: 16),
          SizedBox(width: 8),
          Text('Potřebuji pomoc', style: AppTypography.body.copyWith(
            color: AppColors.accentWarm, fontSize: 13)),
        ]),
      ),
    );
  }
}

// BottomSheet s kontakty — žádné alarmující barvy
// "Jsi tady a to je dost."
// [Linka bezpečí] [Centrum krizové intervence] [Kontaktovat blízkého]
```

**Zásady pro celou UX:**
- Skóre se nikdy nenazývá "špatné" nebo "dobré" — jen "odchylka od tvého průměru"
- Žádné push notifikace v noci (22:00 – 8:00)
- Po 3 dnech bez nahrávky: **žádná** urgentní notifikace — jen jemná "Dávno jsme se neviděli"
- Smazání dat: okamžité, bez podmínek, bez "jsi si jistý 3×"
```

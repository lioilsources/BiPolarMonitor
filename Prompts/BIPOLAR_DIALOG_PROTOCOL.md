# BipolarMonitor — Standardizovaný Dialog Protokol

> Verze 1.0 | Inspirace: Voigt-Kampff test | Jazyk: CS primární

---

## Filozofie protokolu

Každá otázka je navržena jako **psychologicky kalibrovaný stimul** — ne terapeutická
intervence. Uživatel nikdy nesmí cítit, že je testován nebo hodnocen. Tón aplikace
je vždy klidný, zvědavý, přátelský.

Otázky cílí na šest dimenzí:
1. **Tempo** — rychlost řeči, pauzy, hesitace
2. **Koheze** — zůstává u tématu, nebo přeskakuje?
3. **Abstrakce** — schopnost metafory, asociace
4. **Valence** — emoční zabarvení obsahu
5. **Energie** — délka odpovědi, iniciativa, rozvinutí
6. **Orientace** — minulost/přítomnost/budoucnost, konkrétnost

---

## Otázky — všech 15 variant

### OTÁZKA 1 — Orientace v přítomnosti
*Cílí na: Tempo, Energie, Orientace (přítomnost)*
*Instrukce pro ML: baseline speech rate, počet slov, délka pauz na začátku odpovědi*

**Varianta A**
> „Popiš mi, co jsi dělal dnes ráno. Ale začni od druhé věci, co tě napadne."

**Varianta B**
> „Co jsi dělal posledních pár hodin? Řekni mi to pozpátku — od teď dozadu."

**Varianta C**
> „Kdybys měl popsat dnešní ráno jedním gestem, jakým by bylo? A teď mi ho popiš slovy."

---

### OTÁZKA 2 — Abstraktní asociace
*Cílí na: Abstrakce, Koheze, Valence*
*Instrukce pro ML: počet metafor, délka odpovědi, tematické přechody, emoční valence slov (LIWC nebo vlastní slovník)*

**Varianta A**
> „Kdybys byl počasí, jaké by bylo dnes? Ne jaké chceš — jaké skutečně je."

**Varianta B**
> „Kdybys byl zvuk, co by teď hrál? Můžeš být cokoliv — hudba, hluk, ticho."

**Varianta C**
> „Kdybys byl místnost, jak by teď vypadala? Co by v ní bylo a co by v ní chybělo?"

---

### OTÁZKA 3 — Kognitivní zátěž
*Cílí na: Tempo, Orientace, Energie*
*Instrukce pro ML: latence mezi kroky úlohy, dokončení obou částí (ano/ne), plynulost přechodu*

**Varianta A**
> „Vyjmenuj pět věcí, které vidíš kolem sebe. Pak řekni, která z nich by přežila požár."

**Varianta B**
> „Řekni mi tři barvy, které teď vidíš. A pak — která z nich je nejhlučnější?"

**Varianta C**
> „Popiš mi povrch nejbližšího předmětu, kterého se dotýkáš. A pak řekni, čemu se podobá."

---

### OTÁZKA 4 — Emoční valence
*Cílí na: Valence, Energie, Koheze*
*Instrukce pro ML: délka odpovědi, sentiment analýza (CZ BERT nebo přeložené embeddingy), tempo zpomalení při těžkých tématech, vyhýbání (krátká odpověď = potenciální flag)*

**Varianta A**
> „Co bylo poslední dobou těžké? Nemusí to být nic velkého."

**Varianta B**
> „Co tě v posledních dnech překvapilo — příjemně nebo nepříjemně?"

**Varianta C**
> „Co ti teď leží na mysli, i když o tom nechceš moc přemýšlet?"

---

### OTÁZKA 5 — Uzavření a budoucnost
*Cílí na: Valence, Orientace (budoucnost), Abstrakce*
*Instrukce pro ML: orientace do budoucna (slovesa budoucího času), délka a konkrétnost, energetický vzestup/pokles oproti Q4*

**Varianta A**
> „Řekni mi jednu věc, na kterou se těšíš. Klidně vymyšlenou."

**Varianta B**
> „Co by byl dobrý den? Nemusí být reálný — prostě dobrý."

**Varianta C**
> „Kdyby zítra bylo jiné než dnes — v čem by to bylo?"

---

## Rotační schéma

```
Kombinace = (Q1.varianta, Q2.varianta, Q3.varianta, Q4.varianta, Q5.varianta)
Celkem kombinací: 3^5 = 243

Algoritmus:
  1. Zjisti poslední použitou variantu každé otázky
  2. Pro každou otázku zvol variantu, která nebyla použita nejdéle
  3. Stejná varianta Q4 se neopakuje dříve než za 21 dní (nejcitlivější otázka)
  4. Stejná kombinace se neopakuje dříve než za 60 dní

Implementace (pseudokód):
  last_used[question_id][variant_id] = timestamp
  next_variant = argmin(last_used[question_id])
```

---

## Scoring schéma

### Přehled dimenzí a jejich zdrojů

```
┌─────────────────┬──────────────────────────────────┬────────────┐
│ Dimenze         │ Zdroj signálu                    │ Váha MVP   │
├─────────────────┼──────────────────────────────────┼────────────┤
│ Speech Rate     │ Whisper timestamps               │ 0.20       │
│ Pause Pattern   │ Whisper + openSMILE              │ 0.15       │
│ Voice Energy    │ openSMILE (GeMAPS: loudness, F0) │ 0.20       │
│ Response Length │ Whisper (word count per Q)       │ 0.15       │
│ Cohesion        │ BERT embeddings (topic drift)    │ 0.15       │
│ Facial Affect   │ OpenFace AU aktivace             │ 0.15       │
└─────────────────┴──────────────────────────────────┴────────────┘
```

---

### DIMENZE 1 — Speech Rate

**Co měříme:** Slova za minutu (WPM), zvlášť pro každou odpověď.

**Výpočet:**
```python
def speech_rate(transcript_with_timestamps):
    # Whisper vrací word-level timestamps
    words = [w for w in transcript if w['text'].strip()]
    duration = words[-1]['end'] - words[0]['start']
    wpm = (len(words) / duration) * 60
    return wpm

# Typické rozsahy (CZ řeč):
# Depresivní epizoda:  80–110 WPM
# Baseline:           120–160 WPM
# Hypomanie:          160–200 WPM
# Manie:              200+ WPM
```

**Scoring:**
```python
def score_speech_rate(wpm, user_baseline_wpm, user_baseline_std):
    zscore = (wpm - user_baseline_wpm) / user_baseline_std
    # zscore > +2.0 → elevated flag
    # zscore < -2.0 → suppressed flag
    return zscore
```

**Specifika per otázka:**
- Q1 (přítomnost): očekáváme střední tempo — referenční baseline
- Q3 (kognitivní zátěž): přirozené zpomalení při druhé části je normální
- Q4 (emoce): mírné zpomalení normální — výrazné zpomalení = flag

---

### DIMENZE 2 — Pause Pattern

**Co měříme:**
- `pause_ratio` — % času v pauzách (>0.3s)
- `initial_latency` — latence před první slovem (jak rychle začne)
- `within_sentence_pauses` — pauzy uvnitř vět (hesitace)

**Výpočet:**
```python
def pause_analysis(word_timestamps):
    pauses = []
    for i in range(1, len(word_timestamps)):
        gap = word_timestamps[i]['start'] - word_timestamps[i-1]['end']
        if gap > 0.3:  # pauza > 300ms
            pauses.append(gap)

    total_speech_time = word_timestamps[-1]['end'] - word_timestamps[0]['start']
    pause_ratio = sum(pauses) / total_speech_time

    initial_latency = word_timestamps[0]['start']  # od konce otázky

    # Klasifikace pauz
    hesitations = [p for p in pauses if 0.3 < p < 1.0]   # krátké = hesitace
    long_pauses  = [p for p in pauses if p >= 1.0]         # dlouhé = přemýšlení/blok

    return {
        'pause_ratio': pause_ratio,
        'initial_latency': initial_latency,
        'hesitation_count': len(hesitations),
        'long_pause_count': len(long_pauses),
        'mean_pause_duration': np.mean(pauses) if pauses else 0
    }

# Baseline:
#   pause_ratio ~0.15–0.25
#   initial_latency ~0.8–1.5s
#
# Deprese:
#   pause_ratio > 0.35, initial_latency > 2.5s, long_pause_count ++
#
# Manie:
#   pause_ratio < 0.08, initial_latency < 0.4s (přeskočí přemýšlení)
```

**Specifika per otázka:**
- Q3 (dvoustupňová): pauza MEZI kroky je normální, měříme ji zvlášť
- Q1 (pozpátku varianta B): initial_latency přirozeně delší — normalizovat

---

### DIMENZE 3 — Voice Energy (GeMAPS)

**Co měříme z openSMILE eGeMAPS:**
- `F0semitoneFrom27.5Hz_sma3nz` — základní frekvence hlasu (výška)
- `loudness_sma3` — hlasitost (energie)
- `F0_range` — rozsah výšky hlasu během odpovědi
- `jitterLocal_sma3nz` — mikrofluktuace hlasu (stres/napětí)

**Výpočet:**
```python
import opensmile

smile = opensmile.Smile(
    feature_set=opensmile.FeatureSet.eGeMAPS,
    feature_level=opensmile.FeatureLevel.Functionals,
)

def voice_energy_features(audio_path):
    features = smile.process_file(audio_path)
    return {
        'f0_mean':    features['F0semitoneFrom27.5Hz_sma3nz_amean'].values[0],
        'f0_std':     features['F0semitoneFrom27.5Hz_sma3nz_stddevNorm'].values[0],
        'loudness':   features['loudness_sma3_amean'].values[0],
        'f0_range':   features['F0semitoneFrom27.5Hz_sma3nz_pctlrange0-2'].values[0],
        'jitter':     features['jitterLocal_sma3nz_amean'].values[0],
    }

# Baseline:
#   f0_range střední (přirozená intonace)
#   jitter nízký (hlas klidný)
#
# Deprese:
#   f0_range nízký (monotónní hlas — klíčový ukazatel)
#   loudness nízká
#
# Manie:
#   f0_range vysoký (expresivní, výrazné vzestupy)
#   loudness vysoká
#   jitter může být vyšší (vzrušení)
```

**Segmentace per otázka:**
```python
# Každou odpověď analyzuj jako samostatný audio segment
# Whisper timestamps → ořez audio souboru → openSMILE per segment
def segment_audio(audio_path, word_timestamps_by_question):
    segments = {}
    for q_id, words in word_timestamps_by_question.items():
        start = words[0]['start'] - 0.1
        end   = words[-1]['end']  + 0.1
        segment = extract_audio_segment(audio_path, start, end)
        segments[q_id] = voice_energy_features(segment)
    return segments
```

---

### DIMENZE 4 — Response Length

**Co měříme:** Počet slov per otázka. Jednoduchý ale velmi silný prediktor.

**Výpočet:**
```python
def response_lengths(transcript_by_question):
    return {q_id: len(words.split()) for q_id, words in transcript_by_question.items()}

# Očekávané délky (baseline):
#   Q1 (přítomnost):     30–60 slov
#   Q2 (asociace):       20–45 slov
#   Q3 (kognitivní):     15–30 slov
#   Q4 (emoce):          20–50 slov
#   Q5 (budoucnost):     15–35 slov

# Flags:
#   Jakákoliv odpověď < 8 slov → "minimal_response" flag
#   Jakákoliv odpověď > 120 slov → "extended_response" flag (flight of ideas)
#   Q4 < 10 slov → "emotional_avoidance" flag (zvláštní pozornost)
```

**Energetický profil dialogu:**
```python
# Sleduj trend délky odpovědí přes dialog
# Normální: Q1 > Q2 ~ Q3 < Q4 ~ Q5 (Q4 bývá delší)
# Deprese: klesající profil (Q1 delší, Q5 velmi krátká)
# Manie:   rostoucí nebo chaotický profil
def energy_profile(lengths_by_question):
    values = [lengths_by_question[f'Q{i}'] for i in range(1, 6)]
    slope = np.polyfit(range(5), values, 1)[0]
    return {
        'profile': values,
        'slope': slope,          # záporný = klesající energie
        'variance': np.var(values)  # vysoký = nestabilní
    }
```

---

### DIMENZE 5 — Cohesion (Tematická soudržnost)

**Co měříme:** Zůstává uživatel u tématu otázky, nebo odbíhá?

**Výpočet pomocí sentence embeddings:**
```python
from sentence_transformers import SentenceTransformer

# Model pro češtinu:
# 'sentence-transformers/paraphrase-multilingual-mpnet-base-v2'
# nebo 'Seznam/simcse-dist-mpnet-paracrawl-cs-v1'

model = SentenceTransformer('paraphrase-multilingual-mpnet-base-v2')

def cohesion_score(question_text, answer_text):
    q_embedding = model.encode(question_text)
    a_embedding = model.encode(answer_text)
    similarity = cosine_similarity([q_embedding], [a_embedding])[0][0]
    return float(similarity)

# Typické hodnoty:
#   Kohezní odpověď:    0.55–0.85
#   Mírný drift:        0.35–0.55
#   Výrazný drift:      < 0.35 → "topic_drift" flag

# Navíc — vnitřní koheze dlouhé odpovědi:
def internal_cohesion(answer_text):
    sentences = sent_tokenize(answer_text, language='czech')
    if len(sentences) < 2:
        return 1.0
    embeddings = model.encode(sentences)
    # Průměrná kosinová podobnost sousedních vět
    similarities = [
        cosine_similarity([embeddings[i]], [embeddings[i+1]])[0][0]
        for i in range(len(embeddings)-1)
    ]
    return float(np.mean(similarities))

# Nízká internal_cohesion + vysoká WPM → silný flight_of_ideas flag
```

---

### DIMENZE 6 — Facial Affect (OpenFace AU)

**Co měříme:** Action Units relevantní pro afektivní stav.

```python
# Klíčové Action Units:
AU_MAP = {
    'AU01': 'inner_brow_raise',      # smutek, starosti
    'AU04': 'brow_lowerer',          # negativní afekt, koncentrace
    'AU06': 'cheek_raiser',          # pravý úsměv (s AU12)
    'AU12': 'lip_corner_puller',     # úsměv
    'AU15': 'lip_corner_depressor',  # smutek
    'AU17': 'chin_raiser',           # negativní afekt
    'AU45': 'blink',                 # frekvence mrkání (stres, únava)
}

def facial_features(openface_csv_path):
    df = pd.read_csv(openface_csv_path)
    features = {}

    for au, name in AU_MAP.items():
        col_intensity = f'{au}_r'   # intensity 0–5
        col_presence  = f'{au}_c'   # presence 0/1
        features[f'{name}_mean'] = df[col_intensity].mean()
        features[f'{name}_std']  = df[col_intensity].std()
        features[f'{name}_pct']  = df[col_presence].mean()  # % času aktivní

    # Odvozené kompozitní metriky
    features['genuine_smile'] = min(
        features['cheek_raiser_mean'],
        features['lip_corner_puller_mean']
    )  # Duchenne smile — oba AU musí být aktivní

    features['negative_affect'] = np.mean([
        features['brow_lowerer_mean'],
        features['lip_corner_depressor_mean'],
        features['chin_raiser_mean'],
    ])

    features['blink_rate'] = features['blink_pct'] * 30  # blinks/min (30fps)
    # Baseline blink rate: 15–20/min
    # Stres/únava: > 25/min nebo < 8/min

    return features

# Segmentace per otázka: stejná logika jako audio
# Zvláštní pozornost: Q4 (emoce) — AU01 + AU04 aktivace
```

**Gaze a head pose jako doplněk:**
```python
# OpenFace také dává:
features['gaze_angle_x_std'] = df['gaze_angle_x'].std()
features['head_pose_rx_std'] = df['pose_Rx'].std()
# Vysoký std = neklid, agitace
# Nízký std + averze pohledu = stažení, depresivní afekt
```

---

## Kompozitní scoring pipeline

```python
def compute_composite_score(features, user_baseline):
    """
    Vrací dict se z-score pro každou dimenzi a kompozitní skóre.
    Pozitivní z-score = zvýšení oproti baseline (energie, aktivace)
    Záporný z-score = snížení oproti baseline (stažení, zpomalení)
    """

    def zscore(value, key):
        mean = user_baseline[key]['mean']
        std  = user_baseline[key]['std']
        if std < 1e-6:
            return 0.0
        return (value - mean) / std

    dimensions = {
        'speech_rate':       zscore(features['wpm'], 'wpm'),
        'pause_ratio':      -zscore(features['pause_ratio'], 'pause_ratio'),  # invertováno
        'voice_energy':      zscore(features['loudness'], 'loudness'),
        'f0_range':          zscore(features['f0_range'], 'f0_range'),
        'response_length':   zscore(features['total_words'], 'total_words'),
        'cohesion':          zscore(features['cohesion_mean'], 'cohesion_mean'),
        'facial_affect':     zscore(features['genuine_smile'], 'genuine_smile'),
        'negative_affect':  -zscore(features['negative_affect'], 'negative_affect'),
    }

    weights = {
        'speech_rate':      0.18,
        'pause_ratio':      0.12,
        'voice_energy':     0.15,
        'f0_range':         0.10,
        'response_length':  0.15,
        'cohesion':         0.12,
        'facial_affect':    0.10,
        'negative_affect':  0.08,
    }

    composite = sum(dimensions[k] * weights[k] for k in dimensions)

    return {
        'dimensions': dimensions,
        'composite_zscore': composite,
        'flags': detect_flags(features, dimensions, user_baseline),
    }


def detect_flags(features, dimensions, baseline):
    flags = []

    # Rychlost řeči
    if dimensions['speech_rate'] > 2.0:
        flags.append('elevated_speech_rate')
    if dimensions['speech_rate'] < -2.0:
        flags.append('suppressed_speech_rate')

    # Délka odpovědí
    if features.get('minimal_responses', 0) >= 2:
        flags.append('minimal_responses')
    if features.get('extended_responses', 0) >= 2:
        flags.append('extended_responses')

    # Emocionální vyhýbání (Q4 specificky)
    if features.get('q4_word_count', 99) < 10:
        flags.append('emotional_avoidance')

    # Flight of ideas
    if dimensions['speech_rate'] > 1.5 and features['internal_cohesion'] < 0.40:
        flags.append('flight_of_ideas')

    # Monotónní hlas (depresivní marker)
    if dimensions['f0_range'] < -1.8:
        flags.append('monotone_voice')

    # Celková energetická deplece
    depleted = sum(1 for k in ['speech_rate', 'voice_energy', 'response_length']
                   if dimensions[k] < -1.5)
    if depleted >= 2:
        flags.append('low_energy_profile')

    return flags
```

---

## Baseline kalibrace

```python
# Baseline se staví z prvních 7 měření
# Update: rolling window posledních 30 měření (s váhou novějších)

def update_baseline(user_id, new_features, db):
    history = db.get_recent_features(user_id, limit=30)
    history.append(new_features)

    weights = np.linspace(0.5, 1.0, len(history))  # novější = vyšší váha

    baseline = {}
    for key in new_features:
        values = [h[key] for h in history if key in h]
        w = weights[-len(values):]
        baseline[key] = {
            'mean': np.average(values, weights=w),
            'std':  np.std(values),  # std bez vah — konzervativní
        }

    db.save_baseline(user_id, baseline)
    return baseline

# Poznámka: baseline aktualizuj POUZE pokud měření prošlo
# speaker verification (cosine sim > 0.75)
# Zabraňuje kontaminaci baseline cizí osobou nebo extrémní epizodou
```

---

## Výstupní formát pro Flutter

```json
{
  "measurement_id": "uuid",
  "recorded_at": "2026-05-07T14:30:00Z",
  "protocol_version": "ALPHA-1",
  "questions_used": ["Q1B", "Q2A", "Q3C", "Q4A", "Q5B"],

  "scores": {
    "speech_rate_zscore":    1.4,
    "pause_ratio_zscore":   -0.3,
    "voice_energy_zscore":   0.8,
    "f0_range_zscore":       1.1,
    "response_length_zscore": 0.6,
    "cohesion_zscore":       -0.2,
    "facial_affect_zscore":  0.9,
    "composite_zscore":      0.72
  },

  "per_question": {
    "Q1": { "wpm": 148, "word_count": 42, "pause_ratio": 0.18 },
    "Q2": { "wpm": 162, "word_count": 38, "cohesion": 0.71 },
    "Q3": { "wpm": 155, "word_count": 24, "task_completed": true },
    "Q4": { "wpm": 131, "word_count": 35, "cohesion": 0.68 },
    "Q5": { "wpm": 159, "word_count": 28, "cohesion": 0.74 }
  },

  "energy_profile": {
    "word_counts": [42, 38, 24, 35, 28],
    "slope": -1.8,
    "pattern": "mild_declining"
  },

  "flags": ["elevated_speech_rate"],

  "baseline": {
    "composite_mean": 0.52,
    "composite_std":  0.08,
    "deviation_sigma": 1.6,
    "based_on_n": 23
  },

  "trend_7d": "mildly_elevated",
  "speaker_verified": true,
  "speaker_similarity": 0.89
}
```

---

## UI — jak zobrazit výsledky (bez diagnostických termínů)

```
Dimenze             Zobrazení v aplikaci
─────────────────────────────────────────────────────────
speech_rate         "Tempo řeči"          ← → →  (šipky)
voice_energy        "Energie hlasu"       ● ● ○  (tečky)
response_length     "Délka odpovědí"      ↑ normální
f0_range            "Melodie hlasu"       mírně vyšší
cohesion            "Soustředění"         v normě
facial_affect       "Výraz tváře"         v normě

Flags → přátelský text:
  elevated_speech_rate  → "Mluvil jsi dnes rychleji než obvykle"
  monotone_voice        → "Tvůj hlas byl dnes tišší a klidnější"
  emotional_avoidance   → (nezobrazovat — pouze log pro psychiatra)
  flight_of_ideas       → "Hodně myšlenek najednou?"
  low_energy_profile    → "Dnes to vypadá na klidnější den"
```

---

## Doporučení pro fine-tuning (budoucnost)

Jakmile máš 100+ měření s ground truth (uživatel sám označí "dobrý den / špatný den"):

```python
# Supervised baseline correction
# Vstup: features + user_label (good/neutral/bad)
# Model: lightweight XGBoost nebo logistic regression
# Trénink: per-user (personalizovaný) + global prior

# Dataset pro pre-training:
# AVEC 2013/2014 — deprese scoring z videa/audia (anglicky)
# DAIC-WOZ — depresivní rozhovory (anglicky)
# → transfer learning + fine-tune na CZ dialogy

# Alternativa bez labeled data:
# Unsupervised anomaly detection (Isolation Forest)
# Trénink pouze na baseline měřeních → anomálie = odchylka
```

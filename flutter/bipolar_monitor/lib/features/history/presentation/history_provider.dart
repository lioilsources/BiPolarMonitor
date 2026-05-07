import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class MeasurementSummary {
  final String id;
  final DateTime recordedAt;
  final int durationSeconds;
  final bool analyzed;
  final double? compositeZscore;
  final List<String> flags;
  final String? trend7d;

  const MeasurementSummary({
    required this.id,
    required this.recordedAt,
    required this.durationSeconds,
    required this.analyzed,
    this.compositeZscore,
    this.flags = const [],
    this.trend7d,
  });

  factory MeasurementSummary.fromJson(Map<String, dynamic> json) => MeasurementSummary(
        id: json['id'] as String,
        recordedAt: DateTime.parse(json['recorded_at'] as String),
        durationSeconds: json['duration_seconds'] as int,
        analyzed: json['analyzed'] as bool,
        compositeZscore: (json['composite_zscore'] as num?)?.toDouble(),
        flags: (json['flags'] as List?)?.cast<String>() ?? [],
        trend7d: json['trend_7d'] as String?,
      );
}

class MeasurementDetail extends MeasurementSummary {
  final List<String> questionsUsed;
  final bool? speakerVerified;
  final double? speakerSimilarity;
  final String? notes;
  final Map<String, double>? scores;
  final Map<String, dynamic>? perQuestion;
  final Map<String, dynamic>? energyProfile;
  final Map<String, dynamic>? baseline;

  const MeasurementDetail({
    required super.id,
    required super.recordedAt,
    required super.durationSeconds,
    required super.analyzed,
    super.compositeZscore,
    super.flags,
    super.trend7d,
    this.questionsUsed = const [],
    this.speakerVerified,
    this.speakerSimilarity,
    this.notes,
    this.scores,
    this.perQuestion,
    this.energyProfile,
    this.baseline,
  });

  factory MeasurementDetail.fromJson(Map<String, dynamic> json) {
    final scores = json['scores'] as Map<String, dynamic>?;
    return MeasurementDetail(
      id: json['id'] as String,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      durationSeconds: json['duration_seconds'] as int,
      analyzed: json['analyzed'] as bool,
      compositeZscore: (scores?['composite_zscore'] as num?)?.toDouble(),
      flags: (json['flags'] as List?)?.cast<String>() ?? [],
      trend7d: json['trend_7d'] as String?,
      questionsUsed: (json['questions_used'] as List?)?.cast<String>() ?? [],
      speakerVerified: json['speaker_verified'] as bool?,
      speakerSimilarity: (json['speaker_similarity'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      scores: scores?.map((k, v) => MapEntry(k, (v as num?)?.toDouble() ?? 0.0)),
      perQuestion: json['per_question'] as Map<String, dynamic>?,
      energyProfile: json['energy_profile'] as Map<String, dynamic>?,
      baseline: json['baseline'] as Map<String, dynamic>?,
    );
  }
}

// Paginated history list
class HistoryNotifier extends StateNotifier<AsyncValue<List<MeasurementSummary>>> {
  final Ref _ref;
  int _page = 0;
  bool _hasMore = true;
  static const _pageSize = 20;

  HistoryNotifier(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final api = _ref.read(apiClientProvider);
      final resp = await api.get('/measurements/?limit=$_pageSize&offset=${_page * _pageSize}');
      final items = (resp['items'] as List? ?? resp as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(MeasurementSummary.fromJson)
          .toList();
      _hasMore = items.length == _pageSize;
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data([...current, ...items]);
      _page++;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    _page = 0;
    _hasMore = true;
    state = const AsyncValue.loading();
    await load();
  }

  Future<void> delete(String id) async {
    await _ref.read(apiClientProvider).delete('/measurements/$id');
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(current.where((m) => m.id != id).toList());
  }

  bool get hasMore => _hasMore;
}

final historyProvider = StateNotifierProvider<HistoryNotifier, AsyncValue<List<MeasurementSummary>>>(
  (ref) => HistoryNotifier(ref),
);

final measurementDetailProvider = FutureProvider.family<MeasurementDetail, String>((ref, id) async {
  final resp = await ref.read(apiClientProvider).get('/measurements/$id');
  return MeasurementDetail.fromJson(resp);
});

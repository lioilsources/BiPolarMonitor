import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/network/api_client.dart';

final speakerVerifierProvider = Provider<SpeakerVerifier>((ref) => SpeakerVerifier(ref));

class SpeakerVerifier {
  final Ref _ref;

  SpeakerVerifier(this._ref);

  /// Compute cosine similarity between two float vectors.
  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length || a.isEmpty) return 0.0;
    double dot = 0, normA = 0, normB = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    final denom = sqrt(normA) * sqrt(normB);
    return denom < 1e-8 ? 0.0 : dot / denom;
  }

  /// Request embedding computation from ML service for an audio file,
  /// then compare against stored user embedding.
  /// Returns similarity score 0–1, or null if no enrollment exists.
  Future<double?> verify(String audioPath) async {
    try {
      final api = _ref.read(apiClientProvider);
      // Ask ML service to compute embedding for this audio
      final resp = await api.post('/ml/speaker-embedding', {'audio_path': audioPath});
      final embedding = (resp['embedding'] as List).cast<double>();

      // Fetch stored embedding from API
      final profileResp = await api.get('/user/profile');
      if (profileResp['has_speaker_embedding'] != true) return null;

      final storedResp = await api.get('/user/speaker-embedding');
      final stored = (storedResp['embedding'] as List).cast<double>();

      return cosineSimilarity(embedding, stored);
    } catch (_) {
      return null; // verification unavailable — don't block
    }
  }
}

/// Threshold below which we show a soft warning (not a hard block).
const double kSpeakerSimilarityThreshold = 0.75;

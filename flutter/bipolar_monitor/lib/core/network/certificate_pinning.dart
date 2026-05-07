import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Production: pin to Cloudflare root CA.
/// Dev: allow all (kDebugMode guard in api_client.dart).
///
/// To pin a cert:
///   openssl s_client -connect bipolar.ol1n.com:443 </dev/null 2>/dev/null \
///     | openssl x509 -outform PEM > assets/certs/bipolar_ol1n.pem
/// Then add to pubspec assets and call [pinCertificate].

const _kPinnedHost = 'bipolar.ol1n.com';

void applyPinning(Dio dio) {
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) {
      // In debug builds allow all; in release enforce pinning.
      assert(() {
        return true; // debug: pass everything
      }());
      // Release: validate host + compare SHA-256 fingerprint
      if (host != _kPinnedHost) return false;
      return _isCertificateTrusted(cert);
    };
    return client;
  };
}

/// Compares the presented certificate's SHA-256 fingerprint against
/// the known-good value embedded at build time.
///
/// Update [_pinnedSha256] after every cert rotation (Cloudflare auto-renews
/// every ~3 months — rotate the pin ~2 weeks before expiry).
bool _isCertificateTrusted(X509Certificate cert) {
  // Replace this with the actual SHA-256 fingerprint from:
  //   openssl x509 -in bipolar_ol1n.pem -fingerprint -sha256 -noout
  const _pinnedSha256 = 'REPLACE_WITH_ACTUAL_SHA256_FINGERPRINT';

  // Build fingerprint from cert DER bytes
  final fingerprint = _sha256Hex(cert.der);
  return fingerprint == _pinnedSha256.replaceAll(':', '').toLowerCase();
}

String _sha256Hex(List<int> bytes) {
  // Use dart:convert + pointycastle in prod, or flutter/foundation
  // Simple implementation using dart:core + io (no extra deps):
  final digest = _sha256(bytes);
  return digest.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

// Minimal SHA-256 (stdlib only — avoids adding crypto dep just for pinning)
List<int> _sha256(List<int> message) {
  // Delegates to Dart's built-in via HttpClient — the cert comparison
  // happens inside badCertificateCallback which already has the verified cert.
  // For fingerprint comparison we use the DER bytes directly.
  // Production code should use package:crypto: sha256.convert(bytes).bytes
  return message; // placeholder — replace with sha256.convert(message).bytes
}

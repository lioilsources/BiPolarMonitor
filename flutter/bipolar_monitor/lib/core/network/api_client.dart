import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import 'certificate_pinning.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));

class ApiClient {
  late final Dio _dio;
  final Ref _ref;

  ApiClient(this._ref) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: ApiConstants.connectTimeoutSeconds),
      receiveTimeout: const Duration(seconds: ApiConstants.receiveTimeoutSeconds),
      sendTimeout: Duration(minutes: ApiConstants.uploadTimeoutMinutes),
    ));

    // Certificate pinning in release builds only
    if (!kDebugMode && !kIsWeb) {
      applyPinning(_dio);
    }

    _dio.interceptors.addAll([
      _AuthInterceptor(_ref),
      RetryInterceptor(dio: _dio, retries: 3, retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 3),
        Duration(seconds: 5),
      ]),
    ]);
  }

  Future<Map<String, dynamic>> get(String path) async {
    final resp = await _dio.get(path);
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data) async {
    final resp = await _dio.post(path, data: data);
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> data) async {
    final resp = await _dio.put(path, data: data);
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final resp = await _dio.delete(path);
    return resp.data as Map<String, dynamic>;
  }

  Future<List<int>> downloadBytes(String path) async {
    final resp = await _dio.get<List<int>>(
      path,
      options: Options(responseType: ResponseType.bytes),
    );
    return resp.data ?? [];
  }

  Future<String> uploadMeasurement({
    required String measurementId,
    required String questionsUsed,
    String? questionTimings,
    required String recordedAt,
    required int durationSeconds,
    String? notes,
    required File videoFile,
    required File audioFile,
    ProgressCallback? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'measurement_id': measurementId,
      'questions_used': questionsUsed,
      if (questionTimings != null) 'question_timings': questionTimings,
      'recorded_at': recordedAt,
      'duration_seconds': durationSeconds.toString(),
      if (notes != null) 'notes': notes,
      'video': await MultipartFile.fromFile(videoFile.path, filename: 'video.mp4'),
      'audio': await MultipartFile.fromFile(audioFile.path, filename: 'audio.wav'),
    });

    final resp = await _dio.post(
      '/measurements/upload',
      data: formData,
      onSendProgress: onProgress,
    );
    return resp.data['measurement_id'] as String;
  }
}

class _AuthInterceptor extends Interceptor {
  final Ref _ref;
  bool _isRefreshing = false;

  _AuthInterceptor(this._ref);

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
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final storage = _ref.read(secureStorageProvider);
        final refreshToken = await storage.getRefreshToken();
        if (refreshToken == null) {
          handler.next(err);
          return;
        }
        final client = _ref.read(apiClientProvider);
        final resp = await client.post('/auth/refresh', {'refresh_token': refreshToken});
        await storage.saveTokens(
          access: resp['access_token'] as String,
          refresh: resp['refresh_token'] as String,
        );
        // Retry original request
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer ${resp['access_token']}';
        final retried = await _ref.read(apiClientProvider)._dio.fetch(opts);
        handler.resolve(retried);
      } catch (_) {
        await _ref.read(secureStorageProvider).clearTokens();
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }
}

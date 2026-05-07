import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'local_database.g.dart';

// ─── Tables ──────────────────────────────────────────────────────────────────

class LocalMeasurements extends Table {
  TextColumn get id => text()();
  DateTimeColumn get recordedAt => dateTime()();
  IntColumn get durationSeconds => integer()();
  BoolColumn get uploaded => boolean().withDefault(const Constant(false))();
  BoolColumn get analyzed => boolean().withDefault(const Constant(false))();
  TextColumn get localVideoPath => text().nullable()();
  TextColumn get localAudioPath => text().nullable()();
  TextColumn get questionsUsed => text()(); // JSON ["Q1B","Q2A",...]
  TextColumn get notes => text().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalScores extends Table {
  TextColumn get measurementId => text()();
  RealColumn get speechRateZscore => real().nullable()();
  RealColumn get pauseRatioZscore => real().nullable()();
  RealColumn get voiceEnergyZscore => real().nullable()();
  RealColumn get f0RangeZscore => real().nullable()();
  RealColumn get responseLengthZscore => real().nullable()();
  RealColumn get cohesionZscore => real().nullable()();
  RealColumn get facialAffectZscore => real().nullable()();
  RealColumn get compositeZscore => real().nullable()();
  TextColumn get flags => text().nullable()(); // JSON array
  TextColumn get trend7d => text().nullable()();
  RealColumn get baselineMean => real().nullable()();
  RealColumn get baselineStd => real().nullable()();
  IntColumn get baselineN => integer().nullable()();
  TextColumn get perQuestion => text().nullable()(); // JSON
  TextColumn get energyProfile => text().nullable()(); // JSON
  DateTimeColumn get analyzedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {measurementId};
}

class LocalUserProfile extends Table {
  TextColumn get userId => text()();
  TextColumn get displayName => text()();
  TextColumn get email => text()();
  BoolColumn get hasSpeakerEmbedding => boolean().withDefault(const Constant(false))();
  IntColumn get totalMeasurements => integer().withDefault(const Constant(0))();
  // Settings
  IntColumn get recordingDurationSeconds => integer().withDefault(const Constant(150))(); // 5 × 30s
  TextColumn get promptLanguage => text().withDefault(const Constant('cs'))();
  BoolColumn get speakerVerificationEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get dailyReminderEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get dailyReminderHour => integer().withDefault(const Constant(9))();
  IntColumn get dailyReminderMinute => integer().withDefault(const Constant(0))();
  BoolColumn get analysisNotificationsEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get onboardingComplete => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {userId};
}

// ─── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [LocalMeasurements, LocalScores, LocalUserProfile])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Measurements
  Future<List<LocalMeasurement>> getAllMeasurements({int limit = 50, int offset = 0}) =>
      (select(localMeasurements)
            ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)])
            ..limit(limit, offset: offset))
          .get();

  Future<List<LocalMeasurement>> getPendingUploads() =>
      (select(localMeasurements)
            ..where((t) => t.uploaded.equals(false))
            ..where((t) => t.retryCount.isSmallerThanValue(5)))
          .get();

  Future<void> markUploaded(String id) =>
      (update(localMeasurements)..where((t) => t.id.equals(id)))
          .write(const LocalMeasurementsCompanion(uploaded: Value(true)));

  Future<void> markAnalyzed(String id) =>
      (update(localMeasurements)..where((t) => t.id.equals(id)))
          .write(const LocalMeasurementsCompanion(analyzed: Value(true)));

  Future<void> incrementRetry(String id, DateTime nextRetry) =>
      customUpdate(
        'UPDATE local_measurements SET retry_count = retry_count + 1, next_retry_at = ? WHERE id = ?',
        variables: [Variable(nextRetry), Variable(id)],
      );

  Future<void> upsertMeasurement(LocalMeasurementsCompanion m) =>
      into(localMeasurements).insertOnConflictUpdate(m);

  Future<void> deleteMeasurement(String id) async {
    await (delete(localMeasurements)..where((t) => t.id.equals(id))).go();
    await (delete(localScores)..where((t) => t.measurementId.equals(id))).go();
  }

  // Scores
  Future<LocalScore?> getScore(String measurementId) =>
      (select(localScores)..where((t) => t.measurementId.equals(measurementId)))
          .getSingleOrNull();

  Future<void> upsertScore(LocalScoresCompanion s) =>
      into(localScores).insertOnConflictUpdate(s);

  // User profile
  Future<LocalUserProfile?> getProfile() =>
      select(localUserProfile).getSingleOrNull();

  Future<void> upsertProfile(LocalUserProfileCompanion p) =>
      into(localUserProfile).insertOnConflictUpdate(p);

  Future<void> updateSettings(LocalUserProfileCompanion p) =>
      (update(localUserProfile)).write(p);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'bipolar.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

final localDbProvider = Provider<LocalDatabase>((ref) {
  final db = LocalDatabase();
  ref.onDispose(db.close);
  return db;
});

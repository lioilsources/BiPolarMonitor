// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $LocalMeasurementsTable extends LocalMeasurements
    with TableInfo<$LocalMeasurementsTable, LocalMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _uploadedMeta =
      const VerificationMeta('uploaded');
  @override
  late final GeneratedColumn<bool> uploaded = GeneratedColumn<bool>(
      'uploaded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("uploaded" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _analyzedMeta =
      const VerificationMeta('analyzed');
  @override
  late final GeneratedColumn<bool> analyzed = GeneratedColumn<bool>(
      'analyzed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("analyzed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _localVideoPathMeta =
      const VerificationMeta('localVideoPath');
  @override
  late final GeneratedColumn<String> localVideoPath = GeneratedColumn<String>(
      'local_video_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localAudioPathMeta =
      const VerificationMeta('localAudioPath');
  @override
  late final GeneratedColumn<String> localAudioPath = GeneratedColumn<String>(
      'local_audio_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _questionsUsedMeta =
      const VerificationMeta('questionsUsed');
  @override
  late final GeneratedColumn<String> questionsUsed = GeneratedColumn<String>(
      'questions_used', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nextRetryAtMeta =
      const VerificationMeta('nextRetryAt');
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
      'next_retry_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        recordedAt,
        durationSeconds,
        uploaded,
        analyzed,
        localVideoPath,
        localAudioPath,
        questionsUsed,
        notes,
        retryCount,
        nextRetryAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_measurements';
  @override
  VerificationContext validateIntegrity(Insertable<LocalMeasurement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('uploaded')) {
      context.handle(_uploadedMeta,
          uploaded.isAcceptableOrUnknown(data['uploaded']!, _uploadedMeta));
    }
    if (data.containsKey('analyzed')) {
      context.handle(_analyzedMeta,
          analyzed.isAcceptableOrUnknown(data['analyzed']!, _analyzedMeta));
    }
    if (data.containsKey('local_video_path')) {
      context.handle(
          _localVideoPathMeta,
          localVideoPath.isAcceptableOrUnknown(
              data['local_video_path']!, _localVideoPathMeta));
    }
    if (data.containsKey('local_audio_path')) {
      context.handle(
          _localAudioPathMeta,
          localAudioPath.isAcceptableOrUnknown(
              data['local_audio_path']!, _localAudioPathMeta));
    }
    if (data.containsKey('questions_used')) {
      context.handle(
          _questionsUsedMeta,
          questionsUsed.isAcceptableOrUnknown(
              data['questions_used']!, _questionsUsedMeta));
    } else if (isInserting) {
      context.missing(_questionsUsedMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
          _nextRetryAtMeta,
          nextRetryAt.isAcceptableOrUnknown(
              data['next_retry_at']!, _nextRetryAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMeasurement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      uploaded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}uploaded'])!,
      analyzed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}analyzed'])!,
      localVideoPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_video_path']),
      localAudioPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_audio_path']),
      questionsUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}questions_used'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      nextRetryAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}next_retry_at']),
    );
  }

  @override
  $LocalMeasurementsTable createAlias(String alias) {
    return $LocalMeasurementsTable(attachedDatabase, alias);
  }
}

class LocalMeasurement extends DataClass
    implements Insertable<LocalMeasurement> {
  final String id;
  final DateTime recordedAt;
  final int durationSeconds;
  final bool uploaded;
  final bool analyzed;
  final String? localVideoPath;
  final String? localAudioPath;
  final String questionsUsed;
  final String? notes;
  final int retryCount;
  final DateTime? nextRetryAt;
  const LocalMeasurement(
      {required this.id,
      required this.recordedAt,
      required this.durationSeconds,
      required this.uploaded,
      required this.analyzed,
      this.localVideoPath,
      this.localAudioPath,
      required this.questionsUsed,
      this.notes,
      required this.retryCount,
      this.nextRetryAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['uploaded'] = Variable<bool>(uploaded);
    map['analyzed'] = Variable<bool>(analyzed);
    if (!nullToAbsent || localVideoPath != null) {
      map['local_video_path'] = Variable<String>(localVideoPath);
    }
    if (!nullToAbsent || localAudioPath != null) {
      map['local_audio_path'] = Variable<String>(localAudioPath);
    }
    map['questions_used'] = Variable<String>(questionsUsed);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    return map;
  }

  LocalMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return LocalMeasurementsCompanion(
      id: Value(id),
      recordedAt: Value(recordedAt),
      durationSeconds: Value(durationSeconds),
      uploaded: Value(uploaded),
      analyzed: Value(analyzed),
      localVideoPath: localVideoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localVideoPath),
      localAudioPath: localAudioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localAudioPath),
      questionsUsed: Value(questionsUsed),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      retryCount: Value(retryCount),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
    );
  }

  factory LocalMeasurement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMeasurement(
      id: serializer.fromJson<String>(json['id']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      uploaded: serializer.fromJson<bool>(json['uploaded']),
      analyzed: serializer.fromJson<bool>(json['analyzed']),
      localVideoPath: serializer.fromJson<String?>(json['localVideoPath']),
      localAudioPath: serializer.fromJson<String?>(json['localAudioPath']),
      questionsUsed: serializer.fromJson<String>(json['questionsUsed']),
      notes: serializer.fromJson<String?>(json['notes']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'uploaded': serializer.toJson<bool>(uploaded),
      'analyzed': serializer.toJson<bool>(analyzed),
      'localVideoPath': serializer.toJson<String?>(localVideoPath),
      'localAudioPath': serializer.toJson<String?>(localAudioPath),
      'questionsUsed': serializer.toJson<String>(questionsUsed),
      'notes': serializer.toJson<String?>(notes),
      'retryCount': serializer.toJson<int>(retryCount),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
    };
  }

  LocalMeasurement copyWith(
          {String? id,
          DateTime? recordedAt,
          int? durationSeconds,
          bool? uploaded,
          bool? analyzed,
          Value<String?> localVideoPath = const Value.absent(),
          Value<String?> localAudioPath = const Value.absent(),
          String? questionsUsed,
          Value<String?> notes = const Value.absent(),
          int? retryCount,
          Value<DateTime?> nextRetryAt = const Value.absent()}) =>
      LocalMeasurement(
        id: id ?? this.id,
        recordedAt: recordedAt ?? this.recordedAt,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        uploaded: uploaded ?? this.uploaded,
        analyzed: analyzed ?? this.analyzed,
        localVideoPath:
            localVideoPath.present ? localVideoPath.value : this.localVideoPath,
        localAudioPath:
            localAudioPath.present ? localAudioPath.value : this.localAudioPath,
        questionsUsed: questionsUsed ?? this.questionsUsed,
        notes: notes.present ? notes.value : this.notes,
        retryCount: retryCount ?? this.retryCount,
        nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
      );
  LocalMeasurement copyWithCompanion(LocalMeasurementsCompanion data) {
    return LocalMeasurement(
      id: data.id.present ? data.id.value : this.id,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      uploaded: data.uploaded.present ? data.uploaded.value : this.uploaded,
      analyzed: data.analyzed.present ? data.analyzed.value : this.analyzed,
      localVideoPath: data.localVideoPath.present
          ? data.localVideoPath.value
          : this.localVideoPath,
      localAudioPath: data.localAudioPath.present
          ? data.localAudioPath.value
          : this.localAudioPath,
      questionsUsed: data.questionsUsed.present
          ? data.questionsUsed.value
          : this.questionsUsed,
      notes: data.notes.present ? data.notes.value : this.notes,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      nextRetryAt:
          data.nextRetryAt.present ? data.nextRetryAt.value : this.nextRetryAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMeasurement(')
          ..write('id: $id, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('uploaded: $uploaded, ')
          ..write('analyzed: $analyzed, ')
          ..write('localVideoPath: $localVideoPath, ')
          ..write('localAudioPath: $localAudioPath, ')
          ..write('questionsUsed: $questionsUsed, ')
          ..write('notes: $notes, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAt: $nextRetryAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      recordedAt,
      durationSeconds,
      uploaded,
      analyzed,
      localVideoPath,
      localAudioPath,
      questionsUsed,
      notes,
      retryCount,
      nextRetryAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMeasurement &&
          other.id == this.id &&
          other.recordedAt == this.recordedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.uploaded == this.uploaded &&
          other.analyzed == this.analyzed &&
          other.localVideoPath == this.localVideoPath &&
          other.localAudioPath == this.localAudioPath &&
          other.questionsUsed == this.questionsUsed &&
          other.notes == this.notes &&
          other.retryCount == this.retryCount &&
          other.nextRetryAt == this.nextRetryAt);
}

class LocalMeasurementsCompanion extends UpdateCompanion<LocalMeasurement> {
  final Value<String> id;
  final Value<DateTime> recordedAt;
  final Value<int> durationSeconds;
  final Value<bool> uploaded;
  final Value<bool> analyzed;
  final Value<String?> localVideoPath;
  final Value<String?> localAudioPath;
  final Value<String> questionsUsed;
  final Value<String?> notes;
  final Value<int> retryCount;
  final Value<DateTime?> nextRetryAt;
  final Value<int> rowid;
  const LocalMeasurementsCompanion({
    this.id = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.uploaded = const Value.absent(),
    this.analyzed = const Value.absent(),
    this.localVideoPath = const Value.absent(),
    this.localAudioPath = const Value.absent(),
    this.questionsUsed = const Value.absent(),
    this.notes = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMeasurementsCompanion.insert({
    required String id,
    required DateTime recordedAt,
    required int durationSeconds,
    this.uploaded = const Value.absent(),
    this.analyzed = const Value.absent(),
    this.localVideoPath = const Value.absent(),
    this.localAudioPath = const Value.absent(),
    required String questionsUsed,
    this.notes = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        recordedAt = Value(recordedAt),
        durationSeconds = Value(durationSeconds),
        questionsUsed = Value(questionsUsed);
  static Insertable<LocalMeasurement> custom({
    Expression<String>? id,
    Expression<DateTime>? recordedAt,
    Expression<int>? durationSeconds,
    Expression<bool>? uploaded,
    Expression<bool>? analyzed,
    Expression<String>? localVideoPath,
    Expression<String>? localAudioPath,
    Expression<String>? questionsUsed,
    Expression<String>? notes,
    Expression<int>? retryCount,
    Expression<DateTime>? nextRetryAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (uploaded != null) 'uploaded': uploaded,
      if (analyzed != null) 'analyzed': analyzed,
      if (localVideoPath != null) 'local_video_path': localVideoPath,
      if (localAudioPath != null) 'local_audio_path': localAudioPath,
      if (questionsUsed != null) 'questions_used': questionsUsed,
      if (notes != null) 'notes': notes,
      if (retryCount != null) 'retry_count': retryCount,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMeasurementsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? recordedAt,
      Value<int>? durationSeconds,
      Value<bool>? uploaded,
      Value<bool>? analyzed,
      Value<String?>? localVideoPath,
      Value<String?>? localAudioPath,
      Value<String>? questionsUsed,
      Value<String?>? notes,
      Value<int>? retryCount,
      Value<DateTime?>? nextRetryAt,
      Value<int>? rowid}) {
    return LocalMeasurementsCompanion(
      id: id ?? this.id,
      recordedAt: recordedAt ?? this.recordedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      uploaded: uploaded ?? this.uploaded,
      analyzed: analyzed ?? this.analyzed,
      localVideoPath: localVideoPath ?? this.localVideoPath,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      questionsUsed: questionsUsed ?? this.questionsUsed,
      notes: notes ?? this.notes,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (uploaded.present) {
      map['uploaded'] = Variable<bool>(uploaded.value);
    }
    if (analyzed.present) {
      map['analyzed'] = Variable<bool>(analyzed.value);
    }
    if (localVideoPath.present) {
      map['local_video_path'] = Variable<String>(localVideoPath.value);
    }
    if (localAudioPath.present) {
      map['local_audio_path'] = Variable<String>(localAudioPath.value);
    }
    if (questionsUsed.present) {
      map['questions_used'] = Variable<String>(questionsUsed.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('uploaded: $uploaded, ')
          ..write('analyzed: $analyzed, ')
          ..write('localVideoPath: $localVideoPath, ')
          ..write('localAudioPath: $localAudioPath, ')
          ..write('questionsUsed: $questionsUsed, ')
          ..write('notes: $notes, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalScoresTable extends LocalScores
    with TableInfo<$LocalScoresTable, LocalScore> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalScoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _measurementIdMeta =
      const VerificationMeta('measurementId');
  @override
  late final GeneratedColumn<String> measurementId = GeneratedColumn<String>(
      'measurement_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _speechRateZscoreMeta =
      const VerificationMeta('speechRateZscore');
  @override
  late final GeneratedColumn<double> speechRateZscore = GeneratedColumn<double>(
      'speech_rate_zscore', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _pauseRatioZscoreMeta =
      const VerificationMeta('pauseRatioZscore');
  @override
  late final GeneratedColumn<double> pauseRatioZscore = GeneratedColumn<double>(
      'pause_ratio_zscore', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _voiceEnergyZscoreMeta =
      const VerificationMeta('voiceEnergyZscore');
  @override
  late final GeneratedColumn<double> voiceEnergyZscore =
      GeneratedColumn<double>('voice_energy_zscore', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _f0RangeZscoreMeta =
      const VerificationMeta('f0RangeZscore');
  @override
  late final GeneratedColumn<double> f0RangeZscore = GeneratedColumn<double>(
      'f0_range_zscore', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _responseLengthZscoreMeta =
      const VerificationMeta('responseLengthZscore');
  @override
  late final GeneratedColumn<double> responseLengthZscore =
      GeneratedColumn<double>('response_length_zscore', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _cohesionZscoreMeta =
      const VerificationMeta('cohesionZscore');
  @override
  late final GeneratedColumn<double> cohesionZscore = GeneratedColumn<double>(
      'cohesion_zscore', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _facialAffectZscoreMeta =
      const VerificationMeta('facialAffectZscore');
  @override
  late final GeneratedColumn<double> facialAffectZscore =
      GeneratedColumn<double>('facial_affect_zscore', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _compositeZscoreMeta =
      const VerificationMeta('compositeZscore');
  @override
  late final GeneratedColumn<double> compositeZscore = GeneratedColumn<double>(
      'composite_zscore', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _flagsMeta = const VerificationMeta('flags');
  @override
  late final GeneratedColumn<String> flags = GeneratedColumn<String>(
      'flags', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _trend7dMeta =
      const VerificationMeta('trend7d');
  @override
  late final GeneratedColumn<String> trend7d = GeneratedColumn<String>(
      'trend7d', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _baselineMeanMeta =
      const VerificationMeta('baselineMean');
  @override
  late final GeneratedColumn<double> baselineMean = GeneratedColumn<double>(
      'baseline_mean', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _baselineStdMeta =
      const VerificationMeta('baselineStd');
  @override
  late final GeneratedColumn<double> baselineStd = GeneratedColumn<double>(
      'baseline_std', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _baselineNMeta =
      const VerificationMeta('baselineN');
  @override
  late final GeneratedColumn<int> baselineN = GeneratedColumn<int>(
      'baseline_n', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _perQuestionMeta =
      const VerificationMeta('perQuestion');
  @override
  late final GeneratedColumn<String> perQuestion = GeneratedColumn<String>(
      'per_question', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _energyProfileMeta =
      const VerificationMeta('energyProfile');
  @override
  late final GeneratedColumn<String> energyProfile = GeneratedColumn<String>(
      'energy_profile', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _analyzedAtMeta =
      const VerificationMeta('analyzedAt');
  @override
  late final GeneratedColumn<DateTime> analyzedAt = GeneratedColumn<DateTime>(
      'analyzed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        measurementId,
        speechRateZscore,
        pauseRatioZscore,
        voiceEnergyZscore,
        f0RangeZscore,
        responseLengthZscore,
        cohesionZscore,
        facialAffectZscore,
        compositeZscore,
        flags,
        trend7d,
        baselineMean,
        baselineStd,
        baselineN,
        perQuestion,
        energyProfile,
        analyzedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_scores';
  @override
  VerificationContext validateIntegrity(Insertable<LocalScore> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('measurement_id')) {
      context.handle(
          _measurementIdMeta,
          measurementId.isAcceptableOrUnknown(
              data['measurement_id']!, _measurementIdMeta));
    } else if (isInserting) {
      context.missing(_measurementIdMeta);
    }
    if (data.containsKey('speech_rate_zscore')) {
      context.handle(
          _speechRateZscoreMeta,
          speechRateZscore.isAcceptableOrUnknown(
              data['speech_rate_zscore']!, _speechRateZscoreMeta));
    }
    if (data.containsKey('pause_ratio_zscore')) {
      context.handle(
          _pauseRatioZscoreMeta,
          pauseRatioZscore.isAcceptableOrUnknown(
              data['pause_ratio_zscore']!, _pauseRatioZscoreMeta));
    }
    if (data.containsKey('voice_energy_zscore')) {
      context.handle(
          _voiceEnergyZscoreMeta,
          voiceEnergyZscore.isAcceptableOrUnknown(
              data['voice_energy_zscore']!, _voiceEnergyZscoreMeta));
    }
    if (data.containsKey('f0_range_zscore')) {
      context.handle(
          _f0RangeZscoreMeta,
          f0RangeZscore.isAcceptableOrUnknown(
              data['f0_range_zscore']!, _f0RangeZscoreMeta));
    }
    if (data.containsKey('response_length_zscore')) {
      context.handle(
          _responseLengthZscoreMeta,
          responseLengthZscore.isAcceptableOrUnknown(
              data['response_length_zscore']!, _responseLengthZscoreMeta));
    }
    if (data.containsKey('cohesion_zscore')) {
      context.handle(
          _cohesionZscoreMeta,
          cohesionZscore.isAcceptableOrUnknown(
              data['cohesion_zscore']!, _cohesionZscoreMeta));
    }
    if (data.containsKey('facial_affect_zscore')) {
      context.handle(
          _facialAffectZscoreMeta,
          facialAffectZscore.isAcceptableOrUnknown(
              data['facial_affect_zscore']!, _facialAffectZscoreMeta));
    }
    if (data.containsKey('composite_zscore')) {
      context.handle(
          _compositeZscoreMeta,
          compositeZscore.isAcceptableOrUnknown(
              data['composite_zscore']!, _compositeZscoreMeta));
    }
    if (data.containsKey('flags')) {
      context.handle(
          _flagsMeta, flags.isAcceptableOrUnknown(data['flags']!, _flagsMeta));
    }
    if (data.containsKey('trend7d')) {
      context.handle(_trend7dMeta,
          trend7d.isAcceptableOrUnknown(data['trend7d']!, _trend7dMeta));
    }
    if (data.containsKey('baseline_mean')) {
      context.handle(
          _baselineMeanMeta,
          baselineMean.isAcceptableOrUnknown(
              data['baseline_mean']!, _baselineMeanMeta));
    }
    if (data.containsKey('baseline_std')) {
      context.handle(
          _baselineStdMeta,
          baselineStd.isAcceptableOrUnknown(
              data['baseline_std']!, _baselineStdMeta));
    }
    if (data.containsKey('baseline_n')) {
      context.handle(_baselineNMeta,
          baselineN.isAcceptableOrUnknown(data['baseline_n']!, _baselineNMeta));
    }
    if (data.containsKey('per_question')) {
      context.handle(
          _perQuestionMeta,
          perQuestion.isAcceptableOrUnknown(
              data['per_question']!, _perQuestionMeta));
    }
    if (data.containsKey('energy_profile')) {
      context.handle(
          _energyProfileMeta,
          energyProfile.isAcceptableOrUnknown(
              data['energy_profile']!, _energyProfileMeta));
    }
    if (data.containsKey('analyzed_at')) {
      context.handle(
          _analyzedAtMeta,
          analyzedAt.isAcceptableOrUnknown(
              data['analyzed_at']!, _analyzedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {measurementId};
  @override
  LocalScore map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalScore(
      measurementId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}measurement_id'])!,
      speechRateZscore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}speech_rate_zscore']),
      pauseRatioZscore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}pause_ratio_zscore']),
      voiceEnergyZscore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}voice_energy_zscore']),
      f0RangeZscore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}f0_range_zscore']),
      responseLengthZscore: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}response_length_zscore']),
      cohesionZscore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cohesion_zscore']),
      facialAffectZscore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}facial_affect_zscore']),
      compositeZscore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}composite_zscore']),
      flags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}flags']),
      trend7d: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trend7d']),
      baselineMean: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}baseline_mean']),
      baselineStd: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}baseline_std']),
      baselineN: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}baseline_n']),
      perQuestion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}per_question']),
      energyProfile: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}energy_profile']),
      analyzedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}analyzed_at']),
    );
  }

  @override
  $LocalScoresTable createAlias(String alias) {
    return $LocalScoresTable(attachedDatabase, alias);
  }
}

class LocalScore extends DataClass implements Insertable<LocalScore> {
  final String measurementId;
  final double? speechRateZscore;
  final double? pauseRatioZscore;
  final double? voiceEnergyZscore;
  final double? f0RangeZscore;
  final double? responseLengthZscore;
  final double? cohesionZscore;
  final double? facialAffectZscore;
  final double? compositeZscore;
  final String? flags;
  final String? trend7d;
  final double? baselineMean;
  final double? baselineStd;
  final int? baselineN;
  final String? perQuestion;
  final String? energyProfile;
  final DateTime? analyzedAt;
  const LocalScore(
      {required this.measurementId,
      this.speechRateZscore,
      this.pauseRatioZscore,
      this.voiceEnergyZscore,
      this.f0RangeZscore,
      this.responseLengthZscore,
      this.cohesionZscore,
      this.facialAffectZscore,
      this.compositeZscore,
      this.flags,
      this.trend7d,
      this.baselineMean,
      this.baselineStd,
      this.baselineN,
      this.perQuestion,
      this.energyProfile,
      this.analyzedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['measurement_id'] = Variable<String>(measurementId);
    if (!nullToAbsent || speechRateZscore != null) {
      map['speech_rate_zscore'] = Variable<double>(speechRateZscore);
    }
    if (!nullToAbsent || pauseRatioZscore != null) {
      map['pause_ratio_zscore'] = Variable<double>(pauseRatioZscore);
    }
    if (!nullToAbsent || voiceEnergyZscore != null) {
      map['voice_energy_zscore'] = Variable<double>(voiceEnergyZscore);
    }
    if (!nullToAbsent || f0RangeZscore != null) {
      map['f0_range_zscore'] = Variable<double>(f0RangeZscore);
    }
    if (!nullToAbsent || responseLengthZscore != null) {
      map['response_length_zscore'] = Variable<double>(responseLengthZscore);
    }
    if (!nullToAbsent || cohesionZscore != null) {
      map['cohesion_zscore'] = Variable<double>(cohesionZscore);
    }
    if (!nullToAbsent || facialAffectZscore != null) {
      map['facial_affect_zscore'] = Variable<double>(facialAffectZscore);
    }
    if (!nullToAbsent || compositeZscore != null) {
      map['composite_zscore'] = Variable<double>(compositeZscore);
    }
    if (!nullToAbsent || flags != null) {
      map['flags'] = Variable<String>(flags);
    }
    if (!nullToAbsent || trend7d != null) {
      map['trend7d'] = Variable<String>(trend7d);
    }
    if (!nullToAbsent || baselineMean != null) {
      map['baseline_mean'] = Variable<double>(baselineMean);
    }
    if (!nullToAbsent || baselineStd != null) {
      map['baseline_std'] = Variable<double>(baselineStd);
    }
    if (!nullToAbsent || baselineN != null) {
      map['baseline_n'] = Variable<int>(baselineN);
    }
    if (!nullToAbsent || perQuestion != null) {
      map['per_question'] = Variable<String>(perQuestion);
    }
    if (!nullToAbsent || energyProfile != null) {
      map['energy_profile'] = Variable<String>(energyProfile);
    }
    if (!nullToAbsent || analyzedAt != null) {
      map['analyzed_at'] = Variable<DateTime>(analyzedAt);
    }
    return map;
  }

  LocalScoresCompanion toCompanion(bool nullToAbsent) {
    return LocalScoresCompanion(
      measurementId: Value(measurementId),
      speechRateZscore: speechRateZscore == null && nullToAbsent
          ? const Value.absent()
          : Value(speechRateZscore),
      pauseRatioZscore: pauseRatioZscore == null && nullToAbsent
          ? const Value.absent()
          : Value(pauseRatioZscore),
      voiceEnergyZscore: voiceEnergyZscore == null && nullToAbsent
          ? const Value.absent()
          : Value(voiceEnergyZscore),
      f0RangeZscore: f0RangeZscore == null && nullToAbsent
          ? const Value.absent()
          : Value(f0RangeZscore),
      responseLengthZscore: responseLengthZscore == null && nullToAbsent
          ? const Value.absent()
          : Value(responseLengthZscore),
      cohesionZscore: cohesionZscore == null && nullToAbsent
          ? const Value.absent()
          : Value(cohesionZscore),
      facialAffectZscore: facialAffectZscore == null && nullToAbsent
          ? const Value.absent()
          : Value(facialAffectZscore),
      compositeZscore: compositeZscore == null && nullToAbsent
          ? const Value.absent()
          : Value(compositeZscore),
      flags:
          flags == null && nullToAbsent ? const Value.absent() : Value(flags),
      trend7d: trend7d == null && nullToAbsent
          ? const Value.absent()
          : Value(trend7d),
      baselineMean: baselineMean == null && nullToAbsent
          ? const Value.absent()
          : Value(baselineMean),
      baselineStd: baselineStd == null && nullToAbsent
          ? const Value.absent()
          : Value(baselineStd),
      baselineN: baselineN == null && nullToAbsent
          ? const Value.absent()
          : Value(baselineN),
      perQuestion: perQuestion == null && nullToAbsent
          ? const Value.absent()
          : Value(perQuestion),
      energyProfile: energyProfile == null && nullToAbsent
          ? const Value.absent()
          : Value(energyProfile),
      analyzedAt: analyzedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(analyzedAt),
    );
  }

  factory LocalScore.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalScore(
      measurementId: serializer.fromJson<String>(json['measurementId']),
      speechRateZscore: serializer.fromJson<double?>(json['speechRateZscore']),
      pauseRatioZscore: serializer.fromJson<double?>(json['pauseRatioZscore']),
      voiceEnergyZscore:
          serializer.fromJson<double?>(json['voiceEnergyZscore']),
      f0RangeZscore: serializer.fromJson<double?>(json['f0RangeZscore']),
      responseLengthZscore:
          serializer.fromJson<double?>(json['responseLengthZscore']),
      cohesionZscore: serializer.fromJson<double?>(json['cohesionZscore']),
      facialAffectZscore:
          serializer.fromJson<double?>(json['facialAffectZscore']),
      compositeZscore: serializer.fromJson<double?>(json['compositeZscore']),
      flags: serializer.fromJson<String?>(json['flags']),
      trend7d: serializer.fromJson<String?>(json['trend7d']),
      baselineMean: serializer.fromJson<double?>(json['baselineMean']),
      baselineStd: serializer.fromJson<double?>(json['baselineStd']),
      baselineN: serializer.fromJson<int?>(json['baselineN']),
      perQuestion: serializer.fromJson<String?>(json['perQuestion']),
      energyProfile: serializer.fromJson<String?>(json['energyProfile']),
      analyzedAt: serializer.fromJson<DateTime?>(json['analyzedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'measurementId': serializer.toJson<String>(measurementId),
      'speechRateZscore': serializer.toJson<double?>(speechRateZscore),
      'pauseRatioZscore': serializer.toJson<double?>(pauseRatioZscore),
      'voiceEnergyZscore': serializer.toJson<double?>(voiceEnergyZscore),
      'f0RangeZscore': serializer.toJson<double?>(f0RangeZscore),
      'responseLengthZscore': serializer.toJson<double?>(responseLengthZscore),
      'cohesionZscore': serializer.toJson<double?>(cohesionZscore),
      'facialAffectZscore': serializer.toJson<double?>(facialAffectZscore),
      'compositeZscore': serializer.toJson<double?>(compositeZscore),
      'flags': serializer.toJson<String?>(flags),
      'trend7d': serializer.toJson<String?>(trend7d),
      'baselineMean': serializer.toJson<double?>(baselineMean),
      'baselineStd': serializer.toJson<double?>(baselineStd),
      'baselineN': serializer.toJson<int?>(baselineN),
      'perQuestion': serializer.toJson<String?>(perQuestion),
      'energyProfile': serializer.toJson<String?>(energyProfile),
      'analyzedAt': serializer.toJson<DateTime?>(analyzedAt),
    };
  }

  LocalScore copyWith(
          {String? measurementId,
          Value<double?> speechRateZscore = const Value.absent(),
          Value<double?> pauseRatioZscore = const Value.absent(),
          Value<double?> voiceEnergyZscore = const Value.absent(),
          Value<double?> f0RangeZscore = const Value.absent(),
          Value<double?> responseLengthZscore = const Value.absent(),
          Value<double?> cohesionZscore = const Value.absent(),
          Value<double?> facialAffectZscore = const Value.absent(),
          Value<double?> compositeZscore = const Value.absent(),
          Value<String?> flags = const Value.absent(),
          Value<String?> trend7d = const Value.absent(),
          Value<double?> baselineMean = const Value.absent(),
          Value<double?> baselineStd = const Value.absent(),
          Value<int?> baselineN = const Value.absent(),
          Value<String?> perQuestion = const Value.absent(),
          Value<String?> energyProfile = const Value.absent(),
          Value<DateTime?> analyzedAt = const Value.absent()}) =>
      LocalScore(
        measurementId: measurementId ?? this.measurementId,
        speechRateZscore: speechRateZscore.present
            ? speechRateZscore.value
            : this.speechRateZscore,
        pauseRatioZscore: pauseRatioZscore.present
            ? pauseRatioZscore.value
            : this.pauseRatioZscore,
        voiceEnergyZscore: voiceEnergyZscore.present
            ? voiceEnergyZscore.value
            : this.voiceEnergyZscore,
        f0RangeZscore:
            f0RangeZscore.present ? f0RangeZscore.value : this.f0RangeZscore,
        responseLengthZscore: responseLengthZscore.present
            ? responseLengthZscore.value
            : this.responseLengthZscore,
        cohesionZscore:
            cohesionZscore.present ? cohesionZscore.value : this.cohesionZscore,
        facialAffectZscore: facialAffectZscore.present
            ? facialAffectZscore.value
            : this.facialAffectZscore,
        compositeZscore: compositeZscore.present
            ? compositeZscore.value
            : this.compositeZscore,
        flags: flags.present ? flags.value : this.flags,
        trend7d: trend7d.present ? trend7d.value : this.trend7d,
        baselineMean:
            baselineMean.present ? baselineMean.value : this.baselineMean,
        baselineStd: baselineStd.present ? baselineStd.value : this.baselineStd,
        baselineN: baselineN.present ? baselineN.value : this.baselineN,
        perQuestion: perQuestion.present ? perQuestion.value : this.perQuestion,
        energyProfile:
            energyProfile.present ? energyProfile.value : this.energyProfile,
        analyzedAt: analyzedAt.present ? analyzedAt.value : this.analyzedAt,
      );
  LocalScore copyWithCompanion(LocalScoresCompanion data) {
    return LocalScore(
      measurementId: data.measurementId.present
          ? data.measurementId.value
          : this.measurementId,
      speechRateZscore: data.speechRateZscore.present
          ? data.speechRateZscore.value
          : this.speechRateZscore,
      pauseRatioZscore: data.pauseRatioZscore.present
          ? data.pauseRatioZscore.value
          : this.pauseRatioZscore,
      voiceEnergyZscore: data.voiceEnergyZscore.present
          ? data.voiceEnergyZscore.value
          : this.voiceEnergyZscore,
      f0RangeZscore: data.f0RangeZscore.present
          ? data.f0RangeZscore.value
          : this.f0RangeZscore,
      responseLengthZscore: data.responseLengthZscore.present
          ? data.responseLengthZscore.value
          : this.responseLengthZscore,
      cohesionZscore: data.cohesionZscore.present
          ? data.cohesionZscore.value
          : this.cohesionZscore,
      facialAffectZscore: data.facialAffectZscore.present
          ? data.facialAffectZscore.value
          : this.facialAffectZscore,
      compositeZscore: data.compositeZscore.present
          ? data.compositeZscore.value
          : this.compositeZscore,
      flags: data.flags.present ? data.flags.value : this.flags,
      trend7d: data.trend7d.present ? data.trend7d.value : this.trend7d,
      baselineMean: data.baselineMean.present
          ? data.baselineMean.value
          : this.baselineMean,
      baselineStd:
          data.baselineStd.present ? data.baselineStd.value : this.baselineStd,
      baselineN: data.baselineN.present ? data.baselineN.value : this.baselineN,
      perQuestion:
          data.perQuestion.present ? data.perQuestion.value : this.perQuestion,
      energyProfile: data.energyProfile.present
          ? data.energyProfile.value
          : this.energyProfile,
      analyzedAt:
          data.analyzedAt.present ? data.analyzedAt.value : this.analyzedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalScore(')
          ..write('measurementId: $measurementId, ')
          ..write('speechRateZscore: $speechRateZscore, ')
          ..write('pauseRatioZscore: $pauseRatioZscore, ')
          ..write('voiceEnergyZscore: $voiceEnergyZscore, ')
          ..write('f0RangeZscore: $f0RangeZscore, ')
          ..write('responseLengthZscore: $responseLengthZscore, ')
          ..write('cohesionZscore: $cohesionZscore, ')
          ..write('facialAffectZscore: $facialAffectZscore, ')
          ..write('compositeZscore: $compositeZscore, ')
          ..write('flags: $flags, ')
          ..write('trend7d: $trend7d, ')
          ..write('baselineMean: $baselineMean, ')
          ..write('baselineStd: $baselineStd, ')
          ..write('baselineN: $baselineN, ')
          ..write('perQuestion: $perQuestion, ')
          ..write('energyProfile: $energyProfile, ')
          ..write('analyzedAt: $analyzedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      measurementId,
      speechRateZscore,
      pauseRatioZscore,
      voiceEnergyZscore,
      f0RangeZscore,
      responseLengthZscore,
      cohesionZscore,
      facialAffectZscore,
      compositeZscore,
      flags,
      trend7d,
      baselineMean,
      baselineStd,
      baselineN,
      perQuestion,
      energyProfile,
      analyzedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalScore &&
          other.measurementId == this.measurementId &&
          other.speechRateZscore == this.speechRateZscore &&
          other.pauseRatioZscore == this.pauseRatioZscore &&
          other.voiceEnergyZscore == this.voiceEnergyZscore &&
          other.f0RangeZscore == this.f0RangeZscore &&
          other.responseLengthZscore == this.responseLengthZscore &&
          other.cohesionZscore == this.cohesionZscore &&
          other.facialAffectZscore == this.facialAffectZscore &&
          other.compositeZscore == this.compositeZscore &&
          other.flags == this.flags &&
          other.trend7d == this.trend7d &&
          other.baselineMean == this.baselineMean &&
          other.baselineStd == this.baselineStd &&
          other.baselineN == this.baselineN &&
          other.perQuestion == this.perQuestion &&
          other.energyProfile == this.energyProfile &&
          other.analyzedAt == this.analyzedAt);
}

class LocalScoresCompanion extends UpdateCompanion<LocalScore> {
  final Value<String> measurementId;
  final Value<double?> speechRateZscore;
  final Value<double?> pauseRatioZscore;
  final Value<double?> voiceEnergyZscore;
  final Value<double?> f0RangeZscore;
  final Value<double?> responseLengthZscore;
  final Value<double?> cohesionZscore;
  final Value<double?> facialAffectZscore;
  final Value<double?> compositeZscore;
  final Value<String?> flags;
  final Value<String?> trend7d;
  final Value<double?> baselineMean;
  final Value<double?> baselineStd;
  final Value<int?> baselineN;
  final Value<String?> perQuestion;
  final Value<String?> energyProfile;
  final Value<DateTime?> analyzedAt;
  final Value<int> rowid;
  const LocalScoresCompanion({
    this.measurementId = const Value.absent(),
    this.speechRateZscore = const Value.absent(),
    this.pauseRatioZscore = const Value.absent(),
    this.voiceEnergyZscore = const Value.absent(),
    this.f0RangeZscore = const Value.absent(),
    this.responseLengthZscore = const Value.absent(),
    this.cohesionZscore = const Value.absent(),
    this.facialAffectZscore = const Value.absent(),
    this.compositeZscore = const Value.absent(),
    this.flags = const Value.absent(),
    this.trend7d = const Value.absent(),
    this.baselineMean = const Value.absent(),
    this.baselineStd = const Value.absent(),
    this.baselineN = const Value.absent(),
    this.perQuestion = const Value.absent(),
    this.energyProfile = const Value.absent(),
    this.analyzedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalScoresCompanion.insert({
    required String measurementId,
    this.speechRateZscore = const Value.absent(),
    this.pauseRatioZscore = const Value.absent(),
    this.voiceEnergyZscore = const Value.absent(),
    this.f0RangeZscore = const Value.absent(),
    this.responseLengthZscore = const Value.absent(),
    this.cohesionZscore = const Value.absent(),
    this.facialAffectZscore = const Value.absent(),
    this.compositeZscore = const Value.absent(),
    this.flags = const Value.absent(),
    this.trend7d = const Value.absent(),
    this.baselineMean = const Value.absent(),
    this.baselineStd = const Value.absent(),
    this.baselineN = const Value.absent(),
    this.perQuestion = const Value.absent(),
    this.energyProfile = const Value.absent(),
    this.analyzedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : measurementId = Value(measurementId);
  static Insertable<LocalScore> custom({
    Expression<String>? measurementId,
    Expression<double>? speechRateZscore,
    Expression<double>? pauseRatioZscore,
    Expression<double>? voiceEnergyZscore,
    Expression<double>? f0RangeZscore,
    Expression<double>? responseLengthZscore,
    Expression<double>? cohesionZscore,
    Expression<double>? facialAffectZscore,
    Expression<double>? compositeZscore,
    Expression<String>? flags,
    Expression<String>? trend7d,
    Expression<double>? baselineMean,
    Expression<double>? baselineStd,
    Expression<int>? baselineN,
    Expression<String>? perQuestion,
    Expression<String>? energyProfile,
    Expression<DateTime>? analyzedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (measurementId != null) 'measurement_id': measurementId,
      if (speechRateZscore != null) 'speech_rate_zscore': speechRateZscore,
      if (pauseRatioZscore != null) 'pause_ratio_zscore': pauseRatioZscore,
      if (voiceEnergyZscore != null) 'voice_energy_zscore': voiceEnergyZscore,
      if (f0RangeZscore != null) 'f0_range_zscore': f0RangeZscore,
      if (responseLengthZscore != null)
        'response_length_zscore': responseLengthZscore,
      if (cohesionZscore != null) 'cohesion_zscore': cohesionZscore,
      if (facialAffectZscore != null)
        'facial_affect_zscore': facialAffectZscore,
      if (compositeZscore != null) 'composite_zscore': compositeZscore,
      if (flags != null) 'flags': flags,
      if (trend7d != null) 'trend7d': trend7d,
      if (baselineMean != null) 'baseline_mean': baselineMean,
      if (baselineStd != null) 'baseline_std': baselineStd,
      if (baselineN != null) 'baseline_n': baselineN,
      if (perQuestion != null) 'per_question': perQuestion,
      if (energyProfile != null) 'energy_profile': energyProfile,
      if (analyzedAt != null) 'analyzed_at': analyzedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalScoresCompanion copyWith(
      {Value<String>? measurementId,
      Value<double?>? speechRateZscore,
      Value<double?>? pauseRatioZscore,
      Value<double?>? voiceEnergyZscore,
      Value<double?>? f0RangeZscore,
      Value<double?>? responseLengthZscore,
      Value<double?>? cohesionZscore,
      Value<double?>? facialAffectZscore,
      Value<double?>? compositeZscore,
      Value<String?>? flags,
      Value<String?>? trend7d,
      Value<double?>? baselineMean,
      Value<double?>? baselineStd,
      Value<int?>? baselineN,
      Value<String?>? perQuestion,
      Value<String?>? energyProfile,
      Value<DateTime?>? analyzedAt,
      Value<int>? rowid}) {
    return LocalScoresCompanion(
      measurementId: measurementId ?? this.measurementId,
      speechRateZscore: speechRateZscore ?? this.speechRateZscore,
      pauseRatioZscore: pauseRatioZscore ?? this.pauseRatioZscore,
      voiceEnergyZscore: voiceEnergyZscore ?? this.voiceEnergyZscore,
      f0RangeZscore: f0RangeZscore ?? this.f0RangeZscore,
      responseLengthZscore: responseLengthZscore ?? this.responseLengthZscore,
      cohesionZscore: cohesionZscore ?? this.cohesionZscore,
      facialAffectZscore: facialAffectZscore ?? this.facialAffectZscore,
      compositeZscore: compositeZscore ?? this.compositeZscore,
      flags: flags ?? this.flags,
      trend7d: trend7d ?? this.trend7d,
      baselineMean: baselineMean ?? this.baselineMean,
      baselineStd: baselineStd ?? this.baselineStd,
      baselineN: baselineN ?? this.baselineN,
      perQuestion: perQuestion ?? this.perQuestion,
      energyProfile: energyProfile ?? this.energyProfile,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (measurementId.present) {
      map['measurement_id'] = Variable<String>(measurementId.value);
    }
    if (speechRateZscore.present) {
      map['speech_rate_zscore'] = Variable<double>(speechRateZscore.value);
    }
    if (pauseRatioZscore.present) {
      map['pause_ratio_zscore'] = Variable<double>(pauseRatioZscore.value);
    }
    if (voiceEnergyZscore.present) {
      map['voice_energy_zscore'] = Variable<double>(voiceEnergyZscore.value);
    }
    if (f0RangeZscore.present) {
      map['f0_range_zscore'] = Variable<double>(f0RangeZscore.value);
    }
    if (responseLengthZscore.present) {
      map['response_length_zscore'] =
          Variable<double>(responseLengthZscore.value);
    }
    if (cohesionZscore.present) {
      map['cohesion_zscore'] = Variable<double>(cohesionZscore.value);
    }
    if (facialAffectZscore.present) {
      map['facial_affect_zscore'] = Variable<double>(facialAffectZscore.value);
    }
    if (compositeZscore.present) {
      map['composite_zscore'] = Variable<double>(compositeZscore.value);
    }
    if (flags.present) {
      map['flags'] = Variable<String>(flags.value);
    }
    if (trend7d.present) {
      map['trend7d'] = Variable<String>(trend7d.value);
    }
    if (baselineMean.present) {
      map['baseline_mean'] = Variable<double>(baselineMean.value);
    }
    if (baselineStd.present) {
      map['baseline_std'] = Variable<double>(baselineStd.value);
    }
    if (baselineN.present) {
      map['baseline_n'] = Variable<int>(baselineN.value);
    }
    if (perQuestion.present) {
      map['per_question'] = Variable<String>(perQuestion.value);
    }
    if (energyProfile.present) {
      map['energy_profile'] = Variable<String>(energyProfile.value);
    }
    if (analyzedAt.present) {
      map['analyzed_at'] = Variable<DateTime>(analyzedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalScoresCompanion(')
          ..write('measurementId: $measurementId, ')
          ..write('speechRateZscore: $speechRateZscore, ')
          ..write('pauseRatioZscore: $pauseRatioZscore, ')
          ..write('voiceEnergyZscore: $voiceEnergyZscore, ')
          ..write('f0RangeZscore: $f0RangeZscore, ')
          ..write('responseLengthZscore: $responseLengthZscore, ')
          ..write('cohesionZscore: $cohesionZscore, ')
          ..write('facialAffectZscore: $facialAffectZscore, ')
          ..write('compositeZscore: $compositeZscore, ')
          ..write('flags: $flags, ')
          ..write('trend7d: $trend7d, ')
          ..write('baselineMean: $baselineMean, ')
          ..write('baselineStd: $baselineStd, ')
          ..write('baselineN: $baselineN, ')
          ..write('perQuestion: $perQuestion, ')
          ..write('energyProfile: $energyProfile, ')
          ..write('analyzedAt: $analyzedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalUserProfileTable extends LocalUserProfile
    with TableInfo<$LocalUserProfileTable, LocalUserProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUserProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hasSpeakerEmbeddingMeta =
      const VerificationMeta('hasSpeakerEmbedding');
  @override
  late final GeneratedColumn<bool> hasSpeakerEmbedding = GeneratedColumn<bool>(
      'has_speaker_embedding', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_speaker_embedding" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _totalMeasurementsMeta =
      const VerificationMeta('totalMeasurements');
  @override
  late final GeneratedColumn<int> totalMeasurements = GeneratedColumn<int>(
      'total_measurements', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _recordingDurationSecondsMeta =
      const VerificationMeta('recordingDurationSeconds');
  @override
  late final GeneratedColumn<int> recordingDurationSeconds =
      GeneratedColumn<int>('recording_duration_seconds', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultValue: const Constant(150));
  static const VerificationMeta _promptLanguageMeta =
      const VerificationMeta('promptLanguage');
  @override
  late final GeneratedColumn<String> promptLanguage = GeneratedColumn<String>(
      'prompt_language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('cs'));
  static const VerificationMeta _speakerVerificationEnabledMeta =
      const VerificationMeta('speakerVerificationEnabled');
  @override
  late final GeneratedColumn<bool> speakerVerificationEnabled =
      GeneratedColumn<bool>('speaker_verification_enabled', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("speaker_verification_enabled" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _dailyReminderEnabledMeta =
      const VerificationMeta('dailyReminderEnabled');
  @override
  late final GeneratedColumn<bool> dailyReminderEnabled = GeneratedColumn<bool>(
      'daily_reminder_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("daily_reminder_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _dailyReminderHourMeta =
      const VerificationMeta('dailyReminderHour');
  @override
  late final GeneratedColumn<int> dailyReminderHour = GeneratedColumn<int>(
      'daily_reminder_hour', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(9));
  static const VerificationMeta _dailyReminderMinuteMeta =
      const VerificationMeta('dailyReminderMinute');
  @override
  late final GeneratedColumn<int> dailyReminderMinute = GeneratedColumn<int>(
      'daily_reminder_minute', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _analysisNotificationsEnabledMeta =
      const VerificationMeta('analysisNotificationsEnabled');
  @override
  late final GeneratedColumn<bool> analysisNotificationsEnabled =
      GeneratedColumn<bool>(
          'analysis_notifications_enabled', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("analysis_notifications_enabled" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _onboardingCompleteMeta =
      const VerificationMeta('onboardingComplete');
  @override
  late final GeneratedColumn<bool> onboardingComplete = GeneratedColumn<bool>(
      'onboarding_complete', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("onboarding_complete" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        userId,
        displayName,
        email,
        hasSpeakerEmbedding,
        totalMeasurements,
        recordingDurationSeconds,
        promptLanguage,
        speakerVerificationEnabled,
        dailyReminderEnabled,
        dailyReminderHour,
        dailyReminderMinute,
        analysisNotificationsEnabled,
        onboardingComplete
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_user_profile';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalUserProfileData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('has_speaker_embedding')) {
      context.handle(
          _hasSpeakerEmbeddingMeta,
          hasSpeakerEmbedding.isAcceptableOrUnknown(
              data['has_speaker_embedding']!, _hasSpeakerEmbeddingMeta));
    }
    if (data.containsKey('total_measurements')) {
      context.handle(
          _totalMeasurementsMeta,
          totalMeasurements.isAcceptableOrUnknown(
              data['total_measurements']!, _totalMeasurementsMeta));
    }
    if (data.containsKey('recording_duration_seconds')) {
      context.handle(
          _recordingDurationSecondsMeta,
          recordingDurationSeconds.isAcceptableOrUnknown(
              data['recording_duration_seconds']!,
              _recordingDurationSecondsMeta));
    }
    if (data.containsKey('prompt_language')) {
      context.handle(
          _promptLanguageMeta,
          promptLanguage.isAcceptableOrUnknown(
              data['prompt_language']!, _promptLanguageMeta));
    }
    if (data.containsKey('speaker_verification_enabled')) {
      context.handle(
          _speakerVerificationEnabledMeta,
          speakerVerificationEnabled.isAcceptableOrUnknown(
              data['speaker_verification_enabled']!,
              _speakerVerificationEnabledMeta));
    }
    if (data.containsKey('daily_reminder_enabled')) {
      context.handle(
          _dailyReminderEnabledMeta,
          dailyReminderEnabled.isAcceptableOrUnknown(
              data['daily_reminder_enabled']!, _dailyReminderEnabledMeta));
    }
    if (data.containsKey('daily_reminder_hour')) {
      context.handle(
          _dailyReminderHourMeta,
          dailyReminderHour.isAcceptableOrUnknown(
              data['daily_reminder_hour']!, _dailyReminderHourMeta));
    }
    if (data.containsKey('daily_reminder_minute')) {
      context.handle(
          _dailyReminderMinuteMeta,
          dailyReminderMinute.isAcceptableOrUnknown(
              data['daily_reminder_minute']!, _dailyReminderMinuteMeta));
    }
    if (data.containsKey('analysis_notifications_enabled')) {
      context.handle(
          _analysisNotificationsEnabledMeta,
          analysisNotificationsEnabled.isAcceptableOrUnknown(
              data['analysis_notifications_enabled']!,
              _analysisNotificationsEnabledMeta));
    }
    if (data.containsKey('onboarding_complete')) {
      context.handle(
          _onboardingCompleteMeta,
          onboardingComplete.isAcceptableOrUnknown(
              data['onboarding_complete']!, _onboardingCompleteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  LocalUserProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUserProfileData(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      hasSpeakerEmbedding: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}has_speaker_embedding'])!,
      totalMeasurements: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}total_measurements'])!,
      recordingDurationSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}recording_duration_seconds'])!,
      promptLanguage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}prompt_language'])!,
      speakerVerificationEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}speaker_verification_enabled'])!,
      dailyReminderEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}daily_reminder_enabled'])!,
      dailyReminderHour: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}daily_reminder_hour'])!,
      dailyReminderMinute: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}daily_reminder_minute'])!,
      analysisNotificationsEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}analysis_notifications_enabled'])!,
      onboardingComplete: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}onboarding_complete'])!,
    );
  }

  @override
  $LocalUserProfileTable createAlias(String alias) {
    return $LocalUserProfileTable(attachedDatabase, alias);
  }
}

class LocalUserProfileData extends DataClass
    implements Insertable<LocalUserProfileData> {
  final String userId;
  final String displayName;
  final String email;
  final bool hasSpeakerEmbedding;
  final int totalMeasurements;
  final int recordingDurationSeconds;
  final String promptLanguage;
  final bool speakerVerificationEnabled;
  final bool dailyReminderEnabled;
  final int dailyReminderHour;
  final int dailyReminderMinute;
  final bool analysisNotificationsEnabled;
  final bool onboardingComplete;
  const LocalUserProfileData(
      {required this.userId,
      required this.displayName,
      required this.email,
      required this.hasSpeakerEmbedding,
      required this.totalMeasurements,
      required this.recordingDurationSeconds,
      required this.promptLanguage,
      required this.speakerVerificationEnabled,
      required this.dailyReminderEnabled,
      required this.dailyReminderHour,
      required this.dailyReminderMinute,
      required this.analysisNotificationsEnabled,
      required this.onboardingComplete});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['display_name'] = Variable<String>(displayName);
    map['email'] = Variable<String>(email);
    map['has_speaker_embedding'] = Variable<bool>(hasSpeakerEmbedding);
    map['total_measurements'] = Variable<int>(totalMeasurements);
    map['recording_duration_seconds'] = Variable<int>(recordingDurationSeconds);
    map['prompt_language'] = Variable<String>(promptLanguage);
    map['speaker_verification_enabled'] =
        Variable<bool>(speakerVerificationEnabled);
    map['daily_reminder_enabled'] = Variable<bool>(dailyReminderEnabled);
    map['daily_reminder_hour'] = Variable<int>(dailyReminderHour);
    map['daily_reminder_minute'] = Variable<int>(dailyReminderMinute);
    map['analysis_notifications_enabled'] =
        Variable<bool>(analysisNotificationsEnabled);
    map['onboarding_complete'] = Variable<bool>(onboardingComplete);
    return map;
  }

  LocalUserProfileCompanion toCompanion(bool nullToAbsent) {
    return LocalUserProfileCompanion(
      userId: Value(userId),
      displayName: Value(displayName),
      email: Value(email),
      hasSpeakerEmbedding: Value(hasSpeakerEmbedding),
      totalMeasurements: Value(totalMeasurements),
      recordingDurationSeconds: Value(recordingDurationSeconds),
      promptLanguage: Value(promptLanguage),
      speakerVerificationEnabled: Value(speakerVerificationEnabled),
      dailyReminderEnabled: Value(dailyReminderEnabled),
      dailyReminderHour: Value(dailyReminderHour),
      dailyReminderMinute: Value(dailyReminderMinute),
      analysisNotificationsEnabled: Value(analysisNotificationsEnabled),
      onboardingComplete: Value(onboardingComplete),
    );
  }

  factory LocalUserProfileData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUserProfileData(
      userId: serializer.fromJson<String>(json['userId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      email: serializer.fromJson<String>(json['email']),
      hasSpeakerEmbedding:
          serializer.fromJson<bool>(json['hasSpeakerEmbedding']),
      totalMeasurements: serializer.fromJson<int>(json['totalMeasurements']),
      recordingDurationSeconds:
          serializer.fromJson<int>(json['recordingDurationSeconds']),
      promptLanguage: serializer.fromJson<String>(json['promptLanguage']),
      speakerVerificationEnabled:
          serializer.fromJson<bool>(json['speakerVerificationEnabled']),
      dailyReminderEnabled:
          serializer.fromJson<bool>(json['dailyReminderEnabled']),
      dailyReminderHour: serializer.fromJson<int>(json['dailyReminderHour']),
      dailyReminderMinute:
          serializer.fromJson<int>(json['dailyReminderMinute']),
      analysisNotificationsEnabled:
          serializer.fromJson<bool>(json['analysisNotificationsEnabled']),
      onboardingComplete: serializer.fromJson<bool>(json['onboardingComplete']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'displayName': serializer.toJson<String>(displayName),
      'email': serializer.toJson<String>(email),
      'hasSpeakerEmbedding': serializer.toJson<bool>(hasSpeakerEmbedding),
      'totalMeasurements': serializer.toJson<int>(totalMeasurements),
      'recordingDurationSeconds':
          serializer.toJson<int>(recordingDurationSeconds),
      'promptLanguage': serializer.toJson<String>(promptLanguage),
      'speakerVerificationEnabled':
          serializer.toJson<bool>(speakerVerificationEnabled),
      'dailyReminderEnabled': serializer.toJson<bool>(dailyReminderEnabled),
      'dailyReminderHour': serializer.toJson<int>(dailyReminderHour),
      'dailyReminderMinute': serializer.toJson<int>(dailyReminderMinute),
      'analysisNotificationsEnabled':
          serializer.toJson<bool>(analysisNotificationsEnabled),
      'onboardingComplete': serializer.toJson<bool>(onboardingComplete),
    };
  }

  LocalUserProfileData copyWith(
          {String? userId,
          String? displayName,
          String? email,
          bool? hasSpeakerEmbedding,
          int? totalMeasurements,
          int? recordingDurationSeconds,
          String? promptLanguage,
          bool? speakerVerificationEnabled,
          bool? dailyReminderEnabled,
          int? dailyReminderHour,
          int? dailyReminderMinute,
          bool? analysisNotificationsEnabled,
          bool? onboardingComplete}) =>
      LocalUserProfileData(
        userId: userId ?? this.userId,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        hasSpeakerEmbedding: hasSpeakerEmbedding ?? this.hasSpeakerEmbedding,
        totalMeasurements: totalMeasurements ?? this.totalMeasurements,
        recordingDurationSeconds:
            recordingDurationSeconds ?? this.recordingDurationSeconds,
        promptLanguage: promptLanguage ?? this.promptLanguage,
        speakerVerificationEnabled:
            speakerVerificationEnabled ?? this.speakerVerificationEnabled,
        dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
        dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
        dailyReminderMinute: dailyReminderMinute ?? this.dailyReminderMinute,
        analysisNotificationsEnabled:
            analysisNotificationsEnabled ?? this.analysisNotificationsEnabled,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      );
  LocalUserProfileData copyWithCompanion(LocalUserProfileCompanion data) {
    return LocalUserProfileData(
      userId: data.userId.present ? data.userId.value : this.userId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      email: data.email.present ? data.email.value : this.email,
      hasSpeakerEmbedding: data.hasSpeakerEmbedding.present
          ? data.hasSpeakerEmbedding.value
          : this.hasSpeakerEmbedding,
      totalMeasurements: data.totalMeasurements.present
          ? data.totalMeasurements.value
          : this.totalMeasurements,
      recordingDurationSeconds: data.recordingDurationSeconds.present
          ? data.recordingDurationSeconds.value
          : this.recordingDurationSeconds,
      promptLanguage: data.promptLanguage.present
          ? data.promptLanguage.value
          : this.promptLanguage,
      speakerVerificationEnabled: data.speakerVerificationEnabled.present
          ? data.speakerVerificationEnabled.value
          : this.speakerVerificationEnabled,
      dailyReminderEnabled: data.dailyReminderEnabled.present
          ? data.dailyReminderEnabled.value
          : this.dailyReminderEnabled,
      dailyReminderHour: data.dailyReminderHour.present
          ? data.dailyReminderHour.value
          : this.dailyReminderHour,
      dailyReminderMinute: data.dailyReminderMinute.present
          ? data.dailyReminderMinute.value
          : this.dailyReminderMinute,
      analysisNotificationsEnabled: data.analysisNotificationsEnabled.present
          ? data.analysisNotificationsEnabled.value
          : this.analysisNotificationsEnabled,
      onboardingComplete: data.onboardingComplete.present
          ? data.onboardingComplete.value
          : this.onboardingComplete,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserProfileData(')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('hasSpeakerEmbedding: $hasSpeakerEmbedding, ')
          ..write('totalMeasurements: $totalMeasurements, ')
          ..write('recordingDurationSeconds: $recordingDurationSeconds, ')
          ..write('promptLanguage: $promptLanguage, ')
          ..write('speakerVerificationEnabled: $speakerVerificationEnabled, ')
          ..write('dailyReminderEnabled: $dailyReminderEnabled, ')
          ..write('dailyReminderHour: $dailyReminderHour, ')
          ..write('dailyReminderMinute: $dailyReminderMinute, ')
          ..write(
              'analysisNotificationsEnabled: $analysisNotificationsEnabled, ')
          ..write('onboardingComplete: $onboardingComplete')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      userId,
      displayName,
      email,
      hasSpeakerEmbedding,
      totalMeasurements,
      recordingDurationSeconds,
      promptLanguage,
      speakerVerificationEnabled,
      dailyReminderEnabled,
      dailyReminderHour,
      dailyReminderMinute,
      analysisNotificationsEnabled,
      onboardingComplete);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUserProfileData &&
          other.userId == this.userId &&
          other.displayName == this.displayName &&
          other.email == this.email &&
          other.hasSpeakerEmbedding == this.hasSpeakerEmbedding &&
          other.totalMeasurements == this.totalMeasurements &&
          other.recordingDurationSeconds == this.recordingDurationSeconds &&
          other.promptLanguage == this.promptLanguage &&
          other.speakerVerificationEnabled == this.speakerVerificationEnabled &&
          other.dailyReminderEnabled == this.dailyReminderEnabled &&
          other.dailyReminderHour == this.dailyReminderHour &&
          other.dailyReminderMinute == this.dailyReminderMinute &&
          other.analysisNotificationsEnabled ==
              this.analysisNotificationsEnabled &&
          other.onboardingComplete == this.onboardingComplete);
}

class LocalUserProfileCompanion extends UpdateCompanion<LocalUserProfileData> {
  final Value<String> userId;
  final Value<String> displayName;
  final Value<String> email;
  final Value<bool> hasSpeakerEmbedding;
  final Value<int> totalMeasurements;
  final Value<int> recordingDurationSeconds;
  final Value<String> promptLanguage;
  final Value<bool> speakerVerificationEnabled;
  final Value<bool> dailyReminderEnabled;
  final Value<int> dailyReminderHour;
  final Value<int> dailyReminderMinute;
  final Value<bool> analysisNotificationsEnabled;
  final Value<bool> onboardingComplete;
  final Value<int> rowid;
  const LocalUserProfileCompanion({
    this.userId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.email = const Value.absent(),
    this.hasSpeakerEmbedding = const Value.absent(),
    this.totalMeasurements = const Value.absent(),
    this.recordingDurationSeconds = const Value.absent(),
    this.promptLanguage = const Value.absent(),
    this.speakerVerificationEnabled = const Value.absent(),
    this.dailyReminderEnabled = const Value.absent(),
    this.dailyReminderHour = const Value.absent(),
    this.dailyReminderMinute = const Value.absent(),
    this.analysisNotificationsEnabled = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUserProfileCompanion.insert({
    required String userId,
    required String displayName,
    required String email,
    this.hasSpeakerEmbedding = const Value.absent(),
    this.totalMeasurements = const Value.absent(),
    this.recordingDurationSeconds = const Value.absent(),
    this.promptLanguage = const Value.absent(),
    this.speakerVerificationEnabled = const Value.absent(),
    this.dailyReminderEnabled = const Value.absent(),
    this.dailyReminderHour = const Value.absent(),
    this.dailyReminderMinute = const Value.absent(),
    this.analysisNotificationsEnabled = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        displayName = Value(displayName),
        email = Value(email);
  static Insertable<LocalUserProfileData> custom({
    Expression<String>? userId,
    Expression<String>? displayName,
    Expression<String>? email,
    Expression<bool>? hasSpeakerEmbedding,
    Expression<int>? totalMeasurements,
    Expression<int>? recordingDurationSeconds,
    Expression<String>? promptLanguage,
    Expression<bool>? speakerVerificationEnabled,
    Expression<bool>? dailyReminderEnabled,
    Expression<int>? dailyReminderHour,
    Expression<int>? dailyReminderMinute,
    Expression<bool>? analysisNotificationsEnabled,
    Expression<bool>? onboardingComplete,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (displayName != null) 'display_name': displayName,
      if (email != null) 'email': email,
      if (hasSpeakerEmbedding != null)
        'has_speaker_embedding': hasSpeakerEmbedding,
      if (totalMeasurements != null) 'total_measurements': totalMeasurements,
      if (recordingDurationSeconds != null)
        'recording_duration_seconds': recordingDurationSeconds,
      if (promptLanguage != null) 'prompt_language': promptLanguage,
      if (speakerVerificationEnabled != null)
        'speaker_verification_enabled': speakerVerificationEnabled,
      if (dailyReminderEnabled != null)
        'daily_reminder_enabled': dailyReminderEnabled,
      if (dailyReminderHour != null) 'daily_reminder_hour': dailyReminderHour,
      if (dailyReminderMinute != null)
        'daily_reminder_minute': dailyReminderMinute,
      if (analysisNotificationsEnabled != null)
        'analysis_notifications_enabled': analysisNotificationsEnabled,
      if (onboardingComplete != null) 'onboarding_complete': onboardingComplete,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUserProfileCompanion copyWith(
      {Value<String>? userId,
      Value<String>? displayName,
      Value<String>? email,
      Value<bool>? hasSpeakerEmbedding,
      Value<int>? totalMeasurements,
      Value<int>? recordingDurationSeconds,
      Value<String>? promptLanguage,
      Value<bool>? speakerVerificationEnabled,
      Value<bool>? dailyReminderEnabled,
      Value<int>? dailyReminderHour,
      Value<int>? dailyReminderMinute,
      Value<bool>? analysisNotificationsEnabled,
      Value<bool>? onboardingComplete,
      Value<int>? rowid}) {
    return LocalUserProfileCompanion(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      hasSpeakerEmbedding: hasSpeakerEmbedding ?? this.hasSpeakerEmbedding,
      totalMeasurements: totalMeasurements ?? this.totalMeasurements,
      recordingDurationSeconds:
          recordingDurationSeconds ?? this.recordingDurationSeconds,
      promptLanguage: promptLanguage ?? this.promptLanguage,
      speakerVerificationEnabled:
          speakerVerificationEnabled ?? this.speakerVerificationEnabled,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      dailyReminderMinute: dailyReminderMinute ?? this.dailyReminderMinute,
      analysisNotificationsEnabled:
          analysisNotificationsEnabled ?? this.analysisNotificationsEnabled,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (hasSpeakerEmbedding.present) {
      map['has_speaker_embedding'] = Variable<bool>(hasSpeakerEmbedding.value);
    }
    if (totalMeasurements.present) {
      map['total_measurements'] = Variable<int>(totalMeasurements.value);
    }
    if (recordingDurationSeconds.present) {
      map['recording_duration_seconds'] =
          Variable<int>(recordingDurationSeconds.value);
    }
    if (promptLanguage.present) {
      map['prompt_language'] = Variable<String>(promptLanguage.value);
    }
    if (speakerVerificationEnabled.present) {
      map['speaker_verification_enabled'] =
          Variable<bool>(speakerVerificationEnabled.value);
    }
    if (dailyReminderEnabled.present) {
      map['daily_reminder_enabled'] =
          Variable<bool>(dailyReminderEnabled.value);
    }
    if (dailyReminderHour.present) {
      map['daily_reminder_hour'] = Variable<int>(dailyReminderHour.value);
    }
    if (dailyReminderMinute.present) {
      map['daily_reminder_minute'] = Variable<int>(dailyReminderMinute.value);
    }
    if (analysisNotificationsEnabled.present) {
      map['analysis_notifications_enabled'] =
          Variable<bool>(analysisNotificationsEnabled.value);
    }
    if (onboardingComplete.present) {
      map['onboarding_complete'] = Variable<bool>(onboardingComplete.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserProfileCompanion(')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('hasSpeakerEmbedding: $hasSpeakerEmbedding, ')
          ..write('totalMeasurements: $totalMeasurements, ')
          ..write('recordingDurationSeconds: $recordingDurationSeconds, ')
          ..write('promptLanguage: $promptLanguage, ')
          ..write('speakerVerificationEnabled: $speakerVerificationEnabled, ')
          ..write('dailyReminderEnabled: $dailyReminderEnabled, ')
          ..write('dailyReminderHour: $dailyReminderHour, ')
          ..write('dailyReminderMinute: $dailyReminderMinute, ')
          ..write(
              'analysisNotificationsEnabled: $analysisNotificationsEnabled, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $LocalMeasurementsTable localMeasurements =
      $LocalMeasurementsTable(this);
  late final $LocalScoresTable localScores = $LocalScoresTable(this);
  late final $LocalUserProfileTable localUserProfile =
      $LocalUserProfileTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [localMeasurements, localScores, localUserProfile];
}

typedef $$LocalMeasurementsTableCreateCompanionBuilder
    = LocalMeasurementsCompanion Function({
  required String id,
  required DateTime recordedAt,
  required int durationSeconds,
  Value<bool> uploaded,
  Value<bool> analyzed,
  Value<String?> localVideoPath,
  Value<String?> localAudioPath,
  required String questionsUsed,
  Value<String?> notes,
  Value<int> retryCount,
  Value<DateTime?> nextRetryAt,
  Value<int> rowid,
});
typedef $$LocalMeasurementsTableUpdateCompanionBuilder
    = LocalMeasurementsCompanion Function({
  Value<String> id,
  Value<DateTime> recordedAt,
  Value<int> durationSeconds,
  Value<bool> uploaded,
  Value<bool> analyzed,
  Value<String?> localVideoPath,
  Value<String?> localAudioPath,
  Value<String> questionsUsed,
  Value<String?> notes,
  Value<int> retryCount,
  Value<DateTime?> nextRetryAt,
  Value<int> rowid,
});

class $$LocalMeasurementsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalMeasurementsTable> {
  $$LocalMeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get uploaded => $composableBuilder(
      column: $table.uploaded, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get analyzed => $composableBuilder(
      column: $table.analyzed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localVideoPath => $composableBuilder(
      column: $table.localVideoPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localAudioPath => $composableBuilder(
      column: $table.localAudioPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionsUsed => $composableBuilder(
      column: $table.questionsUsed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => ColumnFilters(column));
}

class $$LocalMeasurementsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalMeasurementsTable> {
  $$LocalMeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get uploaded => $composableBuilder(
      column: $table.uploaded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get analyzed => $composableBuilder(
      column: $table.analyzed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localVideoPath => $composableBuilder(
      column: $table.localVideoPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localAudioPath => $composableBuilder(
      column: $table.localAudioPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionsUsed => $composableBuilder(
      column: $table.questionsUsed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalMeasurementsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalMeasurementsTable> {
  $$LocalMeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<bool> get uploaded =>
      $composableBuilder(column: $table.uploaded, builder: (column) => column);

  GeneratedColumn<bool> get analyzed =>
      $composableBuilder(column: $table.analyzed, builder: (column) => column);

  GeneratedColumn<String> get localVideoPath => $composableBuilder(
      column: $table.localVideoPath, builder: (column) => column);

  GeneratedColumn<String> get localAudioPath => $composableBuilder(
      column: $table.localAudioPath, builder: (column) => column);

  GeneratedColumn<String> get questionsUsed => $composableBuilder(
      column: $table.questionsUsed, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => column);
}

class $$LocalMeasurementsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalMeasurementsTable,
    LocalMeasurement,
    $$LocalMeasurementsTableFilterComposer,
    $$LocalMeasurementsTableOrderingComposer,
    $$LocalMeasurementsTableAnnotationComposer,
    $$LocalMeasurementsTableCreateCompanionBuilder,
    $$LocalMeasurementsTableUpdateCompanionBuilder,
    (
      LocalMeasurement,
      BaseReferences<_$LocalDatabase, $LocalMeasurementsTable, LocalMeasurement>
    ),
    LocalMeasurement,
    PrefetchHooks Function()> {
  $$LocalMeasurementsTableTableManager(
      _$LocalDatabase db, $LocalMeasurementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMeasurementsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<bool> uploaded = const Value.absent(),
            Value<bool> analyzed = const Value.absent(),
            Value<String?> localVideoPath = const Value.absent(),
            Value<String?> localAudioPath = const Value.absent(),
            Value<String> questionsUsed = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime?> nextRetryAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMeasurementsCompanion(
            id: id,
            recordedAt: recordedAt,
            durationSeconds: durationSeconds,
            uploaded: uploaded,
            analyzed: analyzed,
            localVideoPath: localVideoPath,
            localAudioPath: localAudioPath,
            questionsUsed: questionsUsed,
            notes: notes,
            retryCount: retryCount,
            nextRetryAt: nextRetryAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime recordedAt,
            required int durationSeconds,
            Value<bool> uploaded = const Value.absent(),
            Value<bool> analyzed = const Value.absent(),
            Value<String?> localVideoPath = const Value.absent(),
            Value<String?> localAudioPath = const Value.absent(),
            required String questionsUsed,
            Value<String?> notes = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime?> nextRetryAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMeasurementsCompanion.insert(
            id: id,
            recordedAt: recordedAt,
            durationSeconds: durationSeconds,
            uploaded: uploaded,
            analyzed: analyzed,
            localVideoPath: localVideoPath,
            localAudioPath: localAudioPath,
            questionsUsed: questionsUsed,
            notes: notes,
            retryCount: retryCount,
            nextRetryAt: nextRetryAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalMeasurementsTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalMeasurementsTable,
    LocalMeasurement,
    $$LocalMeasurementsTableFilterComposer,
    $$LocalMeasurementsTableOrderingComposer,
    $$LocalMeasurementsTableAnnotationComposer,
    $$LocalMeasurementsTableCreateCompanionBuilder,
    $$LocalMeasurementsTableUpdateCompanionBuilder,
    (
      LocalMeasurement,
      BaseReferences<_$LocalDatabase, $LocalMeasurementsTable, LocalMeasurement>
    ),
    LocalMeasurement,
    PrefetchHooks Function()>;
typedef $$LocalScoresTableCreateCompanionBuilder = LocalScoresCompanion
    Function({
  required String measurementId,
  Value<double?> speechRateZscore,
  Value<double?> pauseRatioZscore,
  Value<double?> voiceEnergyZscore,
  Value<double?> f0RangeZscore,
  Value<double?> responseLengthZscore,
  Value<double?> cohesionZscore,
  Value<double?> facialAffectZscore,
  Value<double?> compositeZscore,
  Value<String?> flags,
  Value<String?> trend7d,
  Value<double?> baselineMean,
  Value<double?> baselineStd,
  Value<int?> baselineN,
  Value<String?> perQuestion,
  Value<String?> energyProfile,
  Value<DateTime?> analyzedAt,
  Value<int> rowid,
});
typedef $$LocalScoresTableUpdateCompanionBuilder = LocalScoresCompanion
    Function({
  Value<String> measurementId,
  Value<double?> speechRateZscore,
  Value<double?> pauseRatioZscore,
  Value<double?> voiceEnergyZscore,
  Value<double?> f0RangeZscore,
  Value<double?> responseLengthZscore,
  Value<double?> cohesionZscore,
  Value<double?> facialAffectZscore,
  Value<double?> compositeZscore,
  Value<String?> flags,
  Value<String?> trend7d,
  Value<double?> baselineMean,
  Value<double?> baselineStd,
  Value<int?> baselineN,
  Value<String?> perQuestion,
  Value<String?> energyProfile,
  Value<DateTime?> analyzedAt,
  Value<int> rowid,
});

class $$LocalScoresTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalScoresTable> {
  $$LocalScoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get measurementId => $composableBuilder(
      column: $table.measurementId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get speechRateZscore => $composableBuilder(
      column: $table.speechRateZscore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pauseRatioZscore => $composableBuilder(
      column: $table.pauseRatioZscore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get voiceEnergyZscore => $composableBuilder(
      column: $table.voiceEnergyZscore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get f0RangeZscore => $composableBuilder(
      column: $table.f0RangeZscore, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get responseLengthZscore => $composableBuilder(
      column: $table.responseLengthZscore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cohesionZscore => $composableBuilder(
      column: $table.cohesionZscore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get facialAffectZscore => $composableBuilder(
      column: $table.facialAffectZscore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get compositeZscore => $composableBuilder(
      column: $table.compositeZscore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get flags => $composableBuilder(
      column: $table.flags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trend7d => $composableBuilder(
      column: $table.trend7d, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get baselineMean => $composableBuilder(
      column: $table.baselineMean, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get baselineStd => $composableBuilder(
      column: $table.baselineStd, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get baselineN => $composableBuilder(
      column: $table.baselineN, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get perQuestion => $composableBuilder(
      column: $table.perQuestion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get energyProfile => $composableBuilder(
      column: $table.energyProfile, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get analyzedAt => $composableBuilder(
      column: $table.analyzedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalScoresTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalScoresTable> {
  $$LocalScoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get measurementId => $composableBuilder(
      column: $table.measurementId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get speechRateZscore => $composableBuilder(
      column: $table.speechRateZscore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pauseRatioZscore => $composableBuilder(
      column: $table.pauseRatioZscore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get voiceEnergyZscore => $composableBuilder(
      column: $table.voiceEnergyZscore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get f0RangeZscore => $composableBuilder(
      column: $table.f0RangeZscore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get responseLengthZscore => $composableBuilder(
      column: $table.responseLengthZscore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cohesionZscore => $composableBuilder(
      column: $table.cohesionZscore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get facialAffectZscore => $composableBuilder(
      column: $table.facialAffectZscore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get compositeZscore => $composableBuilder(
      column: $table.compositeZscore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get flags => $composableBuilder(
      column: $table.flags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trend7d => $composableBuilder(
      column: $table.trend7d, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get baselineMean => $composableBuilder(
      column: $table.baselineMean,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get baselineStd => $composableBuilder(
      column: $table.baselineStd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get baselineN => $composableBuilder(
      column: $table.baselineN, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get perQuestion => $composableBuilder(
      column: $table.perQuestion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get energyProfile => $composableBuilder(
      column: $table.energyProfile,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get analyzedAt => $composableBuilder(
      column: $table.analyzedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalScoresTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalScoresTable> {
  $$LocalScoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get measurementId => $composableBuilder(
      column: $table.measurementId, builder: (column) => column);

  GeneratedColumn<double> get speechRateZscore => $composableBuilder(
      column: $table.speechRateZscore, builder: (column) => column);

  GeneratedColumn<double> get pauseRatioZscore => $composableBuilder(
      column: $table.pauseRatioZscore, builder: (column) => column);

  GeneratedColumn<double> get voiceEnergyZscore => $composableBuilder(
      column: $table.voiceEnergyZscore, builder: (column) => column);

  GeneratedColumn<double> get f0RangeZscore => $composableBuilder(
      column: $table.f0RangeZscore, builder: (column) => column);

  GeneratedColumn<double> get responseLengthZscore => $composableBuilder(
      column: $table.responseLengthZscore, builder: (column) => column);

  GeneratedColumn<double> get cohesionZscore => $composableBuilder(
      column: $table.cohesionZscore, builder: (column) => column);

  GeneratedColumn<double> get facialAffectZscore => $composableBuilder(
      column: $table.facialAffectZscore, builder: (column) => column);

  GeneratedColumn<double> get compositeZscore => $composableBuilder(
      column: $table.compositeZscore, builder: (column) => column);

  GeneratedColumn<String> get flags =>
      $composableBuilder(column: $table.flags, builder: (column) => column);

  GeneratedColumn<String> get trend7d =>
      $composableBuilder(column: $table.trend7d, builder: (column) => column);

  GeneratedColumn<double> get baselineMean => $composableBuilder(
      column: $table.baselineMean, builder: (column) => column);

  GeneratedColumn<double> get baselineStd => $composableBuilder(
      column: $table.baselineStd, builder: (column) => column);

  GeneratedColumn<int> get baselineN =>
      $composableBuilder(column: $table.baselineN, builder: (column) => column);

  GeneratedColumn<String> get perQuestion => $composableBuilder(
      column: $table.perQuestion, builder: (column) => column);

  GeneratedColumn<String> get energyProfile => $composableBuilder(
      column: $table.energyProfile, builder: (column) => column);

  GeneratedColumn<DateTime> get analyzedAt => $composableBuilder(
      column: $table.analyzedAt, builder: (column) => column);
}

class $$LocalScoresTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalScoresTable,
    LocalScore,
    $$LocalScoresTableFilterComposer,
    $$LocalScoresTableOrderingComposer,
    $$LocalScoresTableAnnotationComposer,
    $$LocalScoresTableCreateCompanionBuilder,
    $$LocalScoresTableUpdateCompanionBuilder,
    (
      LocalScore,
      BaseReferences<_$LocalDatabase, $LocalScoresTable, LocalScore>
    ),
    LocalScore,
    PrefetchHooks Function()> {
  $$LocalScoresTableTableManager(_$LocalDatabase db, $LocalScoresTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalScoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalScoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalScoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> measurementId = const Value.absent(),
            Value<double?> speechRateZscore = const Value.absent(),
            Value<double?> pauseRatioZscore = const Value.absent(),
            Value<double?> voiceEnergyZscore = const Value.absent(),
            Value<double?> f0RangeZscore = const Value.absent(),
            Value<double?> responseLengthZscore = const Value.absent(),
            Value<double?> cohesionZscore = const Value.absent(),
            Value<double?> facialAffectZscore = const Value.absent(),
            Value<double?> compositeZscore = const Value.absent(),
            Value<String?> flags = const Value.absent(),
            Value<String?> trend7d = const Value.absent(),
            Value<double?> baselineMean = const Value.absent(),
            Value<double?> baselineStd = const Value.absent(),
            Value<int?> baselineN = const Value.absent(),
            Value<String?> perQuestion = const Value.absent(),
            Value<String?> energyProfile = const Value.absent(),
            Value<DateTime?> analyzedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalScoresCompanion(
            measurementId: measurementId,
            speechRateZscore: speechRateZscore,
            pauseRatioZscore: pauseRatioZscore,
            voiceEnergyZscore: voiceEnergyZscore,
            f0RangeZscore: f0RangeZscore,
            responseLengthZscore: responseLengthZscore,
            cohesionZscore: cohesionZscore,
            facialAffectZscore: facialAffectZscore,
            compositeZscore: compositeZscore,
            flags: flags,
            trend7d: trend7d,
            baselineMean: baselineMean,
            baselineStd: baselineStd,
            baselineN: baselineN,
            perQuestion: perQuestion,
            energyProfile: energyProfile,
            analyzedAt: analyzedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String measurementId,
            Value<double?> speechRateZscore = const Value.absent(),
            Value<double?> pauseRatioZscore = const Value.absent(),
            Value<double?> voiceEnergyZscore = const Value.absent(),
            Value<double?> f0RangeZscore = const Value.absent(),
            Value<double?> responseLengthZscore = const Value.absent(),
            Value<double?> cohesionZscore = const Value.absent(),
            Value<double?> facialAffectZscore = const Value.absent(),
            Value<double?> compositeZscore = const Value.absent(),
            Value<String?> flags = const Value.absent(),
            Value<String?> trend7d = const Value.absent(),
            Value<double?> baselineMean = const Value.absent(),
            Value<double?> baselineStd = const Value.absent(),
            Value<int?> baselineN = const Value.absent(),
            Value<String?> perQuestion = const Value.absent(),
            Value<String?> energyProfile = const Value.absent(),
            Value<DateTime?> analyzedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalScoresCompanion.insert(
            measurementId: measurementId,
            speechRateZscore: speechRateZscore,
            pauseRatioZscore: pauseRatioZscore,
            voiceEnergyZscore: voiceEnergyZscore,
            f0RangeZscore: f0RangeZscore,
            responseLengthZscore: responseLengthZscore,
            cohesionZscore: cohesionZscore,
            facialAffectZscore: facialAffectZscore,
            compositeZscore: compositeZscore,
            flags: flags,
            trend7d: trend7d,
            baselineMean: baselineMean,
            baselineStd: baselineStd,
            baselineN: baselineN,
            perQuestion: perQuestion,
            energyProfile: energyProfile,
            analyzedAt: analyzedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalScoresTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalScoresTable,
    LocalScore,
    $$LocalScoresTableFilterComposer,
    $$LocalScoresTableOrderingComposer,
    $$LocalScoresTableAnnotationComposer,
    $$LocalScoresTableCreateCompanionBuilder,
    $$LocalScoresTableUpdateCompanionBuilder,
    (
      LocalScore,
      BaseReferences<_$LocalDatabase, $LocalScoresTable, LocalScore>
    ),
    LocalScore,
    PrefetchHooks Function()>;
typedef $$LocalUserProfileTableCreateCompanionBuilder
    = LocalUserProfileCompanion Function({
  required String userId,
  required String displayName,
  required String email,
  Value<bool> hasSpeakerEmbedding,
  Value<int> totalMeasurements,
  Value<int> recordingDurationSeconds,
  Value<String> promptLanguage,
  Value<bool> speakerVerificationEnabled,
  Value<bool> dailyReminderEnabled,
  Value<int> dailyReminderHour,
  Value<int> dailyReminderMinute,
  Value<bool> analysisNotificationsEnabled,
  Value<bool> onboardingComplete,
  Value<int> rowid,
});
typedef $$LocalUserProfileTableUpdateCompanionBuilder
    = LocalUserProfileCompanion Function({
  Value<String> userId,
  Value<String> displayName,
  Value<String> email,
  Value<bool> hasSpeakerEmbedding,
  Value<int> totalMeasurements,
  Value<int> recordingDurationSeconds,
  Value<String> promptLanguage,
  Value<bool> speakerVerificationEnabled,
  Value<bool> dailyReminderEnabled,
  Value<int> dailyReminderHour,
  Value<int> dailyReminderMinute,
  Value<bool> analysisNotificationsEnabled,
  Value<bool> onboardingComplete,
  Value<int> rowid,
});

class $$LocalUserProfileTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalUserProfileTable> {
  $$LocalUserProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasSpeakerEmbedding => $composableBuilder(
      column: $table.hasSpeakerEmbedding,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalMeasurements => $composableBuilder(
      column: $table.totalMeasurements,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recordingDurationSeconds => $composableBuilder(
      column: $table.recordingDurationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get promptLanguage => $composableBuilder(
      column: $table.promptLanguage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get speakerVerificationEnabled => $composableBuilder(
      column: $table.speakerVerificationEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dailyReminderEnabled => $composableBuilder(
      column: $table.dailyReminderEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dailyReminderHour => $composableBuilder(
      column: $table.dailyReminderHour,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dailyReminderMinute => $composableBuilder(
      column: $table.dailyReminderMinute,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get analysisNotificationsEnabled => $composableBuilder(
      column: $table.analysisNotificationsEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onboardingComplete => $composableBuilder(
      column: $table.onboardingComplete,
      builder: (column) => ColumnFilters(column));
}

class $$LocalUserProfileTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalUserProfileTable> {
  $$LocalUserProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasSpeakerEmbedding => $composableBuilder(
      column: $table.hasSpeakerEmbedding,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalMeasurements => $composableBuilder(
      column: $table.totalMeasurements,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recordingDurationSeconds => $composableBuilder(
      column: $table.recordingDurationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get promptLanguage => $composableBuilder(
      column: $table.promptLanguage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get speakerVerificationEnabled => $composableBuilder(
      column: $table.speakerVerificationEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dailyReminderEnabled => $composableBuilder(
      column: $table.dailyReminderEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dailyReminderHour => $composableBuilder(
      column: $table.dailyReminderHour,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dailyReminderMinute => $composableBuilder(
      column: $table.dailyReminderMinute,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get analysisNotificationsEnabled => $composableBuilder(
      column: $table.analysisNotificationsEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onboardingComplete => $composableBuilder(
      column: $table.onboardingComplete,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalUserProfileTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalUserProfileTable> {
  $$LocalUserProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<bool> get hasSpeakerEmbedding => $composableBuilder(
      column: $table.hasSpeakerEmbedding, builder: (column) => column);

  GeneratedColumn<int> get totalMeasurements => $composableBuilder(
      column: $table.totalMeasurements, builder: (column) => column);

  GeneratedColumn<int> get recordingDurationSeconds => $composableBuilder(
      column: $table.recordingDurationSeconds, builder: (column) => column);

  GeneratedColumn<String> get promptLanguage => $composableBuilder(
      column: $table.promptLanguage, builder: (column) => column);

  GeneratedColumn<bool> get speakerVerificationEnabled => $composableBuilder(
      column: $table.speakerVerificationEnabled, builder: (column) => column);

  GeneratedColumn<bool> get dailyReminderEnabled => $composableBuilder(
      column: $table.dailyReminderEnabled, builder: (column) => column);

  GeneratedColumn<int> get dailyReminderHour => $composableBuilder(
      column: $table.dailyReminderHour, builder: (column) => column);

  GeneratedColumn<int> get dailyReminderMinute => $composableBuilder(
      column: $table.dailyReminderMinute, builder: (column) => column);

  GeneratedColumn<bool> get analysisNotificationsEnabled => $composableBuilder(
      column: $table.analysisNotificationsEnabled, builder: (column) => column);

  GeneratedColumn<bool> get onboardingComplete => $composableBuilder(
      column: $table.onboardingComplete, builder: (column) => column);
}

class $$LocalUserProfileTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalUserProfileTable,
    LocalUserProfileData,
    $$LocalUserProfileTableFilterComposer,
    $$LocalUserProfileTableOrderingComposer,
    $$LocalUserProfileTableAnnotationComposer,
    $$LocalUserProfileTableCreateCompanionBuilder,
    $$LocalUserProfileTableUpdateCompanionBuilder,
    (
      LocalUserProfileData,
      BaseReferences<_$LocalDatabase, $LocalUserProfileTable,
          LocalUserProfileData>
    ),
    LocalUserProfileData,
    PrefetchHooks Function()> {
  $$LocalUserProfileTableTableManager(
      _$LocalDatabase db, $LocalUserProfileTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUserProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUserProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUserProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<bool> hasSpeakerEmbedding = const Value.absent(),
            Value<int> totalMeasurements = const Value.absent(),
            Value<int> recordingDurationSeconds = const Value.absent(),
            Value<String> promptLanguage = const Value.absent(),
            Value<bool> speakerVerificationEnabled = const Value.absent(),
            Value<bool> dailyReminderEnabled = const Value.absent(),
            Value<int> dailyReminderHour = const Value.absent(),
            Value<int> dailyReminderMinute = const Value.absent(),
            Value<bool> analysisNotificationsEnabled = const Value.absent(),
            Value<bool> onboardingComplete = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalUserProfileCompanion(
            userId: userId,
            displayName: displayName,
            email: email,
            hasSpeakerEmbedding: hasSpeakerEmbedding,
            totalMeasurements: totalMeasurements,
            recordingDurationSeconds: recordingDurationSeconds,
            promptLanguage: promptLanguage,
            speakerVerificationEnabled: speakerVerificationEnabled,
            dailyReminderEnabled: dailyReminderEnabled,
            dailyReminderHour: dailyReminderHour,
            dailyReminderMinute: dailyReminderMinute,
            analysisNotificationsEnabled: analysisNotificationsEnabled,
            onboardingComplete: onboardingComplete,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            required String displayName,
            required String email,
            Value<bool> hasSpeakerEmbedding = const Value.absent(),
            Value<int> totalMeasurements = const Value.absent(),
            Value<int> recordingDurationSeconds = const Value.absent(),
            Value<String> promptLanguage = const Value.absent(),
            Value<bool> speakerVerificationEnabled = const Value.absent(),
            Value<bool> dailyReminderEnabled = const Value.absent(),
            Value<int> dailyReminderHour = const Value.absent(),
            Value<int> dailyReminderMinute = const Value.absent(),
            Value<bool> analysisNotificationsEnabled = const Value.absent(),
            Value<bool> onboardingComplete = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalUserProfileCompanion.insert(
            userId: userId,
            displayName: displayName,
            email: email,
            hasSpeakerEmbedding: hasSpeakerEmbedding,
            totalMeasurements: totalMeasurements,
            recordingDurationSeconds: recordingDurationSeconds,
            promptLanguage: promptLanguage,
            speakerVerificationEnabled: speakerVerificationEnabled,
            dailyReminderEnabled: dailyReminderEnabled,
            dailyReminderHour: dailyReminderHour,
            dailyReminderMinute: dailyReminderMinute,
            analysisNotificationsEnabled: analysisNotificationsEnabled,
            onboardingComplete: onboardingComplete,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalUserProfileTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalUserProfileTable,
    LocalUserProfileData,
    $$LocalUserProfileTableFilterComposer,
    $$LocalUserProfileTableOrderingComposer,
    $$LocalUserProfileTableAnnotationComposer,
    $$LocalUserProfileTableCreateCompanionBuilder,
    $$LocalUserProfileTableUpdateCompanionBuilder,
    (
      LocalUserProfileData,
      BaseReferences<_$LocalDatabase, $LocalUserProfileTable,
          LocalUserProfileData>
    ),
    LocalUserProfileData,
    PrefetchHooks Function()>;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$LocalMeasurementsTableTableManager get localMeasurements =>
      $$LocalMeasurementsTableTableManager(_db, _db.localMeasurements);
  $$LocalScoresTableTableManager get localScores =>
      $$LocalScoresTableTableManager(_db, _db.localScores);
  $$LocalUserProfileTableTableManager get localUserProfile =>
      $$LocalUserProfileTableTableManager(_db, _db.localUserProfile);
}

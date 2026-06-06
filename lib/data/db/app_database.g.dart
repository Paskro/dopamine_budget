// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SessionsTableTable extends SessionsTable
    with TableInfo<$SessionsTableTable, SessionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<int> phase = GeneratedColumn<int>(
    'phase',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgScoreMeta = const VerificationMeta(
    'avgScore',
  );
  @override
  late final GeneratedColumn<double> avgScore = GeneratedColumn<double>(
    'avg_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isReviewedMeta = const VerificationMeta(
    'isReviewed',
  );
  @override
  late final GeneratedColumn<bool> isReviewed = GeneratedColumn<bool>(
    'is_reviewed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_reviewed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _shouldDecreaseMeta = const VerificationMeta(
    'shouldDecrease',
  );
  @override
  late final GeneratedColumn<bool> shouldDecrease = GeneratedColumn<bool>(
    'should_decrease',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("should_decrease" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _decreasePercentageMeta =
      const VerificationMeta('decreasePercentage');
  @override
  late final GeneratedColumn<double> decreasePercentage =
      GeneratedColumn<double>(
        'decrease_percentage',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _decreaseIntervalMeta = const VerificationMeta(
    'decreaseInterval',
  );
  @override
  late final GeneratedColumn<String> decreaseInterval = GeneratedColumn<String>(
    'decrease_interval',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    phase,
    avgScore,
    isReviewed,
    shouldDecrease,
    decreasePercentage,
    decreaseInterval,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    } else if (isInserting) {
      context.missing(_phaseMeta);
    }
    if (data.containsKey('avg_score')) {
      context.handle(
        _avgScoreMeta,
        avgScore.isAcceptableOrUnknown(data['avg_score']!, _avgScoreMeta),
      );
    }
    if (data.containsKey('is_reviewed')) {
      context.handle(
        _isReviewedMeta,
        isReviewed.isAcceptableOrUnknown(data['is_reviewed']!, _isReviewedMeta),
      );
    }
    if (data.containsKey('should_decrease')) {
      context.handle(
        _shouldDecreaseMeta,
        shouldDecrease.isAcceptableOrUnknown(
          data['should_decrease']!,
          _shouldDecreaseMeta,
        ),
      );
    }
    if (data.containsKey('decrease_percentage')) {
      context.handle(
        _decreasePercentageMeta,
        decreasePercentage.isAcceptableOrUnknown(
          data['decrease_percentage']!,
          _decreasePercentageMeta,
        ),
      );
    }
    if (data.containsKey('decrease_interval')) {
      context.handle(
        _decreaseIntervalMeta,
        decreaseInterval.isAcceptableOrUnknown(
          data['decrease_interval']!,
          _decreaseIntervalMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}phase'],
      )!,
      avgScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_score'],
      ),
      isReviewed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_reviewed'],
      )!,
      shouldDecrease: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}should_decrease'],
      )!,
      decreasePercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}decrease_percentage'],
      ),
      decreaseInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decrease_interval'],
      ),
    );
  }

  @override
  $SessionsTableTable createAlias(String alias) {
    return $SessionsTableTable(attachedDatabase, alias);
  }
}

class SessionsTableData extends DataClass
    implements Insertable<SessionsTableData> {
  final String id;
  final DateTime createdAt;
  final int phase;
  final double? avgScore;
  final bool isReviewed;
  final bool shouldDecrease;
  final double? decreasePercentage;
  final String? decreaseInterval;
  const SessionsTableData({
    required this.id,
    required this.createdAt,
    required this.phase,
    this.avgScore,
    required this.isReviewed,
    required this.shouldDecrease,
    this.decreasePercentage,
    this.decreaseInterval,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['phase'] = Variable<int>(phase);
    if (!nullToAbsent || avgScore != null) {
      map['avg_score'] = Variable<double>(avgScore);
    }
    map['is_reviewed'] = Variable<bool>(isReviewed);
    map['should_decrease'] = Variable<bool>(shouldDecrease);
    if (!nullToAbsent || decreasePercentage != null) {
      map['decrease_percentage'] = Variable<double>(decreasePercentage);
    }
    if (!nullToAbsent || decreaseInterval != null) {
      map['decrease_interval'] = Variable<String>(decreaseInterval);
    }
    return map;
  }

  SessionsTableCompanion toCompanion(bool nullToAbsent) {
    return SessionsTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      phase: Value(phase),
      avgScore: avgScore == null && nullToAbsent
          ? const Value.absent()
          : Value(avgScore),
      isReviewed: Value(isReviewed),
      shouldDecrease: Value(shouldDecrease),
      decreasePercentage: decreasePercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(decreasePercentage),
      decreaseInterval: decreaseInterval == null && nullToAbsent
          ? const Value.absent()
          : Value(decreaseInterval),
    );
  }

  factory SessionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionsTableData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      phase: serializer.fromJson<int>(json['phase']),
      avgScore: serializer.fromJson<double?>(json['avgScore']),
      isReviewed: serializer.fromJson<bool>(json['isReviewed']),
      shouldDecrease: serializer.fromJson<bool>(json['shouldDecrease']),
      decreasePercentage: serializer.fromJson<double?>(
        json['decreasePercentage'],
      ),
      decreaseInterval: serializer.fromJson<String?>(json['decreaseInterval']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'phase': serializer.toJson<int>(phase),
      'avgScore': serializer.toJson<double?>(avgScore),
      'isReviewed': serializer.toJson<bool>(isReviewed),
      'shouldDecrease': serializer.toJson<bool>(shouldDecrease),
      'decreasePercentage': serializer.toJson<double?>(decreasePercentage),
      'decreaseInterval': serializer.toJson<String?>(decreaseInterval),
    };
  }

  SessionsTableData copyWith({
    String? id,
    DateTime? createdAt,
    int? phase,
    Value<double?> avgScore = const Value.absent(),
    bool? isReviewed,
    bool? shouldDecrease,
    Value<double?> decreasePercentage = const Value.absent(),
    Value<String?> decreaseInterval = const Value.absent(),
  }) => SessionsTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    phase: phase ?? this.phase,
    avgScore: avgScore.present ? avgScore.value : this.avgScore,
    isReviewed: isReviewed ?? this.isReviewed,
    shouldDecrease: shouldDecrease ?? this.shouldDecrease,
    decreasePercentage: decreasePercentage.present
        ? decreasePercentage.value
        : this.decreasePercentage,
    decreaseInterval: decreaseInterval.present
        ? decreaseInterval.value
        : this.decreaseInterval,
  );
  SessionsTableData copyWithCompanion(SessionsTableCompanion data) {
    return SessionsTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      phase: data.phase.present ? data.phase.value : this.phase,
      avgScore: data.avgScore.present ? data.avgScore.value : this.avgScore,
      isReviewed: data.isReviewed.present
          ? data.isReviewed.value
          : this.isReviewed,
      shouldDecrease: data.shouldDecrease.present
          ? data.shouldDecrease.value
          : this.shouldDecrease,
      decreasePercentage: data.decreasePercentage.present
          ? data.decreasePercentage.value
          : this.decreasePercentage,
      decreaseInterval: data.decreaseInterval.present
          ? data.decreaseInterval.value
          : this.decreaseInterval,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionsTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('phase: $phase, ')
          ..write('avgScore: $avgScore, ')
          ..write('isReviewed: $isReviewed, ')
          ..write('shouldDecrease: $shouldDecrease, ')
          ..write('decreasePercentage: $decreasePercentage, ')
          ..write('decreaseInterval: $decreaseInterval')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    phase,
    avgScore,
    isReviewed,
    shouldDecrease,
    decreasePercentage,
    decreaseInterval,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionsTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.phase == this.phase &&
          other.avgScore == this.avgScore &&
          other.isReviewed == this.isReviewed &&
          other.shouldDecrease == this.shouldDecrease &&
          other.decreasePercentage == this.decreasePercentage &&
          other.decreaseInterval == this.decreaseInterval);
}

class SessionsTableCompanion extends UpdateCompanion<SessionsTableData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<int> phase;
  final Value<double?> avgScore;
  final Value<bool> isReviewed;
  final Value<bool> shouldDecrease;
  final Value<double?> decreasePercentage;
  final Value<String?> decreaseInterval;
  final Value<int> rowid;
  const SessionsTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.phase = const Value.absent(),
    this.avgScore = const Value.absent(),
    this.isReviewed = const Value.absent(),
    this.shouldDecrease = const Value.absent(),
    this.decreasePercentage = const Value.absent(),
    this.decreaseInterval = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsTableCompanion.insert({
    required String id,
    required DateTime createdAt,
    required int phase,
    this.avgScore = const Value.absent(),
    this.isReviewed = const Value.absent(),
    this.shouldDecrease = const Value.absent(),
    this.decreasePercentage = const Value.absent(),
    this.decreaseInterval = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       phase = Value(phase);
  static Insertable<SessionsTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<int>? phase,
    Expression<double>? avgScore,
    Expression<bool>? isReviewed,
    Expression<bool>? shouldDecrease,
    Expression<double>? decreasePercentage,
    Expression<String>? decreaseInterval,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (phase != null) 'phase': phase,
      if (avgScore != null) 'avg_score': avgScore,
      if (isReviewed != null) 'is_reviewed': isReviewed,
      if (shouldDecrease != null) 'should_decrease': shouldDecrease,
      if (decreasePercentage != null) 'decrease_percentage': decreasePercentage,
      if (decreaseInterval != null) 'decrease_interval': decreaseInterval,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<int>? phase,
    Value<double?>? avgScore,
    Value<bool>? isReviewed,
    Value<bool>? shouldDecrease,
    Value<double?>? decreasePercentage,
    Value<String?>? decreaseInterval,
    Value<int>? rowid,
  }) {
    return SessionsTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      phase: phase ?? this.phase,
      avgScore: avgScore ?? this.avgScore,
      isReviewed: isReviewed ?? this.isReviewed,
      shouldDecrease: shouldDecrease ?? this.shouldDecrease,
      decreasePercentage: decreasePercentage ?? this.decreasePercentage,
      decreaseInterval: decreaseInterval ?? this.decreaseInterval,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (phase.present) {
      map['phase'] = Variable<int>(phase.value);
    }
    if (avgScore.present) {
      map['avg_score'] = Variable<double>(avgScore.value);
    }
    if (isReviewed.present) {
      map['is_reviewed'] = Variable<bool>(isReviewed.value);
    }
    if (shouldDecrease.present) {
      map['should_decrease'] = Variable<bool>(shouldDecrease.value);
    }
    if (decreasePercentage.present) {
      map['decrease_percentage'] = Variable<double>(decreasePercentage.value);
    }
    if (decreaseInterval.present) {
      map['decrease_interval'] = Variable<String>(decreaseInterval.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('phase: $phase, ')
          ..write('avgScore: $avgScore, ')
          ..write('isReviewed: $isReviewed, ')
          ..write('shouldDecrease: $shouldDecrease, ')
          ..write('decreasePercentage: $decreasePercentage, ')
          ..write('decreaseInterval: $decreaseInterval, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActionsTableTable extends ActionsTable
    with TableInfo<$ActionsTableTable, ActionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _habitTypeMeta = const VerificationMeta(
    'habitType',
  );
  @override
  late final GeneratedColumn<String> habitType = GeneratedColumn<String>(
    'habit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreValueMeta = const VerificationMeta(
    'scoreValue',
  );
  @override
  late final GeneratedColumn<int> scoreValue = GeneratedColumn<int>(
    'score_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, habitType, scoreValue, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'actions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_type')) {
      context.handle(
        _habitTypeMeta,
        habitType.isAcceptableOrUnknown(data['habit_type']!, _habitTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_habitTypeMeta);
    }
    if (data.containsKey('score_value')) {
      context.handle(
        _scoreValueMeta,
        scoreValue.isAcceptableOrUnknown(data['score_value']!, _scoreValueMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreValueMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      habitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_type'],
      )!,
      scoreValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score_value'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $ActionsTableTable createAlias(String alias) {
    return $ActionsTableTable(attachedDatabase, alias);
  }
}

class ActionsTableData extends DataClass
    implements Insertable<ActionsTableData> {
  final int id;
  final String habitType;
  final int scoreValue;
  final DateTime timestamp;
  const ActionsTableData({
    required this.id,
    required this.habitType,
    required this.scoreValue,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_type'] = Variable<String>(habitType);
    map['score_value'] = Variable<int>(scoreValue);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  ActionsTableCompanion toCompanion(bool nullToAbsent) {
    return ActionsTableCompanion(
      id: Value(id),
      habitType: Value(habitType),
      scoreValue: Value(scoreValue),
      timestamp: Value(timestamp),
    );
  }

  factory ActionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActionsTableData(
      id: serializer.fromJson<int>(json['id']),
      habitType: serializer.fromJson<String>(json['habitType']),
      scoreValue: serializer.fromJson<int>(json['scoreValue']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitType': serializer.toJson<String>(habitType),
      'scoreValue': serializer.toJson<int>(scoreValue),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  ActionsTableData copyWith({
    int? id,
    String? habitType,
    int? scoreValue,
    DateTime? timestamp,
  }) => ActionsTableData(
    id: id ?? this.id,
    habitType: habitType ?? this.habitType,
    scoreValue: scoreValue ?? this.scoreValue,
    timestamp: timestamp ?? this.timestamp,
  );
  ActionsTableData copyWithCompanion(ActionsTableCompanion data) {
    return ActionsTableData(
      id: data.id.present ? data.id.value : this.id,
      habitType: data.habitType.present ? data.habitType.value : this.habitType,
      scoreValue: data.scoreValue.present
          ? data.scoreValue.value
          : this.scoreValue,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActionsTableData(')
          ..write('id: $id, ')
          ..write('habitType: $habitType, ')
          ..write('scoreValue: $scoreValue, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitType, scoreValue, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionsTableData &&
          other.id == this.id &&
          other.habitType == this.habitType &&
          other.scoreValue == this.scoreValue &&
          other.timestamp == this.timestamp);
}

class ActionsTableCompanion extends UpdateCompanion<ActionsTableData> {
  final Value<int> id;
  final Value<String> habitType;
  final Value<int> scoreValue;
  final Value<DateTime> timestamp;
  const ActionsTableCompanion({
    this.id = const Value.absent(),
    this.habitType = const Value.absent(),
    this.scoreValue = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  ActionsTableCompanion.insert({
    this.id = const Value.absent(),
    required String habitType,
    required int scoreValue,
    required DateTime timestamp,
  }) : habitType = Value(habitType),
       scoreValue = Value(scoreValue),
       timestamp = Value(timestamp);
  static Insertable<ActionsTableData> custom({
    Expression<int>? id,
    Expression<String>? habitType,
    Expression<int>? scoreValue,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitType != null) 'habit_type': habitType,
      if (scoreValue != null) 'score_value': scoreValue,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  ActionsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? habitType,
    Value<int>? scoreValue,
    Value<DateTime>? timestamp,
  }) {
    return ActionsTableCompanion(
      id: id ?? this.id,
      habitType: habitType ?? this.habitType,
      scoreValue: scoreValue ?? this.scoreValue,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitType.present) {
      map['habit_type'] = Variable<String>(habitType.value);
    }
    if (scoreValue.present) {
      map['score_value'] = Variable<int>(scoreValue.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActionsTableCompanion(')
          ..write('id: $id, ')
          ..write('habitType: $habitType, ')
          ..write('scoreValue: $scoreValue, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $HabitsTableTable extends HabitsTable
    with TableInfo<$HabitsTableTable, HabitsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreValueMeta = const VerificationMeta(
    'scoreValue',
  );
  @override
  late final GeneratedColumn<int> scoreValue = GeneratedColumn<int>(
    'score_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, scoreValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('score_value')) {
      context.handle(
        _scoreValueMeta,
        scoreValue.isAcceptableOrUnknown(data['score_value']!, _scoreValueMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      scoreValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score_value'],
      )!,
    );
  }

  @override
  $HabitsTableTable createAlias(String alias) {
    return $HabitsTableTable(attachedDatabase, alias);
  }
}

class HabitsTableData extends DataClass implements Insertable<HabitsTableData> {
  final int id;
  final String title;
  final int scoreValue;
  const HabitsTableData({
    required this.id,
    required this.title,
    required this.scoreValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['score_value'] = Variable<int>(scoreValue);
    return map;
  }

  HabitsTableCompanion toCompanion(bool nullToAbsent) {
    return HabitsTableCompanion(
      id: Value(id),
      title: Value(title),
      scoreValue: Value(scoreValue),
    );
  }

  factory HabitsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitsTableData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      scoreValue: serializer.fromJson<int>(json['scoreValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'scoreValue': serializer.toJson<int>(scoreValue),
    };
  }

  HabitsTableData copyWith({int? id, String? title, int? scoreValue}) =>
      HabitsTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        scoreValue: scoreValue ?? this.scoreValue,
      );
  HabitsTableData copyWithCompanion(HabitsTableCompanion data) {
    return HabitsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      scoreValue: data.scoreValue.present
          ? data.scoreValue.value
          : this.scoreValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('scoreValue: $scoreValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, scoreValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.scoreValue == this.scoreValue);
}

class HabitsTableCompanion extends UpdateCompanion<HabitsTableData> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> scoreValue;
  const HabitsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.scoreValue = const Value.absent(),
  });
  HabitsTableCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int scoreValue,
  }) : title = Value(title),
       scoreValue = Value(scoreValue);
  static Insertable<HabitsTableData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? scoreValue,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (scoreValue != null) 'score_value': scoreValue,
    });
  }

  HabitsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int>? scoreValue,
  }) {
    return HabitsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      scoreValue: scoreValue ?? this.scoreValue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (scoreValue.present) {
      map['score_value'] = Variable<int>(scoreValue.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('scoreValue: $scoreValue')
          ..write(')'))
        .toString();
  }
}

class $SessionHabitsTableTable extends SessionHabitsTable
    with TableInfo<$SessionHabitsTableTable, SessionHabitsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionHabitsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sessionId, habitId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_habits_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionHabitsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionId, habitId},
  ];
  @override
  SessionHabitsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionHabitsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
    );
  }

  @override
  $SessionHabitsTableTable createAlias(String alias) {
    return $SessionHabitsTableTable(attachedDatabase, alias);
  }
}

class SessionHabitsTableData extends DataClass
    implements Insertable<SessionHabitsTableData> {
  final int id;
  final String sessionId;
  final int habitId;
  const SessionHabitsTableData({
    required this.id,
    required this.sessionId,
    required this.habitId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['habit_id'] = Variable<int>(habitId);
    return map;
  }

  SessionHabitsTableCompanion toCompanion(bool nullToAbsent) {
    return SessionHabitsTableCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      habitId: Value(habitId),
    );
  }

  factory SessionHabitsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionHabitsTableData(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      habitId: serializer.fromJson<int>(json['habitId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'habitId': serializer.toJson<int>(habitId),
    };
  }

  SessionHabitsTableData copyWith({int? id, String? sessionId, int? habitId}) =>
      SessionHabitsTableData(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        habitId: habitId ?? this.habitId,
      );
  SessionHabitsTableData copyWithCompanion(SessionHabitsTableCompanion data) {
    return SessionHabitsTableData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionHabitsTableData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('habitId: $habitId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, habitId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionHabitsTableData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.habitId == this.habitId);
}

class SessionHabitsTableCompanion
    extends UpdateCompanion<SessionHabitsTableData> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<int> habitId;
  const SessionHabitsTableCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.habitId = const Value.absent(),
  });
  SessionHabitsTableCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required int habitId,
  }) : sessionId = Value(sessionId),
       habitId = Value(habitId);
  static Insertable<SessionHabitsTableData> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<int>? habitId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (habitId != null) 'habit_id': habitId,
    });
  }

  SessionHabitsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<int>? habitId,
  }) {
    return SessionHabitsTableCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      habitId: habitId ?? this.habitId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionHabitsTableCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('habitId: $habitId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTableTable sessionsTable = $SessionsTableTable(this);
  late final $ActionsTableTable actionsTable = $ActionsTableTable(this);
  late final $HabitsTableTable habitsTable = $HabitsTableTable(this);
  late final $SessionHabitsTableTable sessionHabitsTable =
      $SessionHabitsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sessionsTable,
    actionsTable,
    habitsTable,
    sessionHabitsTable,
  ];
}

typedef $$SessionsTableTableCreateCompanionBuilder =
    SessionsTableCompanion Function({
      required String id,
      required DateTime createdAt,
      required int phase,
      Value<double?> avgScore,
      Value<bool> isReviewed,
      Value<bool> shouldDecrease,
      Value<double?> decreasePercentage,
      Value<String?> decreaseInterval,
      Value<int> rowid,
    });
typedef $$SessionsTableTableUpdateCompanionBuilder =
    SessionsTableCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<int> phase,
      Value<double?> avgScore,
      Value<bool> isReviewed,
      Value<bool> shouldDecrease,
      Value<double?> decreasePercentage,
      Value<String?> decreaseInterval,
      Value<int> rowid,
    });

class $$SessionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTableTable> {
  $$SessionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgScore => $composableBuilder(
    column: $table.avgScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isReviewed => $composableBuilder(
    column: $table.isReviewed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shouldDecrease => $composableBuilder(
    column: $table.shouldDecrease,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get decreasePercentage => $composableBuilder(
    column: $table.decreasePercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decreaseInterval => $composableBuilder(
    column: $table.decreaseInterval,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTableTable> {
  $$SessionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgScore => $composableBuilder(
    column: $table.avgScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isReviewed => $composableBuilder(
    column: $table.isReviewed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shouldDecrease => $composableBuilder(
    column: $table.shouldDecrease,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get decreasePercentage => $composableBuilder(
    column: $table.decreasePercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decreaseInterval => $composableBuilder(
    column: $table.decreaseInterval,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTableTable> {
  $$SessionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<double> get avgScore =>
      $composableBuilder(column: $table.avgScore, builder: (column) => column);

  GeneratedColumn<bool> get isReviewed => $composableBuilder(
    column: $table.isReviewed,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get shouldDecrease => $composableBuilder(
    column: $table.shouldDecrease,
    builder: (column) => column,
  );

  GeneratedColumn<double> get decreasePercentage => $composableBuilder(
    column: $table.decreasePercentage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get decreaseInterval => $composableBuilder(
    column: $table.decreaseInterval,
    builder: (column) => column,
  );
}

class $$SessionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTableTable,
          SessionsTableData,
          $$SessionsTableTableFilterComposer,
          $$SessionsTableTableOrderingComposer,
          $$SessionsTableTableAnnotationComposer,
          $$SessionsTableTableCreateCompanionBuilder,
          $$SessionsTableTableUpdateCompanionBuilder,
          (
            SessionsTableData,
            BaseReferences<
              _$AppDatabase,
              $SessionsTableTable,
              SessionsTableData
            >,
          ),
          SessionsTableData,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableTableManager(_$AppDatabase db, $SessionsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> phase = const Value.absent(),
                Value<double?> avgScore = const Value.absent(),
                Value<bool> isReviewed = const Value.absent(),
                Value<bool> shouldDecrease = const Value.absent(),
                Value<double?> decreasePercentage = const Value.absent(),
                Value<String?> decreaseInterval = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsTableCompanion(
                id: id,
                createdAt: createdAt,
                phase: phase,
                avgScore: avgScore,
                isReviewed: isReviewed,
                shouldDecrease: shouldDecrease,
                decreasePercentage: decreasePercentage,
                decreaseInterval: decreaseInterval,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required int phase,
                Value<double?> avgScore = const Value.absent(),
                Value<bool> isReviewed = const Value.absent(),
                Value<bool> shouldDecrease = const Value.absent(),
                Value<double?> decreasePercentage = const Value.absent(),
                Value<String?> decreaseInterval = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                phase: phase,
                avgScore: avgScore,
                isReviewed: isReviewed,
                shouldDecrease: shouldDecrease,
                decreasePercentage: decreasePercentage,
                decreaseInterval: decreaseInterval,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTableTable,
      SessionsTableData,
      $$SessionsTableTableFilterComposer,
      $$SessionsTableTableOrderingComposer,
      $$SessionsTableTableAnnotationComposer,
      $$SessionsTableTableCreateCompanionBuilder,
      $$SessionsTableTableUpdateCompanionBuilder,
      (
        SessionsTableData,
        BaseReferences<_$AppDatabase, $SessionsTableTable, SessionsTableData>,
      ),
      SessionsTableData,
      PrefetchHooks Function()
    >;
typedef $$ActionsTableTableCreateCompanionBuilder =
    ActionsTableCompanion Function({
      Value<int> id,
      required String habitType,
      required int scoreValue,
      required DateTime timestamp,
    });
typedef $$ActionsTableTableUpdateCompanionBuilder =
    ActionsTableCompanion Function({
      Value<int> id,
      Value<String> habitType,
      Value<int> scoreValue,
      Value<DateTime> timestamp,
    });

class $$ActionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ActionsTableTable> {
  $$ActionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitType => $composableBuilder(
    column: $table.habitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scoreValue => $composableBuilder(
    column: $table.scoreValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ActionsTableTable> {
  $$ActionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitType => $composableBuilder(
    column: $table.habitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scoreValue => $composableBuilder(
    column: $table.scoreValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActionsTableTable> {
  $$ActionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get habitType =>
      $composableBuilder(column: $table.habitType, builder: (column) => column);

  GeneratedColumn<int> get scoreValue => $composableBuilder(
    column: $table.scoreValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$ActionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActionsTableTable,
          ActionsTableData,
          $$ActionsTableTableFilterComposer,
          $$ActionsTableTableOrderingComposer,
          $$ActionsTableTableAnnotationComposer,
          $$ActionsTableTableCreateCompanionBuilder,
          $$ActionsTableTableUpdateCompanionBuilder,
          (
            ActionsTableData,
            BaseReferences<_$AppDatabase, $ActionsTableTable, ActionsTableData>,
          ),
          ActionsTableData,
          PrefetchHooks Function()
        > {
  $$ActionsTableTableTableManager(_$AppDatabase db, $ActionsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActionsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> habitType = const Value.absent(),
                Value<int> scoreValue = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => ActionsTableCompanion(
                id: id,
                habitType: habitType,
                scoreValue: scoreValue,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String habitType,
                required int scoreValue,
                required DateTime timestamp,
              }) => ActionsTableCompanion.insert(
                id: id,
                habitType: habitType,
                scoreValue: scoreValue,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActionsTableTable,
      ActionsTableData,
      $$ActionsTableTableFilterComposer,
      $$ActionsTableTableOrderingComposer,
      $$ActionsTableTableAnnotationComposer,
      $$ActionsTableTableCreateCompanionBuilder,
      $$ActionsTableTableUpdateCompanionBuilder,
      (
        ActionsTableData,
        BaseReferences<_$AppDatabase, $ActionsTableTable, ActionsTableData>,
      ),
      ActionsTableData,
      PrefetchHooks Function()
    >;
typedef $$HabitsTableTableCreateCompanionBuilder =
    HabitsTableCompanion Function({
      Value<int> id,
      required String title,
      required int scoreValue,
    });
typedef $$HabitsTableTableUpdateCompanionBuilder =
    HabitsTableCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<int> scoreValue,
    });

class $$HabitsTableTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTableTable> {
  $$HabitsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scoreValue => $composableBuilder(
    column: $table.scoreValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTableTable> {
  $$HabitsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scoreValue => $composableBuilder(
    column: $table.scoreValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTableTable> {
  $$HabitsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get scoreValue => $composableBuilder(
    column: $table.scoreValue,
    builder: (column) => column,
  );
}

class $$HabitsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTableTable,
          HabitsTableData,
          $$HabitsTableTableFilterComposer,
          $$HabitsTableTableOrderingComposer,
          $$HabitsTableTableAnnotationComposer,
          $$HabitsTableTableCreateCompanionBuilder,
          $$HabitsTableTableUpdateCompanionBuilder,
          (
            HabitsTableData,
            BaseReferences<_$AppDatabase, $HabitsTableTable, HabitsTableData>,
          ),
          HabitsTableData,
          PrefetchHooks Function()
        > {
  $$HabitsTableTableTableManager(_$AppDatabase db, $HabitsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> scoreValue = const Value.absent(),
              }) => HabitsTableCompanion(
                id: id,
                title: title,
                scoreValue: scoreValue,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required int scoreValue,
              }) => HabitsTableCompanion.insert(
                id: id,
                title: title,
                scoreValue: scoreValue,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTableTable,
      HabitsTableData,
      $$HabitsTableTableFilterComposer,
      $$HabitsTableTableOrderingComposer,
      $$HabitsTableTableAnnotationComposer,
      $$HabitsTableTableCreateCompanionBuilder,
      $$HabitsTableTableUpdateCompanionBuilder,
      (
        HabitsTableData,
        BaseReferences<_$AppDatabase, $HabitsTableTable, HabitsTableData>,
      ),
      HabitsTableData,
      PrefetchHooks Function()
    >;
typedef $$SessionHabitsTableTableCreateCompanionBuilder =
    SessionHabitsTableCompanion Function({
      Value<int> id,
      required String sessionId,
      required int habitId,
    });
typedef $$SessionHabitsTableTableUpdateCompanionBuilder =
    SessionHabitsTableCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<int> habitId,
    });

class $$SessionHabitsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SessionHabitsTableTable> {
  $$SessionHabitsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionHabitsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionHabitsTableTable> {
  $$SessionHabitsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionHabitsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionHabitsTableTable> {
  $$SessionHabitsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);
}

class $$SessionHabitsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionHabitsTableTable,
          SessionHabitsTableData,
          $$SessionHabitsTableTableFilterComposer,
          $$SessionHabitsTableTableOrderingComposer,
          $$SessionHabitsTableTableAnnotationComposer,
          $$SessionHabitsTableTableCreateCompanionBuilder,
          $$SessionHabitsTableTableUpdateCompanionBuilder,
          (
            SessionHabitsTableData,
            BaseReferences<
              _$AppDatabase,
              $SessionHabitsTableTable,
              SessionHabitsTableData
            >,
          ),
          SessionHabitsTableData,
          PrefetchHooks Function()
        > {
  $$SessionHabitsTableTableTableManager(
    _$AppDatabase db,
    $SessionHabitsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionHabitsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionHabitsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionHabitsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> habitId = const Value.absent(),
              }) => SessionHabitsTableCompanion(
                id: id,
                sessionId: sessionId,
                habitId: habitId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                required int habitId,
              }) => SessionHabitsTableCompanion.insert(
                id: id,
                sessionId: sessionId,
                habitId: habitId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionHabitsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionHabitsTableTable,
      SessionHabitsTableData,
      $$SessionHabitsTableTableFilterComposer,
      $$SessionHabitsTableTableOrderingComposer,
      $$SessionHabitsTableTableAnnotationComposer,
      $$SessionHabitsTableTableCreateCompanionBuilder,
      $$SessionHabitsTableTableUpdateCompanionBuilder,
      (
        SessionHabitsTableData,
        BaseReferences<
          _$AppDatabase,
          $SessionHabitsTableTable,
          SessionHabitsTableData
        >,
      ),
      SessionHabitsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableTableManager get sessionsTable =>
      $$SessionsTableTableTableManager(_db, _db.sessionsTable);
  $$ActionsTableTableTableManager get actionsTable =>
      $$ActionsTableTableTableManager(_db, _db.actionsTable);
  $$HabitsTableTableTableManager get habitsTable =>
      $$HabitsTableTableTableManager(_db, _db.habitsTable);
  $$SessionHabitsTableTableTableManager get sessionHabitsTable =>
      $$SessionHabitsTableTableTableManager(_db, _db.sessionHabitsTable);
}

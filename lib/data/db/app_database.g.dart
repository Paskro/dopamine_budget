// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
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
  static const VerificationMeta _calibrationDaysMeta = const VerificationMeta(
    'calibrationDays',
  );
  @override
  late final GeneratedColumn<int> calibrationDays = GeneratedColumn<int>(
    'calibration_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _controlStartedAtMeta = const VerificationMeta(
    'controlStartedAt',
  );
  @override
  late final GeneratedColumn<DateTime> controlStartedAt =
      GeneratedColumn<DateTime>(
        'control_started_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _baseShrinkingLimitMeta =
      const VerificationMeta('baseShrinkingLimit');
  @override
  late final GeneratedColumn<double> baseShrinkingLimit =
      GeneratedColumn<double>(
        'base_shrinking_limit',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _shrinkingStartedAtMeta =
      const VerificationMeta('shrinkingStartedAt');
  @override
  late final GeneratedColumn<DateTime> shrinkingStartedAt =
      GeneratedColumn<DateTime>(
        'shrinking_started_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
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
  static const VerificationMeta _decreaseIntervalDaysMeta =
      const VerificationMeta('decreaseIntervalDays');
  @override
  late final GeneratedColumn<int> decreaseIntervalDays = GeneratedColumn<int>(
    'decrease_interval_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    calibrationDays,
    controlStartedAt,
    baseShrinkingLimit,
    shrinkingStartedAt,
    decreasePercentage,
    decreaseIntervalDays,
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
    if (data.containsKey('calibration_days')) {
      context.handle(
        _calibrationDaysMeta,
        calibrationDays.isAcceptableOrUnknown(
          data['calibration_days']!,
          _calibrationDaysMeta,
        ),
      );
    }
    if (data.containsKey('control_started_at')) {
      context.handle(
        _controlStartedAtMeta,
        controlStartedAt.isAcceptableOrUnknown(
          data['control_started_at']!,
          _controlStartedAtMeta,
        ),
      );
    }
    if (data.containsKey('base_shrinking_limit')) {
      context.handle(
        _baseShrinkingLimitMeta,
        baseShrinkingLimit.isAcceptableOrUnknown(
          data['base_shrinking_limit']!,
          _baseShrinkingLimitMeta,
        ),
      );
    }
    if (data.containsKey('shrinking_started_at')) {
      context.handle(
        _shrinkingStartedAtMeta,
        shrinkingStartedAt.isAcceptableOrUnknown(
          data['shrinking_started_at']!,
          _shrinkingStartedAtMeta,
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
    if (data.containsKey('decrease_interval_days')) {
      context.handle(
        _decreaseIntervalDaysMeta,
        decreaseIntervalDays.isAcceptableOrUnknown(
          data['decrease_interval_days']!,
          _decreaseIntervalDaysMeta,
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
      calibrationDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calibration_days'],
      )!,
      controlStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}control_started_at'],
      ),
      baseShrinkingLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}base_shrinking_limit'],
      ),
      shrinkingStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}shrinking_started_at'],
      ),
      decreasePercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}decrease_percentage'],
      ),
      decreaseIntervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}decrease_interval_days'],
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
  final int calibrationDays;
  final DateTime? controlStartedAt;
  final double? baseShrinkingLimit;
  final DateTime? shrinkingStartedAt;
  final double? decreasePercentage;
  final int? decreaseIntervalDays;
  const SessionsTableData({
    required this.id,
    required this.createdAt,
    required this.phase,
    this.avgScore,
    required this.isReviewed,
    required this.shouldDecrease,
    required this.calibrationDays,
    this.controlStartedAt,
    this.baseShrinkingLimit,
    this.shrinkingStartedAt,
    this.decreasePercentage,
    this.decreaseIntervalDays,
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
    map['calibration_days'] = Variable<int>(calibrationDays);
    if (!nullToAbsent || controlStartedAt != null) {
      map['control_started_at'] = Variable<DateTime>(controlStartedAt);
    }
    if (!nullToAbsent || baseShrinkingLimit != null) {
      map['base_shrinking_limit'] = Variable<double>(baseShrinkingLimit);
    }
    if (!nullToAbsent || shrinkingStartedAt != null) {
      map['shrinking_started_at'] = Variable<DateTime>(shrinkingStartedAt);
    }
    if (!nullToAbsent || decreasePercentage != null) {
      map['decrease_percentage'] = Variable<double>(decreasePercentage);
    }
    if (!nullToAbsent || decreaseIntervalDays != null) {
      map['decrease_interval_days'] = Variable<int>(decreaseIntervalDays);
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
      calibrationDays: Value(calibrationDays),
      controlStartedAt: controlStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(controlStartedAt),
      baseShrinkingLimit: baseShrinkingLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(baseShrinkingLimit),
      shrinkingStartedAt: shrinkingStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(shrinkingStartedAt),
      decreasePercentage: decreasePercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(decreasePercentage),
      decreaseIntervalDays: decreaseIntervalDays == null && nullToAbsent
          ? const Value.absent()
          : Value(decreaseIntervalDays),
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
      calibrationDays: serializer.fromJson<int>(json['calibrationDays']),
      controlStartedAt: serializer.fromJson<DateTime?>(
        json['controlStartedAt'],
      ),
      baseShrinkingLimit: serializer.fromJson<double?>(
        json['baseShrinkingLimit'],
      ),
      shrinkingStartedAt: serializer.fromJson<DateTime?>(
        json['shrinkingStartedAt'],
      ),
      decreasePercentage: serializer.fromJson<double?>(
        json['decreasePercentage'],
      ),
      decreaseIntervalDays: serializer.fromJson<int?>(
        json['decreaseIntervalDays'],
      ),
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
      'calibrationDays': serializer.toJson<int>(calibrationDays),
      'controlStartedAt': serializer.toJson<DateTime?>(controlStartedAt),
      'baseShrinkingLimit': serializer.toJson<double?>(baseShrinkingLimit),
      'shrinkingStartedAt': serializer.toJson<DateTime?>(shrinkingStartedAt),
      'decreasePercentage': serializer.toJson<double?>(decreasePercentage),
      'decreaseIntervalDays': serializer.toJson<int?>(decreaseIntervalDays),
    };
  }

  SessionsTableData copyWith({
    String? id,
    DateTime? createdAt,
    int? phase,
    Value<double?> avgScore = const Value.absent(),
    bool? isReviewed,
    bool? shouldDecrease,
    int? calibrationDays,
    Value<DateTime?> controlStartedAt = const Value.absent(),
    Value<double?> baseShrinkingLimit = const Value.absent(),
    Value<DateTime?> shrinkingStartedAt = const Value.absent(),
    Value<double?> decreasePercentage = const Value.absent(),
    Value<int?> decreaseIntervalDays = const Value.absent(),
  }) => SessionsTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    phase: phase ?? this.phase,
    avgScore: avgScore.present ? avgScore.value : this.avgScore,
    isReviewed: isReviewed ?? this.isReviewed,
    shouldDecrease: shouldDecrease ?? this.shouldDecrease,
    calibrationDays: calibrationDays ?? this.calibrationDays,
    controlStartedAt: controlStartedAt.present
        ? controlStartedAt.value
        : this.controlStartedAt,
    baseShrinkingLimit: baseShrinkingLimit.present
        ? baseShrinkingLimit.value
        : this.baseShrinkingLimit,
    shrinkingStartedAt: shrinkingStartedAt.present
        ? shrinkingStartedAt.value
        : this.shrinkingStartedAt,
    decreasePercentage: decreasePercentage.present
        ? decreasePercentage.value
        : this.decreasePercentage,
    decreaseIntervalDays: decreaseIntervalDays.present
        ? decreaseIntervalDays.value
        : this.decreaseIntervalDays,
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
      calibrationDays: data.calibrationDays.present
          ? data.calibrationDays.value
          : this.calibrationDays,
      controlStartedAt: data.controlStartedAt.present
          ? data.controlStartedAt.value
          : this.controlStartedAt,
      baseShrinkingLimit: data.baseShrinkingLimit.present
          ? data.baseShrinkingLimit.value
          : this.baseShrinkingLimit,
      shrinkingStartedAt: data.shrinkingStartedAt.present
          ? data.shrinkingStartedAt.value
          : this.shrinkingStartedAt,
      decreasePercentage: data.decreasePercentage.present
          ? data.decreasePercentage.value
          : this.decreasePercentage,
      decreaseIntervalDays: data.decreaseIntervalDays.present
          ? data.decreaseIntervalDays.value
          : this.decreaseIntervalDays,
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
          ..write('calibrationDays: $calibrationDays, ')
          ..write('controlStartedAt: $controlStartedAt, ')
          ..write('baseShrinkingLimit: $baseShrinkingLimit, ')
          ..write('shrinkingStartedAt: $shrinkingStartedAt, ')
          ..write('decreasePercentage: $decreasePercentage, ')
          ..write('decreaseIntervalDays: $decreaseIntervalDays')
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
    calibrationDays,
    controlStartedAt,
    baseShrinkingLimit,
    shrinkingStartedAt,
    decreasePercentage,
    decreaseIntervalDays,
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
          other.calibrationDays == this.calibrationDays &&
          other.controlStartedAt == this.controlStartedAt &&
          other.baseShrinkingLimit == this.baseShrinkingLimit &&
          other.shrinkingStartedAt == this.shrinkingStartedAt &&
          other.decreasePercentage == this.decreasePercentage &&
          other.decreaseIntervalDays == this.decreaseIntervalDays);
}

class SessionsTableCompanion extends UpdateCompanion<SessionsTableData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<int> phase;
  final Value<double?> avgScore;
  final Value<bool> isReviewed;
  final Value<bool> shouldDecrease;
  final Value<int> calibrationDays;
  final Value<DateTime?> controlStartedAt;
  final Value<double?> baseShrinkingLimit;
  final Value<DateTime?> shrinkingStartedAt;
  final Value<double?> decreasePercentage;
  final Value<int?> decreaseIntervalDays;
  final Value<int> rowid;
  const SessionsTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.phase = const Value.absent(),
    this.avgScore = const Value.absent(),
    this.isReviewed = const Value.absent(),
    this.shouldDecrease = const Value.absent(),
    this.calibrationDays = const Value.absent(),
    this.controlStartedAt = const Value.absent(),
    this.baseShrinkingLimit = const Value.absent(),
    this.shrinkingStartedAt = const Value.absent(),
    this.decreasePercentage = const Value.absent(),
    this.decreaseIntervalDays = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsTableCompanion.insert({
    required String id,
    required DateTime createdAt,
    required int phase,
    this.avgScore = const Value.absent(),
    this.isReviewed = const Value.absent(),
    this.shouldDecrease = const Value.absent(),
    this.calibrationDays = const Value.absent(),
    this.controlStartedAt = const Value.absent(),
    this.baseShrinkingLimit = const Value.absent(),
    this.shrinkingStartedAt = const Value.absent(),
    this.decreasePercentage = const Value.absent(),
    this.decreaseIntervalDays = const Value.absent(),
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
    Expression<int>? calibrationDays,
    Expression<DateTime>? controlStartedAt,
    Expression<double>? baseShrinkingLimit,
    Expression<DateTime>? shrinkingStartedAt,
    Expression<double>? decreasePercentage,
    Expression<int>? decreaseIntervalDays,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (phase != null) 'phase': phase,
      if (avgScore != null) 'avg_score': avgScore,
      if (isReviewed != null) 'is_reviewed': isReviewed,
      if (shouldDecrease != null) 'should_decrease': shouldDecrease,
      if (calibrationDays != null) 'calibration_days': calibrationDays,
      if (controlStartedAt != null) 'control_started_at': controlStartedAt,
      if (baseShrinkingLimit != null)
        'base_shrinking_limit': baseShrinkingLimit,
      if (shrinkingStartedAt != null)
        'shrinking_started_at': shrinkingStartedAt,
      if (decreasePercentage != null) 'decrease_percentage': decreasePercentage,
      if (decreaseIntervalDays != null)
        'decrease_interval_days': decreaseIntervalDays,
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
    Value<int>? calibrationDays,
    Value<DateTime?>? controlStartedAt,
    Value<double?>? baseShrinkingLimit,
    Value<DateTime?>? shrinkingStartedAt,
    Value<double?>? decreasePercentage,
    Value<int?>? decreaseIntervalDays,
    Value<int>? rowid,
  }) {
    return SessionsTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      phase: phase ?? this.phase,
      avgScore: avgScore ?? this.avgScore,
      isReviewed: isReviewed ?? this.isReviewed,
      shouldDecrease: shouldDecrease ?? this.shouldDecrease,
      calibrationDays: calibrationDays ?? this.calibrationDays,
      controlStartedAt: controlStartedAt ?? this.controlStartedAt,
      baseShrinkingLimit: baseShrinkingLimit ?? this.baseShrinkingLimit,
      shrinkingStartedAt: shrinkingStartedAt ?? this.shrinkingStartedAt,
      decreasePercentage: decreasePercentage ?? this.decreasePercentage,
      decreaseIntervalDays: decreaseIntervalDays ?? this.decreaseIntervalDays,
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
    if (calibrationDays.present) {
      map['calibration_days'] = Variable<int>(calibrationDays.value);
    }
    if (controlStartedAt.present) {
      map['control_started_at'] = Variable<DateTime>(controlStartedAt.value);
    }
    if (baseShrinkingLimit.present) {
      map['base_shrinking_limit'] = Variable<double>(baseShrinkingLimit.value);
    }
    if (shrinkingStartedAt.present) {
      map['shrinking_started_at'] = Variable<DateTime>(
        shrinkingStartedAt.value,
      );
    }
    if (decreasePercentage.present) {
      map['decrease_percentage'] = Variable<double>(decreasePercentage.value);
    }
    if (decreaseIntervalDays.present) {
      map['decrease_interval_days'] = Variable<int>(decreaseIntervalDays.value);
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
          ..write('calibrationDays: $calibrationDays, ')
          ..write('controlStartedAt: $controlStartedAt, ')
          ..write('baseShrinkingLimit: $baseShrinkingLimit, ')
          ..write('shrinkingStartedAt: $shrinkingStartedAt, ')
          ..write('decreasePercentage: $decreasePercentage, ')
          ..write('decreaseIntervalDays: $decreaseIntervalDays, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitLogsTableTable extends HabitLogsTable
    with TableInfo<$HabitLogsTableTable, HabitLogsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitLogsTableTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits_table (id)',
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions_table (id) ON DELETE CASCADE',
    ),
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
  List<GeneratedColumn> get $columns => [id, habitId, sessionId, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_logs_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitLogsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
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
  HabitLogsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitLogsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $HabitLogsTableTable createAlias(String alias) {
    return $HabitLogsTableTable(attachedDatabase, alias);
  }
}

class HabitLogsTableData extends DataClass
    implements Insertable<HabitLogsTableData> {
  final int id;
  final int habitId;
  final String sessionId;
  final DateTime timestamp;
  const HabitLogsTableData({
    required this.id,
    required this.habitId,
    required this.sessionId,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<int>(habitId);
    map['session_id'] = Variable<String>(sessionId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  HabitLogsTableCompanion toCompanion(bool nullToAbsent) {
    return HabitLogsTableCompanion(
      id: Value(id),
      habitId: Value(habitId),
      sessionId: Value(sessionId),
      timestamp: Value(timestamp),
    );
  }

  factory HabitLogsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitLogsTableData(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<int>(json['habitId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<int>(habitId),
      'sessionId': serializer.toJson<String>(sessionId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  HabitLogsTableData copyWith({
    int? id,
    int? habitId,
    String? sessionId,
    DateTime? timestamp,
  }) => HabitLogsTableData(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    sessionId: sessionId ?? this.sessionId,
    timestamp: timestamp ?? this.timestamp,
  );
  HabitLogsTableData copyWithCompanion(HabitLogsTableCompanion data) {
    return HabitLogsTableData(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitLogsTableData(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('sessionId: $sessionId, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitId, sessionId, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitLogsTableData &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.sessionId == this.sessionId &&
          other.timestamp == this.timestamp);
}

class HabitLogsTableCompanion extends UpdateCompanion<HabitLogsTableData> {
  final Value<int> id;
  final Value<int> habitId;
  final Value<String> sessionId;
  final Value<DateTime> timestamp;
  const HabitLogsTableCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  HabitLogsTableCompanion.insert({
    this.id = const Value.absent(),
    required int habitId,
    required String sessionId,
    required DateTime timestamp,
  }) : habitId = Value(habitId),
       sessionId = Value(sessionId),
       timestamp = Value(timestamp);
  static Insertable<HabitLogsTableData> custom({
    Expression<int>? id,
    Expression<int>? habitId,
    Expression<String>? sessionId,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (sessionId != null) 'session_id': sessionId,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  HabitLogsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? habitId,
    Value<String>? sessionId,
    Value<DateTime>? timestamp,
  }) {
    return HabitLogsTableCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      sessionId: sessionId ?? this.sessionId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitLogsTableCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('sessionId: $sessionId, ')
          ..write('timestamp: $timestamp')
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

class $DaysTableTable extends DaysTable
    with TableInfo<$DaysTableTable, DaysTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DaysTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'UNIQUE NOT NULL',
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _isBrokenClickedMeta = const VerificationMeta(
    'isBrokenClicked',
  );
  @override
  late final GeneratedColumn<bool> isBrokenClicked = GeneratedColumn<bool>(
    'is_broken_clicked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_broken_clicked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isGoodBoyClickedMeta = const VerificationMeta(
    'isGoodBoyClicked',
  );
  @override
  late final GeneratedColumn<bool> isGoodBoyClicked = GeneratedColumn<bool>(
    'is_good_boy_clicked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_good_boy_clicked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dayStatusMeta = const VerificationMeta(
    'dayStatus',
  );
  @override
  late final GeneratedColumn<String> dayStatus = GeneratedColumn<String>(
    'day_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('regular'),
  );
  static const VerificationMeta _isWeeklyReportReviewedMeta =
      const VerificationMeta('isWeeklyReportReviewed');
  @override
  late final GeneratedColumn<bool> isWeeklyReportReviewed =
      GeneratedColumn<bool>(
        'is_weekly_report_reviewed',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_weekly_report_reviewed" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    sessionId,
    isBrokenClicked,
    isGoodBoyClicked,
    dayStatus,
    isWeeklyReportReviewed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'days_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DaysTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('is_broken_clicked')) {
      context.handle(
        _isBrokenClickedMeta,
        isBrokenClicked.isAcceptableOrUnknown(
          data['is_broken_clicked']!,
          _isBrokenClickedMeta,
        ),
      );
    }
    if (data.containsKey('is_good_boy_clicked')) {
      context.handle(
        _isGoodBoyClickedMeta,
        isGoodBoyClicked.isAcceptableOrUnknown(
          data['is_good_boy_clicked']!,
          _isGoodBoyClickedMeta,
        ),
      );
    }
    if (data.containsKey('day_status')) {
      context.handle(
        _dayStatusMeta,
        dayStatus.isAcceptableOrUnknown(data['day_status']!, _dayStatusMeta),
      );
    }
    if (data.containsKey('is_weekly_report_reviewed')) {
      context.handle(
        _isWeeklyReportReviewedMeta,
        isWeeklyReportReviewed.isAcceptableOrUnknown(
          data['is_weekly_report_reviewed']!,
          _isWeeklyReportReviewedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DaysTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DaysTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      isBrokenClicked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_broken_clicked'],
      )!,
      isGoodBoyClicked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_good_boy_clicked'],
      )!,
      dayStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_status'],
      )!,
      isWeeklyReportReviewed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_weekly_report_reviewed'],
      )!,
    );
  }

  @override
  $DaysTableTable createAlias(String alias) {
    return $DaysTableTable(attachedDatabase, alias);
  }
}

class DaysTableData extends DataClass implements Insertable<DaysTableData> {
  final int id;
  final String date;
  final String sessionId;
  final bool isBrokenClicked;
  final bool isGoodBoyClicked;
  final String dayStatus;
  final bool isWeeklyReportReviewed;
  const DaysTableData({
    required this.id,
    required this.date,
    required this.sessionId,
    required this.isBrokenClicked,
    required this.isGoodBoyClicked,
    required this.dayStatus,
    required this.isWeeklyReportReviewed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['session_id'] = Variable<String>(sessionId);
    map['is_broken_clicked'] = Variable<bool>(isBrokenClicked);
    map['is_good_boy_clicked'] = Variable<bool>(isGoodBoyClicked);
    map['day_status'] = Variable<String>(dayStatus);
    map['is_weekly_report_reviewed'] = Variable<bool>(isWeeklyReportReviewed);
    return map;
  }

  DaysTableCompanion toCompanion(bool nullToAbsent) {
    return DaysTableCompanion(
      id: Value(id),
      date: Value(date),
      sessionId: Value(sessionId),
      isBrokenClicked: Value(isBrokenClicked),
      isGoodBoyClicked: Value(isGoodBoyClicked),
      dayStatus: Value(dayStatus),
      isWeeklyReportReviewed: Value(isWeeklyReportReviewed),
    );
  }

  factory DaysTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DaysTableData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      isBrokenClicked: serializer.fromJson<bool>(json['isBrokenClicked']),
      isGoodBoyClicked: serializer.fromJson<bool>(json['isGoodBoyClicked']),
      dayStatus: serializer.fromJson<String>(json['dayStatus']),
      isWeeklyReportReviewed: serializer.fromJson<bool>(
        json['isWeeklyReportReviewed'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'sessionId': serializer.toJson<String>(sessionId),
      'isBrokenClicked': serializer.toJson<bool>(isBrokenClicked),
      'isGoodBoyClicked': serializer.toJson<bool>(isGoodBoyClicked),
      'dayStatus': serializer.toJson<String>(dayStatus),
      'isWeeklyReportReviewed': serializer.toJson<bool>(isWeeklyReportReviewed),
    };
  }

  DaysTableData copyWith({
    int? id,
    String? date,
    String? sessionId,
    bool? isBrokenClicked,
    bool? isGoodBoyClicked,
    String? dayStatus,
    bool? isWeeklyReportReviewed,
  }) => DaysTableData(
    id: id ?? this.id,
    date: date ?? this.date,
    sessionId: sessionId ?? this.sessionId,
    isBrokenClicked: isBrokenClicked ?? this.isBrokenClicked,
    isGoodBoyClicked: isGoodBoyClicked ?? this.isGoodBoyClicked,
    dayStatus: dayStatus ?? this.dayStatus,
    isWeeklyReportReviewed:
        isWeeklyReportReviewed ?? this.isWeeklyReportReviewed,
  );
  DaysTableData copyWithCompanion(DaysTableCompanion data) {
    return DaysTableData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      isBrokenClicked: data.isBrokenClicked.present
          ? data.isBrokenClicked.value
          : this.isBrokenClicked,
      isGoodBoyClicked: data.isGoodBoyClicked.present
          ? data.isGoodBoyClicked.value
          : this.isGoodBoyClicked,
      dayStatus: data.dayStatus.present ? data.dayStatus.value : this.dayStatus,
      isWeeklyReportReviewed: data.isWeeklyReportReviewed.present
          ? data.isWeeklyReportReviewed.value
          : this.isWeeklyReportReviewed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DaysTableData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('sessionId: $sessionId, ')
          ..write('isBrokenClicked: $isBrokenClicked, ')
          ..write('isGoodBoyClicked: $isGoodBoyClicked, ')
          ..write('dayStatus: $dayStatus, ')
          ..write('isWeeklyReportReviewed: $isWeeklyReportReviewed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    sessionId,
    isBrokenClicked,
    isGoodBoyClicked,
    dayStatus,
    isWeeklyReportReviewed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DaysTableData &&
          other.id == this.id &&
          other.date == this.date &&
          other.sessionId == this.sessionId &&
          other.isBrokenClicked == this.isBrokenClicked &&
          other.isGoodBoyClicked == this.isGoodBoyClicked &&
          other.dayStatus == this.dayStatus &&
          other.isWeeklyReportReviewed == this.isWeeklyReportReviewed);
}

class DaysTableCompanion extends UpdateCompanion<DaysTableData> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> sessionId;
  final Value<bool> isBrokenClicked;
  final Value<bool> isGoodBoyClicked;
  final Value<String> dayStatus;
  final Value<bool> isWeeklyReportReviewed;
  const DaysTableCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.isBrokenClicked = const Value.absent(),
    this.isGoodBoyClicked = const Value.absent(),
    this.dayStatus = const Value.absent(),
    this.isWeeklyReportReviewed = const Value.absent(),
  });
  DaysTableCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String sessionId,
    this.isBrokenClicked = const Value.absent(),
    this.isGoodBoyClicked = const Value.absent(),
    this.dayStatus = const Value.absent(),
    this.isWeeklyReportReviewed = const Value.absent(),
  }) : date = Value(date),
       sessionId = Value(sessionId);
  static Insertable<DaysTableData> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? sessionId,
    Expression<bool>? isBrokenClicked,
    Expression<bool>? isGoodBoyClicked,
    Expression<String>? dayStatus,
    Expression<bool>? isWeeklyReportReviewed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (sessionId != null) 'session_id': sessionId,
      if (isBrokenClicked != null) 'is_broken_clicked': isBrokenClicked,
      if (isGoodBoyClicked != null) 'is_good_boy_clicked': isGoodBoyClicked,
      if (dayStatus != null) 'day_status': dayStatus,
      if (isWeeklyReportReviewed != null)
        'is_weekly_report_reviewed': isWeeklyReportReviewed,
    });
  }

  DaysTableCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String>? sessionId,
    Value<bool>? isBrokenClicked,
    Value<bool>? isGoodBoyClicked,
    Value<String>? dayStatus,
    Value<bool>? isWeeklyReportReviewed,
  }) {
    return DaysTableCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      sessionId: sessionId ?? this.sessionId,
      isBrokenClicked: isBrokenClicked ?? this.isBrokenClicked,
      isGoodBoyClicked: isGoodBoyClicked ?? this.isGoodBoyClicked,
      dayStatus: dayStatus ?? this.dayStatus,
      isWeeklyReportReviewed:
          isWeeklyReportReviewed ?? this.isWeeklyReportReviewed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (isBrokenClicked.present) {
      map['is_broken_clicked'] = Variable<bool>(isBrokenClicked.value);
    }
    if (isGoodBoyClicked.present) {
      map['is_good_boy_clicked'] = Variable<bool>(isGoodBoyClicked.value);
    }
    if (dayStatus.present) {
      map['day_status'] = Variable<String>(dayStatus.value);
    }
    if (isWeeklyReportReviewed.present) {
      map['is_weekly_report_reviewed'] = Variable<bool>(
        isWeeklyReportReviewed.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DaysTableCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('sessionId: $sessionId, ')
          ..write('isBrokenClicked: $isBrokenClicked, ')
          ..write('isGoodBoyClicked: $isGoodBoyClicked, ')
          ..write('dayStatus: $dayStatus, ')
          ..write('isWeeklyReportReviewed: $isWeeklyReportReviewed')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HabitsTableTable habitsTable = $HabitsTableTable(this);
  late final $SessionsTableTable sessionsTable = $SessionsTableTable(this);
  late final $HabitLogsTableTable habitLogsTable = $HabitLogsTableTable(this);
  late final $SessionHabitsTableTable sessionHabitsTable =
      $SessionHabitsTableTable(this);
  late final $DaysTableTable daysTable = $DaysTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    habitsTable,
    sessionsTable,
    habitLogsTable,
    sessionHabitsTable,
    daysTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('habit_logs_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('days_table', kind: UpdateKind.delete)],
    ),
  ]);
}

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

final class $$HabitsTableTableReferences
    extends BaseReferences<_$AppDatabase, $HabitsTableTable, HabitsTableData> {
  $$HabitsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HabitLogsTableTable, List<HabitLogsTableData>>
  _habitLogsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.habitLogsTable,
    aliasName: $_aliasNameGenerator(
      db.habitsTable.id,
      db.habitLogsTable.habitId,
    ),
  );

  $$HabitLogsTableTableProcessedTableManager get habitLogsTableRefs {
    final manager = $$HabitLogsTableTableTableManager(
      $_db,
      $_db.habitLogsTable,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitLogsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  Expression<bool> habitLogsTableRefs(
    Expression<bool> Function($$HabitLogsTableTableFilterComposer f) f,
  ) {
    final $$HabitLogsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogsTable,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitLogsTableTableFilterComposer(
            $db: $db,
            $table: $db.habitLogsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  Expression<T> habitLogsTableRefs<T extends Object>(
    Expression<T> Function($$HabitLogsTableTableAnnotationComposer a) f,
  ) {
    final $$HabitLogsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogsTable,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitLogsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.habitLogsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (HabitsTableData, $$HabitsTableTableReferences),
          HabitsTableData,
          PrefetchHooks Function({bool habitLogsTableRefs})
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
              .map(
                (e) => (
                  e.readTable(table),
                  $$HabitsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitLogsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (habitLogsTableRefs) db.habitLogsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (habitLogsTableRefs)
                    await $_getPrefetchedData<
                      HabitsTableData,
                      $HabitsTableTable,
                      HabitLogsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$HabitsTableTableReferences
                          ._habitLogsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$HabitsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).habitLogsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.habitId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
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
      (HabitsTableData, $$HabitsTableTableReferences),
      HabitsTableData,
      PrefetchHooks Function({bool habitLogsTableRefs})
    >;
typedef $$SessionsTableTableCreateCompanionBuilder =
    SessionsTableCompanion Function({
      required String id,
      required DateTime createdAt,
      required int phase,
      Value<double?> avgScore,
      Value<bool> isReviewed,
      Value<bool> shouldDecrease,
      Value<int> calibrationDays,
      Value<DateTime?> controlStartedAt,
      Value<double?> baseShrinkingLimit,
      Value<DateTime?> shrinkingStartedAt,
      Value<double?> decreasePercentage,
      Value<int?> decreaseIntervalDays,
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
      Value<int> calibrationDays,
      Value<DateTime?> controlStartedAt,
      Value<double?> baseShrinkingLimit,
      Value<DateTime?> shrinkingStartedAt,
      Value<double?> decreasePercentage,
      Value<int?> decreaseIntervalDays,
      Value<int> rowid,
    });

final class $$SessionsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $SessionsTableTable, SessionsTableData> {
  $$SessionsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$HabitLogsTableTable, List<HabitLogsTableData>>
  _habitLogsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.habitLogsTable,
    aliasName: $_aliasNameGenerator(
      db.sessionsTable.id,
      db.habitLogsTable.sessionId,
    ),
  );

  $$HabitLogsTableTableProcessedTableManager get habitLogsTableRefs {
    final manager = $$HabitLogsTableTableTableManager(
      $_db,
      $_db.habitLogsTable,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitLogsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DaysTableTable, List<DaysTableData>>
  _daysTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.daysTable,
    aliasName: $_aliasNameGenerator(
      db.sessionsTable.id,
      db.daysTable.sessionId,
    ),
  );

  $$DaysTableTableProcessedTableManager get daysTableRefs {
    final manager = $$DaysTableTableTableManager(
      $_db,
      $_db.daysTable,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_daysTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnFilters<int> get calibrationDays => $composableBuilder(
    column: $table.calibrationDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get controlStartedAt => $composableBuilder(
    column: $table.controlStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get baseShrinkingLimit => $composableBuilder(
    column: $table.baseShrinkingLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get shrinkingStartedAt => $composableBuilder(
    column: $table.shrinkingStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get decreasePercentage => $composableBuilder(
    column: $table.decreasePercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get decreaseIntervalDays => $composableBuilder(
    column: $table.decreaseIntervalDays,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> habitLogsTableRefs(
    Expression<bool> Function($$HabitLogsTableTableFilterComposer f) f,
  ) {
    final $$HabitLogsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogsTable,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitLogsTableTableFilterComposer(
            $db: $db,
            $table: $db.habitLogsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> daysTableRefs(
    Expression<bool> Function($$DaysTableTableFilterComposer f) f,
  ) {
    final $$DaysTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.daysTable,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaysTableTableFilterComposer(
            $db: $db,
            $table: $db.daysTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  ColumnOrderings<int> get calibrationDays => $composableBuilder(
    column: $table.calibrationDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get controlStartedAt => $composableBuilder(
    column: $table.controlStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get baseShrinkingLimit => $composableBuilder(
    column: $table.baseShrinkingLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get shrinkingStartedAt => $composableBuilder(
    column: $table.shrinkingStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get decreasePercentage => $composableBuilder(
    column: $table.decreasePercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get decreaseIntervalDays => $composableBuilder(
    column: $table.decreaseIntervalDays,
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

  GeneratedColumn<int> get calibrationDays => $composableBuilder(
    column: $table.calibrationDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get controlStartedAt => $composableBuilder(
    column: $table.controlStartedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get baseShrinkingLimit => $composableBuilder(
    column: $table.baseShrinkingLimit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get shrinkingStartedAt => $composableBuilder(
    column: $table.shrinkingStartedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get decreasePercentage => $composableBuilder(
    column: $table.decreasePercentage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get decreaseIntervalDays => $composableBuilder(
    column: $table.decreaseIntervalDays,
    builder: (column) => column,
  );

  Expression<T> habitLogsTableRefs<T extends Object>(
    Expression<T> Function($$HabitLogsTableTableAnnotationComposer a) f,
  ) {
    final $$HabitLogsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogsTable,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitLogsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.habitLogsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> daysTableRefs<T extends Object>(
    Expression<T> Function($$DaysTableTableAnnotationComposer a) f,
  ) {
    final $$DaysTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.daysTable,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaysTableTableAnnotationComposer(
            $db: $db,
            $table: $db.daysTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (SessionsTableData, $$SessionsTableTableReferences),
          SessionsTableData,
          PrefetchHooks Function({bool habitLogsTableRefs, bool daysTableRefs})
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
                Value<int> calibrationDays = const Value.absent(),
                Value<DateTime?> controlStartedAt = const Value.absent(),
                Value<double?> baseShrinkingLimit = const Value.absent(),
                Value<DateTime?> shrinkingStartedAt = const Value.absent(),
                Value<double?> decreasePercentage = const Value.absent(),
                Value<int?> decreaseIntervalDays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsTableCompanion(
                id: id,
                createdAt: createdAt,
                phase: phase,
                avgScore: avgScore,
                isReviewed: isReviewed,
                shouldDecrease: shouldDecrease,
                calibrationDays: calibrationDays,
                controlStartedAt: controlStartedAt,
                baseShrinkingLimit: baseShrinkingLimit,
                shrinkingStartedAt: shrinkingStartedAt,
                decreasePercentage: decreasePercentage,
                decreaseIntervalDays: decreaseIntervalDays,
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
                Value<int> calibrationDays = const Value.absent(),
                Value<DateTime?> controlStartedAt = const Value.absent(),
                Value<double?> baseShrinkingLimit = const Value.absent(),
                Value<DateTime?> shrinkingStartedAt = const Value.absent(),
                Value<double?> decreasePercentage = const Value.absent(),
                Value<int?> decreaseIntervalDays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                phase: phase,
                avgScore: avgScore,
                isReviewed: isReviewed,
                shouldDecrease: shouldDecrease,
                calibrationDays: calibrationDays,
                controlStartedAt: controlStartedAt,
                baseShrinkingLimit: baseShrinkingLimit,
                shrinkingStartedAt: shrinkingStartedAt,
                decreasePercentage: decreasePercentage,
                decreaseIntervalDays: decreaseIntervalDays,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({habitLogsTableRefs = false, daysTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (habitLogsTableRefs) db.habitLogsTable,
                    if (daysTableRefs) db.daysTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (habitLogsTableRefs)
                        await $_getPrefetchedData<
                          SessionsTableData,
                          $SessionsTableTable,
                          HabitLogsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableTableReferences
                              ._habitLogsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).habitLogsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (daysTableRefs)
                        await $_getPrefetchedData<
                          SessionsTableData,
                          $SessionsTableTable,
                          DaysTableData
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableTableReferences
                              ._daysTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).daysTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
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
      (SessionsTableData, $$SessionsTableTableReferences),
      SessionsTableData,
      PrefetchHooks Function({bool habitLogsTableRefs, bool daysTableRefs})
    >;
typedef $$HabitLogsTableTableCreateCompanionBuilder =
    HabitLogsTableCompanion Function({
      Value<int> id,
      required int habitId,
      required String sessionId,
      required DateTime timestamp,
    });
typedef $$HabitLogsTableTableUpdateCompanionBuilder =
    HabitLogsTableCompanion Function({
      Value<int> id,
      Value<int> habitId,
      Value<String> sessionId,
      Value<DateTime> timestamp,
    });

final class $$HabitLogsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $HabitLogsTableTable,
          HabitLogsTableData
        > {
  $$HabitLogsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HabitsTableTable _habitIdTable(_$AppDatabase db) =>
      db.habitsTable.createAlias(
        $_aliasNameGenerator(db.habitLogsTable.habitId, db.habitsTable.id),
      );

  $$HabitsTableTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<int>('habit_id')!;

    final manager = $$HabitsTableTableTableManager(
      $_db,
      $_db.habitsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SessionsTableTable _sessionIdTable(_$AppDatabase db) =>
      db.sessionsTable.createAlias(
        $_aliasNameGenerator(db.habitLogsTable.sessionId, db.sessionsTable.id),
      );

  $$SessionsTableTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableTableManager(
      $_db,
      $_db.sessionsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HabitLogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $HabitLogsTableTable> {
  $$HabitLogsTableTableFilterComposer({
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

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableTableFilterComposer get habitId {
    final $$HabitsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habitsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableTableFilterComposer(
            $db: $db,
            $table: $db.habitsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionsTableTableFilterComposer get sessionId {
    final $$SessionsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessionsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableTableFilterComposer(
            $db: $db,
            $table: $db.sessionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitLogsTableTable> {
  $$HabitLogsTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableTableOrderingComposer get habitId {
    final $$HabitsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habitsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableTableOrderingComposer(
            $db: $db,
            $table: $db.habitsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionsTableTableOrderingComposer get sessionId {
    final $$SessionsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessionsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableTableOrderingComposer(
            $db: $db,
            $table: $db.sessionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitLogsTableTable> {
  $$HabitLogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$HabitsTableTableAnnotationComposer get habitId {
    final $$HabitsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habitsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.habitsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionsTableTableAnnotationComposer get sessionId {
    final $$SessionsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessionsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitLogsTableTable,
          HabitLogsTableData,
          $$HabitLogsTableTableFilterComposer,
          $$HabitLogsTableTableOrderingComposer,
          $$HabitLogsTableTableAnnotationComposer,
          $$HabitLogsTableTableCreateCompanionBuilder,
          $$HabitLogsTableTableUpdateCompanionBuilder,
          (HabitLogsTableData, $$HabitLogsTableTableReferences),
          HabitLogsTableData,
          PrefetchHooks Function({bool habitId, bool sessionId})
        > {
  $$HabitLogsTableTableTableManager(
    _$AppDatabase db,
    $HabitLogsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitLogsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitLogsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitLogsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> habitId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => HabitLogsTableCompanion(
                id: id,
                habitId: habitId,
                sessionId: sessionId,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int habitId,
                required String sessionId,
                required DateTime timestamp,
              }) => HabitLogsTableCompanion.insert(
                id: id,
                habitId: habitId,
                sessionId: sessionId,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HabitLogsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false, sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable: $$HabitLogsTableTableReferences
                                    ._habitIdTable(db),
                                referencedColumn:
                                    $$HabitLogsTableTableReferences
                                        ._habitIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$HabitLogsTableTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn:
                                    $$HabitLogsTableTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HabitLogsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitLogsTableTable,
      HabitLogsTableData,
      $$HabitLogsTableTableFilterComposer,
      $$HabitLogsTableTableOrderingComposer,
      $$HabitLogsTableTableAnnotationComposer,
      $$HabitLogsTableTableCreateCompanionBuilder,
      $$HabitLogsTableTableUpdateCompanionBuilder,
      (HabitLogsTableData, $$HabitLogsTableTableReferences),
      HabitLogsTableData,
      PrefetchHooks Function({bool habitId, bool sessionId})
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
typedef $$DaysTableTableCreateCompanionBuilder =
    DaysTableCompanion Function({
      Value<int> id,
      required String date,
      required String sessionId,
      Value<bool> isBrokenClicked,
      Value<bool> isGoodBoyClicked,
      Value<String> dayStatus,
      Value<bool> isWeeklyReportReviewed,
    });
typedef $$DaysTableTableUpdateCompanionBuilder =
    DaysTableCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<String> sessionId,
      Value<bool> isBrokenClicked,
      Value<bool> isGoodBoyClicked,
      Value<String> dayStatus,
      Value<bool> isWeeklyReportReviewed,
    });

final class $$DaysTableTableReferences
    extends BaseReferences<_$AppDatabase, $DaysTableTable, DaysTableData> {
  $$DaysTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTableTable _sessionIdTable(_$AppDatabase db) =>
      db.sessionsTable.createAlias(
        $_aliasNameGenerator(db.daysTable.sessionId, db.sessionsTable.id),
      );

  $$SessionsTableTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableTableManager(
      $_db,
      $_db.sessionsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DaysTableTableFilterComposer
    extends Composer<_$AppDatabase, $DaysTableTable> {
  $$DaysTableTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBrokenClicked => $composableBuilder(
    column: $table.isBrokenClicked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGoodBoyClicked => $composableBuilder(
    column: $table.isGoodBoyClicked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayStatus => $composableBuilder(
    column: $table.dayStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWeeklyReportReviewed => $composableBuilder(
    column: $table.isWeeklyReportReviewed,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableTableFilterComposer get sessionId {
    final $$SessionsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessionsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableTableFilterComposer(
            $db: $db,
            $table: $db.sessionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DaysTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DaysTableTable> {
  $$DaysTableTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBrokenClicked => $composableBuilder(
    column: $table.isBrokenClicked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGoodBoyClicked => $composableBuilder(
    column: $table.isGoodBoyClicked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayStatus => $composableBuilder(
    column: $table.dayStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWeeklyReportReviewed => $composableBuilder(
    column: $table.isWeeklyReportReviewed,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableTableOrderingComposer get sessionId {
    final $$SessionsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessionsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableTableOrderingComposer(
            $db: $db,
            $table: $db.sessionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DaysTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DaysTableTable> {
  $$DaysTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get isBrokenClicked => $composableBuilder(
    column: $table.isBrokenClicked,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isGoodBoyClicked => $composableBuilder(
    column: $table.isGoodBoyClicked,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dayStatus =>
      $composableBuilder(column: $table.dayStatus, builder: (column) => column);

  GeneratedColumn<bool> get isWeeklyReportReviewed => $composableBuilder(
    column: $table.isWeeklyReportReviewed,
    builder: (column) => column,
  );

  $$SessionsTableTableAnnotationComposer get sessionId {
    final $$SessionsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessionsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DaysTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DaysTableTable,
          DaysTableData,
          $$DaysTableTableFilterComposer,
          $$DaysTableTableOrderingComposer,
          $$DaysTableTableAnnotationComposer,
          $$DaysTableTableCreateCompanionBuilder,
          $$DaysTableTableUpdateCompanionBuilder,
          (DaysTableData, $$DaysTableTableReferences),
          DaysTableData,
          PrefetchHooks Function({bool sessionId})
        > {
  $$DaysTableTableTableManager(_$AppDatabase db, $DaysTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DaysTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DaysTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DaysTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<bool> isBrokenClicked = const Value.absent(),
                Value<bool> isGoodBoyClicked = const Value.absent(),
                Value<String> dayStatus = const Value.absent(),
                Value<bool> isWeeklyReportReviewed = const Value.absent(),
              }) => DaysTableCompanion(
                id: id,
                date: date,
                sessionId: sessionId,
                isBrokenClicked: isBrokenClicked,
                isGoodBoyClicked: isGoodBoyClicked,
                dayStatus: dayStatus,
                isWeeklyReportReviewed: isWeeklyReportReviewed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required String sessionId,
                Value<bool> isBrokenClicked = const Value.absent(),
                Value<bool> isGoodBoyClicked = const Value.absent(),
                Value<String> dayStatus = const Value.absent(),
                Value<bool> isWeeklyReportReviewed = const Value.absent(),
              }) => DaysTableCompanion.insert(
                id: id,
                date: date,
                sessionId: sessionId,
                isBrokenClicked: isBrokenClicked,
                isGoodBoyClicked: isGoodBoyClicked,
                dayStatus: dayStatus,
                isWeeklyReportReviewed: isWeeklyReportReviewed,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DaysTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$DaysTableTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$DaysTableTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DaysTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DaysTableTable,
      DaysTableData,
      $$DaysTableTableFilterComposer,
      $$DaysTableTableOrderingComposer,
      $$DaysTableTableAnnotationComposer,
      $$DaysTableTableCreateCompanionBuilder,
      $$DaysTableTableUpdateCompanionBuilder,
      (DaysTableData, $$DaysTableTableReferences),
      DaysTableData,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HabitsTableTableTableManager get habitsTable =>
      $$HabitsTableTableTableManager(_db, _db.habitsTable);
  $$SessionsTableTableTableManager get sessionsTable =>
      $$SessionsTableTableTableManager(_db, _db.sessionsTable);
  $$HabitLogsTableTableTableManager get habitLogsTable =>
      $$HabitLogsTableTableTableManager(_db, _db.habitLogsTable);
  $$SessionHabitsTableTableTableManager get sessionHabitsTable =>
      $$SessionHabitsTableTableTableManager(_db, _db.sessionHabitsTable);
  $$DaysTableTableTableManager get daysTable =>
      $$DaysTableTableTableManager(_db, _db.daysTable);
}

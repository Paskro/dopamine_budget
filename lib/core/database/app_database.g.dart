// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ActionsTableTable actionsTable = $ActionsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [actionsTable];
}

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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ActionsTableTableTableManager get actionsTable =>
      $$ActionsTableTableTableManager(_db, _db.actionsTable);
}

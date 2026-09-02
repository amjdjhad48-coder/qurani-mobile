// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p0_02_encrypted_sqlite_spike.dart';

// ignore_for_file: type=lint
class $P002ProbeRecordsTable extends P002ProbeRecords
    with TableInfo<$P002ProbeRecordsTable, P002ProbeRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $P002ProbeRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'p002_probe_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<P002ProbeRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  P002ProbeRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return P002ProbeRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $P002ProbeRecordsTable createAlias(String alias) {
    return $P002ProbeRecordsTable(attachedDatabase, alias);
  }
}

class P002ProbeRecord extends DataClass implements Insertable<P002ProbeRecord> {
  final int id;
  final String payload;
  const P002ProbeRecord({required this.id, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  P002ProbeRecordsCompanion toCompanion(bool nullToAbsent) {
    return P002ProbeRecordsCompanion(id: Value(id), payload: Value(payload));
  }

  factory P002ProbeRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return P002ProbeRecord(
      id: serializer.fromJson<int>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'payload': serializer.toJson<String>(payload),
    };
  }

  P002ProbeRecord copyWith({int? id, String? payload}) =>
      P002ProbeRecord(id: id ?? this.id, payload: payload ?? this.payload);
  P002ProbeRecord copyWithCompanion(P002ProbeRecordsCompanion data) {
    return P002ProbeRecord(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('P002ProbeRecord(')
          ..write('id: $id, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is P002ProbeRecord &&
          other.id == this.id &&
          other.payload == this.payload);
}

class P002ProbeRecordsCompanion extends UpdateCompanion<P002ProbeRecord> {
  final Value<int> id;
  final Value<String> payload;
  const P002ProbeRecordsCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
  });
  P002ProbeRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String payload,
  }) : payload = Value(payload);
  static Insertable<P002ProbeRecord> custom({
    Expression<int>? id,
    Expression<String>? payload,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
    });
  }

  P002ProbeRecordsCompanion copyWith({Value<int>? id, Value<String>? payload}) {
    return P002ProbeRecordsCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('P002ProbeRecordsCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }
}

abstract class _$P002SpikeDatabase extends GeneratedDatabase {
  _$P002SpikeDatabase(QueryExecutor e) : super(e);
  $P002SpikeDatabaseManager get managers => $P002SpikeDatabaseManager(this);
  late final $P002ProbeRecordsTable p002ProbeRecords = $P002ProbeRecordsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [p002ProbeRecords];
}

typedef $$P002ProbeRecordsTableCreateCompanionBuilder =
    P002ProbeRecordsCompanion Function({
      Value<int> id,
      required String payload,
    });
typedef $$P002ProbeRecordsTableUpdateCompanionBuilder =
    P002ProbeRecordsCompanion Function({Value<int> id, Value<String> payload});

class $$P002ProbeRecordsTableFilterComposer
    extends Composer<_$P002SpikeDatabase, $P002ProbeRecordsTable> {
  $$P002ProbeRecordsTableFilterComposer({
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

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$P002ProbeRecordsTableOrderingComposer
    extends Composer<_$P002SpikeDatabase, $P002ProbeRecordsTable> {
  $$P002ProbeRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$P002ProbeRecordsTableAnnotationComposer
    extends Composer<_$P002SpikeDatabase, $P002ProbeRecordsTable> {
  $$P002ProbeRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$P002ProbeRecordsTableTableManager
    extends
        RootTableManager<
          _$P002SpikeDatabase,
          $P002ProbeRecordsTable,
          P002ProbeRecord,
          $$P002ProbeRecordsTableFilterComposer,
          $$P002ProbeRecordsTableOrderingComposer,
          $$P002ProbeRecordsTableAnnotationComposer,
          $$P002ProbeRecordsTableCreateCompanionBuilder,
          $$P002ProbeRecordsTableUpdateCompanionBuilder,
          (
            P002ProbeRecord,
            BaseReferences<
              _$P002SpikeDatabase,
              $P002ProbeRecordsTable,
              P002ProbeRecord
            >,
          ),
          P002ProbeRecord,
          PrefetchHooks Function()
        > {
  $$P002ProbeRecordsTableTableManager(
    _$P002SpikeDatabase db,
    $P002ProbeRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$P002ProbeRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$P002ProbeRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$P002ProbeRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
              }) => P002ProbeRecordsCompanion(id: id, payload: payload),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String payload,
              }) => P002ProbeRecordsCompanion.insert(id: id, payload: payload),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$P002ProbeRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$P002SpikeDatabase,
      $P002ProbeRecordsTable,
      P002ProbeRecord,
      $$P002ProbeRecordsTableFilterComposer,
      $$P002ProbeRecordsTableOrderingComposer,
      $$P002ProbeRecordsTableAnnotationComposer,
      $$P002ProbeRecordsTableCreateCompanionBuilder,
      $$P002ProbeRecordsTableUpdateCompanionBuilder,
      (
        P002ProbeRecord,
        BaseReferences<
          _$P002SpikeDatabase,
          $P002ProbeRecordsTable,
          P002ProbeRecord
        >,
      ),
      P002ProbeRecord,
      PrefetchHooks Function()
    >;

class $P002SpikeDatabaseManager {
  final _$P002SpikeDatabase _db;
  $P002SpikeDatabaseManager(this._db);
  $$P002ProbeRecordsTableTableManager get p002ProbeRecords =>
      $$P002ProbeRecordsTableTableManager(_db, _db.p002ProbeRecords);
}

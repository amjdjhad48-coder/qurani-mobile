// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HalaqahsTable extends Halaqahs with TableInfo<$HalaqahsTable, Halaqah> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HalaqahsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _teacherNameMeta = const VerificationMeta(
    'teacherName',
  );
  @override
  late final GeneratedColumn<String> teacherName = GeneratedColumn<String>(
    'teacher_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _halaqahNameMeta = const VerificationMeta(
    'halaqahName',
  );
  @override
  late final GeneratedColumn<String> halaqahName = GeneratedColumn<String>(
    'halaqah_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _centerNameMeta = const VerificationMeta(
    'centerName',
  );
  @override
  late final GeneratedColumn<String> centerName = GeneratedColumn<String>(
    'center_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    teacherName,
    halaqahName,
    centerName,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'halaqahs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Halaqah> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('teacher_name')) {
      context.handle(
        _teacherNameMeta,
        teacherName.isAcceptableOrUnknown(
          data['teacher_name']!,
          _teacherNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_teacherNameMeta);
    }
    if (data.containsKey('halaqah_name')) {
      context.handle(
        _halaqahNameMeta,
        halaqahName.isAcceptableOrUnknown(
          data['halaqah_name']!,
          _halaqahNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_halaqahNameMeta);
    }
    if (data.containsKey('center_name')) {
      context.handle(
        _centerNameMeta,
        centerName.isAcceptableOrUnknown(data['center_name']!, _centerNameMeta),
      );
    } else if (isInserting) {
      context.missing(_centerNameMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Halaqah map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Halaqah(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      teacherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_name'],
      )!,
      halaqahName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}halaqah_name'],
      )!,
      centerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}center_name'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $HalaqahsTable createAlias(String alias) {
    return $HalaqahsTable(attachedDatabase, alias);
  }
}

class Halaqah extends DataClass implements Insertable<Halaqah> {
  final int id;
  final String teacherName;
  final String halaqahName;
  final String centerName;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  const Halaqah({
    required this.id,
    required this.teacherName,
    required this.halaqahName,
    required this.centerName,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['teacher_name'] = Variable<String>(teacherName);
    map['halaqah_name'] = Variable<String>(halaqahName);
    map['center_name'] = Variable<String>(centerName);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    return map;
  }

  HalaqahsCompanion toCompanion(bool nullToAbsent) {
    return HalaqahsCompanion(
      id: Value(id),
      teacherName: Value(teacherName),
      halaqahName: Value(halaqahName),
      centerName: Value(centerName),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory Halaqah.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Halaqah(
      id: serializer.fromJson<int>(json['id']),
      teacherName: serializer.fromJson<String>(json['teacherName']),
      halaqahName: serializer.fromJson<String>(json['halaqahName']),
      centerName: serializer.fromJson<String>(json['centerName']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'teacherName': serializer.toJson<String>(teacherName),
      'halaqahName': serializer.toJson<String>(halaqahName),
      'centerName': serializer.toJson<String>(centerName),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  Halaqah copyWith({
    int? id,
    String? teacherName,
    String? halaqahName,
    String? centerName,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
  }) => Halaqah(
    id: id ?? this.id,
    teacherName: teacherName ?? this.teacherName,
    halaqahName: halaqahName ?? this.halaqahName,
    centerName: centerName ?? this.centerName,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  Halaqah copyWithCompanion(HalaqahsCompanion data) {
    return Halaqah(
      id: data.id.present ? data.id.value : this.id,
      teacherName: data.teacherName.present
          ? data.teacherName.value
          : this.teacherName,
      halaqahName: data.halaqahName.present
          ? data.halaqahName.value
          : this.halaqahName,
      centerName: data.centerName.present
          ? data.centerName.value
          : this.centerName,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Halaqah(')
          ..write('id: $id, ')
          ..write('teacherName: $teacherName, ')
          ..write('halaqahName: $halaqahName, ')
          ..write('centerName: $centerName, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    teacherName,
    halaqahName,
    centerName,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Halaqah &&
          other.id == this.id &&
          other.teacherName == this.teacherName &&
          other.halaqahName == this.halaqahName &&
          other.centerName == this.centerName &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class HalaqahsCompanion extends UpdateCompanion<Halaqah> {
  final Value<int> id;
  final Value<String> teacherName;
  final Value<String> halaqahName;
  final Value<String> centerName;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  const HalaqahsCompanion({
    this.id = const Value.absent(),
    this.teacherName = const Value.absent(),
    this.halaqahName = const Value.absent(),
    this.centerName = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  HalaqahsCompanion.insert({
    this.id = const Value.absent(),
    required String teacherName,
    required String halaqahName,
    required String centerName,
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
  }) : teacherName = Value(teacherName),
       halaqahName = Value(halaqahName),
       centerName = Value(centerName),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<Halaqah> custom({
    Expression<int>? id,
    Expression<String>? teacherName,
    Expression<String>? halaqahName,
    Expression<String>? centerName,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (teacherName != null) 'teacher_name': teacherName,
      if (halaqahName != null) 'halaqah_name': halaqahName,
      if (centerName != null) 'center_name': centerName,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  HalaqahsCompanion copyWith({
    Value<int>? id,
    Value<String>? teacherName,
    Value<String>? halaqahName,
    Value<String>? centerName,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
  }) {
    return HalaqahsCompanion(
      id: id ?? this.id,
      teacherName: teacherName ?? this.teacherName,
      halaqahName: halaqahName ?? this.halaqahName,
      centerName: centerName ?? this.centerName,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (teacherName.present) {
      map['teacher_name'] = Variable<String>(teacherName.value);
    }
    if (halaqahName.present) {
      map['halaqah_name'] = Variable<String>(halaqahName.value);
    }
    if (centerName.present) {
      map['center_name'] = Variable<String>(centerName.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HalaqahsCompanion(')
          ..write('id: $id, ')
          ..write('teacherName: $teacherName, ')
          ..write('halaqahName: $halaqahName, ')
          ..write('centerName: $centerName, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $SupportProgramSettingsTable extends SupportProgramSettings
    with TableInfo<$SupportProgramSettingsTable, SupportProgramSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupportProgramSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _halaqahIdMeta = const VerificationMeta(
    'halaqahId',
  );
  @override
  late final GeneratedColumn<int> halaqahId = GeneratedColumn<int>(
    'halaqah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES halaqahs (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _organizationNameMeta = const VerificationMeta(
    'organizationName',
  );
  @override
  late final GeneratedColumn<String> organizationName = GeneratedColumn<String>(
    'organization_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    halaqahId,
    status,
    organizationName,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'support_program_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupportProgramSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('halaqah_id')) {
      context.handle(
        _halaqahIdMeta,
        halaqahId.isAcceptableOrUnknown(data['halaqah_id']!, _halaqahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_halaqahIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('organization_name')) {
      context.handle(
        _organizationNameMeta,
        organizationName.isAcceptableOrUnknown(
          data['organization_name']!,
          _organizationNameMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {halaqahId},
  ];
  @override
  SupportProgramSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupportProgramSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      halaqahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}halaqah_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      organizationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization_name'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $SupportProgramSettingsTable createAlias(String alias) {
    return $SupportProgramSettingsTable(attachedDatabase, alias);
  }
}

class SupportProgramSetting extends DataClass
    implements Insertable<SupportProgramSetting> {
  final int id;
  final int halaqahId;
  final String status;
  final String? organizationName;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  const SupportProgramSetting({
    required this.id,
    required this.halaqahId,
    required this.status,
    this.organizationName,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['halaqah_id'] = Variable<int>(halaqahId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || organizationName != null) {
      map['organization_name'] = Variable<String>(organizationName);
    }
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    return map;
  }

  SupportProgramSettingsCompanion toCompanion(bool nullToAbsent) {
    return SupportProgramSettingsCompanion(
      id: Value(id),
      halaqahId: Value(halaqahId),
      status: Value(status),
      organizationName: organizationName == null && nullToAbsent
          ? const Value.absent()
          : Value(organizationName),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory SupportProgramSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupportProgramSetting(
      id: serializer.fromJson<int>(json['id']),
      halaqahId: serializer.fromJson<int>(json['halaqahId']),
      status: serializer.fromJson<String>(json['status']),
      organizationName: serializer.fromJson<String?>(json['organizationName']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'halaqahId': serializer.toJson<int>(halaqahId),
      'status': serializer.toJson<String>(status),
      'organizationName': serializer.toJson<String?>(organizationName),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  SupportProgramSetting copyWith({
    int? id,
    int? halaqahId,
    String? status,
    Value<String?> organizationName = const Value.absent(),
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
  }) => SupportProgramSetting(
    id: id ?? this.id,
    halaqahId: halaqahId ?? this.halaqahId,
    status: status ?? this.status,
    organizationName: organizationName.present
        ? organizationName.value
        : this.organizationName,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  SupportProgramSetting copyWithCompanion(
    SupportProgramSettingsCompanion data,
  ) {
    return SupportProgramSetting(
      id: data.id.present ? data.id.value : this.id,
      halaqahId: data.halaqahId.present ? data.halaqahId.value : this.halaqahId,
      status: data.status.present ? data.status.value : this.status,
      organizationName: data.organizationName.present
          ? data.organizationName.value
          : this.organizationName,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupportProgramSetting(')
          ..write('id: $id, ')
          ..write('halaqahId: $halaqahId, ')
          ..write('status: $status, ')
          ..write('organizationName: $organizationName, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    halaqahId,
    status,
    organizationName,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupportProgramSetting &&
          other.id == this.id &&
          other.halaqahId == this.halaqahId &&
          other.status == this.status &&
          other.organizationName == this.organizationName &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class SupportProgramSettingsCompanion
    extends UpdateCompanion<SupportProgramSetting> {
  final Value<int> id;
  final Value<int> halaqahId;
  final Value<String> status;
  final Value<String?> organizationName;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  const SupportProgramSettingsCompanion({
    this.id = const Value.absent(),
    this.halaqahId = const Value.absent(),
    this.status = const Value.absent(),
    this.organizationName = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  SupportProgramSettingsCompanion.insert({
    this.id = const Value.absent(),
    required int halaqahId,
    required String status,
    this.organizationName = const Value.absent(),
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
  }) : halaqahId = Value(halaqahId),
       status = Value(status),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<SupportProgramSetting> custom({
    Expression<int>? id,
    Expression<int>? halaqahId,
    Expression<String>? status,
    Expression<String>? organizationName,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (halaqahId != null) 'halaqah_id': halaqahId,
      if (status != null) 'status': status,
      if (organizationName != null) 'organization_name': organizationName,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  SupportProgramSettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? halaqahId,
    Value<String>? status,
    Value<String?>? organizationName,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
  }) {
    return SupportProgramSettingsCompanion(
      id: id ?? this.id,
      halaqahId: halaqahId ?? this.halaqahId,
      status: status ?? this.status,
      organizationName: organizationName ?? this.organizationName,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (halaqahId.present) {
      map['halaqah_id'] = Variable<int>(halaqahId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (organizationName.present) {
      map['organization_name'] = Variable<String>(organizationName.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupportProgramSettingsCompanion(')
          ..write('id: $id, ')
          ..write('halaqahId: $halaqahId, ')
          ..write('status: $status, ')
          ..write('organizationName: $organizationName, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $SupportProgramPeriodsTable extends SupportProgramPeriods
    with TableInfo<$SupportProgramPeriodsTable, SupportProgramPeriod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupportProgramPeriodsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _halaqahIdMeta = const VerificationMeta(
    'halaqahId',
  );
  @override
  late final GeneratedColumn<int> halaqahId = GeneratedColumn<int>(
    'halaqah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES halaqahs (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _organizationNameMeta = const VerificationMeta(
    'organizationName',
  );
  @override
  late final GeneratedColumn<String> organizationName = GeneratedColumn<String>(
    'organization_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtUtcMeta = const VerificationMeta(
    'startedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> startedAtUtc = GeneratedColumn<DateTime>(
    'started_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtUtcMeta = const VerificationMeta(
    'endedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> endedAtUtc = GeneratedColumn<DateTime>(
    'ended_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    halaqahId,
    organizationName,
    startedAtUtc,
    endedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'support_program_periods';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupportProgramPeriod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('halaqah_id')) {
      context.handle(
        _halaqahIdMeta,
        halaqahId.isAcceptableOrUnknown(data['halaqah_id']!, _halaqahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_halaqahIdMeta);
    }
    if (data.containsKey('organization_name')) {
      context.handle(
        _organizationNameMeta,
        organizationName.isAcceptableOrUnknown(
          data['organization_name']!,
          _organizationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationNameMeta);
    }
    if (data.containsKey('started_at_utc')) {
      context.handle(
        _startedAtUtcMeta,
        startedAtUtc.isAcceptableOrUnknown(
          data['started_at_utc']!,
          _startedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtUtcMeta);
    }
    if (data.containsKey('ended_at_utc')) {
      context.handle(
        _endedAtUtcMeta,
        endedAtUtc.isAcceptableOrUnknown(
          data['ended_at_utc']!,
          _endedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupportProgramPeriod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupportProgramPeriod(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      halaqahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}halaqah_id'],
      )!,
      organizationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization_name'],
      )!,
      startedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at_utc'],
      )!,
      endedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at_utc'],
      ),
    );
  }

  @override
  $SupportProgramPeriodsTable createAlias(String alias) {
    return $SupportProgramPeriodsTable(attachedDatabase, alias);
  }
}

class SupportProgramPeriod extends DataClass
    implements Insertable<SupportProgramPeriod> {
  final int id;
  final int halaqahId;
  final String organizationName;
  final DateTime startedAtUtc;
  final DateTime? endedAtUtc;
  const SupportProgramPeriod({
    required this.id,
    required this.halaqahId,
    required this.organizationName,
    required this.startedAtUtc,
    this.endedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['halaqah_id'] = Variable<int>(halaqahId);
    map['organization_name'] = Variable<String>(organizationName);
    map['started_at_utc'] = Variable<DateTime>(startedAtUtc);
    if (!nullToAbsent || endedAtUtc != null) {
      map['ended_at_utc'] = Variable<DateTime>(endedAtUtc);
    }
    return map;
  }

  SupportProgramPeriodsCompanion toCompanion(bool nullToAbsent) {
    return SupportProgramPeriodsCompanion(
      id: Value(id),
      halaqahId: Value(halaqahId),
      organizationName: Value(organizationName),
      startedAtUtc: Value(startedAtUtc),
      endedAtUtc: endedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAtUtc),
    );
  }

  factory SupportProgramPeriod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupportProgramPeriod(
      id: serializer.fromJson<int>(json['id']),
      halaqahId: serializer.fromJson<int>(json['halaqahId']),
      organizationName: serializer.fromJson<String>(json['organizationName']),
      startedAtUtc: serializer.fromJson<DateTime>(json['startedAtUtc']),
      endedAtUtc: serializer.fromJson<DateTime?>(json['endedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'halaqahId': serializer.toJson<int>(halaqahId),
      'organizationName': serializer.toJson<String>(organizationName),
      'startedAtUtc': serializer.toJson<DateTime>(startedAtUtc),
      'endedAtUtc': serializer.toJson<DateTime?>(endedAtUtc),
    };
  }

  SupportProgramPeriod copyWith({
    int? id,
    int? halaqahId,
    String? organizationName,
    DateTime? startedAtUtc,
    Value<DateTime?> endedAtUtc = const Value.absent(),
  }) => SupportProgramPeriod(
    id: id ?? this.id,
    halaqahId: halaqahId ?? this.halaqahId,
    organizationName: organizationName ?? this.organizationName,
    startedAtUtc: startedAtUtc ?? this.startedAtUtc,
    endedAtUtc: endedAtUtc.present ? endedAtUtc.value : this.endedAtUtc,
  );
  SupportProgramPeriod copyWithCompanion(SupportProgramPeriodsCompanion data) {
    return SupportProgramPeriod(
      id: data.id.present ? data.id.value : this.id,
      halaqahId: data.halaqahId.present ? data.halaqahId.value : this.halaqahId,
      organizationName: data.organizationName.present
          ? data.organizationName.value
          : this.organizationName,
      startedAtUtc: data.startedAtUtc.present
          ? data.startedAtUtc.value
          : this.startedAtUtc,
      endedAtUtc: data.endedAtUtc.present
          ? data.endedAtUtc.value
          : this.endedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupportProgramPeriod(')
          ..write('id: $id, ')
          ..write('halaqahId: $halaqahId, ')
          ..write('organizationName: $organizationName, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('endedAtUtc: $endedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, halaqahId, organizationName, startedAtUtc, endedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupportProgramPeriod &&
          other.id == this.id &&
          other.halaqahId == this.halaqahId &&
          other.organizationName == this.organizationName &&
          other.startedAtUtc == this.startedAtUtc &&
          other.endedAtUtc == this.endedAtUtc);
}

class SupportProgramPeriodsCompanion
    extends UpdateCompanion<SupportProgramPeriod> {
  final Value<int> id;
  final Value<int> halaqahId;
  final Value<String> organizationName;
  final Value<DateTime> startedAtUtc;
  final Value<DateTime?> endedAtUtc;
  const SupportProgramPeriodsCompanion({
    this.id = const Value.absent(),
    this.halaqahId = const Value.absent(),
    this.organizationName = const Value.absent(),
    this.startedAtUtc = const Value.absent(),
    this.endedAtUtc = const Value.absent(),
  });
  SupportProgramPeriodsCompanion.insert({
    this.id = const Value.absent(),
    required int halaqahId,
    required String organizationName,
    required DateTime startedAtUtc,
    this.endedAtUtc = const Value.absent(),
  }) : halaqahId = Value(halaqahId),
       organizationName = Value(organizationName),
       startedAtUtc = Value(startedAtUtc);
  static Insertable<SupportProgramPeriod> custom({
    Expression<int>? id,
    Expression<int>? halaqahId,
    Expression<String>? organizationName,
    Expression<DateTime>? startedAtUtc,
    Expression<DateTime>? endedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (halaqahId != null) 'halaqah_id': halaqahId,
      if (organizationName != null) 'organization_name': organizationName,
      if (startedAtUtc != null) 'started_at_utc': startedAtUtc,
      if (endedAtUtc != null) 'ended_at_utc': endedAtUtc,
    });
  }

  SupportProgramPeriodsCompanion copyWith({
    Value<int>? id,
    Value<int>? halaqahId,
    Value<String>? organizationName,
    Value<DateTime>? startedAtUtc,
    Value<DateTime?>? endedAtUtc,
  }) {
    return SupportProgramPeriodsCompanion(
      id: id ?? this.id,
      halaqahId: halaqahId ?? this.halaqahId,
      organizationName: organizationName ?? this.organizationName,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      endedAtUtc: endedAtUtc ?? this.endedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (halaqahId.present) {
      map['halaqah_id'] = Variable<int>(halaqahId.value);
    }
    if (organizationName.present) {
      map['organization_name'] = Variable<String>(organizationName.value);
    }
    if (startedAtUtc.present) {
      map['started_at_utc'] = Variable<DateTime>(startedAtUtc.value);
    }
    if (endedAtUtc.present) {
      map['ended_at_utc'] = Variable<DateTime>(endedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupportProgramPeriodsCompanion(')
          ..write('id: $id, ')
          ..write('halaqahId: $halaqahId, ')
          ..write('organizationName: $organizationName, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('endedAtUtc: $endedAtUtc')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HalaqahsTable halaqahs = $HalaqahsTable(this);
  late final $SupportProgramSettingsTable supportProgramSettings =
      $SupportProgramSettingsTable(this);
  late final $SupportProgramPeriodsTable supportProgramPeriods =
      $SupportProgramPeriodsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    halaqahs,
    supportProgramSettings,
    supportProgramPeriods,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$HalaqahsTableCreateCompanionBuilder =
    HalaqahsCompanion Function({
      Value<int> id,
      required String teacherName,
      required String halaqahName,
      required String centerName,
      required DateTime createdAtUtc,
      required DateTime updatedAtUtc,
    });
typedef $$HalaqahsTableUpdateCompanionBuilder =
    HalaqahsCompanion Function({
      Value<int> id,
      Value<String> teacherName,
      Value<String> halaqahName,
      Value<String> centerName,
      Value<DateTime> createdAtUtc,
      Value<DateTime> updatedAtUtc,
    });

final class $$HalaqahsTableReferences
    extends BaseReferences<_$AppDatabase, $HalaqahsTable, Halaqah> {
  $$HalaqahsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $SupportProgramSettingsTable,
    List<SupportProgramSetting>
  >
  _supportProgramSettingsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.supportProgramSettings,
        aliasName: 'halaqahs__id__support_program_settings__halaqah_id',
      );

  $$SupportProgramSettingsTableProcessedTableManager
  get supportProgramSettingsRefs {
    final manager = $$SupportProgramSettingsTableTableManager(
      $_db,
      $_db.supportProgramSettings,
    ).filter((f) => f.halaqahId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supportProgramSettingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SupportProgramPeriodsTable,
    List<SupportProgramPeriod>
  >
  _supportProgramPeriodsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.supportProgramPeriods,
        aliasName: 'halaqahs__id__support_program_periods__halaqah_id',
      );

  $$SupportProgramPeriodsTableProcessedTableManager
  get supportProgramPeriodsRefs {
    final manager = $$SupportProgramPeriodsTableTableManager(
      $_db,
      $_db.supportProgramPeriods,
    ).filter((f) => f.halaqahId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supportProgramPeriodsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HalaqahsTableFilterComposer
    extends Composer<_$AppDatabase, $HalaqahsTable> {
  $$HalaqahsTableFilterComposer({
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

  ColumnFilters<String> get teacherName => $composableBuilder(
    column: $table.teacherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get halaqahName => $composableBuilder(
    column: $table.halaqahName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get centerName => $composableBuilder(
    column: $table.centerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> supportProgramSettingsRefs(
    Expression<bool> Function($$SupportProgramSettingsTableFilterComposer f) f,
  ) {
    final $$SupportProgramSettingsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportProgramSettings,
          getReferencedColumn: (t) => t.halaqahId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportProgramSettingsTableFilterComposer(
                $db: $db,
                $table: $db.supportProgramSettings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> supportProgramPeriodsRefs(
    Expression<bool> Function($$SupportProgramPeriodsTableFilterComposer f) f,
  ) {
    final $$SupportProgramPeriodsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportProgramPeriods,
          getReferencedColumn: (t) => t.halaqahId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportProgramPeriodsTableFilterComposer(
                $db: $db,
                $table: $db.supportProgramPeriods,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$HalaqahsTableOrderingComposer
    extends Composer<_$AppDatabase, $HalaqahsTable> {
  $$HalaqahsTableOrderingComposer({
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

  ColumnOrderings<String> get teacherName => $composableBuilder(
    column: $table.teacherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get halaqahName => $composableBuilder(
    column: $table.halaqahName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get centerName => $composableBuilder(
    column: $table.centerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HalaqahsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HalaqahsTable> {
  $$HalaqahsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get teacherName => $composableBuilder(
    column: $table.teacherName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get halaqahName => $composableBuilder(
    column: $table.halaqahName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get centerName => $composableBuilder(
    column: $table.centerName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  Expression<T> supportProgramSettingsRefs<T extends Object>(
    Expression<T> Function($$SupportProgramSettingsTableAnnotationComposer a) f,
  ) {
    final $$SupportProgramSettingsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportProgramSettings,
          getReferencedColumn: (t) => t.halaqahId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportProgramSettingsTableAnnotationComposer(
                $db: $db,
                $table: $db.supportProgramSettings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> supportProgramPeriodsRefs<T extends Object>(
    Expression<T> Function($$SupportProgramPeriodsTableAnnotationComposer a) f,
  ) {
    final $$SupportProgramPeriodsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportProgramPeriods,
          getReferencedColumn: (t) => t.halaqahId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportProgramPeriodsTableAnnotationComposer(
                $db: $db,
                $table: $db.supportProgramPeriods,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$HalaqahsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HalaqahsTable,
          Halaqah,
          $$HalaqahsTableFilterComposer,
          $$HalaqahsTableOrderingComposer,
          $$HalaqahsTableAnnotationComposer,
          $$HalaqahsTableCreateCompanionBuilder,
          $$HalaqahsTableUpdateCompanionBuilder,
          (Halaqah, $$HalaqahsTableReferences),
          Halaqah,
          PrefetchHooks Function({
            bool supportProgramSettingsRefs,
            bool supportProgramPeriodsRefs,
          })
        > {
  $$HalaqahsTableTableManager(_$AppDatabase db, $HalaqahsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HalaqahsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HalaqahsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HalaqahsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> teacherName = const Value.absent(),
                Value<String> halaqahName = const Value.absent(),
                Value<String> centerName = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
              }) => HalaqahsCompanion(
                id: id,
                teacherName: teacherName,
                halaqahName: halaqahName,
                centerName: centerName,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String teacherName,
                required String halaqahName,
                required String centerName,
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
              }) => HalaqahsCompanion.insert(
                id: id,
                teacherName: teacherName,
                halaqahName: halaqahName,
                centerName: centerName,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HalaqahsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                supportProgramSettingsRefs = false,
                supportProgramPeriodsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (supportProgramSettingsRefs) db.supportProgramSettings,
                    if (supportProgramPeriodsRefs) db.supportProgramPeriods,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (supportProgramSettingsRefs)
                        await $_getPrefetchedData<
                          Halaqah,
                          $HalaqahsTable,
                          SupportProgramSetting
                        >(
                          currentTable: table,
                          referencedTable: $$HalaqahsTableReferences
                              ._supportProgramSettingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HalaqahsTableReferences(
                                db,
                                table,
                                p0,
                              ).supportProgramSettingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.halaqahId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supportProgramPeriodsRefs)
                        await $_getPrefetchedData<
                          Halaqah,
                          $HalaqahsTable,
                          SupportProgramPeriod
                        >(
                          currentTable: table,
                          referencedTable: $$HalaqahsTableReferences
                              ._supportProgramPeriodsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HalaqahsTableReferences(
                                db,
                                table,
                                p0,
                              ).supportProgramPeriodsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.halaqahId == item.id,
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

typedef $$HalaqahsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HalaqahsTable,
      Halaqah,
      $$HalaqahsTableFilterComposer,
      $$HalaqahsTableOrderingComposer,
      $$HalaqahsTableAnnotationComposer,
      $$HalaqahsTableCreateCompanionBuilder,
      $$HalaqahsTableUpdateCompanionBuilder,
      (Halaqah, $$HalaqahsTableReferences),
      Halaqah,
      PrefetchHooks Function({
        bool supportProgramSettingsRefs,
        bool supportProgramPeriodsRefs,
      })
    >;
typedef $$SupportProgramSettingsTableCreateCompanionBuilder =
    SupportProgramSettingsCompanion Function({
      Value<int> id,
      required int halaqahId,
      required String status,
      Value<String?> organizationName,
      required DateTime createdAtUtc,
      required DateTime updatedAtUtc,
    });
typedef $$SupportProgramSettingsTableUpdateCompanionBuilder =
    SupportProgramSettingsCompanion Function({
      Value<int> id,
      Value<int> halaqahId,
      Value<String> status,
      Value<String?> organizationName,
      Value<DateTime> createdAtUtc,
      Value<DateTime> updatedAtUtc,
    });

final class $$SupportProgramSettingsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SupportProgramSettingsTable,
          SupportProgramSetting
        > {
  $$SupportProgramSettingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HalaqahsTable _halaqahIdTable(_$AppDatabase db) => db.halaqahs
      .createAlias('support_program_settings__halaqah_id__halaqahs__id');

  $$HalaqahsTableProcessedTableManager get halaqahId {
    final $_column = $_itemColumn<int>('halaqah_id')!;

    final manager = $$HalaqahsTableTableManager(
      $_db,
      $_db.halaqahs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_halaqahIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SupportProgramSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SupportProgramSettingsTable> {
  $$SupportProgramSettingsTableFilterComposer({
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

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organizationName => $composableBuilder(
    column: $table.organizationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$HalaqahsTableFilterComposer get halaqahId {
    final $$HalaqahsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.halaqahId,
      referencedTable: $db.halaqahs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HalaqahsTableFilterComposer(
            $db: $db,
            $table: $db.halaqahs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupportProgramSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupportProgramSettingsTable> {
  $$SupportProgramSettingsTableOrderingComposer({
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organizationName => $composableBuilder(
    column: $table.organizationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$HalaqahsTableOrderingComposer get halaqahId {
    final $$HalaqahsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.halaqahId,
      referencedTable: $db.halaqahs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HalaqahsTableOrderingComposer(
            $db: $db,
            $table: $db.halaqahs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupportProgramSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupportProgramSettingsTable> {
  $$SupportProgramSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get organizationName => $composableBuilder(
    column: $table.organizationName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  $$HalaqahsTableAnnotationComposer get halaqahId {
    final $$HalaqahsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.halaqahId,
      referencedTable: $db.halaqahs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HalaqahsTableAnnotationComposer(
            $db: $db,
            $table: $db.halaqahs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupportProgramSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupportProgramSettingsTable,
          SupportProgramSetting,
          $$SupportProgramSettingsTableFilterComposer,
          $$SupportProgramSettingsTableOrderingComposer,
          $$SupportProgramSettingsTableAnnotationComposer,
          $$SupportProgramSettingsTableCreateCompanionBuilder,
          $$SupportProgramSettingsTableUpdateCompanionBuilder,
          (SupportProgramSetting, $$SupportProgramSettingsTableReferences),
          SupportProgramSetting,
          PrefetchHooks Function({bool halaqahId})
        > {
  $$SupportProgramSettingsTableTableManager(
    _$AppDatabase db,
    $SupportProgramSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupportProgramSettingsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SupportProgramSettingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SupportProgramSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> halaqahId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> organizationName = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
              }) => SupportProgramSettingsCompanion(
                id: id,
                halaqahId: halaqahId,
                status: status,
                organizationName: organizationName,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int halaqahId,
                required String status,
                Value<String?> organizationName = const Value.absent(),
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
              }) => SupportProgramSettingsCompanion.insert(
                id: id,
                halaqahId: halaqahId,
                status: status,
                organizationName: organizationName,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SupportProgramSettingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({halaqahId = false}) {
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
                    if (halaqahId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.halaqahId,
                                referencedTable:
                                    $$SupportProgramSettingsTableReferences
                                        ._halaqahIdTable(db),
                                referencedColumn:
                                    $$SupportProgramSettingsTableReferences
                                        ._halaqahIdTable(db)
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

typedef $$SupportProgramSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupportProgramSettingsTable,
      SupportProgramSetting,
      $$SupportProgramSettingsTableFilterComposer,
      $$SupportProgramSettingsTableOrderingComposer,
      $$SupportProgramSettingsTableAnnotationComposer,
      $$SupportProgramSettingsTableCreateCompanionBuilder,
      $$SupportProgramSettingsTableUpdateCompanionBuilder,
      (SupportProgramSetting, $$SupportProgramSettingsTableReferences),
      SupportProgramSetting,
      PrefetchHooks Function({bool halaqahId})
    >;
typedef $$SupportProgramPeriodsTableCreateCompanionBuilder =
    SupportProgramPeriodsCompanion Function({
      Value<int> id,
      required int halaqahId,
      required String organizationName,
      required DateTime startedAtUtc,
      Value<DateTime?> endedAtUtc,
    });
typedef $$SupportProgramPeriodsTableUpdateCompanionBuilder =
    SupportProgramPeriodsCompanion Function({
      Value<int> id,
      Value<int> halaqahId,
      Value<String> organizationName,
      Value<DateTime> startedAtUtc,
      Value<DateTime?> endedAtUtc,
    });

final class $$SupportProgramPeriodsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SupportProgramPeriodsTable,
          SupportProgramPeriod
        > {
  $$SupportProgramPeriodsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HalaqahsTable _halaqahIdTable(_$AppDatabase db) => db.halaqahs
      .createAlias('support_program_periods__halaqah_id__halaqahs__id');

  $$HalaqahsTableProcessedTableManager get halaqahId {
    final $_column = $_itemColumn<int>('halaqah_id')!;

    final manager = $$HalaqahsTableTableManager(
      $_db,
      $_db.halaqahs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_halaqahIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SupportProgramPeriodsTableFilterComposer
    extends Composer<_$AppDatabase, $SupportProgramPeriodsTable> {
  $$SupportProgramPeriodsTableFilterComposer({
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

  ColumnFilters<String> get organizationName => $composableBuilder(
    column: $table.organizationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAtUtc => $composableBuilder(
    column: $table.endedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$HalaqahsTableFilterComposer get halaqahId {
    final $$HalaqahsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.halaqahId,
      referencedTable: $db.halaqahs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HalaqahsTableFilterComposer(
            $db: $db,
            $table: $db.halaqahs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupportProgramPeriodsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupportProgramPeriodsTable> {
  $$SupportProgramPeriodsTableOrderingComposer({
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

  ColumnOrderings<String> get organizationName => $composableBuilder(
    column: $table.organizationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAtUtc => $composableBuilder(
    column: $table.endedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$HalaqahsTableOrderingComposer get halaqahId {
    final $$HalaqahsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.halaqahId,
      referencedTable: $db.halaqahs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HalaqahsTableOrderingComposer(
            $db: $db,
            $table: $db.halaqahs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupportProgramPeriodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupportProgramPeriodsTable> {
  $$SupportProgramPeriodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get organizationName => $composableBuilder(
    column: $table.organizationName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endedAtUtc => $composableBuilder(
    column: $table.endedAtUtc,
    builder: (column) => column,
  );

  $$HalaqahsTableAnnotationComposer get halaqahId {
    final $$HalaqahsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.halaqahId,
      referencedTable: $db.halaqahs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HalaqahsTableAnnotationComposer(
            $db: $db,
            $table: $db.halaqahs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupportProgramPeriodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupportProgramPeriodsTable,
          SupportProgramPeriod,
          $$SupportProgramPeriodsTableFilterComposer,
          $$SupportProgramPeriodsTableOrderingComposer,
          $$SupportProgramPeriodsTableAnnotationComposer,
          $$SupportProgramPeriodsTableCreateCompanionBuilder,
          $$SupportProgramPeriodsTableUpdateCompanionBuilder,
          (SupportProgramPeriod, $$SupportProgramPeriodsTableReferences),
          SupportProgramPeriod,
          PrefetchHooks Function({bool halaqahId})
        > {
  $$SupportProgramPeriodsTableTableManager(
    _$AppDatabase db,
    $SupportProgramPeriodsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupportProgramPeriodsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SupportProgramPeriodsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SupportProgramPeriodsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> halaqahId = const Value.absent(),
                Value<String> organizationName = const Value.absent(),
                Value<DateTime> startedAtUtc = const Value.absent(),
                Value<DateTime?> endedAtUtc = const Value.absent(),
              }) => SupportProgramPeriodsCompanion(
                id: id,
                halaqahId: halaqahId,
                organizationName: organizationName,
                startedAtUtc: startedAtUtc,
                endedAtUtc: endedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int halaqahId,
                required String organizationName,
                required DateTime startedAtUtc,
                Value<DateTime?> endedAtUtc = const Value.absent(),
              }) => SupportProgramPeriodsCompanion.insert(
                id: id,
                halaqahId: halaqahId,
                organizationName: organizationName,
                startedAtUtc: startedAtUtc,
                endedAtUtc: endedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SupportProgramPeriodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({halaqahId = false}) {
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
                    if (halaqahId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.halaqahId,
                                referencedTable:
                                    $$SupportProgramPeriodsTableReferences
                                        ._halaqahIdTable(db),
                                referencedColumn:
                                    $$SupportProgramPeriodsTableReferences
                                        ._halaqahIdTable(db)
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

typedef $$SupportProgramPeriodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupportProgramPeriodsTable,
      SupportProgramPeriod,
      $$SupportProgramPeriodsTableFilterComposer,
      $$SupportProgramPeriodsTableOrderingComposer,
      $$SupportProgramPeriodsTableAnnotationComposer,
      $$SupportProgramPeriodsTableCreateCompanionBuilder,
      $$SupportProgramPeriodsTableUpdateCompanionBuilder,
      (SupportProgramPeriod, $$SupportProgramPeriodsTableReferences),
      SupportProgramPeriod,
      PrefetchHooks Function({bool halaqahId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HalaqahsTableTableManager get halaqahs =>
      $$HalaqahsTableTableManager(_db, _db.halaqahs);
  $$SupportProgramSettingsTableTableManager get supportProgramSettings =>
      $$SupportProgramSettingsTableTableManager(
        _db,
        _db.supportProgramSettings,
      );
  $$SupportProgramPeriodsTableTableManager get supportProgramPeriods =>
      $$SupportProgramPeriodsTableTableManager(_db, _db.supportProgramPeriods);
}

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

class $StudentsTable extends Students with TableInfo<$StudentsTable, Student> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _studentNameMeta = const VerificationMeta(
    'studentName',
  );
  @override
  late final GeneratedColumn<String> studentName = GeneratedColumn<String>(
    'student_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatherNameMeta = const VerificationMeta(
    'fatherName',
  );
  @override
  late final GeneratedColumn<String> fatherName = GeneratedColumn<String>(
    'father_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageYearsMeta = const VerificationMeta(
    'ageYears',
  );
  @override
  late final GeneratedColumn<int> ageYears = GeneratedColumn<int>(
    'age_years',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _guardianCountryCodeMeta =
      const VerificationMeta('guardianCountryCode');
  @override
  late final GeneratedColumn<String> guardianCountryCode =
      GeneratedColumn<String>(
        'guardian_country_code',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 4,
          maxTextLength: 4,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _guardianNationalNumberMeta =
      const VerificationMeta('guardianNationalNumber');
  @override
  late final GeneratedColumn<String> guardianNationalNumber =
      GeneratedColumn<String>(
        'guardian_national_number',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _previousMemorizationTextMeta =
      const VerificationMeta('previousMemorizationText');
  @override
  late final GeneratedColumn<String> previousMemorizationText =
      GeneratedColumn<String>(
        'previous_memorization_text',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supportStudentNumberMeta =
      const VerificationMeta('supportStudentNumber');
  @override
  late final GeneratedColumn<String> supportStudentNumber =
      GeneratedColumn<String>(
        'support_student_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _displayOrderMeta = const VerificationMeta(
    'displayOrder',
  );
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
    'display_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _archivedAtUtcMeta = const VerificationMeta(
    'archivedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAtUtc =
      GeneratedColumn<DateTime>(
        'archived_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    halaqahId,
    studentName,
    fatherName,
    ageYears,
    guardianCountryCode,
    guardianNationalNumber,
    previousMemorizationText,
    note,
    supportStudentNumber,
    displayOrder,
    isActive,
    archivedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(
    Insertable<Student> instance, {
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
    if (data.containsKey('student_name')) {
      context.handle(
        _studentNameMeta,
        studentName.isAcceptableOrUnknown(
          data['student_name']!,
          _studentNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_studentNameMeta);
    }
    if (data.containsKey('father_name')) {
      context.handle(
        _fatherNameMeta,
        fatherName.isAcceptableOrUnknown(data['father_name']!, _fatherNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fatherNameMeta);
    }
    if (data.containsKey('age_years')) {
      context.handle(
        _ageYearsMeta,
        ageYears.isAcceptableOrUnknown(data['age_years']!, _ageYearsMeta),
      );
    } else if (isInserting) {
      context.missing(_ageYearsMeta);
    }
    if (data.containsKey('guardian_country_code')) {
      context.handle(
        _guardianCountryCodeMeta,
        guardianCountryCode.isAcceptableOrUnknown(
          data['guardian_country_code']!,
          _guardianCountryCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_guardianCountryCodeMeta);
    }
    if (data.containsKey('guardian_national_number')) {
      context.handle(
        _guardianNationalNumberMeta,
        guardianNationalNumber.isAcceptableOrUnknown(
          data['guardian_national_number']!,
          _guardianNationalNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_guardianNationalNumberMeta);
    }
    if (data.containsKey('previous_memorization_text')) {
      context.handle(
        _previousMemorizationTextMeta,
        previousMemorizationText.isAcceptableOrUnknown(
          data['previous_memorization_text']!,
          _previousMemorizationTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previousMemorizationTextMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('support_student_number')) {
      context.handle(
        _supportStudentNumberMeta,
        supportStudentNumber.isAcceptableOrUnknown(
          data['support_student_number']!,
          _supportStudentNumberMeta,
        ),
      );
    }
    if (data.containsKey('display_order')) {
      context.handle(
        _displayOrderMeta,
        displayOrder.isAcceptableOrUnknown(
          data['display_order']!,
          _displayOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayOrderMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('archived_at_utc')) {
      context.handle(
        _archivedAtUtcMeta,
        archivedAtUtc.isAcceptableOrUnknown(
          data['archived_at_utc']!,
          _archivedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {halaqahId, supportStudentNumber},
  ];
  @override
  Student map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Student(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      halaqahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}halaqah_id'],
      )!,
      studentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_name'],
      )!,
      fatherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_name'],
      )!,
      ageYears: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age_years'],
      )!,
      guardianCountryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guardian_country_code'],
      )!,
      guardianNationalNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guardian_national_number'],
      )!,
      previousMemorizationText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_memorization_text'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      supportStudentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}support_student_number'],
      ),
      displayOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      archivedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at_utc'],
      ),
    );
  }

  @override
  $StudentsTable createAlias(String alias) {
    return $StudentsTable(attachedDatabase, alias);
  }
}

class Student extends DataClass implements Insertable<Student> {
  final int id;
  final int halaqahId;
  final String studentName;
  final String fatherName;
  final int ageYears;
  final String guardianCountryCode;
  final String guardianNationalNumber;
  final String previousMemorizationText;
  final String? note;
  final String? supportStudentNumber;
  final int displayOrder;
  final bool isActive;
  final DateTime? archivedAtUtc;
  const Student({
    required this.id,
    required this.halaqahId,
    required this.studentName,
    required this.fatherName,
    required this.ageYears,
    required this.guardianCountryCode,
    required this.guardianNationalNumber,
    required this.previousMemorizationText,
    this.note,
    this.supportStudentNumber,
    required this.displayOrder,
    required this.isActive,
    this.archivedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['halaqah_id'] = Variable<int>(halaqahId);
    map['student_name'] = Variable<String>(studentName);
    map['father_name'] = Variable<String>(fatherName);
    map['age_years'] = Variable<int>(ageYears);
    map['guardian_country_code'] = Variable<String>(guardianCountryCode);
    map['guardian_national_number'] = Variable<String>(guardianNationalNumber);
    map['previous_memorization_text'] = Variable<String>(
      previousMemorizationText,
    );
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || supportStudentNumber != null) {
      map['support_student_number'] = Variable<String>(supportStudentNumber);
    }
    map['display_order'] = Variable<int>(displayOrder);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || archivedAtUtc != null) {
      map['archived_at_utc'] = Variable<DateTime>(archivedAtUtc);
    }
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      id: Value(id),
      halaqahId: Value(halaqahId),
      studentName: Value(studentName),
      fatherName: Value(fatherName),
      ageYears: Value(ageYears),
      guardianCountryCode: Value(guardianCountryCode),
      guardianNationalNumber: Value(guardianNationalNumber),
      previousMemorizationText: Value(previousMemorizationText),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      supportStudentNumber: supportStudentNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(supportStudentNumber),
      displayOrder: Value(displayOrder),
      isActive: Value(isActive),
      archivedAtUtc: archivedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAtUtc),
    );
  }

  factory Student.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Student(
      id: serializer.fromJson<int>(json['id']),
      halaqahId: serializer.fromJson<int>(json['halaqahId']),
      studentName: serializer.fromJson<String>(json['studentName']),
      fatherName: serializer.fromJson<String>(json['fatherName']),
      ageYears: serializer.fromJson<int>(json['ageYears']),
      guardianCountryCode: serializer.fromJson<String>(
        json['guardianCountryCode'],
      ),
      guardianNationalNumber: serializer.fromJson<String>(
        json['guardianNationalNumber'],
      ),
      previousMemorizationText: serializer.fromJson<String>(
        json['previousMemorizationText'],
      ),
      note: serializer.fromJson<String?>(json['note']),
      supportStudentNumber: serializer.fromJson<String?>(
        json['supportStudentNumber'],
      ),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      archivedAtUtc: serializer.fromJson<DateTime?>(json['archivedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'halaqahId': serializer.toJson<int>(halaqahId),
      'studentName': serializer.toJson<String>(studentName),
      'fatherName': serializer.toJson<String>(fatherName),
      'ageYears': serializer.toJson<int>(ageYears),
      'guardianCountryCode': serializer.toJson<String>(guardianCountryCode),
      'guardianNationalNumber': serializer.toJson<String>(
        guardianNationalNumber,
      ),
      'previousMemorizationText': serializer.toJson<String>(
        previousMemorizationText,
      ),
      'note': serializer.toJson<String?>(note),
      'supportStudentNumber': serializer.toJson<String?>(supportStudentNumber),
      'displayOrder': serializer.toJson<int>(displayOrder),
      'isActive': serializer.toJson<bool>(isActive),
      'archivedAtUtc': serializer.toJson<DateTime?>(archivedAtUtc),
    };
  }

  Student copyWith({
    int? id,
    int? halaqahId,
    String? studentName,
    String? fatherName,
    int? ageYears,
    String? guardianCountryCode,
    String? guardianNationalNumber,
    String? previousMemorizationText,
    Value<String?> note = const Value.absent(),
    Value<String?> supportStudentNumber = const Value.absent(),
    int? displayOrder,
    bool? isActive,
    Value<DateTime?> archivedAtUtc = const Value.absent(),
  }) => Student(
    id: id ?? this.id,
    halaqahId: halaqahId ?? this.halaqahId,
    studentName: studentName ?? this.studentName,
    fatherName: fatherName ?? this.fatherName,
    ageYears: ageYears ?? this.ageYears,
    guardianCountryCode: guardianCountryCode ?? this.guardianCountryCode,
    guardianNationalNumber:
        guardianNationalNumber ?? this.guardianNationalNumber,
    previousMemorizationText:
        previousMemorizationText ?? this.previousMemorizationText,
    note: note.present ? note.value : this.note,
    supportStudentNumber: supportStudentNumber.present
        ? supportStudentNumber.value
        : this.supportStudentNumber,
    displayOrder: displayOrder ?? this.displayOrder,
    isActive: isActive ?? this.isActive,
    archivedAtUtc: archivedAtUtc.present
        ? archivedAtUtc.value
        : this.archivedAtUtc,
  );
  Student copyWithCompanion(StudentsCompanion data) {
    return Student(
      id: data.id.present ? data.id.value : this.id,
      halaqahId: data.halaqahId.present ? data.halaqahId.value : this.halaqahId,
      studentName: data.studentName.present
          ? data.studentName.value
          : this.studentName,
      fatherName: data.fatherName.present
          ? data.fatherName.value
          : this.fatherName,
      ageYears: data.ageYears.present ? data.ageYears.value : this.ageYears,
      guardianCountryCode: data.guardianCountryCode.present
          ? data.guardianCountryCode.value
          : this.guardianCountryCode,
      guardianNationalNumber: data.guardianNationalNumber.present
          ? data.guardianNationalNumber.value
          : this.guardianNationalNumber,
      previousMemorizationText: data.previousMemorizationText.present
          ? data.previousMemorizationText.value
          : this.previousMemorizationText,
      note: data.note.present ? data.note.value : this.note,
      supportStudentNumber: data.supportStudentNumber.present
          ? data.supportStudentNumber.value
          : this.supportStudentNumber,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      archivedAtUtc: data.archivedAtUtc.present
          ? data.archivedAtUtc.value
          : this.archivedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Student(')
          ..write('id: $id, ')
          ..write('halaqahId: $halaqahId, ')
          ..write('studentName: $studentName, ')
          ..write('fatherName: $fatherName, ')
          ..write('ageYears: $ageYears, ')
          ..write('guardianCountryCode: $guardianCountryCode, ')
          ..write('guardianNationalNumber: $guardianNationalNumber, ')
          ..write('previousMemorizationText: $previousMemorizationText, ')
          ..write('note: $note, ')
          ..write('supportStudentNumber: $supportStudentNumber, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('isActive: $isActive, ')
          ..write('archivedAtUtc: $archivedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    halaqahId,
    studentName,
    fatherName,
    ageYears,
    guardianCountryCode,
    guardianNationalNumber,
    previousMemorizationText,
    note,
    supportStudentNumber,
    displayOrder,
    isActive,
    archivedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Student &&
          other.id == this.id &&
          other.halaqahId == this.halaqahId &&
          other.studentName == this.studentName &&
          other.fatherName == this.fatherName &&
          other.ageYears == this.ageYears &&
          other.guardianCountryCode == this.guardianCountryCode &&
          other.guardianNationalNumber == this.guardianNationalNumber &&
          other.previousMemorizationText == this.previousMemorizationText &&
          other.note == this.note &&
          other.supportStudentNumber == this.supportStudentNumber &&
          other.displayOrder == this.displayOrder &&
          other.isActive == this.isActive &&
          other.archivedAtUtc == this.archivedAtUtc);
}

class StudentsCompanion extends UpdateCompanion<Student> {
  final Value<int> id;
  final Value<int> halaqahId;
  final Value<String> studentName;
  final Value<String> fatherName;
  final Value<int> ageYears;
  final Value<String> guardianCountryCode;
  final Value<String> guardianNationalNumber;
  final Value<String> previousMemorizationText;
  final Value<String?> note;
  final Value<String?> supportStudentNumber;
  final Value<int> displayOrder;
  final Value<bool> isActive;
  final Value<DateTime?> archivedAtUtc;
  const StudentsCompanion({
    this.id = const Value.absent(),
    this.halaqahId = const Value.absent(),
    this.studentName = const Value.absent(),
    this.fatherName = const Value.absent(),
    this.ageYears = const Value.absent(),
    this.guardianCountryCode = const Value.absent(),
    this.guardianNationalNumber = const Value.absent(),
    this.previousMemorizationText = const Value.absent(),
    this.note = const Value.absent(),
    this.supportStudentNumber = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.archivedAtUtc = const Value.absent(),
  });
  StudentsCompanion.insert({
    this.id = const Value.absent(),
    required int halaqahId,
    required String studentName,
    required String fatherName,
    required int ageYears,
    required String guardianCountryCode,
    required String guardianNationalNumber,
    required String previousMemorizationText,
    this.note = const Value.absent(),
    this.supportStudentNumber = const Value.absent(),
    required int displayOrder,
    this.isActive = const Value.absent(),
    this.archivedAtUtc = const Value.absent(),
  }) : halaqahId = Value(halaqahId),
       studentName = Value(studentName),
       fatherName = Value(fatherName),
       ageYears = Value(ageYears),
       guardianCountryCode = Value(guardianCountryCode),
       guardianNationalNumber = Value(guardianNationalNumber),
       previousMemorizationText = Value(previousMemorizationText),
       displayOrder = Value(displayOrder);
  static Insertable<Student> custom({
    Expression<int>? id,
    Expression<int>? halaqahId,
    Expression<String>? studentName,
    Expression<String>? fatherName,
    Expression<int>? ageYears,
    Expression<String>? guardianCountryCode,
    Expression<String>? guardianNationalNumber,
    Expression<String>? previousMemorizationText,
    Expression<String>? note,
    Expression<String>? supportStudentNumber,
    Expression<int>? displayOrder,
    Expression<bool>? isActive,
    Expression<DateTime>? archivedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (halaqahId != null) 'halaqah_id': halaqahId,
      if (studentName != null) 'student_name': studentName,
      if (fatherName != null) 'father_name': fatherName,
      if (ageYears != null) 'age_years': ageYears,
      if (guardianCountryCode != null)
        'guardian_country_code': guardianCountryCode,
      if (guardianNationalNumber != null)
        'guardian_national_number': guardianNationalNumber,
      if (previousMemorizationText != null)
        'previous_memorization_text': previousMemorizationText,
      if (note != null) 'note': note,
      if (supportStudentNumber != null)
        'support_student_number': supportStudentNumber,
      if (displayOrder != null) 'display_order': displayOrder,
      if (isActive != null) 'is_active': isActive,
      if (archivedAtUtc != null) 'archived_at_utc': archivedAtUtc,
    });
  }

  StudentsCompanion copyWith({
    Value<int>? id,
    Value<int>? halaqahId,
    Value<String>? studentName,
    Value<String>? fatherName,
    Value<int>? ageYears,
    Value<String>? guardianCountryCode,
    Value<String>? guardianNationalNumber,
    Value<String>? previousMemorizationText,
    Value<String?>? note,
    Value<String?>? supportStudentNumber,
    Value<int>? displayOrder,
    Value<bool>? isActive,
    Value<DateTime?>? archivedAtUtc,
  }) {
    return StudentsCompanion(
      id: id ?? this.id,
      halaqahId: halaqahId ?? this.halaqahId,
      studentName: studentName ?? this.studentName,
      fatherName: fatherName ?? this.fatherName,
      ageYears: ageYears ?? this.ageYears,
      guardianCountryCode: guardianCountryCode ?? this.guardianCountryCode,
      guardianNationalNumber:
          guardianNationalNumber ?? this.guardianNationalNumber,
      previousMemorizationText:
          previousMemorizationText ?? this.previousMemorizationText,
      note: note ?? this.note,
      supportStudentNumber: supportStudentNumber ?? this.supportStudentNumber,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      archivedAtUtc: archivedAtUtc ?? this.archivedAtUtc,
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
    if (studentName.present) {
      map['student_name'] = Variable<String>(studentName.value);
    }
    if (fatherName.present) {
      map['father_name'] = Variable<String>(fatherName.value);
    }
    if (ageYears.present) {
      map['age_years'] = Variable<int>(ageYears.value);
    }
    if (guardianCountryCode.present) {
      map['guardian_country_code'] = Variable<String>(
        guardianCountryCode.value,
      );
    }
    if (guardianNationalNumber.present) {
      map['guardian_national_number'] = Variable<String>(
        guardianNationalNumber.value,
      );
    }
    if (previousMemorizationText.present) {
      map['previous_memorization_text'] = Variable<String>(
        previousMemorizationText.value,
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (supportStudentNumber.present) {
      map['support_student_number'] = Variable<String>(
        supportStudentNumber.value,
      );
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (archivedAtUtc.present) {
      map['archived_at_utc'] = Variable<DateTime>(archivedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('id: $id, ')
          ..write('halaqahId: $halaqahId, ')
          ..write('studentName: $studentName, ')
          ..write('fatherName: $fatherName, ')
          ..write('ageYears: $ageYears, ')
          ..write('guardianCountryCode: $guardianCountryCode, ')
          ..write('guardianNationalNumber: $guardianNationalNumber, ')
          ..write('previousMemorizationText: $previousMemorizationText, ')
          ..write('note: $note, ')
          ..write('supportStudentNumber: $supportStudentNumber, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('isActive: $isActive, ')
          ..write('archivedAtUtc: $archivedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $StudentProgressPlansTable extends StudentProgressPlans
    with TableInfo<$StudentProgressPlansTable, StudentProgressPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentProgressPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _currentJuzMeta = const VerificationMeta(
    'currentJuz',
  );
  @override
  late final GeneratedColumn<int> currentJuz = GeneratedColumn<int>(
    'current_juz',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyPlanTextMeta = const VerificationMeta(
    'dailyPlanText',
  );
  @override
  late final GeneratedColumn<String> dailyPlanText = GeneratedColumn<String>(
    'daily_plan_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [studentId, currentJuz, dailyPlanText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'student_progress_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudentProgressPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    }
    if (data.containsKey('current_juz')) {
      context.handle(
        _currentJuzMeta,
        currentJuz.isAcceptableOrUnknown(data['current_juz']!, _currentJuzMeta),
      );
    }
    if (data.containsKey('daily_plan_text')) {
      context.handle(
        _dailyPlanTextMeta,
        dailyPlanText.isAcceptableOrUnknown(
          data['daily_plan_text']!,
          _dailyPlanTextMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {studentId};
  @override
  StudentProgressPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudentProgressPlan(
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      currentJuz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_juz'],
      ),
      dailyPlanText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_plan_text'],
      ),
    );
  }

  @override
  $StudentProgressPlansTable createAlias(String alias) {
    return $StudentProgressPlansTable(attachedDatabase, alias);
  }
}

class StudentProgressPlan extends DataClass
    implements Insertable<StudentProgressPlan> {
  final int studentId;
  final int? currentJuz;
  final String? dailyPlanText;
  const StudentProgressPlan({
    required this.studentId,
    this.currentJuz,
    this.dailyPlanText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['student_id'] = Variable<int>(studentId);
    if (!nullToAbsent || currentJuz != null) {
      map['current_juz'] = Variable<int>(currentJuz);
    }
    if (!nullToAbsent || dailyPlanText != null) {
      map['daily_plan_text'] = Variable<String>(dailyPlanText);
    }
    return map;
  }

  StudentProgressPlansCompanion toCompanion(bool nullToAbsent) {
    return StudentProgressPlansCompanion(
      studentId: Value(studentId),
      currentJuz: currentJuz == null && nullToAbsent
          ? const Value.absent()
          : Value(currentJuz),
      dailyPlanText: dailyPlanText == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyPlanText),
    );
  }

  factory StudentProgressPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudentProgressPlan(
      studentId: serializer.fromJson<int>(json['studentId']),
      currentJuz: serializer.fromJson<int?>(json['currentJuz']),
      dailyPlanText: serializer.fromJson<String?>(json['dailyPlanText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'studentId': serializer.toJson<int>(studentId),
      'currentJuz': serializer.toJson<int?>(currentJuz),
      'dailyPlanText': serializer.toJson<String?>(dailyPlanText),
    };
  }

  StudentProgressPlan copyWith({
    int? studentId,
    Value<int?> currentJuz = const Value.absent(),
    Value<String?> dailyPlanText = const Value.absent(),
  }) => StudentProgressPlan(
    studentId: studentId ?? this.studentId,
    currentJuz: currentJuz.present ? currentJuz.value : this.currentJuz,
    dailyPlanText: dailyPlanText.present
        ? dailyPlanText.value
        : this.dailyPlanText,
  );
  StudentProgressPlan copyWithCompanion(StudentProgressPlansCompanion data) {
    return StudentProgressPlan(
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      currentJuz: data.currentJuz.present
          ? data.currentJuz.value
          : this.currentJuz,
      dailyPlanText: data.dailyPlanText.present
          ? data.dailyPlanText.value
          : this.dailyPlanText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudentProgressPlan(')
          ..write('studentId: $studentId, ')
          ..write('currentJuz: $currentJuz, ')
          ..write('dailyPlanText: $dailyPlanText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(studentId, currentJuz, dailyPlanText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudentProgressPlan &&
          other.studentId == this.studentId &&
          other.currentJuz == this.currentJuz &&
          other.dailyPlanText == this.dailyPlanText);
}

class StudentProgressPlansCompanion
    extends UpdateCompanion<StudentProgressPlan> {
  final Value<int> studentId;
  final Value<int?> currentJuz;
  final Value<String?> dailyPlanText;
  const StudentProgressPlansCompanion({
    this.studentId = const Value.absent(),
    this.currentJuz = const Value.absent(),
    this.dailyPlanText = const Value.absent(),
  });
  StudentProgressPlansCompanion.insert({
    this.studentId = const Value.absent(),
    this.currentJuz = const Value.absent(),
    this.dailyPlanText = const Value.absent(),
  });
  static Insertable<StudentProgressPlan> custom({
    Expression<int>? studentId,
    Expression<int>? currentJuz,
    Expression<String>? dailyPlanText,
  }) {
    return RawValuesInsertable({
      if (studentId != null) 'student_id': studentId,
      if (currentJuz != null) 'current_juz': currentJuz,
      if (dailyPlanText != null) 'daily_plan_text': dailyPlanText,
    });
  }

  StudentProgressPlansCompanion copyWith({
    Value<int>? studentId,
    Value<int?>? currentJuz,
    Value<String?>? dailyPlanText,
  }) {
    return StudentProgressPlansCompanion(
      studentId: studentId ?? this.studentId,
      currentJuz: currentJuz ?? this.currentJuz,
      dailyPlanText: dailyPlanText ?? this.dailyPlanText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (currentJuz.present) {
      map['current_juz'] = Variable<int>(currentJuz.value);
    }
    if (dailyPlanText.present) {
      map['daily_plan_text'] = Variable<String>(dailyPlanText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentProgressPlansCompanion(')
          ..write('studentId: $studentId, ')
          ..write('currentJuz: $currentJuz, ')
          ..write('dailyPlanText: $dailyPlanText')
          ..write(')'))
        .toString();
  }
}

class $StudentActivityPeriodsTable extends StudentActivityPeriods
    with TableInfo<$StudentActivityPeriodsTable, StudentActivityPeriod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentActivityPeriodsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _activeFromDateMeta = const VerificationMeta(
    'activeFromDate',
  );
  @override
  late final GeneratedColumn<String> activeFromDate = GeneratedColumn<String>(
    'active_from_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeToDateMeta = const VerificationMeta(
    'activeToDate',
  );
  @override
  late final GeneratedColumn<String> activeToDate = GeneratedColumn<String>(
    'active_to_date',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    activeFromDate,
    activeToDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'student_activity_periods';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudentActivityPeriod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('active_from_date')) {
      context.handle(
        _activeFromDateMeta,
        activeFromDate.isAcceptableOrUnknown(
          data['active_from_date']!,
          _activeFromDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activeFromDateMeta);
    }
    if (data.containsKey('active_to_date')) {
      context.handle(
        _activeToDateMeta,
        activeToDate.isAcceptableOrUnknown(
          data['active_to_date']!,
          _activeToDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudentActivityPeriod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudentActivityPeriod(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      activeFromDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_from_date'],
      )!,
      activeToDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_to_date'],
      ),
    );
  }

  @override
  $StudentActivityPeriodsTable createAlias(String alias) {
    return $StudentActivityPeriodsTable(attachedDatabase, alias);
  }
}

class StudentActivityPeriod extends DataClass
    implements Insertable<StudentActivityPeriod> {
  final int id;
  final int studentId;
  final String activeFromDate;
  final String? activeToDate;
  const StudentActivityPeriod({
    required this.id,
    required this.studentId,
    required this.activeFromDate,
    this.activeToDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['active_from_date'] = Variable<String>(activeFromDate);
    if (!nullToAbsent || activeToDate != null) {
      map['active_to_date'] = Variable<String>(activeToDate);
    }
    return map;
  }

  StudentActivityPeriodsCompanion toCompanion(bool nullToAbsent) {
    return StudentActivityPeriodsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      activeFromDate: Value(activeFromDate),
      activeToDate: activeToDate == null && nullToAbsent
          ? const Value.absent()
          : Value(activeToDate),
    );
  }

  factory StudentActivityPeriod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudentActivityPeriod(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      activeFromDate: serializer.fromJson<String>(json['activeFromDate']),
      activeToDate: serializer.fromJson<String?>(json['activeToDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'activeFromDate': serializer.toJson<String>(activeFromDate),
      'activeToDate': serializer.toJson<String?>(activeToDate),
    };
  }

  StudentActivityPeriod copyWith({
    int? id,
    int? studentId,
    String? activeFromDate,
    Value<String?> activeToDate = const Value.absent(),
  }) => StudentActivityPeriod(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    activeFromDate: activeFromDate ?? this.activeFromDate,
    activeToDate: activeToDate.present ? activeToDate.value : this.activeToDate,
  );
  StudentActivityPeriod copyWithCompanion(
    StudentActivityPeriodsCompanion data,
  ) {
    return StudentActivityPeriod(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      activeFromDate: data.activeFromDate.present
          ? data.activeFromDate.value
          : this.activeFromDate,
      activeToDate: data.activeToDate.present
          ? data.activeToDate.value
          : this.activeToDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudentActivityPeriod(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('activeFromDate: $activeFromDate, ')
          ..write('activeToDate: $activeToDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, studentId, activeFromDate, activeToDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudentActivityPeriod &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.activeFromDate == this.activeFromDate &&
          other.activeToDate == this.activeToDate);
}

class StudentActivityPeriodsCompanion
    extends UpdateCompanion<StudentActivityPeriod> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<String> activeFromDate;
  final Value<String?> activeToDate;
  const StudentActivityPeriodsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.activeFromDate = const Value.absent(),
    this.activeToDate = const Value.absent(),
  });
  StudentActivityPeriodsCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required String activeFromDate,
    this.activeToDate = const Value.absent(),
  }) : studentId = Value(studentId),
       activeFromDate = Value(activeFromDate);
  static Insertable<StudentActivityPeriod> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<String>? activeFromDate,
    Expression<String>? activeToDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (activeFromDate != null) 'active_from_date': activeFromDate,
      if (activeToDate != null) 'active_to_date': activeToDate,
    });
  }

  StudentActivityPeriodsCompanion copyWith({
    Value<int>? id,
    Value<int>? studentId,
    Value<String>? activeFromDate,
    Value<String?>? activeToDate,
  }) {
    return StudentActivityPeriodsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      activeFromDate: activeFromDate ?? this.activeFromDate,
      activeToDate: activeToDate ?? this.activeToDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (activeFromDate.present) {
      map['active_from_date'] = Variable<String>(activeFromDate.value);
    }
    if (activeToDate.present) {
      map['active_to_date'] = Variable<String>(activeToDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentActivityPeriodsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('activeFromDate: $activeFromDate, ')
          ..write('activeToDate: $activeToDate')
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
  late final $StudentsTable students = $StudentsTable(this);
  late final $StudentProgressPlansTable studentProgressPlans =
      $StudentProgressPlansTable(this);
  late final $StudentActivityPeriodsTable studentActivityPeriods =
      $StudentActivityPeriodsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    halaqahs,
    supportProgramSettings,
    supportProgramPeriods,
    students,
    studentProgressPlans,
    studentActivityPeriods,
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

  static MultiTypedResultKey<$StudentsTable, List<Student>> _studentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.students,
    aliasName: 'halaqahs__id__students__halaqah_id',
  );

  $$StudentsTableProcessedTableManager get studentsRefs {
    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.halaqahId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_studentsRefsTable($_db));
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

  Expression<bool> studentsRefs(
    Expression<bool> Function($$StudentsTableFilterComposer f) f,
  ) {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.halaqahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
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

  Expression<T> studentsRefs<T extends Object>(
    Expression<T> Function($$StudentsTableAnnotationComposer a) f,
  ) {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.halaqahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
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
            bool studentsRefs,
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
                studentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (supportProgramSettingsRefs) db.supportProgramSettings,
                    if (supportProgramPeriodsRefs) db.supportProgramPeriods,
                    if (studentsRefs) db.students,
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
                      if (studentsRefs)
                        await $_getPrefetchedData<
                          Halaqah,
                          $HalaqahsTable,
                          Student
                        >(
                          currentTable: table,
                          referencedTable: $$HalaqahsTableReferences
                              ._studentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HalaqahsTableReferences(
                                db,
                                table,
                                p0,
                              ).studentsRefs,
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
        bool studentsRefs,
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
typedef $$StudentsTableCreateCompanionBuilder =
    StudentsCompanion Function({
      Value<int> id,
      required int halaqahId,
      required String studentName,
      required String fatherName,
      required int ageYears,
      required String guardianCountryCode,
      required String guardianNationalNumber,
      required String previousMemorizationText,
      Value<String?> note,
      Value<String?> supportStudentNumber,
      required int displayOrder,
      Value<bool> isActive,
      Value<DateTime?> archivedAtUtc,
    });
typedef $$StudentsTableUpdateCompanionBuilder =
    StudentsCompanion Function({
      Value<int> id,
      Value<int> halaqahId,
      Value<String> studentName,
      Value<String> fatherName,
      Value<int> ageYears,
      Value<String> guardianCountryCode,
      Value<String> guardianNationalNumber,
      Value<String> previousMemorizationText,
      Value<String?> note,
      Value<String?> supportStudentNumber,
      Value<int> displayOrder,
      Value<bool> isActive,
      Value<DateTime?> archivedAtUtc,
    });

final class $$StudentsTableReferences
    extends BaseReferences<_$AppDatabase, $StudentsTable, Student> {
  $$StudentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HalaqahsTable _halaqahIdTable(_$AppDatabase db) =>
      db.halaqahs.createAlias('students__halaqah_id__halaqahs__id');

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

  static MultiTypedResultKey<
    $StudentProgressPlansTable,
    List<StudentProgressPlan>
  >
  _studentProgressPlansRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.studentProgressPlans,
        aliasName: 'students__id__student_progress_plans__student_id',
      );

  $$StudentProgressPlansTableProcessedTableManager
  get studentProgressPlansRefs {
    final manager = $$StudentProgressPlansTableTableManager(
      $_db,
      $_db.studentProgressPlans,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _studentProgressPlansRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StudentActivityPeriodsTable,
    List<StudentActivityPeriod>
  >
  _studentActivityPeriodsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.studentActivityPeriods,
        aliasName: 'students__id__student_activity_periods__student_id',
      );

  $$StudentActivityPeriodsTableProcessedTableManager
  get studentActivityPeriodsRefs {
    final manager = $$StudentActivityPeriodsTableTableManager(
      $_db,
      $_db.studentActivityPeriods,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _studentActivityPeriodsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StudentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableFilterComposer({
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

  ColumnFilters<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ageYears => $composableBuilder(
    column: $table.ageYears,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guardianCountryCode => $composableBuilder(
    column: $table.guardianCountryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guardianNationalNumber => $composableBuilder(
    column: $table.guardianNationalNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousMemorizationText => $composableBuilder(
    column: $table.previousMemorizationText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supportStudentNumber => $composableBuilder(
    column: $table.supportStudentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAtUtc => $composableBuilder(
    column: $table.archivedAtUtc,
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

  Expression<bool> studentProgressPlansRefs(
    Expression<bool> Function($$StudentProgressPlansTableFilterComposer f) f,
  ) {
    final $$StudentProgressPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studentProgressPlans,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentProgressPlansTableFilterComposer(
            $db: $db,
            $table: $db.studentProgressPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> studentActivityPeriodsRefs(
    Expression<bool> Function($$StudentActivityPeriodsTableFilterComposer f) f,
  ) {
    final $$StudentActivityPeriodsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.studentActivityPeriods,
          getReferencedColumn: (t) => t.studentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StudentActivityPeriodsTableFilterComposer(
                $db: $db,
                $table: $db.studentActivityPeriods,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableOrderingComposer({
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

  ColumnOrderings<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ageYears => $composableBuilder(
    column: $table.ageYears,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guardianCountryCode => $composableBuilder(
    column: $table.guardianCountryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guardianNationalNumber => $composableBuilder(
    column: $table.guardianNationalNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousMemorizationText => $composableBuilder(
    column: $table.previousMemorizationText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supportStudentNumber => $composableBuilder(
    column: $table.supportStudentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAtUtc => $composableBuilder(
    column: $table.archivedAtUtc,
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

class $$StudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ageYears =>
      $composableBuilder(column: $table.ageYears, builder: (column) => column);

  GeneratedColumn<String> get guardianCountryCode => $composableBuilder(
    column: $table.guardianCountryCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get guardianNationalNumber => $composableBuilder(
    column: $table.guardianNationalNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previousMemorizationText => $composableBuilder(
    column: $table.previousMemorizationText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get supportStudentNumber => $composableBuilder(
    column: $table.supportStudentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAtUtc => $composableBuilder(
    column: $table.archivedAtUtc,
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

  Expression<T> studentProgressPlansRefs<T extends Object>(
    Expression<T> Function($$StudentProgressPlansTableAnnotationComposer a) f,
  ) {
    final $$StudentProgressPlansTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.studentProgressPlans,
          getReferencedColumn: (t) => t.studentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StudentProgressPlansTableAnnotationComposer(
                $db: $db,
                $table: $db.studentProgressPlans,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> studentActivityPeriodsRefs<T extends Object>(
    Expression<T> Function($$StudentActivityPeriodsTableAnnotationComposer a) f,
  ) {
    final $$StudentActivityPeriodsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.studentActivityPeriods,
          getReferencedColumn: (t) => t.studentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StudentActivityPeriodsTableAnnotationComposer(
                $db: $db,
                $table: $db.studentActivityPeriods,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentsTable,
          Student,
          $$StudentsTableFilterComposer,
          $$StudentsTableOrderingComposer,
          $$StudentsTableAnnotationComposer,
          $$StudentsTableCreateCompanionBuilder,
          $$StudentsTableUpdateCompanionBuilder,
          (Student, $$StudentsTableReferences),
          Student,
          PrefetchHooks Function({
            bool halaqahId,
            bool studentProgressPlansRefs,
            bool studentActivityPeriodsRefs,
          })
        > {
  $$StudentsTableTableManager(_$AppDatabase db, $StudentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> halaqahId = const Value.absent(),
                Value<String> studentName = const Value.absent(),
                Value<String> fatherName = const Value.absent(),
                Value<int> ageYears = const Value.absent(),
                Value<String> guardianCountryCode = const Value.absent(),
                Value<String> guardianNationalNumber = const Value.absent(),
                Value<String> previousMemorizationText = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> supportStudentNumber = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> archivedAtUtc = const Value.absent(),
              }) => StudentsCompanion(
                id: id,
                halaqahId: halaqahId,
                studentName: studentName,
                fatherName: fatherName,
                ageYears: ageYears,
                guardianCountryCode: guardianCountryCode,
                guardianNationalNumber: guardianNationalNumber,
                previousMemorizationText: previousMemorizationText,
                note: note,
                supportStudentNumber: supportStudentNumber,
                displayOrder: displayOrder,
                isActive: isActive,
                archivedAtUtc: archivedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int halaqahId,
                required String studentName,
                required String fatherName,
                required int ageYears,
                required String guardianCountryCode,
                required String guardianNationalNumber,
                required String previousMemorizationText,
                Value<String?> note = const Value.absent(),
                Value<String?> supportStudentNumber = const Value.absent(),
                required int displayOrder,
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> archivedAtUtc = const Value.absent(),
              }) => StudentsCompanion.insert(
                id: id,
                halaqahId: halaqahId,
                studentName: studentName,
                fatherName: fatherName,
                ageYears: ageYears,
                guardianCountryCode: guardianCountryCode,
                guardianNationalNumber: guardianNationalNumber,
                previousMemorizationText: previousMemorizationText,
                note: note,
                supportStudentNumber: supportStudentNumber,
                displayOrder: displayOrder,
                isActive: isActive,
                archivedAtUtc: archivedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StudentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                halaqahId = false,
                studentProgressPlansRefs = false,
                studentActivityPeriodsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (studentProgressPlansRefs) db.studentProgressPlans,
                    if (studentActivityPeriodsRefs) db.studentActivityPeriods,
                  ],
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
                                    referencedTable: $$StudentsTableReferences
                                        ._halaqahIdTable(db),
                                    referencedColumn: $$StudentsTableReferences
                                        ._halaqahIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (studentProgressPlansRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          StudentProgressPlan
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._studentProgressPlansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).studentProgressPlansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (studentActivityPeriodsRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          StudentActivityPeriod
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._studentActivityPeriodsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).studentActivityPeriodsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
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

typedef $$StudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentsTable,
      Student,
      $$StudentsTableFilterComposer,
      $$StudentsTableOrderingComposer,
      $$StudentsTableAnnotationComposer,
      $$StudentsTableCreateCompanionBuilder,
      $$StudentsTableUpdateCompanionBuilder,
      (Student, $$StudentsTableReferences),
      Student,
      PrefetchHooks Function({
        bool halaqahId,
        bool studentProgressPlansRefs,
        bool studentActivityPeriodsRefs,
      })
    >;
typedef $$StudentProgressPlansTableCreateCompanionBuilder =
    StudentProgressPlansCompanion Function({
      Value<int> studentId,
      Value<int?> currentJuz,
      Value<String?> dailyPlanText,
    });
typedef $$StudentProgressPlansTableUpdateCompanionBuilder =
    StudentProgressPlansCompanion Function({
      Value<int> studentId,
      Value<int?> currentJuz,
      Value<String?> dailyPlanText,
    });

final class $$StudentProgressPlansTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StudentProgressPlansTable,
          StudentProgressPlan
        > {
  $$StudentProgressPlansTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudentsTable _studentIdTable(_$AppDatabase db) => db.students
      .createAlias('student_progress_plans__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StudentProgressPlansTableFilterComposer
    extends Composer<_$AppDatabase, $StudentProgressPlansTable> {
  $$StudentProgressPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get currentJuz => $composableBuilder(
    column: $table.currentJuz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dailyPlanText => $composableBuilder(
    column: $table.dailyPlanText,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudentProgressPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentProgressPlansTable> {
  $$StudentProgressPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get currentJuz => $composableBuilder(
    column: $table.currentJuz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dailyPlanText => $composableBuilder(
    column: $table.dailyPlanText,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudentProgressPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentProgressPlansTable> {
  $$StudentProgressPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get currentJuz => $composableBuilder(
    column: $table.currentJuz,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dailyPlanText => $composableBuilder(
    column: $table.dailyPlanText,
    builder: (column) => column,
  );

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudentProgressPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentProgressPlansTable,
          StudentProgressPlan,
          $$StudentProgressPlansTableFilterComposer,
          $$StudentProgressPlansTableOrderingComposer,
          $$StudentProgressPlansTableAnnotationComposer,
          $$StudentProgressPlansTableCreateCompanionBuilder,
          $$StudentProgressPlansTableUpdateCompanionBuilder,
          (StudentProgressPlan, $$StudentProgressPlansTableReferences),
          StudentProgressPlan,
          PrefetchHooks Function({bool studentId})
        > {
  $$StudentProgressPlansTableTableManager(
    _$AppDatabase db,
    $StudentProgressPlansTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentProgressPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentProgressPlansTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StudentProgressPlansTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> studentId = const Value.absent(),
                Value<int?> currentJuz = const Value.absent(),
                Value<String?> dailyPlanText = const Value.absent(),
              }) => StudentProgressPlansCompanion(
                studentId: studentId,
                currentJuz: currentJuz,
                dailyPlanText: dailyPlanText,
              ),
          createCompanionCallback:
              ({
                Value<int> studentId = const Value.absent(),
                Value<int?> currentJuz = const Value.absent(),
                Value<String?> dailyPlanText = const Value.absent(),
              }) => StudentProgressPlansCompanion.insert(
                studentId: studentId,
                currentJuz: currentJuz,
                dailyPlanText: dailyPlanText,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StudentProgressPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false}) {
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
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable:
                                    $$StudentProgressPlansTableReferences
                                        ._studentIdTable(db),
                                referencedColumn:
                                    $$StudentProgressPlansTableReferences
                                        ._studentIdTable(db)
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

typedef $$StudentProgressPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentProgressPlansTable,
      StudentProgressPlan,
      $$StudentProgressPlansTableFilterComposer,
      $$StudentProgressPlansTableOrderingComposer,
      $$StudentProgressPlansTableAnnotationComposer,
      $$StudentProgressPlansTableCreateCompanionBuilder,
      $$StudentProgressPlansTableUpdateCompanionBuilder,
      (StudentProgressPlan, $$StudentProgressPlansTableReferences),
      StudentProgressPlan,
      PrefetchHooks Function({bool studentId})
    >;
typedef $$StudentActivityPeriodsTableCreateCompanionBuilder =
    StudentActivityPeriodsCompanion Function({
      Value<int> id,
      required int studentId,
      required String activeFromDate,
      Value<String?> activeToDate,
    });
typedef $$StudentActivityPeriodsTableUpdateCompanionBuilder =
    StudentActivityPeriodsCompanion Function({
      Value<int> id,
      Value<int> studentId,
      Value<String> activeFromDate,
      Value<String?> activeToDate,
    });

final class $$StudentActivityPeriodsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StudentActivityPeriodsTable,
          StudentActivityPeriod
        > {
  $$StudentActivityPeriodsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudentsTable _studentIdTable(_$AppDatabase db) => db.students
      .createAlias('student_activity_periods__student_id__students__id');

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StudentActivityPeriodsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentActivityPeriodsTable> {
  $$StudentActivityPeriodsTableFilterComposer({
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

  ColumnFilters<String> get activeFromDate => $composableBuilder(
    column: $table.activeFromDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeToDate => $composableBuilder(
    column: $table.activeToDate,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudentActivityPeriodsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentActivityPeriodsTable> {
  $$StudentActivityPeriodsTableOrderingComposer({
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

  ColumnOrderings<String> get activeFromDate => $composableBuilder(
    column: $table.activeFromDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeToDate => $composableBuilder(
    column: $table.activeToDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudentActivityPeriodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentActivityPeriodsTable> {
  $$StudentActivityPeriodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get activeFromDate => $composableBuilder(
    column: $table.activeFromDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeToDate => $composableBuilder(
    column: $table.activeToDate,
    builder: (column) => column,
  );

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudentActivityPeriodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentActivityPeriodsTable,
          StudentActivityPeriod,
          $$StudentActivityPeriodsTableFilterComposer,
          $$StudentActivityPeriodsTableOrderingComposer,
          $$StudentActivityPeriodsTableAnnotationComposer,
          $$StudentActivityPeriodsTableCreateCompanionBuilder,
          $$StudentActivityPeriodsTableUpdateCompanionBuilder,
          (StudentActivityPeriod, $$StudentActivityPeriodsTableReferences),
          StudentActivityPeriod,
          PrefetchHooks Function({bool studentId})
        > {
  $$StudentActivityPeriodsTableTableManager(
    _$AppDatabase db,
    $StudentActivityPeriodsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentActivityPeriodsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$StudentActivityPeriodsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StudentActivityPeriodsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<String> activeFromDate = const Value.absent(),
                Value<String?> activeToDate = const Value.absent(),
              }) => StudentActivityPeriodsCompanion(
                id: id,
                studentId: studentId,
                activeFromDate: activeFromDate,
                activeToDate: activeToDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studentId,
                required String activeFromDate,
                Value<String?> activeToDate = const Value.absent(),
              }) => StudentActivityPeriodsCompanion.insert(
                id: id,
                studentId: studentId,
                activeFromDate: activeFromDate,
                activeToDate: activeToDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StudentActivityPeriodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false}) {
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
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable:
                                    $$StudentActivityPeriodsTableReferences
                                        ._studentIdTable(db),
                                referencedColumn:
                                    $$StudentActivityPeriodsTableReferences
                                        ._studentIdTable(db)
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

typedef $$StudentActivityPeriodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentActivityPeriodsTable,
      StudentActivityPeriod,
      $$StudentActivityPeriodsTableFilterComposer,
      $$StudentActivityPeriodsTableOrderingComposer,
      $$StudentActivityPeriodsTableAnnotationComposer,
      $$StudentActivityPeriodsTableCreateCompanionBuilder,
      $$StudentActivityPeriodsTableUpdateCompanionBuilder,
      (StudentActivityPeriod, $$StudentActivityPeriodsTableReferences),
      StudentActivityPeriod,
      PrefetchHooks Function({bool studentId})
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
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db, _db.students);
  $$StudentProgressPlansTableTableManager get studentProgressPlans =>
      $$StudentProgressPlansTableTableManager(_db, _db.studentProgressPlans);
  $$StudentActivityPeriodsTableTableManager get studentActivityPeriods =>
      $$StudentActivityPeriodsTableTableManager(
        _db,
        _db.studentActivityPeriods,
      );
}

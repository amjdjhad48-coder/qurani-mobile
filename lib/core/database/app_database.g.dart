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

class $HalaqahDaysTable extends HalaqahDays
    with TableInfo<$HalaqahDaysTable, HalaqahDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HalaqahDaysTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dayDateMeta = const VerificationMeta(
    'dayDate',
  );
  @override
  late final GeneratedColumn<String> dayDate = GeneratedColumn<String>(
    'day_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [id, halaqahId, dayDate, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'halaqah_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<HalaqahDay> instance, {
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
    if (data.containsKey('day_date')) {
      context.handle(
        _dayDateMeta,
        dayDate.isAcceptableOrUnknown(data['day_date']!, _dayDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dayDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {halaqahId, dayDate},
  ];
  @override
  HalaqahDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HalaqahDay(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      halaqahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}halaqah_id'],
      )!,
      dayDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $HalaqahDaysTable createAlias(String alias) {
    return $HalaqahDaysTable(attachedDatabase, alias);
  }
}

class HalaqahDay extends DataClass implements Insertable<HalaqahDay> {
  final int id;
  final int halaqahId;
  final String dayDate;
  final String status;
  const HalaqahDay({
    required this.id,
    required this.halaqahId,
    required this.dayDate,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['halaqah_id'] = Variable<int>(halaqahId);
    map['day_date'] = Variable<String>(dayDate);
    map['status'] = Variable<String>(status);
    return map;
  }

  HalaqahDaysCompanion toCompanion(bool nullToAbsent) {
    return HalaqahDaysCompanion(
      id: Value(id),
      halaqahId: Value(halaqahId),
      dayDate: Value(dayDate),
      status: Value(status),
    );
  }

  factory HalaqahDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HalaqahDay(
      id: serializer.fromJson<int>(json['id']),
      halaqahId: serializer.fromJson<int>(json['halaqahId']),
      dayDate: serializer.fromJson<String>(json['dayDate']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'halaqahId': serializer.toJson<int>(halaqahId),
      'dayDate': serializer.toJson<String>(dayDate),
      'status': serializer.toJson<String>(status),
    };
  }

  HalaqahDay copyWith({
    int? id,
    int? halaqahId,
    String? dayDate,
    String? status,
  }) => HalaqahDay(
    id: id ?? this.id,
    halaqahId: halaqahId ?? this.halaqahId,
    dayDate: dayDate ?? this.dayDate,
    status: status ?? this.status,
  );
  HalaqahDay copyWithCompanion(HalaqahDaysCompanion data) {
    return HalaqahDay(
      id: data.id.present ? data.id.value : this.id,
      halaqahId: data.halaqahId.present ? data.halaqahId.value : this.halaqahId,
      dayDate: data.dayDate.present ? data.dayDate.value : this.dayDate,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HalaqahDay(')
          ..write('id: $id, ')
          ..write('halaqahId: $halaqahId, ')
          ..write('dayDate: $dayDate, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, halaqahId, dayDate, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HalaqahDay &&
          other.id == this.id &&
          other.halaqahId == this.halaqahId &&
          other.dayDate == this.dayDate &&
          other.status == this.status);
}

class HalaqahDaysCompanion extends UpdateCompanion<HalaqahDay> {
  final Value<int> id;
  final Value<int> halaqahId;
  final Value<String> dayDate;
  final Value<String> status;
  const HalaqahDaysCompanion({
    this.id = const Value.absent(),
    this.halaqahId = const Value.absent(),
    this.dayDate = const Value.absent(),
    this.status = const Value.absent(),
  });
  HalaqahDaysCompanion.insert({
    this.id = const Value.absent(),
    required int halaqahId,
    required String dayDate,
    required String status,
  }) : halaqahId = Value(halaqahId),
       dayDate = Value(dayDate),
       status = Value(status);
  static Insertable<HalaqahDay> custom({
    Expression<int>? id,
    Expression<int>? halaqahId,
    Expression<String>? dayDate,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (halaqahId != null) 'halaqah_id': halaqahId,
      if (dayDate != null) 'day_date': dayDate,
      if (status != null) 'status': status,
    });
  }

  HalaqahDaysCompanion copyWith({
    Value<int>? id,
    Value<int>? halaqahId,
    Value<String>? dayDate,
    Value<String>? status,
  }) {
    return HalaqahDaysCompanion(
      id: id ?? this.id,
      halaqahId: halaqahId ?? this.halaqahId,
      dayDate: dayDate ?? this.dayDate,
      status: status ?? this.status,
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
    if (dayDate.present) {
      map['day_date'] = Variable<String>(dayDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HalaqahDaysCompanion(')
          ..write('id: $id, ')
          ..write('halaqahId: $halaqahId, ')
          ..write('dayDate: $dayDate, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $AttendanceRecordsTable extends AttendanceRecords
    with TableInfo<$AttendanceRecordsTable, AttendanceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<int> dayId = GeneratedColumn<int>(
    'day_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES halaqah_days (id) ON DELETE RESTRICT',
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, dayId, studentId, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_id')) {
      context.handle(
        _dayIdMeta,
        dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {dayId, studentId},
  ];
  @override
  AttendanceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dayId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $AttendanceRecordsTable createAlias(String alias) {
    return $AttendanceRecordsTable(attachedDatabase, alias);
  }
}

class AttendanceRecord extends DataClass
    implements Insertable<AttendanceRecord> {
  final int id;
  final int dayId;
  final int studentId;
  final String status;
  const AttendanceRecord({
    required this.id,
    required this.dayId,
    required this.studentId,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day_id'] = Variable<int>(dayId);
    map['student_id'] = Variable<int>(studentId);
    map['status'] = Variable<String>(status);
    return map;
  }

  AttendanceRecordsCompanion toCompanion(bool nullToAbsent) {
    return AttendanceRecordsCompanion(
      id: Value(id),
      dayId: Value(dayId),
      studentId: Value(studentId),
      status: Value(status),
    );
  }

  factory AttendanceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceRecord(
      id: serializer.fromJson<int>(json['id']),
      dayId: serializer.fromJson<int>(json['dayId']),
      studentId: serializer.fromJson<int>(json['studentId']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayId': serializer.toJson<int>(dayId),
      'studentId': serializer.toJson<int>(studentId),
      'status': serializer.toJson<String>(status),
    };
  }

  AttendanceRecord copyWith({
    int? id,
    int? dayId,
    int? studentId,
    String? status,
  }) => AttendanceRecord(
    id: id ?? this.id,
    dayId: dayId ?? this.dayId,
    studentId: studentId ?? this.studentId,
    status: status ?? this.status,
  );
  AttendanceRecord copyWithCompanion(AttendanceRecordsCompanion data) {
    return AttendanceRecord(
      id: data.id.present ? data.id.value : this.id,
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceRecord(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('studentId: $studentId, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dayId, studentId, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceRecord &&
          other.id == this.id &&
          other.dayId == this.dayId &&
          other.studentId == this.studentId &&
          other.status == this.status);
}

class AttendanceRecordsCompanion extends UpdateCompanion<AttendanceRecord> {
  final Value<int> id;
  final Value<int> dayId;
  final Value<int> studentId;
  final Value<String> status;
  const AttendanceRecordsCompanion({
    this.id = const Value.absent(),
    this.dayId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.status = const Value.absent(),
  });
  AttendanceRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int dayId,
    required int studentId,
    required String status,
  }) : dayId = Value(dayId),
       studentId = Value(studentId),
       status = Value(status);
  static Insertable<AttendanceRecord> custom({
    Expression<int>? id,
    Expression<int>? dayId,
    Expression<int>? studentId,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayId != null) 'day_id': dayId,
      if (studentId != null) 'student_id': studentId,
      if (status != null) 'status': status,
    });
  }

  AttendanceRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? dayId,
    Value<int>? studentId,
    Value<String>? status,
  }) {
    return AttendanceRecordsCompanion(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayId.present) {
      map['day_id'] = Variable<int>(dayId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceRecordsCompanion(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('studentId: $studentId, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $RecitationsTable extends Recitations
    with TableInfo<$RecitationsTable, Recitation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecitationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<int> dayId = GeneratedColumn<int>(
    'day_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES halaqah_days (id) ON DELETE RESTRICT',
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startSurahMeta = const VerificationMeta(
    'startSurah',
  );
  @override
  late final GeneratedColumn<int> startSurah = GeneratedColumn<int>(
    'start_surah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startAyahMeta = const VerificationMeta(
    'startAyah',
  );
  @override
  late final GeneratedColumn<int> startAyah = GeneratedColumn<int>(
    'start_ayah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endSurahMeta = const VerificationMeta(
    'endSurah',
  );
  @override
  late final GeneratedColumn<int> endSurah = GeneratedColumn<int>(
    'end_surah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAyahMeta = const VerificationMeta(
    'endAyah',
  );
  @override
  late final GeneratedColumn<int> endAyah = GeneratedColumn<int>(
    'end_ayah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _facesQuarterAchievedMeta =
      const VerificationMeta('facesQuarterAchieved');
  @override
  late final GeneratedColumn<int> facesQuarterAchieved = GeneratedColumn<int>(
    'faces_quarter_achieved',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evaluationMeta = const VerificationMeta(
    'evaluation',
  );
  @override
  late final GeneratedColumn<String> evaluation = GeneratedColumn<String>(
    'evaluation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorCountMeta = const VerificationMeta(
    'errorCount',
  );
  @override
  late final GeneratedColumn<int> errorCount = GeneratedColumn<int>(
    'error_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _plannedStartSurahMeta = const VerificationMeta(
    'plannedStartSurah',
  );
  @override
  late final GeneratedColumn<int> plannedStartSurah = GeneratedColumn<int>(
    'planned_start_surah',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedStartAyahMeta = const VerificationMeta(
    'plannedStartAyah',
  );
  @override
  late final GeneratedColumn<int> plannedStartAyah = GeneratedColumn<int>(
    'planned_start_ayah',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedEndSurahMeta = const VerificationMeta(
    'plannedEndSurah',
  );
  @override
  late final GeneratedColumn<int> plannedEndSurah = GeneratedColumn<int>(
    'planned_end_surah',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedEndAyahMeta = const VerificationMeta(
    'plannedEndAyah',
  );
  @override
  late final GeneratedColumn<int> plannedEndAyah = GeneratedColumn<int>(
    'planned_end_ayah',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dayId,
    studentId,
    type,
    startSurah,
    startAyah,
    endSurah,
    endAyah,
    facesQuarterAchieved,
    evaluation,
    errorCount,
    note,
    plannedStartSurah,
    plannedStartAyah,
    plannedEndSurah,
    plannedEndAyah,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recitations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recitation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_id')) {
      context.handle(
        _dayIdMeta,
        dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('start_surah')) {
      context.handle(
        _startSurahMeta,
        startSurah.isAcceptableOrUnknown(data['start_surah']!, _startSurahMeta),
      );
    } else if (isInserting) {
      context.missing(_startSurahMeta);
    }
    if (data.containsKey('start_ayah')) {
      context.handle(
        _startAyahMeta,
        startAyah.isAcceptableOrUnknown(data['start_ayah']!, _startAyahMeta),
      );
    } else if (isInserting) {
      context.missing(_startAyahMeta);
    }
    if (data.containsKey('end_surah')) {
      context.handle(
        _endSurahMeta,
        endSurah.isAcceptableOrUnknown(data['end_surah']!, _endSurahMeta),
      );
    } else if (isInserting) {
      context.missing(_endSurahMeta);
    }
    if (data.containsKey('end_ayah')) {
      context.handle(
        _endAyahMeta,
        endAyah.isAcceptableOrUnknown(data['end_ayah']!, _endAyahMeta),
      );
    } else if (isInserting) {
      context.missing(_endAyahMeta);
    }
    if (data.containsKey('faces_quarter_achieved')) {
      context.handle(
        _facesQuarterAchievedMeta,
        facesQuarterAchieved.isAcceptableOrUnknown(
          data['faces_quarter_achieved']!,
          _facesQuarterAchievedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_facesQuarterAchievedMeta);
    }
    if (data.containsKey('evaluation')) {
      context.handle(
        _evaluationMeta,
        evaluation.isAcceptableOrUnknown(data['evaluation']!, _evaluationMeta),
      );
    } else if (isInserting) {
      context.missing(_evaluationMeta);
    }
    if (data.containsKey('error_count')) {
      context.handle(
        _errorCountMeta,
        errorCount.isAcceptableOrUnknown(data['error_count']!, _errorCountMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('planned_start_surah')) {
      context.handle(
        _plannedStartSurahMeta,
        plannedStartSurah.isAcceptableOrUnknown(
          data['planned_start_surah']!,
          _plannedStartSurahMeta,
        ),
      );
    }
    if (data.containsKey('planned_start_ayah')) {
      context.handle(
        _plannedStartAyahMeta,
        plannedStartAyah.isAcceptableOrUnknown(
          data['planned_start_ayah']!,
          _plannedStartAyahMeta,
        ),
      );
    }
    if (data.containsKey('planned_end_surah')) {
      context.handle(
        _plannedEndSurahMeta,
        plannedEndSurah.isAcceptableOrUnknown(
          data['planned_end_surah']!,
          _plannedEndSurahMeta,
        ),
      );
    }
    if (data.containsKey('planned_end_ayah')) {
      context.handle(
        _plannedEndAyahMeta,
        plannedEndAyah.isAcceptableOrUnknown(
          data['planned_end_ayah']!,
          _plannedEndAyahMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recitation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recitation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dayId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      startSurah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_surah'],
      )!,
      startAyah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ayah'],
      )!,
      endSurah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_surah'],
      )!,
      endAyah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_ayah'],
      )!,
      facesQuarterAchieved: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}faces_quarter_achieved'],
      )!,
      evaluation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evaluation'],
      )!,
      errorCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}error_count'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      plannedStartSurah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_start_surah'],
      ),
      plannedStartAyah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_start_ayah'],
      ),
      plannedEndSurah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_end_surah'],
      ),
      plannedEndAyah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_end_ayah'],
      ),
    );
  }

  @override
  $RecitationsTable createAlias(String alias) {
    return $RecitationsTable(attachedDatabase, alias);
  }
}

class Recitation extends DataClass implements Insertable<Recitation> {
  final int id;
  final int dayId;
  final int studentId;
  final String type;
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;
  final int facesQuarterAchieved;
  final String evaluation;
  final int errorCount;
  final String? note;
  final int? plannedStartSurah;
  final int? plannedStartAyah;
  final int? plannedEndSurah;
  final int? plannedEndAyah;
  const Recitation({
    required this.id,
    required this.dayId,
    required this.studentId,
    required this.type,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
    required this.facesQuarterAchieved,
    required this.evaluation,
    required this.errorCount,
    this.note,
    this.plannedStartSurah,
    this.plannedStartAyah,
    this.plannedEndSurah,
    this.plannedEndAyah,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day_id'] = Variable<int>(dayId);
    map['student_id'] = Variable<int>(studentId);
    map['type'] = Variable<String>(type);
    map['start_surah'] = Variable<int>(startSurah);
    map['start_ayah'] = Variable<int>(startAyah);
    map['end_surah'] = Variable<int>(endSurah);
    map['end_ayah'] = Variable<int>(endAyah);
    map['faces_quarter_achieved'] = Variable<int>(facesQuarterAchieved);
    map['evaluation'] = Variable<String>(evaluation);
    map['error_count'] = Variable<int>(errorCount);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || plannedStartSurah != null) {
      map['planned_start_surah'] = Variable<int>(plannedStartSurah);
    }
    if (!nullToAbsent || plannedStartAyah != null) {
      map['planned_start_ayah'] = Variable<int>(plannedStartAyah);
    }
    if (!nullToAbsent || plannedEndSurah != null) {
      map['planned_end_surah'] = Variable<int>(plannedEndSurah);
    }
    if (!nullToAbsent || plannedEndAyah != null) {
      map['planned_end_ayah'] = Variable<int>(plannedEndAyah);
    }
    return map;
  }

  RecitationsCompanion toCompanion(bool nullToAbsent) {
    return RecitationsCompanion(
      id: Value(id),
      dayId: Value(dayId),
      studentId: Value(studentId),
      type: Value(type),
      startSurah: Value(startSurah),
      startAyah: Value(startAyah),
      endSurah: Value(endSurah),
      endAyah: Value(endAyah),
      facesQuarterAchieved: Value(facesQuarterAchieved),
      evaluation: Value(evaluation),
      errorCount: Value(errorCount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      plannedStartSurah: plannedStartSurah == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedStartSurah),
      plannedStartAyah: plannedStartAyah == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedStartAyah),
      plannedEndSurah: plannedEndSurah == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedEndSurah),
      plannedEndAyah: plannedEndAyah == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedEndAyah),
    );
  }

  factory Recitation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recitation(
      id: serializer.fromJson<int>(json['id']),
      dayId: serializer.fromJson<int>(json['dayId']),
      studentId: serializer.fromJson<int>(json['studentId']),
      type: serializer.fromJson<String>(json['type']),
      startSurah: serializer.fromJson<int>(json['startSurah']),
      startAyah: serializer.fromJson<int>(json['startAyah']),
      endSurah: serializer.fromJson<int>(json['endSurah']),
      endAyah: serializer.fromJson<int>(json['endAyah']),
      facesQuarterAchieved: serializer.fromJson<int>(
        json['facesQuarterAchieved'],
      ),
      evaluation: serializer.fromJson<String>(json['evaluation']),
      errorCount: serializer.fromJson<int>(json['errorCount']),
      note: serializer.fromJson<String?>(json['note']),
      plannedStartSurah: serializer.fromJson<int?>(json['plannedStartSurah']),
      plannedStartAyah: serializer.fromJson<int?>(json['plannedStartAyah']),
      plannedEndSurah: serializer.fromJson<int?>(json['plannedEndSurah']),
      plannedEndAyah: serializer.fromJson<int?>(json['plannedEndAyah']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayId': serializer.toJson<int>(dayId),
      'studentId': serializer.toJson<int>(studentId),
      'type': serializer.toJson<String>(type),
      'startSurah': serializer.toJson<int>(startSurah),
      'startAyah': serializer.toJson<int>(startAyah),
      'endSurah': serializer.toJson<int>(endSurah),
      'endAyah': serializer.toJson<int>(endAyah),
      'facesQuarterAchieved': serializer.toJson<int>(facesQuarterAchieved),
      'evaluation': serializer.toJson<String>(evaluation),
      'errorCount': serializer.toJson<int>(errorCount),
      'note': serializer.toJson<String?>(note),
      'plannedStartSurah': serializer.toJson<int?>(plannedStartSurah),
      'plannedStartAyah': serializer.toJson<int?>(plannedStartAyah),
      'plannedEndSurah': serializer.toJson<int?>(plannedEndSurah),
      'plannedEndAyah': serializer.toJson<int?>(plannedEndAyah),
    };
  }

  Recitation copyWith({
    int? id,
    int? dayId,
    int? studentId,
    String? type,
    int? startSurah,
    int? startAyah,
    int? endSurah,
    int? endAyah,
    int? facesQuarterAchieved,
    String? evaluation,
    int? errorCount,
    Value<String?> note = const Value.absent(),
    Value<int?> plannedStartSurah = const Value.absent(),
    Value<int?> plannedStartAyah = const Value.absent(),
    Value<int?> plannedEndSurah = const Value.absent(),
    Value<int?> plannedEndAyah = const Value.absent(),
  }) => Recitation(
    id: id ?? this.id,
    dayId: dayId ?? this.dayId,
    studentId: studentId ?? this.studentId,
    type: type ?? this.type,
    startSurah: startSurah ?? this.startSurah,
    startAyah: startAyah ?? this.startAyah,
    endSurah: endSurah ?? this.endSurah,
    endAyah: endAyah ?? this.endAyah,
    facesQuarterAchieved: facesQuarterAchieved ?? this.facesQuarterAchieved,
    evaluation: evaluation ?? this.evaluation,
    errorCount: errorCount ?? this.errorCount,
    note: note.present ? note.value : this.note,
    plannedStartSurah: plannedStartSurah.present
        ? plannedStartSurah.value
        : this.plannedStartSurah,
    plannedStartAyah: plannedStartAyah.present
        ? plannedStartAyah.value
        : this.plannedStartAyah,
    plannedEndSurah: plannedEndSurah.present
        ? plannedEndSurah.value
        : this.plannedEndSurah,
    plannedEndAyah: plannedEndAyah.present
        ? plannedEndAyah.value
        : this.plannedEndAyah,
  );
  Recitation copyWithCompanion(RecitationsCompanion data) {
    return Recitation(
      id: data.id.present ? data.id.value : this.id,
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      type: data.type.present ? data.type.value : this.type,
      startSurah: data.startSurah.present
          ? data.startSurah.value
          : this.startSurah,
      startAyah: data.startAyah.present ? data.startAyah.value : this.startAyah,
      endSurah: data.endSurah.present ? data.endSurah.value : this.endSurah,
      endAyah: data.endAyah.present ? data.endAyah.value : this.endAyah,
      facesQuarterAchieved: data.facesQuarterAchieved.present
          ? data.facesQuarterAchieved.value
          : this.facesQuarterAchieved,
      evaluation: data.evaluation.present
          ? data.evaluation.value
          : this.evaluation,
      errorCount: data.errorCount.present
          ? data.errorCount.value
          : this.errorCount,
      note: data.note.present ? data.note.value : this.note,
      plannedStartSurah: data.plannedStartSurah.present
          ? data.plannedStartSurah.value
          : this.plannedStartSurah,
      plannedStartAyah: data.plannedStartAyah.present
          ? data.plannedStartAyah.value
          : this.plannedStartAyah,
      plannedEndSurah: data.plannedEndSurah.present
          ? data.plannedEndSurah.value
          : this.plannedEndSurah,
      plannedEndAyah: data.plannedEndAyah.present
          ? data.plannedEndAyah.value
          : this.plannedEndAyah,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recitation(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('studentId: $studentId, ')
          ..write('type: $type, ')
          ..write('startSurah: $startSurah, ')
          ..write('startAyah: $startAyah, ')
          ..write('endSurah: $endSurah, ')
          ..write('endAyah: $endAyah, ')
          ..write('facesQuarterAchieved: $facesQuarterAchieved, ')
          ..write('evaluation: $evaluation, ')
          ..write('errorCount: $errorCount, ')
          ..write('note: $note, ')
          ..write('plannedStartSurah: $plannedStartSurah, ')
          ..write('plannedStartAyah: $plannedStartAyah, ')
          ..write('plannedEndSurah: $plannedEndSurah, ')
          ..write('plannedEndAyah: $plannedEndAyah')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dayId,
    studentId,
    type,
    startSurah,
    startAyah,
    endSurah,
    endAyah,
    facesQuarterAchieved,
    evaluation,
    errorCount,
    note,
    plannedStartSurah,
    plannedStartAyah,
    plannedEndSurah,
    plannedEndAyah,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recitation &&
          other.id == this.id &&
          other.dayId == this.dayId &&
          other.studentId == this.studentId &&
          other.type == this.type &&
          other.startSurah == this.startSurah &&
          other.startAyah == this.startAyah &&
          other.endSurah == this.endSurah &&
          other.endAyah == this.endAyah &&
          other.facesQuarterAchieved == this.facesQuarterAchieved &&
          other.evaluation == this.evaluation &&
          other.errorCount == this.errorCount &&
          other.note == this.note &&
          other.plannedStartSurah == this.plannedStartSurah &&
          other.plannedStartAyah == this.plannedStartAyah &&
          other.plannedEndSurah == this.plannedEndSurah &&
          other.plannedEndAyah == this.plannedEndAyah);
}

class RecitationsCompanion extends UpdateCompanion<Recitation> {
  final Value<int> id;
  final Value<int> dayId;
  final Value<int> studentId;
  final Value<String> type;
  final Value<int> startSurah;
  final Value<int> startAyah;
  final Value<int> endSurah;
  final Value<int> endAyah;
  final Value<int> facesQuarterAchieved;
  final Value<String> evaluation;
  final Value<int> errorCount;
  final Value<String?> note;
  final Value<int?> plannedStartSurah;
  final Value<int?> plannedStartAyah;
  final Value<int?> plannedEndSurah;
  final Value<int?> plannedEndAyah;
  const RecitationsCompanion({
    this.id = const Value.absent(),
    this.dayId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.type = const Value.absent(),
    this.startSurah = const Value.absent(),
    this.startAyah = const Value.absent(),
    this.endSurah = const Value.absent(),
    this.endAyah = const Value.absent(),
    this.facesQuarterAchieved = const Value.absent(),
    this.evaluation = const Value.absent(),
    this.errorCount = const Value.absent(),
    this.note = const Value.absent(),
    this.plannedStartSurah = const Value.absent(),
    this.plannedStartAyah = const Value.absent(),
    this.plannedEndSurah = const Value.absent(),
    this.plannedEndAyah = const Value.absent(),
  });
  RecitationsCompanion.insert({
    this.id = const Value.absent(),
    required int dayId,
    required int studentId,
    required String type,
    required int startSurah,
    required int startAyah,
    required int endSurah,
    required int endAyah,
    required int facesQuarterAchieved,
    required String evaluation,
    this.errorCount = const Value.absent(),
    this.note = const Value.absent(),
    this.plannedStartSurah = const Value.absent(),
    this.plannedStartAyah = const Value.absent(),
    this.plannedEndSurah = const Value.absent(),
    this.plannedEndAyah = const Value.absent(),
  }) : dayId = Value(dayId),
       studentId = Value(studentId),
       type = Value(type),
       startSurah = Value(startSurah),
       startAyah = Value(startAyah),
       endSurah = Value(endSurah),
       endAyah = Value(endAyah),
       facesQuarterAchieved = Value(facesQuarterAchieved),
       evaluation = Value(evaluation);
  static Insertable<Recitation> custom({
    Expression<int>? id,
    Expression<int>? dayId,
    Expression<int>? studentId,
    Expression<String>? type,
    Expression<int>? startSurah,
    Expression<int>? startAyah,
    Expression<int>? endSurah,
    Expression<int>? endAyah,
    Expression<int>? facesQuarterAchieved,
    Expression<String>? evaluation,
    Expression<int>? errorCount,
    Expression<String>? note,
    Expression<int>? plannedStartSurah,
    Expression<int>? plannedStartAyah,
    Expression<int>? plannedEndSurah,
    Expression<int>? plannedEndAyah,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayId != null) 'day_id': dayId,
      if (studentId != null) 'student_id': studentId,
      if (type != null) 'type': type,
      if (startSurah != null) 'start_surah': startSurah,
      if (startAyah != null) 'start_ayah': startAyah,
      if (endSurah != null) 'end_surah': endSurah,
      if (endAyah != null) 'end_ayah': endAyah,
      if (facesQuarterAchieved != null)
        'faces_quarter_achieved': facesQuarterAchieved,
      if (evaluation != null) 'evaluation': evaluation,
      if (errorCount != null) 'error_count': errorCount,
      if (note != null) 'note': note,
      if (plannedStartSurah != null) 'planned_start_surah': plannedStartSurah,
      if (plannedStartAyah != null) 'planned_start_ayah': plannedStartAyah,
      if (plannedEndSurah != null) 'planned_end_surah': plannedEndSurah,
      if (plannedEndAyah != null) 'planned_end_ayah': plannedEndAyah,
    });
  }

  RecitationsCompanion copyWith({
    Value<int>? id,
    Value<int>? dayId,
    Value<int>? studentId,
    Value<String>? type,
    Value<int>? startSurah,
    Value<int>? startAyah,
    Value<int>? endSurah,
    Value<int>? endAyah,
    Value<int>? facesQuarterAchieved,
    Value<String>? evaluation,
    Value<int>? errorCount,
    Value<String?>? note,
    Value<int?>? plannedStartSurah,
    Value<int?>? plannedStartAyah,
    Value<int?>? plannedEndSurah,
    Value<int?>? plannedEndAyah,
  }) {
    return RecitationsCompanion(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      studentId: studentId ?? this.studentId,
      type: type ?? this.type,
      startSurah: startSurah ?? this.startSurah,
      startAyah: startAyah ?? this.startAyah,
      endSurah: endSurah ?? this.endSurah,
      endAyah: endAyah ?? this.endAyah,
      facesQuarterAchieved: facesQuarterAchieved ?? this.facesQuarterAchieved,
      evaluation: evaluation ?? this.evaluation,
      errorCount: errorCount ?? this.errorCount,
      note: note ?? this.note,
      plannedStartSurah: plannedStartSurah ?? this.plannedStartSurah,
      plannedStartAyah: plannedStartAyah ?? this.plannedStartAyah,
      plannedEndSurah: plannedEndSurah ?? this.plannedEndSurah,
      plannedEndAyah: plannedEndAyah ?? this.plannedEndAyah,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayId.present) {
      map['day_id'] = Variable<int>(dayId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (startSurah.present) {
      map['start_surah'] = Variable<int>(startSurah.value);
    }
    if (startAyah.present) {
      map['start_ayah'] = Variable<int>(startAyah.value);
    }
    if (endSurah.present) {
      map['end_surah'] = Variable<int>(endSurah.value);
    }
    if (endAyah.present) {
      map['end_ayah'] = Variable<int>(endAyah.value);
    }
    if (facesQuarterAchieved.present) {
      map['faces_quarter_achieved'] = Variable<int>(facesQuarterAchieved.value);
    }
    if (evaluation.present) {
      map['evaluation'] = Variable<String>(evaluation.value);
    }
    if (errorCount.present) {
      map['error_count'] = Variable<int>(errorCount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (plannedStartSurah.present) {
      map['planned_start_surah'] = Variable<int>(plannedStartSurah.value);
    }
    if (plannedStartAyah.present) {
      map['planned_start_ayah'] = Variable<int>(plannedStartAyah.value);
    }
    if (plannedEndSurah.present) {
      map['planned_end_surah'] = Variable<int>(plannedEndSurah.value);
    }
    if (plannedEndAyah.present) {
      map['planned_end_ayah'] = Variable<int>(plannedEndAyah.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecitationsCompanion(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('studentId: $studentId, ')
          ..write('type: $type, ')
          ..write('startSurah: $startSurah, ')
          ..write('startAyah: $startAyah, ')
          ..write('endSurah: $endSurah, ')
          ..write('endAyah: $endAyah, ')
          ..write('facesQuarterAchieved: $facesQuarterAchieved, ')
          ..write('evaluation: $evaluation, ')
          ..write('errorCount: $errorCount, ')
          ..write('note: $note, ')
          ..write('plannedStartSurah: $plannedStartSurah, ')
          ..write('plannedStartAyah: $plannedStartAyah, ')
          ..write('plannedEndSurah: $plannedEndSurah, ')
          ..write('plannedEndAyah: $plannedEndAyah')
          ..write(')'))
        .toString();
  }
}

class $ParentFollowUpsTable extends ParentFollowUps
    with TableInfo<$ParentFollowUpsTable, ParentFollowUp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParentFollowUpsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<int> dayId = GeneratedColumn<int>(
    'day_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES halaqah_days (id) ON DELETE RESTRICT',
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _correctsFollowUpIdMeta =
      const VerificationMeta('correctsFollowUpId');
  @override
  late final GeneratedColumn<int> correctsFollowUpId = GeneratedColumn<int>(
    'corrects_follow_up_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES parent_follow_ups (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _attendanceStatusSnapshotMeta =
      const VerificationMeta('attendanceStatusSnapshot');
  @override
  late final GeneratedColumn<String> attendanceStatusSnapshot =
      GeneratedColumn<String>(
        'attendance_status_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _snapshotMessageMeta = const VerificationMeta(
    'snapshotMessage',
  );
  @override
  late final GeneratedColumn<String> snapshotMessage = GeneratedColumn<String>(
    'snapshot_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _channelSnapshotMeta = const VerificationMeta(
    'channelSnapshot',
  );
  @override
  late final GeneratedColumn<String> channelSnapshot = GeneratedColumn<String>(
    'channel_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recipientSnapshotMeta = const VerificationMeta(
    'recipientSnapshot',
  );
  @override
  late final GeneratedColumn<String> recipientSnapshot =
      GeneratedColumn<String>(
        'recipient_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dayId,
    studentId,
    type,
    status,
    correctsFollowUpId,
    attendanceStatusSnapshot,
    snapshotMessage,
    channelSnapshot,
    recipientSnapshot,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parent_follow_ups';
  @override
  VerificationContext validateIntegrity(
    Insertable<ParentFollowUp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_id')) {
      context.handle(
        _dayIdMeta,
        dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('corrects_follow_up_id')) {
      context.handle(
        _correctsFollowUpIdMeta,
        correctsFollowUpId.isAcceptableOrUnknown(
          data['corrects_follow_up_id']!,
          _correctsFollowUpIdMeta,
        ),
      );
    }
    if (data.containsKey('attendance_status_snapshot')) {
      context.handle(
        _attendanceStatusSnapshotMeta,
        attendanceStatusSnapshot.isAcceptableOrUnknown(
          data['attendance_status_snapshot']!,
          _attendanceStatusSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('snapshot_message')) {
      context.handle(
        _snapshotMessageMeta,
        snapshotMessage.isAcceptableOrUnknown(
          data['snapshot_message']!,
          _snapshotMessageMeta,
        ),
      );
    }
    if (data.containsKey('channel_snapshot')) {
      context.handle(
        _channelSnapshotMeta,
        channelSnapshot.isAcceptableOrUnknown(
          data['channel_snapshot']!,
          _channelSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('recipient_snapshot')) {
      context.handle(
        _recipientSnapshotMeta,
        recipientSnapshot.isAcceptableOrUnknown(
          data['recipient_snapshot']!,
          _recipientSnapshotMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ParentFollowUp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParentFollowUp(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dayId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      correctsFollowUpId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}corrects_follow_up_id'],
      ),
      attendanceStatusSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attendance_status_snapshot'],
      ),
      snapshotMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot_message'],
      ),
      channelSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_snapshot'],
      ),
      recipientSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipient_snapshot'],
      ),
    );
  }

  @override
  $ParentFollowUpsTable createAlias(String alias) {
    return $ParentFollowUpsTable(attachedDatabase, alias);
  }
}

class ParentFollowUp extends DataClass implements Insertable<ParentFollowUp> {
  final int id;
  final int dayId;
  final int studentId;
  final String type;
  final String status;
  final int? correctsFollowUpId;
  final String? attendanceStatusSnapshot;
  final String? snapshotMessage;
  final String? channelSnapshot;
  final String? recipientSnapshot;
  const ParentFollowUp({
    required this.id,
    required this.dayId,
    required this.studentId,
    required this.type,
    required this.status,
    this.correctsFollowUpId,
    this.attendanceStatusSnapshot,
    this.snapshotMessage,
    this.channelSnapshot,
    this.recipientSnapshot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day_id'] = Variable<int>(dayId);
    map['student_id'] = Variable<int>(studentId);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || correctsFollowUpId != null) {
      map['corrects_follow_up_id'] = Variable<int>(correctsFollowUpId);
    }
    if (!nullToAbsent || attendanceStatusSnapshot != null) {
      map['attendance_status_snapshot'] = Variable<String>(
        attendanceStatusSnapshot,
      );
    }
    if (!nullToAbsent || snapshotMessage != null) {
      map['snapshot_message'] = Variable<String>(snapshotMessage);
    }
    if (!nullToAbsent || channelSnapshot != null) {
      map['channel_snapshot'] = Variable<String>(channelSnapshot);
    }
    if (!nullToAbsent || recipientSnapshot != null) {
      map['recipient_snapshot'] = Variable<String>(recipientSnapshot);
    }
    return map;
  }

  ParentFollowUpsCompanion toCompanion(bool nullToAbsent) {
    return ParentFollowUpsCompanion(
      id: Value(id),
      dayId: Value(dayId),
      studentId: Value(studentId),
      type: Value(type),
      status: Value(status),
      correctsFollowUpId: correctsFollowUpId == null && nullToAbsent
          ? const Value.absent()
          : Value(correctsFollowUpId),
      attendanceStatusSnapshot: attendanceStatusSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(attendanceStatusSnapshot),
      snapshotMessage: snapshotMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(snapshotMessage),
      channelSnapshot: channelSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(channelSnapshot),
      recipientSnapshot: recipientSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(recipientSnapshot),
    );
  }

  factory ParentFollowUp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ParentFollowUp(
      id: serializer.fromJson<int>(json['id']),
      dayId: serializer.fromJson<int>(json['dayId']),
      studentId: serializer.fromJson<int>(json['studentId']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      correctsFollowUpId: serializer.fromJson<int?>(json['correctsFollowUpId']),
      attendanceStatusSnapshot: serializer.fromJson<String?>(
        json['attendanceStatusSnapshot'],
      ),
      snapshotMessage: serializer.fromJson<String?>(json['snapshotMessage']),
      channelSnapshot: serializer.fromJson<String?>(json['channelSnapshot']),
      recipientSnapshot: serializer.fromJson<String?>(
        json['recipientSnapshot'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayId': serializer.toJson<int>(dayId),
      'studentId': serializer.toJson<int>(studentId),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'correctsFollowUpId': serializer.toJson<int?>(correctsFollowUpId),
      'attendanceStatusSnapshot': serializer.toJson<String?>(
        attendanceStatusSnapshot,
      ),
      'snapshotMessage': serializer.toJson<String?>(snapshotMessage),
      'channelSnapshot': serializer.toJson<String?>(channelSnapshot),
      'recipientSnapshot': serializer.toJson<String?>(recipientSnapshot),
    };
  }

  ParentFollowUp copyWith({
    int? id,
    int? dayId,
    int? studentId,
    String? type,
    String? status,
    Value<int?> correctsFollowUpId = const Value.absent(),
    Value<String?> attendanceStatusSnapshot = const Value.absent(),
    Value<String?> snapshotMessage = const Value.absent(),
    Value<String?> channelSnapshot = const Value.absent(),
    Value<String?> recipientSnapshot = const Value.absent(),
  }) => ParentFollowUp(
    id: id ?? this.id,
    dayId: dayId ?? this.dayId,
    studentId: studentId ?? this.studentId,
    type: type ?? this.type,
    status: status ?? this.status,
    correctsFollowUpId: correctsFollowUpId.present
        ? correctsFollowUpId.value
        : this.correctsFollowUpId,
    attendanceStatusSnapshot: attendanceStatusSnapshot.present
        ? attendanceStatusSnapshot.value
        : this.attendanceStatusSnapshot,
    snapshotMessage: snapshotMessage.present
        ? snapshotMessage.value
        : this.snapshotMessage,
    channelSnapshot: channelSnapshot.present
        ? channelSnapshot.value
        : this.channelSnapshot,
    recipientSnapshot: recipientSnapshot.present
        ? recipientSnapshot.value
        : this.recipientSnapshot,
  );
  ParentFollowUp copyWithCompanion(ParentFollowUpsCompanion data) {
    return ParentFollowUp(
      id: data.id.present ? data.id.value : this.id,
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      correctsFollowUpId: data.correctsFollowUpId.present
          ? data.correctsFollowUpId.value
          : this.correctsFollowUpId,
      attendanceStatusSnapshot: data.attendanceStatusSnapshot.present
          ? data.attendanceStatusSnapshot.value
          : this.attendanceStatusSnapshot,
      snapshotMessage: data.snapshotMessage.present
          ? data.snapshotMessage.value
          : this.snapshotMessage,
      channelSnapshot: data.channelSnapshot.present
          ? data.channelSnapshot.value
          : this.channelSnapshot,
      recipientSnapshot: data.recipientSnapshot.present
          ? data.recipientSnapshot.value
          : this.recipientSnapshot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ParentFollowUp(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('studentId: $studentId, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('correctsFollowUpId: $correctsFollowUpId, ')
          ..write('attendanceStatusSnapshot: $attendanceStatusSnapshot, ')
          ..write('snapshotMessage: $snapshotMessage, ')
          ..write('channelSnapshot: $channelSnapshot, ')
          ..write('recipientSnapshot: $recipientSnapshot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dayId,
    studentId,
    type,
    status,
    correctsFollowUpId,
    attendanceStatusSnapshot,
    snapshotMessage,
    channelSnapshot,
    recipientSnapshot,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParentFollowUp &&
          other.id == this.id &&
          other.dayId == this.dayId &&
          other.studentId == this.studentId &&
          other.type == this.type &&
          other.status == this.status &&
          other.correctsFollowUpId == this.correctsFollowUpId &&
          other.attendanceStatusSnapshot == this.attendanceStatusSnapshot &&
          other.snapshotMessage == this.snapshotMessage &&
          other.channelSnapshot == this.channelSnapshot &&
          other.recipientSnapshot == this.recipientSnapshot);
}

class ParentFollowUpsCompanion extends UpdateCompanion<ParentFollowUp> {
  final Value<int> id;
  final Value<int> dayId;
  final Value<int> studentId;
  final Value<String> type;
  final Value<String> status;
  final Value<int?> correctsFollowUpId;
  final Value<String?> attendanceStatusSnapshot;
  final Value<String?> snapshotMessage;
  final Value<String?> channelSnapshot;
  final Value<String?> recipientSnapshot;
  const ParentFollowUpsCompanion({
    this.id = const Value.absent(),
    this.dayId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.correctsFollowUpId = const Value.absent(),
    this.attendanceStatusSnapshot = const Value.absent(),
    this.snapshotMessage = const Value.absent(),
    this.channelSnapshot = const Value.absent(),
    this.recipientSnapshot = const Value.absent(),
  });
  ParentFollowUpsCompanion.insert({
    this.id = const Value.absent(),
    required int dayId,
    required int studentId,
    required String type,
    this.status = const Value.absent(),
    this.correctsFollowUpId = const Value.absent(),
    this.attendanceStatusSnapshot = const Value.absent(),
    this.snapshotMessage = const Value.absent(),
    this.channelSnapshot = const Value.absent(),
    this.recipientSnapshot = const Value.absent(),
  }) : dayId = Value(dayId),
       studentId = Value(studentId),
       type = Value(type);
  static Insertable<ParentFollowUp> custom({
    Expression<int>? id,
    Expression<int>? dayId,
    Expression<int>? studentId,
    Expression<String>? type,
    Expression<String>? status,
    Expression<int>? correctsFollowUpId,
    Expression<String>? attendanceStatusSnapshot,
    Expression<String>? snapshotMessage,
    Expression<String>? channelSnapshot,
    Expression<String>? recipientSnapshot,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayId != null) 'day_id': dayId,
      if (studentId != null) 'student_id': studentId,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (correctsFollowUpId != null)
        'corrects_follow_up_id': correctsFollowUpId,
      if (attendanceStatusSnapshot != null)
        'attendance_status_snapshot': attendanceStatusSnapshot,
      if (snapshotMessage != null) 'snapshot_message': snapshotMessage,
      if (channelSnapshot != null) 'channel_snapshot': channelSnapshot,
      if (recipientSnapshot != null) 'recipient_snapshot': recipientSnapshot,
    });
  }

  ParentFollowUpsCompanion copyWith({
    Value<int>? id,
    Value<int>? dayId,
    Value<int>? studentId,
    Value<String>? type,
    Value<String>? status,
    Value<int?>? correctsFollowUpId,
    Value<String?>? attendanceStatusSnapshot,
    Value<String?>? snapshotMessage,
    Value<String?>? channelSnapshot,
    Value<String?>? recipientSnapshot,
  }) {
    return ParentFollowUpsCompanion(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      studentId: studentId ?? this.studentId,
      type: type ?? this.type,
      status: status ?? this.status,
      correctsFollowUpId: correctsFollowUpId ?? this.correctsFollowUpId,
      attendanceStatusSnapshot:
          attendanceStatusSnapshot ?? this.attendanceStatusSnapshot,
      snapshotMessage: snapshotMessage ?? this.snapshotMessage,
      channelSnapshot: channelSnapshot ?? this.channelSnapshot,
      recipientSnapshot: recipientSnapshot ?? this.recipientSnapshot,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayId.present) {
      map['day_id'] = Variable<int>(dayId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (correctsFollowUpId.present) {
      map['corrects_follow_up_id'] = Variable<int>(correctsFollowUpId.value);
    }
    if (attendanceStatusSnapshot.present) {
      map['attendance_status_snapshot'] = Variable<String>(
        attendanceStatusSnapshot.value,
      );
    }
    if (snapshotMessage.present) {
      map['snapshot_message'] = Variable<String>(snapshotMessage.value);
    }
    if (channelSnapshot.present) {
      map['channel_snapshot'] = Variable<String>(channelSnapshot.value);
    }
    if (recipientSnapshot.present) {
      map['recipient_snapshot'] = Variable<String>(recipientSnapshot.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParentFollowUpsCompanion(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('studentId: $studentId, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('correctsFollowUpId: $correctsFollowUpId, ')
          ..write('attendanceStatusSnapshot: $attendanceStatusSnapshot, ')
          ..write('snapshotMessage: $snapshotMessage, ')
          ..write('channelSnapshot: $channelSnapshot, ')
          ..write('recipientSnapshot: $recipientSnapshot')
          ..write(')'))
        .toString();
  }
}

class $SupportWeeklyReportsTable extends SupportWeeklyReports
    with TableInfo<$SupportWeeklyReportsTable, SupportWeeklyReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupportWeeklyReportsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _weekStartDateMeta = const VerificationMeta(
    'weekStartDate',
  );
  @override
  late final GeneratedColumn<String> weekStartDate = GeneratedColumn<String>(
    'week_start_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekEndDateMeta = const VerificationMeta(
    'weekEndDate',
  );
  @override
  late final GeneratedColumn<String> weekEndDate = GeneratedColumn<String>(
    'week_end_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _teacherNameSnapshotMeta =
      const VerificationMeta('teacherNameSnapshot');
  @override
  late final GeneratedColumn<String> teacherNameSnapshot =
      GeneratedColumn<String>(
        'teacher_name_snapshot',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 200,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _halaqahNameSnapshotMeta =
      const VerificationMeta('halaqahNameSnapshot');
  @override
  late final GeneratedColumn<String> halaqahNameSnapshot =
      GeneratedColumn<String>(
        'halaqah_name_snapshot',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 200,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _organizationNameSnapshotMeta =
      const VerificationMeta('organizationNameSnapshot');
  @override
  late final GeneratedColumn<String> organizationNameSnapshot =
      GeneratedColumn<String>(
        'organization_name_snapshot',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 200,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _policyVersionMeta = const VerificationMeta(
    'policyVersion',
  );
  @override
  late final GeneratedColumn<int> policyVersion = GeneratedColumn<int>(
    'policy_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateVersionMeta = const VerificationMeta(
    'templateVersion',
  );
  @override
  late final GeneratedColumn<int> templateVersion = GeneratedColumn<int>(
    'template_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceFingerprintMeta = const VerificationMeta(
    'sourceFingerprint',
  );
  @override
  late final GeneratedColumn<String> sourceFingerprint =
      GeneratedColumn<String>(
        'source_fingerprint',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _approvedAtUtcMeta = const VerificationMeta(
    'approvedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> approvedAtUtc =
      GeneratedColumn<DateTime>(
        'approved_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    halaqahId,
    weekStartDate,
    weekEndDate,
    status,
    teacherNameSnapshot,
    halaqahNameSnapshot,
    organizationNameSnapshot,
    policyVersion,
    templateVersion,
    sourceFingerprint,
    approvedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'support_weekly_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupportWeeklyReport> instance, {
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
    if (data.containsKey('week_start_date')) {
      context.handle(
        _weekStartDateMeta,
        weekStartDate.isAcceptableOrUnknown(
          data['week_start_date']!,
          _weekStartDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weekStartDateMeta);
    }
    if (data.containsKey('week_end_date')) {
      context.handle(
        _weekEndDateMeta,
        weekEndDate.isAcceptableOrUnknown(
          data['week_end_date']!,
          _weekEndDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weekEndDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('teacher_name_snapshot')) {
      context.handle(
        _teacherNameSnapshotMeta,
        teacherNameSnapshot.isAcceptableOrUnknown(
          data['teacher_name_snapshot']!,
          _teacherNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_teacherNameSnapshotMeta);
    }
    if (data.containsKey('halaqah_name_snapshot')) {
      context.handle(
        _halaqahNameSnapshotMeta,
        halaqahNameSnapshot.isAcceptableOrUnknown(
          data['halaqah_name_snapshot']!,
          _halaqahNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_halaqahNameSnapshotMeta);
    }
    if (data.containsKey('organization_name_snapshot')) {
      context.handle(
        _organizationNameSnapshotMeta,
        organizationNameSnapshot.isAcceptableOrUnknown(
          data['organization_name_snapshot']!,
          _organizationNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationNameSnapshotMeta);
    }
    if (data.containsKey('policy_version')) {
      context.handle(
        _policyVersionMeta,
        policyVersion.isAcceptableOrUnknown(
          data['policy_version']!,
          _policyVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_policyVersionMeta);
    }
    if (data.containsKey('template_version')) {
      context.handle(
        _templateVersionMeta,
        templateVersion.isAcceptableOrUnknown(
          data['template_version']!,
          _templateVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_templateVersionMeta);
    }
    if (data.containsKey('source_fingerprint')) {
      context.handle(
        _sourceFingerprintMeta,
        sourceFingerprint.isAcceptableOrUnknown(
          data['source_fingerprint']!,
          _sourceFingerprintMeta,
        ),
      );
    }
    if (data.containsKey('approved_at_utc')) {
      context.handle(
        _approvedAtUtcMeta,
        approvedAtUtc.isAcceptableOrUnknown(
          data['approved_at_utc']!,
          _approvedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {halaqahId, weekStartDate},
  ];
  @override
  SupportWeeklyReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupportWeeklyReport(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      halaqahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}halaqah_id'],
      )!,
      weekStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_start_date'],
      )!,
      weekEndDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_end_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      teacherNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_name_snapshot'],
      )!,
      halaqahNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}halaqah_name_snapshot'],
      )!,
      organizationNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization_name_snapshot'],
      )!,
      policyVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}policy_version'],
      )!,
      templateVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}template_version'],
      )!,
      sourceFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_fingerprint'],
      ),
      approvedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}approved_at_utc'],
      ),
    );
  }

  @override
  $SupportWeeklyReportsTable createAlias(String alias) {
    return $SupportWeeklyReportsTable(attachedDatabase, alias);
  }
}

class SupportWeeklyReport extends DataClass
    implements Insertable<SupportWeeklyReport> {
  final int id;
  final int halaqahId;
  final String weekStartDate;
  final String weekEndDate;
  final String status;
  final String teacherNameSnapshot;
  final String halaqahNameSnapshot;
  final String organizationNameSnapshot;
  final int policyVersion;
  final int templateVersion;
  final String? sourceFingerprint;
  final DateTime? approvedAtUtc;
  const SupportWeeklyReport({
    required this.id,
    required this.halaqahId,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.status,
    required this.teacherNameSnapshot,
    required this.halaqahNameSnapshot,
    required this.organizationNameSnapshot,
    required this.policyVersion,
    required this.templateVersion,
    this.sourceFingerprint,
    this.approvedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['halaqah_id'] = Variable<int>(halaqahId);
    map['week_start_date'] = Variable<String>(weekStartDate);
    map['week_end_date'] = Variable<String>(weekEndDate);
    map['status'] = Variable<String>(status);
    map['teacher_name_snapshot'] = Variable<String>(teacherNameSnapshot);
    map['halaqah_name_snapshot'] = Variable<String>(halaqahNameSnapshot);
    map['organization_name_snapshot'] = Variable<String>(
      organizationNameSnapshot,
    );
    map['policy_version'] = Variable<int>(policyVersion);
    map['template_version'] = Variable<int>(templateVersion);
    if (!nullToAbsent || sourceFingerprint != null) {
      map['source_fingerprint'] = Variable<String>(sourceFingerprint);
    }
    if (!nullToAbsent || approvedAtUtc != null) {
      map['approved_at_utc'] = Variable<DateTime>(approvedAtUtc);
    }
    return map;
  }

  SupportWeeklyReportsCompanion toCompanion(bool nullToAbsent) {
    return SupportWeeklyReportsCompanion(
      id: Value(id),
      halaqahId: Value(halaqahId),
      weekStartDate: Value(weekStartDate),
      weekEndDate: Value(weekEndDate),
      status: Value(status),
      teacherNameSnapshot: Value(teacherNameSnapshot),
      halaqahNameSnapshot: Value(halaqahNameSnapshot),
      organizationNameSnapshot: Value(organizationNameSnapshot),
      policyVersion: Value(policyVersion),
      templateVersion: Value(templateVersion),
      sourceFingerprint: sourceFingerprint == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceFingerprint),
      approvedAtUtc: approvedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedAtUtc),
    );
  }

  factory SupportWeeklyReport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupportWeeklyReport(
      id: serializer.fromJson<int>(json['id']),
      halaqahId: serializer.fromJson<int>(json['halaqahId']),
      weekStartDate: serializer.fromJson<String>(json['weekStartDate']),
      weekEndDate: serializer.fromJson<String>(json['weekEndDate']),
      status: serializer.fromJson<String>(json['status']),
      teacherNameSnapshot: serializer.fromJson<String>(
        json['teacherNameSnapshot'],
      ),
      halaqahNameSnapshot: serializer.fromJson<String>(
        json['halaqahNameSnapshot'],
      ),
      organizationNameSnapshot: serializer.fromJson<String>(
        json['organizationNameSnapshot'],
      ),
      policyVersion: serializer.fromJson<int>(json['policyVersion']),
      templateVersion: serializer.fromJson<int>(json['templateVersion']),
      sourceFingerprint: serializer.fromJson<String?>(
        json['sourceFingerprint'],
      ),
      approvedAtUtc: serializer.fromJson<DateTime?>(json['approvedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'halaqahId': serializer.toJson<int>(halaqahId),
      'weekStartDate': serializer.toJson<String>(weekStartDate),
      'weekEndDate': serializer.toJson<String>(weekEndDate),
      'status': serializer.toJson<String>(status),
      'teacherNameSnapshot': serializer.toJson<String>(teacherNameSnapshot),
      'halaqahNameSnapshot': serializer.toJson<String>(halaqahNameSnapshot),
      'organizationNameSnapshot': serializer.toJson<String>(
        organizationNameSnapshot,
      ),
      'policyVersion': serializer.toJson<int>(policyVersion),
      'templateVersion': serializer.toJson<int>(templateVersion),
      'sourceFingerprint': serializer.toJson<String?>(sourceFingerprint),
      'approvedAtUtc': serializer.toJson<DateTime?>(approvedAtUtc),
    };
  }

  SupportWeeklyReport copyWith({
    int? id,
    int? halaqahId,
    String? weekStartDate,
    String? weekEndDate,
    String? status,
    String? teacherNameSnapshot,
    String? halaqahNameSnapshot,
    String? organizationNameSnapshot,
    int? policyVersion,
    int? templateVersion,
    Value<String?> sourceFingerprint = const Value.absent(),
    Value<DateTime?> approvedAtUtc = const Value.absent(),
  }) => SupportWeeklyReport(
    id: id ?? this.id,
    halaqahId: halaqahId ?? this.halaqahId,
    weekStartDate: weekStartDate ?? this.weekStartDate,
    weekEndDate: weekEndDate ?? this.weekEndDate,
    status: status ?? this.status,
    teacherNameSnapshot: teacherNameSnapshot ?? this.teacherNameSnapshot,
    halaqahNameSnapshot: halaqahNameSnapshot ?? this.halaqahNameSnapshot,
    organizationNameSnapshot:
        organizationNameSnapshot ?? this.organizationNameSnapshot,
    policyVersion: policyVersion ?? this.policyVersion,
    templateVersion: templateVersion ?? this.templateVersion,
    sourceFingerprint: sourceFingerprint.present
        ? sourceFingerprint.value
        : this.sourceFingerprint,
    approvedAtUtc: approvedAtUtc.present
        ? approvedAtUtc.value
        : this.approvedAtUtc,
  );
  SupportWeeklyReport copyWithCompanion(SupportWeeklyReportsCompanion data) {
    return SupportWeeklyReport(
      id: data.id.present ? data.id.value : this.id,
      halaqahId: data.halaqahId.present ? data.halaqahId.value : this.halaqahId,
      weekStartDate: data.weekStartDate.present
          ? data.weekStartDate.value
          : this.weekStartDate,
      weekEndDate: data.weekEndDate.present
          ? data.weekEndDate.value
          : this.weekEndDate,
      status: data.status.present ? data.status.value : this.status,
      teacherNameSnapshot: data.teacherNameSnapshot.present
          ? data.teacherNameSnapshot.value
          : this.teacherNameSnapshot,
      halaqahNameSnapshot: data.halaqahNameSnapshot.present
          ? data.halaqahNameSnapshot.value
          : this.halaqahNameSnapshot,
      organizationNameSnapshot: data.organizationNameSnapshot.present
          ? data.organizationNameSnapshot.value
          : this.organizationNameSnapshot,
      policyVersion: data.policyVersion.present
          ? data.policyVersion.value
          : this.policyVersion,
      templateVersion: data.templateVersion.present
          ? data.templateVersion.value
          : this.templateVersion,
      sourceFingerprint: data.sourceFingerprint.present
          ? data.sourceFingerprint.value
          : this.sourceFingerprint,
      approvedAtUtc: data.approvedAtUtc.present
          ? data.approvedAtUtc.value
          : this.approvedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupportWeeklyReport(')
          ..write('id: $id, ')
          ..write('halaqahId: $halaqahId, ')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('weekEndDate: $weekEndDate, ')
          ..write('status: $status, ')
          ..write('teacherNameSnapshot: $teacherNameSnapshot, ')
          ..write('halaqahNameSnapshot: $halaqahNameSnapshot, ')
          ..write('organizationNameSnapshot: $organizationNameSnapshot, ')
          ..write('policyVersion: $policyVersion, ')
          ..write('templateVersion: $templateVersion, ')
          ..write('sourceFingerprint: $sourceFingerprint, ')
          ..write('approvedAtUtc: $approvedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    halaqahId,
    weekStartDate,
    weekEndDate,
    status,
    teacherNameSnapshot,
    halaqahNameSnapshot,
    organizationNameSnapshot,
    policyVersion,
    templateVersion,
    sourceFingerprint,
    approvedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupportWeeklyReport &&
          other.id == this.id &&
          other.halaqahId == this.halaqahId &&
          other.weekStartDate == this.weekStartDate &&
          other.weekEndDate == this.weekEndDate &&
          other.status == this.status &&
          other.teacherNameSnapshot == this.teacherNameSnapshot &&
          other.halaqahNameSnapshot == this.halaqahNameSnapshot &&
          other.organizationNameSnapshot == this.organizationNameSnapshot &&
          other.policyVersion == this.policyVersion &&
          other.templateVersion == this.templateVersion &&
          other.sourceFingerprint == this.sourceFingerprint &&
          other.approvedAtUtc == this.approvedAtUtc);
}

class SupportWeeklyReportsCompanion
    extends UpdateCompanion<SupportWeeklyReport> {
  final Value<int> id;
  final Value<int> halaqahId;
  final Value<String> weekStartDate;
  final Value<String> weekEndDate;
  final Value<String> status;
  final Value<String> teacherNameSnapshot;
  final Value<String> halaqahNameSnapshot;
  final Value<String> organizationNameSnapshot;
  final Value<int> policyVersion;
  final Value<int> templateVersion;
  final Value<String?> sourceFingerprint;
  final Value<DateTime?> approvedAtUtc;
  const SupportWeeklyReportsCompanion({
    this.id = const Value.absent(),
    this.halaqahId = const Value.absent(),
    this.weekStartDate = const Value.absent(),
    this.weekEndDate = const Value.absent(),
    this.status = const Value.absent(),
    this.teacherNameSnapshot = const Value.absent(),
    this.halaqahNameSnapshot = const Value.absent(),
    this.organizationNameSnapshot = const Value.absent(),
    this.policyVersion = const Value.absent(),
    this.templateVersion = const Value.absent(),
    this.sourceFingerprint = const Value.absent(),
    this.approvedAtUtc = const Value.absent(),
  });
  SupportWeeklyReportsCompanion.insert({
    this.id = const Value.absent(),
    required int halaqahId,
    required String weekStartDate,
    required String weekEndDate,
    required String status,
    required String teacherNameSnapshot,
    required String halaqahNameSnapshot,
    required String organizationNameSnapshot,
    required int policyVersion,
    required int templateVersion,
    this.sourceFingerprint = const Value.absent(),
    this.approvedAtUtc = const Value.absent(),
  }) : halaqahId = Value(halaqahId),
       weekStartDate = Value(weekStartDate),
       weekEndDate = Value(weekEndDate),
       status = Value(status),
       teacherNameSnapshot = Value(teacherNameSnapshot),
       halaqahNameSnapshot = Value(halaqahNameSnapshot),
       organizationNameSnapshot = Value(organizationNameSnapshot),
       policyVersion = Value(policyVersion),
       templateVersion = Value(templateVersion);
  static Insertable<SupportWeeklyReport> custom({
    Expression<int>? id,
    Expression<int>? halaqahId,
    Expression<String>? weekStartDate,
    Expression<String>? weekEndDate,
    Expression<String>? status,
    Expression<String>? teacherNameSnapshot,
    Expression<String>? halaqahNameSnapshot,
    Expression<String>? organizationNameSnapshot,
    Expression<int>? policyVersion,
    Expression<int>? templateVersion,
    Expression<String>? sourceFingerprint,
    Expression<DateTime>? approvedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (halaqahId != null) 'halaqah_id': halaqahId,
      if (weekStartDate != null) 'week_start_date': weekStartDate,
      if (weekEndDate != null) 'week_end_date': weekEndDate,
      if (status != null) 'status': status,
      if (teacherNameSnapshot != null)
        'teacher_name_snapshot': teacherNameSnapshot,
      if (halaqahNameSnapshot != null)
        'halaqah_name_snapshot': halaqahNameSnapshot,
      if (organizationNameSnapshot != null)
        'organization_name_snapshot': organizationNameSnapshot,
      if (policyVersion != null) 'policy_version': policyVersion,
      if (templateVersion != null) 'template_version': templateVersion,
      if (sourceFingerprint != null) 'source_fingerprint': sourceFingerprint,
      if (approvedAtUtc != null) 'approved_at_utc': approvedAtUtc,
    });
  }

  SupportWeeklyReportsCompanion copyWith({
    Value<int>? id,
    Value<int>? halaqahId,
    Value<String>? weekStartDate,
    Value<String>? weekEndDate,
    Value<String>? status,
    Value<String>? teacherNameSnapshot,
    Value<String>? halaqahNameSnapshot,
    Value<String>? organizationNameSnapshot,
    Value<int>? policyVersion,
    Value<int>? templateVersion,
    Value<String?>? sourceFingerprint,
    Value<DateTime?>? approvedAtUtc,
  }) {
    return SupportWeeklyReportsCompanion(
      id: id ?? this.id,
      halaqahId: halaqahId ?? this.halaqahId,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      weekEndDate: weekEndDate ?? this.weekEndDate,
      status: status ?? this.status,
      teacherNameSnapshot: teacherNameSnapshot ?? this.teacherNameSnapshot,
      halaqahNameSnapshot: halaqahNameSnapshot ?? this.halaqahNameSnapshot,
      organizationNameSnapshot:
          organizationNameSnapshot ?? this.organizationNameSnapshot,
      policyVersion: policyVersion ?? this.policyVersion,
      templateVersion: templateVersion ?? this.templateVersion,
      sourceFingerprint: sourceFingerprint ?? this.sourceFingerprint,
      approvedAtUtc: approvedAtUtc ?? this.approvedAtUtc,
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
    if (weekStartDate.present) {
      map['week_start_date'] = Variable<String>(weekStartDate.value);
    }
    if (weekEndDate.present) {
      map['week_end_date'] = Variable<String>(weekEndDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (teacherNameSnapshot.present) {
      map['teacher_name_snapshot'] = Variable<String>(
        teacherNameSnapshot.value,
      );
    }
    if (halaqahNameSnapshot.present) {
      map['halaqah_name_snapshot'] = Variable<String>(
        halaqahNameSnapshot.value,
      );
    }
    if (organizationNameSnapshot.present) {
      map['organization_name_snapshot'] = Variable<String>(
        organizationNameSnapshot.value,
      );
    }
    if (policyVersion.present) {
      map['policy_version'] = Variable<int>(policyVersion.value);
    }
    if (templateVersion.present) {
      map['template_version'] = Variable<int>(templateVersion.value);
    }
    if (sourceFingerprint.present) {
      map['source_fingerprint'] = Variable<String>(sourceFingerprint.value);
    }
    if (approvedAtUtc.present) {
      map['approved_at_utc'] = Variable<DateTime>(approvedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupportWeeklyReportsCompanion(')
          ..write('id: $id, ')
          ..write('halaqahId: $halaqahId, ')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('weekEndDate: $weekEndDate, ')
          ..write('status: $status, ')
          ..write('teacherNameSnapshot: $teacherNameSnapshot, ')
          ..write('halaqahNameSnapshot: $halaqahNameSnapshot, ')
          ..write('organizationNameSnapshot: $organizationNameSnapshot, ')
          ..write('policyVersion: $policyVersion, ')
          ..write('templateVersion: $templateVersion, ')
          ..write('sourceFingerprint: $sourceFingerprint, ')
          ..write('approvedAtUtc: $approvedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $SupportWeeklyReportStudentsTable extends SupportWeeklyReportStudents
    with
        TableInfo<
          $SupportWeeklyReportStudentsTable,
          SupportWeeklyReportStudent
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupportWeeklyReportStudentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _reportIdMeta = const VerificationMeta(
    'reportId',
  );
  @override
  late final GeneratedColumn<int> reportId = GeneratedColumn<int>(
    'report_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES support_weekly_reports (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceStudentIdMeta = const VerificationMeta(
    'sourceStudentId',
  );
  @override
  late final GeneratedColumn<int> sourceStudentId = GeneratedColumn<int>(
    'source_student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _supportStudentNumberSnapshotMeta =
      const VerificationMeta('supportStudentNumberSnapshot');
  @override
  late final GeneratedColumn<String> supportStudentNumberSnapshot =
      GeneratedColumn<String>(
        'support_student_number_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _studentNameSnapshotMeta =
      const VerificationMeta('studentNameSnapshot');
  @override
  late final GeneratedColumn<String> studentNameSnapshot =
      GeneratedColumn<String>(
        'student_name_snapshot',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 200,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _currentJuzSnapshotMeta =
      const VerificationMeta('currentJuzSnapshot');
  @override
  late final GeneratedColumn<int> currentJuzSnapshot = GeneratedColumn<int>(
    'current_juz_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyPlanTextSnapshotMeta =
      const VerificationMeta('dailyPlanTextSnapshot');
  @override
  late final GeneratedColumn<String> dailyPlanTextSnapshot =
      GeneratedColumn<String>(
        'daily_plan_text_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _monthlyGoalQuarterFacesSnapshotMeta =
      const VerificationMeta('monthlyGoalQuarterFacesSnapshot');
  @override
  late final GeneratedColumn<int> monthlyGoalQuarterFacesSnapshot =
      GeneratedColumn<int>(
        'monthly_goal_quarter_faces_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _studentNoteSnapshotMeta =
      const VerificationMeta('studentNoteSnapshot');
  @override
  late final GeneratedColumn<String> studentNoteSnapshot =
      GeneratedColumn<String>(
        'student_note_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _displayOrderSnapshotMeta =
      const VerificationMeta('displayOrderSnapshot');
  @override
  late final GeneratedColumn<int> displayOrderSnapshot = GeneratedColumn<int>(
    'display_order_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reportId,
    sourceStudentId,
    supportStudentNumberSnapshot,
    studentNameSnapshot,
    currentJuzSnapshot,
    dailyPlanTextSnapshot,
    monthlyGoalQuarterFacesSnapshot,
    studentNoteSnapshot,
    displayOrderSnapshot,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'support_weekly_report_students';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupportWeeklyReportStudent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('report_id')) {
      context.handle(
        _reportIdMeta,
        reportId.isAcceptableOrUnknown(data['report_id']!, _reportIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reportIdMeta);
    }
    if (data.containsKey('source_student_id')) {
      context.handle(
        _sourceStudentIdMeta,
        sourceStudentId.isAcceptableOrUnknown(
          data['source_student_id']!,
          _sourceStudentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceStudentIdMeta);
    }
    if (data.containsKey('support_student_number_snapshot')) {
      context.handle(
        _supportStudentNumberSnapshotMeta,
        supportStudentNumberSnapshot.isAcceptableOrUnknown(
          data['support_student_number_snapshot']!,
          _supportStudentNumberSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('student_name_snapshot')) {
      context.handle(
        _studentNameSnapshotMeta,
        studentNameSnapshot.isAcceptableOrUnknown(
          data['student_name_snapshot']!,
          _studentNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_studentNameSnapshotMeta);
    }
    if (data.containsKey('current_juz_snapshot')) {
      context.handle(
        _currentJuzSnapshotMeta,
        currentJuzSnapshot.isAcceptableOrUnknown(
          data['current_juz_snapshot']!,
          _currentJuzSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('daily_plan_text_snapshot')) {
      context.handle(
        _dailyPlanTextSnapshotMeta,
        dailyPlanTextSnapshot.isAcceptableOrUnknown(
          data['daily_plan_text_snapshot']!,
          _dailyPlanTextSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('monthly_goal_quarter_faces_snapshot')) {
      context.handle(
        _monthlyGoalQuarterFacesSnapshotMeta,
        monthlyGoalQuarterFacesSnapshot.isAcceptableOrUnknown(
          data['monthly_goal_quarter_faces_snapshot']!,
          _monthlyGoalQuarterFacesSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyGoalQuarterFacesSnapshotMeta);
    }
    if (data.containsKey('student_note_snapshot')) {
      context.handle(
        _studentNoteSnapshotMeta,
        studentNoteSnapshot.isAcceptableOrUnknown(
          data['student_note_snapshot']!,
          _studentNoteSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('display_order_snapshot')) {
      context.handle(
        _displayOrderSnapshotMeta,
        displayOrderSnapshot.isAcceptableOrUnknown(
          data['display_order_snapshot']!,
          _displayOrderSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayOrderSnapshotMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {reportId, sourceStudentId},
  ];
  @override
  SupportWeeklyReportStudent map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupportWeeklyReportStudent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      reportId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}report_id'],
      )!,
      sourceStudentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_student_id'],
      )!,
      supportStudentNumberSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}support_student_number_snapshot'],
      ),
      studentNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_name_snapshot'],
      )!,
      currentJuzSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_juz_snapshot'],
      ),
      dailyPlanTextSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_plan_text_snapshot'],
      ),
      monthlyGoalQuarterFacesSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_goal_quarter_faces_snapshot'],
      )!,
      studentNoteSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_note_snapshot'],
      ),
      displayOrderSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order_snapshot'],
      )!,
    );
  }

  @override
  $SupportWeeklyReportStudentsTable createAlias(String alias) {
    return $SupportWeeklyReportStudentsTable(attachedDatabase, alias);
  }
}

class SupportWeeklyReportStudent extends DataClass
    implements Insertable<SupportWeeklyReportStudent> {
  final int id;
  final int reportId;
  final int sourceStudentId;
  final String? supportStudentNumberSnapshot;
  final String studentNameSnapshot;
  final int? currentJuzSnapshot;
  final String? dailyPlanTextSnapshot;
  final int monthlyGoalQuarterFacesSnapshot;
  final String? studentNoteSnapshot;
  final int displayOrderSnapshot;
  const SupportWeeklyReportStudent({
    required this.id,
    required this.reportId,
    required this.sourceStudentId,
    this.supportStudentNumberSnapshot,
    required this.studentNameSnapshot,
    this.currentJuzSnapshot,
    this.dailyPlanTextSnapshot,
    required this.monthlyGoalQuarterFacesSnapshot,
    this.studentNoteSnapshot,
    required this.displayOrderSnapshot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['report_id'] = Variable<int>(reportId);
    map['source_student_id'] = Variable<int>(sourceStudentId);
    if (!nullToAbsent || supportStudentNumberSnapshot != null) {
      map['support_student_number_snapshot'] = Variable<String>(
        supportStudentNumberSnapshot,
      );
    }
    map['student_name_snapshot'] = Variable<String>(studentNameSnapshot);
    if (!nullToAbsent || currentJuzSnapshot != null) {
      map['current_juz_snapshot'] = Variable<int>(currentJuzSnapshot);
    }
    if (!nullToAbsent || dailyPlanTextSnapshot != null) {
      map['daily_plan_text_snapshot'] = Variable<String>(dailyPlanTextSnapshot);
    }
    map['monthly_goal_quarter_faces_snapshot'] = Variable<int>(
      monthlyGoalQuarterFacesSnapshot,
    );
    if (!nullToAbsent || studentNoteSnapshot != null) {
      map['student_note_snapshot'] = Variable<String>(studentNoteSnapshot);
    }
    map['display_order_snapshot'] = Variable<int>(displayOrderSnapshot);
    return map;
  }

  SupportWeeklyReportStudentsCompanion toCompanion(bool nullToAbsent) {
    return SupportWeeklyReportStudentsCompanion(
      id: Value(id),
      reportId: Value(reportId),
      sourceStudentId: Value(sourceStudentId),
      supportStudentNumberSnapshot:
          supportStudentNumberSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(supportStudentNumberSnapshot),
      studentNameSnapshot: Value(studentNameSnapshot),
      currentJuzSnapshot: currentJuzSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(currentJuzSnapshot),
      dailyPlanTextSnapshot: dailyPlanTextSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyPlanTextSnapshot),
      monthlyGoalQuarterFacesSnapshot: Value(monthlyGoalQuarterFacesSnapshot),
      studentNoteSnapshot: studentNoteSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(studentNoteSnapshot),
      displayOrderSnapshot: Value(displayOrderSnapshot),
    );
  }

  factory SupportWeeklyReportStudent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupportWeeklyReportStudent(
      id: serializer.fromJson<int>(json['id']),
      reportId: serializer.fromJson<int>(json['reportId']),
      sourceStudentId: serializer.fromJson<int>(json['sourceStudentId']),
      supportStudentNumberSnapshot: serializer.fromJson<String?>(
        json['supportStudentNumberSnapshot'],
      ),
      studentNameSnapshot: serializer.fromJson<String>(
        json['studentNameSnapshot'],
      ),
      currentJuzSnapshot: serializer.fromJson<int?>(json['currentJuzSnapshot']),
      dailyPlanTextSnapshot: serializer.fromJson<String?>(
        json['dailyPlanTextSnapshot'],
      ),
      monthlyGoalQuarterFacesSnapshot: serializer.fromJson<int>(
        json['monthlyGoalQuarterFacesSnapshot'],
      ),
      studentNoteSnapshot: serializer.fromJson<String?>(
        json['studentNoteSnapshot'],
      ),
      displayOrderSnapshot: serializer.fromJson<int>(
        json['displayOrderSnapshot'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reportId': serializer.toJson<int>(reportId),
      'sourceStudentId': serializer.toJson<int>(sourceStudentId),
      'supportStudentNumberSnapshot': serializer.toJson<String?>(
        supportStudentNumberSnapshot,
      ),
      'studentNameSnapshot': serializer.toJson<String>(studentNameSnapshot),
      'currentJuzSnapshot': serializer.toJson<int?>(currentJuzSnapshot),
      'dailyPlanTextSnapshot': serializer.toJson<String?>(
        dailyPlanTextSnapshot,
      ),
      'monthlyGoalQuarterFacesSnapshot': serializer.toJson<int>(
        monthlyGoalQuarterFacesSnapshot,
      ),
      'studentNoteSnapshot': serializer.toJson<String?>(studentNoteSnapshot),
      'displayOrderSnapshot': serializer.toJson<int>(displayOrderSnapshot),
    };
  }

  SupportWeeklyReportStudent copyWith({
    int? id,
    int? reportId,
    int? sourceStudentId,
    Value<String?> supportStudentNumberSnapshot = const Value.absent(),
    String? studentNameSnapshot,
    Value<int?> currentJuzSnapshot = const Value.absent(),
    Value<String?> dailyPlanTextSnapshot = const Value.absent(),
    int? monthlyGoalQuarterFacesSnapshot,
    Value<String?> studentNoteSnapshot = const Value.absent(),
    int? displayOrderSnapshot,
  }) => SupportWeeklyReportStudent(
    id: id ?? this.id,
    reportId: reportId ?? this.reportId,
    sourceStudentId: sourceStudentId ?? this.sourceStudentId,
    supportStudentNumberSnapshot: supportStudentNumberSnapshot.present
        ? supportStudentNumberSnapshot.value
        : this.supportStudentNumberSnapshot,
    studentNameSnapshot: studentNameSnapshot ?? this.studentNameSnapshot,
    currentJuzSnapshot: currentJuzSnapshot.present
        ? currentJuzSnapshot.value
        : this.currentJuzSnapshot,
    dailyPlanTextSnapshot: dailyPlanTextSnapshot.present
        ? dailyPlanTextSnapshot.value
        : this.dailyPlanTextSnapshot,
    monthlyGoalQuarterFacesSnapshot:
        monthlyGoalQuarterFacesSnapshot ?? this.monthlyGoalQuarterFacesSnapshot,
    studentNoteSnapshot: studentNoteSnapshot.present
        ? studentNoteSnapshot.value
        : this.studentNoteSnapshot,
    displayOrderSnapshot: displayOrderSnapshot ?? this.displayOrderSnapshot,
  );
  SupportWeeklyReportStudent copyWithCompanion(
    SupportWeeklyReportStudentsCompanion data,
  ) {
    return SupportWeeklyReportStudent(
      id: data.id.present ? data.id.value : this.id,
      reportId: data.reportId.present ? data.reportId.value : this.reportId,
      sourceStudentId: data.sourceStudentId.present
          ? data.sourceStudentId.value
          : this.sourceStudentId,
      supportStudentNumberSnapshot: data.supportStudentNumberSnapshot.present
          ? data.supportStudentNumberSnapshot.value
          : this.supportStudentNumberSnapshot,
      studentNameSnapshot: data.studentNameSnapshot.present
          ? data.studentNameSnapshot.value
          : this.studentNameSnapshot,
      currentJuzSnapshot: data.currentJuzSnapshot.present
          ? data.currentJuzSnapshot.value
          : this.currentJuzSnapshot,
      dailyPlanTextSnapshot: data.dailyPlanTextSnapshot.present
          ? data.dailyPlanTextSnapshot.value
          : this.dailyPlanTextSnapshot,
      monthlyGoalQuarterFacesSnapshot:
          data.monthlyGoalQuarterFacesSnapshot.present
          ? data.monthlyGoalQuarterFacesSnapshot.value
          : this.monthlyGoalQuarterFacesSnapshot,
      studentNoteSnapshot: data.studentNoteSnapshot.present
          ? data.studentNoteSnapshot.value
          : this.studentNoteSnapshot,
      displayOrderSnapshot: data.displayOrderSnapshot.present
          ? data.displayOrderSnapshot.value
          : this.displayOrderSnapshot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupportWeeklyReportStudent(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('sourceStudentId: $sourceStudentId, ')
          ..write(
            'supportStudentNumberSnapshot: $supportStudentNumberSnapshot, ',
          )
          ..write('studentNameSnapshot: $studentNameSnapshot, ')
          ..write('currentJuzSnapshot: $currentJuzSnapshot, ')
          ..write('dailyPlanTextSnapshot: $dailyPlanTextSnapshot, ')
          ..write(
            'monthlyGoalQuarterFacesSnapshot: $monthlyGoalQuarterFacesSnapshot, ',
          )
          ..write('studentNoteSnapshot: $studentNoteSnapshot, ')
          ..write('displayOrderSnapshot: $displayOrderSnapshot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    reportId,
    sourceStudentId,
    supportStudentNumberSnapshot,
    studentNameSnapshot,
    currentJuzSnapshot,
    dailyPlanTextSnapshot,
    monthlyGoalQuarterFacesSnapshot,
    studentNoteSnapshot,
    displayOrderSnapshot,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupportWeeklyReportStudent &&
          other.id == this.id &&
          other.reportId == this.reportId &&
          other.sourceStudentId == this.sourceStudentId &&
          other.supportStudentNumberSnapshot ==
              this.supportStudentNumberSnapshot &&
          other.studentNameSnapshot == this.studentNameSnapshot &&
          other.currentJuzSnapshot == this.currentJuzSnapshot &&
          other.dailyPlanTextSnapshot == this.dailyPlanTextSnapshot &&
          other.monthlyGoalQuarterFacesSnapshot ==
              this.monthlyGoalQuarterFacesSnapshot &&
          other.studentNoteSnapshot == this.studentNoteSnapshot &&
          other.displayOrderSnapshot == this.displayOrderSnapshot);
}

class SupportWeeklyReportStudentsCompanion
    extends UpdateCompanion<SupportWeeklyReportStudent> {
  final Value<int> id;
  final Value<int> reportId;
  final Value<int> sourceStudentId;
  final Value<String?> supportStudentNumberSnapshot;
  final Value<String> studentNameSnapshot;
  final Value<int?> currentJuzSnapshot;
  final Value<String?> dailyPlanTextSnapshot;
  final Value<int> monthlyGoalQuarterFacesSnapshot;
  final Value<String?> studentNoteSnapshot;
  final Value<int> displayOrderSnapshot;
  const SupportWeeklyReportStudentsCompanion({
    this.id = const Value.absent(),
    this.reportId = const Value.absent(),
    this.sourceStudentId = const Value.absent(),
    this.supportStudentNumberSnapshot = const Value.absent(),
    this.studentNameSnapshot = const Value.absent(),
    this.currentJuzSnapshot = const Value.absent(),
    this.dailyPlanTextSnapshot = const Value.absent(),
    this.monthlyGoalQuarterFacesSnapshot = const Value.absent(),
    this.studentNoteSnapshot = const Value.absent(),
    this.displayOrderSnapshot = const Value.absent(),
  });
  SupportWeeklyReportStudentsCompanion.insert({
    this.id = const Value.absent(),
    required int reportId,
    required int sourceStudentId,
    this.supportStudentNumberSnapshot = const Value.absent(),
    required String studentNameSnapshot,
    this.currentJuzSnapshot = const Value.absent(),
    this.dailyPlanTextSnapshot = const Value.absent(),
    required int monthlyGoalQuarterFacesSnapshot,
    this.studentNoteSnapshot = const Value.absent(),
    required int displayOrderSnapshot,
  }) : reportId = Value(reportId),
       sourceStudentId = Value(sourceStudentId),
       studentNameSnapshot = Value(studentNameSnapshot),
       monthlyGoalQuarterFacesSnapshot = Value(monthlyGoalQuarterFacesSnapshot),
       displayOrderSnapshot = Value(displayOrderSnapshot);
  static Insertable<SupportWeeklyReportStudent> custom({
    Expression<int>? id,
    Expression<int>? reportId,
    Expression<int>? sourceStudentId,
    Expression<String>? supportStudentNumberSnapshot,
    Expression<String>? studentNameSnapshot,
    Expression<int>? currentJuzSnapshot,
    Expression<String>? dailyPlanTextSnapshot,
    Expression<int>? monthlyGoalQuarterFacesSnapshot,
    Expression<String>? studentNoteSnapshot,
    Expression<int>? displayOrderSnapshot,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reportId != null) 'report_id': reportId,
      if (sourceStudentId != null) 'source_student_id': sourceStudentId,
      if (supportStudentNumberSnapshot != null)
        'support_student_number_snapshot': supportStudentNumberSnapshot,
      if (studentNameSnapshot != null)
        'student_name_snapshot': studentNameSnapshot,
      if (currentJuzSnapshot != null)
        'current_juz_snapshot': currentJuzSnapshot,
      if (dailyPlanTextSnapshot != null)
        'daily_plan_text_snapshot': dailyPlanTextSnapshot,
      if (monthlyGoalQuarterFacesSnapshot != null)
        'monthly_goal_quarter_faces_snapshot': monthlyGoalQuarterFacesSnapshot,
      if (studentNoteSnapshot != null)
        'student_note_snapshot': studentNoteSnapshot,
      if (displayOrderSnapshot != null)
        'display_order_snapshot': displayOrderSnapshot,
    });
  }

  SupportWeeklyReportStudentsCompanion copyWith({
    Value<int>? id,
    Value<int>? reportId,
    Value<int>? sourceStudentId,
    Value<String?>? supportStudentNumberSnapshot,
    Value<String>? studentNameSnapshot,
    Value<int?>? currentJuzSnapshot,
    Value<String?>? dailyPlanTextSnapshot,
    Value<int>? monthlyGoalQuarterFacesSnapshot,
    Value<String?>? studentNoteSnapshot,
    Value<int>? displayOrderSnapshot,
  }) {
    return SupportWeeklyReportStudentsCompanion(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      sourceStudentId: sourceStudentId ?? this.sourceStudentId,
      supportStudentNumberSnapshot:
          supportStudentNumberSnapshot ?? this.supportStudentNumberSnapshot,
      studentNameSnapshot: studentNameSnapshot ?? this.studentNameSnapshot,
      currentJuzSnapshot: currentJuzSnapshot ?? this.currentJuzSnapshot,
      dailyPlanTextSnapshot:
          dailyPlanTextSnapshot ?? this.dailyPlanTextSnapshot,
      monthlyGoalQuarterFacesSnapshot:
          monthlyGoalQuarterFacesSnapshot ??
          this.monthlyGoalQuarterFacesSnapshot,
      studentNoteSnapshot: studentNoteSnapshot ?? this.studentNoteSnapshot,
      displayOrderSnapshot: displayOrderSnapshot ?? this.displayOrderSnapshot,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reportId.present) {
      map['report_id'] = Variable<int>(reportId.value);
    }
    if (sourceStudentId.present) {
      map['source_student_id'] = Variable<int>(sourceStudentId.value);
    }
    if (supportStudentNumberSnapshot.present) {
      map['support_student_number_snapshot'] = Variable<String>(
        supportStudentNumberSnapshot.value,
      );
    }
    if (studentNameSnapshot.present) {
      map['student_name_snapshot'] = Variable<String>(
        studentNameSnapshot.value,
      );
    }
    if (currentJuzSnapshot.present) {
      map['current_juz_snapshot'] = Variable<int>(currentJuzSnapshot.value);
    }
    if (dailyPlanTextSnapshot.present) {
      map['daily_plan_text_snapshot'] = Variable<String>(
        dailyPlanTextSnapshot.value,
      );
    }
    if (monthlyGoalQuarterFacesSnapshot.present) {
      map['monthly_goal_quarter_faces_snapshot'] = Variable<int>(
        monthlyGoalQuarterFacesSnapshot.value,
      );
    }
    if (studentNoteSnapshot.present) {
      map['student_note_snapshot'] = Variable<String>(
        studentNoteSnapshot.value,
      );
    }
    if (displayOrderSnapshot.present) {
      map['display_order_snapshot'] = Variable<int>(displayOrderSnapshot.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupportWeeklyReportStudentsCompanion(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('sourceStudentId: $sourceStudentId, ')
          ..write(
            'supportStudentNumberSnapshot: $supportStudentNumberSnapshot, ',
          )
          ..write('studentNameSnapshot: $studentNameSnapshot, ')
          ..write('currentJuzSnapshot: $currentJuzSnapshot, ')
          ..write('dailyPlanTextSnapshot: $dailyPlanTextSnapshot, ')
          ..write(
            'monthlyGoalQuarterFacesSnapshot: $monthlyGoalQuarterFacesSnapshot, ',
          )
          ..write('studentNoteSnapshot: $studentNoteSnapshot, ')
          ..write('displayOrderSnapshot: $displayOrderSnapshot')
          ..write(')'))
        .toString();
  }
}

class $SupportWeeklyReportDaysTable extends SupportWeeklyReportDays
    with TableInfo<$SupportWeeklyReportDaysTable, SupportWeeklyReportDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupportWeeklyReportDaysTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _reportIdMeta = const VerificationMeta(
    'reportId',
  );
  @override
  late final GeneratedColumn<int> reportId = GeneratedColumn<int>(
    'report_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES support_weekly_reports (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dayDateMeta = const VerificationMeta(
    'dayDate',
  );
  @override
  late final GeneratedColumn<String> dayDate = GeneratedColumn<String>(
    'day_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayKindMeta = const VerificationMeta(
    'dayKind',
  );
  @override
  late final GeneratedColumn<String> dayKind = GeneratedColumn<String>(
    'day_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, reportId, dayDate, dayKind];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'support_weekly_report_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupportWeeklyReportDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('report_id')) {
      context.handle(
        _reportIdMeta,
        reportId.isAcceptableOrUnknown(data['report_id']!, _reportIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reportIdMeta);
    }
    if (data.containsKey('day_date')) {
      context.handle(
        _dayDateMeta,
        dayDate.isAcceptableOrUnknown(data['day_date']!, _dayDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dayDateMeta);
    }
    if (data.containsKey('day_kind')) {
      context.handle(
        _dayKindMeta,
        dayKind.isAcceptableOrUnknown(data['day_kind']!, _dayKindMeta),
      );
    } else if (isInserting) {
      context.missing(_dayKindMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {reportId, dayDate},
  ];
  @override
  SupportWeeklyReportDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupportWeeklyReportDay(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      reportId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}report_id'],
      )!,
      dayDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_date'],
      )!,
      dayKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_kind'],
      )!,
    );
  }

  @override
  $SupportWeeklyReportDaysTable createAlias(String alias) {
    return $SupportWeeklyReportDaysTable(attachedDatabase, alias);
  }
}

class SupportWeeklyReportDay extends DataClass
    implements Insertable<SupportWeeklyReportDay> {
  final int id;
  final int reportId;
  final String dayDate;
  final String dayKind;
  const SupportWeeklyReportDay({
    required this.id,
    required this.reportId,
    required this.dayDate,
    required this.dayKind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['report_id'] = Variable<int>(reportId);
    map['day_date'] = Variable<String>(dayDate);
    map['day_kind'] = Variable<String>(dayKind);
    return map;
  }

  SupportWeeklyReportDaysCompanion toCompanion(bool nullToAbsent) {
    return SupportWeeklyReportDaysCompanion(
      id: Value(id),
      reportId: Value(reportId),
      dayDate: Value(dayDate),
      dayKind: Value(dayKind),
    );
  }

  factory SupportWeeklyReportDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupportWeeklyReportDay(
      id: serializer.fromJson<int>(json['id']),
      reportId: serializer.fromJson<int>(json['reportId']),
      dayDate: serializer.fromJson<String>(json['dayDate']),
      dayKind: serializer.fromJson<String>(json['dayKind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reportId': serializer.toJson<int>(reportId),
      'dayDate': serializer.toJson<String>(dayDate),
      'dayKind': serializer.toJson<String>(dayKind),
    };
  }

  SupportWeeklyReportDay copyWith({
    int? id,
    int? reportId,
    String? dayDate,
    String? dayKind,
  }) => SupportWeeklyReportDay(
    id: id ?? this.id,
    reportId: reportId ?? this.reportId,
    dayDate: dayDate ?? this.dayDate,
    dayKind: dayKind ?? this.dayKind,
  );
  SupportWeeklyReportDay copyWithCompanion(
    SupportWeeklyReportDaysCompanion data,
  ) {
    return SupportWeeklyReportDay(
      id: data.id.present ? data.id.value : this.id,
      reportId: data.reportId.present ? data.reportId.value : this.reportId,
      dayDate: data.dayDate.present ? data.dayDate.value : this.dayDate,
      dayKind: data.dayKind.present ? data.dayKind.value : this.dayKind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupportWeeklyReportDay(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('dayDate: $dayDate, ')
          ..write('dayKind: $dayKind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, reportId, dayDate, dayKind);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupportWeeklyReportDay &&
          other.id == this.id &&
          other.reportId == this.reportId &&
          other.dayDate == this.dayDate &&
          other.dayKind == this.dayKind);
}

class SupportWeeklyReportDaysCompanion
    extends UpdateCompanion<SupportWeeklyReportDay> {
  final Value<int> id;
  final Value<int> reportId;
  final Value<String> dayDate;
  final Value<String> dayKind;
  const SupportWeeklyReportDaysCompanion({
    this.id = const Value.absent(),
    this.reportId = const Value.absent(),
    this.dayDate = const Value.absent(),
    this.dayKind = const Value.absent(),
  });
  SupportWeeklyReportDaysCompanion.insert({
    this.id = const Value.absent(),
    required int reportId,
    required String dayDate,
    required String dayKind,
  }) : reportId = Value(reportId),
       dayDate = Value(dayDate),
       dayKind = Value(dayKind);
  static Insertable<SupportWeeklyReportDay> custom({
    Expression<int>? id,
    Expression<int>? reportId,
    Expression<String>? dayDate,
    Expression<String>? dayKind,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reportId != null) 'report_id': reportId,
      if (dayDate != null) 'day_date': dayDate,
      if (dayKind != null) 'day_kind': dayKind,
    });
  }

  SupportWeeklyReportDaysCompanion copyWith({
    Value<int>? id,
    Value<int>? reportId,
    Value<String>? dayDate,
    Value<String>? dayKind,
  }) {
    return SupportWeeklyReportDaysCompanion(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      dayDate: dayDate ?? this.dayDate,
      dayKind: dayKind ?? this.dayKind,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reportId.present) {
      map['report_id'] = Variable<int>(reportId.value);
    }
    if (dayDate.present) {
      map['day_date'] = Variable<String>(dayDate.value);
    }
    if (dayKind.present) {
      map['day_kind'] = Variable<String>(dayKind.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupportWeeklyReportDaysCompanion(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('dayDate: $dayDate, ')
          ..write('dayKind: $dayKind')
          ..write(')'))
        .toString();
  }
}

class $SupportWeeklyReportDayEntriesTable extends SupportWeeklyReportDayEntries
    with
        TableInfo<
          $SupportWeeklyReportDayEntriesTable,
          SupportWeeklyReportDayEntry
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupportWeeklyReportDayEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _reportDayIdMeta = const VerificationMeta(
    'reportDayId',
  );
  @override
  late final GeneratedColumn<int> reportDayId = GeneratedColumn<int>(
    'report_day_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES support_weekly_report_days (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _reportStudentIdMeta = const VerificationMeta(
    'reportStudentId',
  );
  @override
  late final GeneratedColumn<int> reportStudentId = GeneratedColumn<int>(
    'report_student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES support_weekly_report_students (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _attendanceStatusSnapshotMeta =
      const VerificationMeta('attendanceStatusSnapshot');
  @override
  late final GeneratedColumn<String> attendanceStatusSnapshot =
      GeneratedColumn<String>(
        'attendance_status_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _achievedQuarterFacesMeta =
      const VerificationMeta('achievedQuarterFaces');
  @override
  late final GeneratedColumn<int> achievedQuarterFaces = GeneratedColumn<int>(
    'achieved_quarter_faces',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startSurahSnapshotMeta =
      const VerificationMeta('startSurahSnapshot');
  @override
  late final GeneratedColumn<int> startSurahSnapshot = GeneratedColumn<int>(
    'start_surah_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startAyahSnapshotMeta = const VerificationMeta(
    'startAyahSnapshot',
  );
  @override
  late final GeneratedColumn<int> startAyahSnapshot = GeneratedColumn<int>(
    'start_ayah_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endSurahSnapshotMeta = const VerificationMeta(
    'endSurahSnapshot',
  );
  @override
  late final GeneratedColumn<int> endSurahSnapshot = GeneratedColumn<int>(
    'end_surah_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endAyahSnapshotMeta = const VerificationMeta(
    'endAyahSnapshot',
  );
  @override
  late final GeneratedColumn<int> endAyahSnapshot = GeneratedColumn<int>(
    'end_ayah_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteSnapshotMeta = const VerificationMeta(
    'noteSnapshot',
  );
  @override
  late final GeneratedColumn<String> noteSnapshot = GeneratedColumn<String>(
    'note_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryOrderMeta = const VerificationMeta(
    'entryOrder',
  );
  @override
  late final GeneratedColumn<int> entryOrder = GeneratedColumn<int>(
    'entry_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reportDayId,
    reportStudentId,
    attendanceStatusSnapshot,
    achievedQuarterFaces,
    startSurahSnapshot,
    startAyahSnapshot,
    endSurahSnapshot,
    endAyahSnapshot,
    noteSnapshot,
    entryOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'support_weekly_report_day_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupportWeeklyReportDayEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('report_day_id')) {
      context.handle(
        _reportDayIdMeta,
        reportDayId.isAcceptableOrUnknown(
          data['report_day_id']!,
          _reportDayIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reportDayIdMeta);
    }
    if (data.containsKey('report_student_id')) {
      context.handle(
        _reportStudentIdMeta,
        reportStudentId.isAcceptableOrUnknown(
          data['report_student_id']!,
          _reportStudentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reportStudentIdMeta);
    }
    if (data.containsKey('attendance_status_snapshot')) {
      context.handle(
        _attendanceStatusSnapshotMeta,
        attendanceStatusSnapshot.isAcceptableOrUnknown(
          data['attendance_status_snapshot']!,
          _attendanceStatusSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('achieved_quarter_faces')) {
      context.handle(
        _achievedQuarterFacesMeta,
        achievedQuarterFaces.isAcceptableOrUnknown(
          data['achieved_quarter_faces']!,
          _achievedQuarterFacesMeta,
        ),
      );
    }
    if (data.containsKey('start_surah_snapshot')) {
      context.handle(
        _startSurahSnapshotMeta,
        startSurahSnapshot.isAcceptableOrUnknown(
          data['start_surah_snapshot']!,
          _startSurahSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('start_ayah_snapshot')) {
      context.handle(
        _startAyahSnapshotMeta,
        startAyahSnapshot.isAcceptableOrUnknown(
          data['start_ayah_snapshot']!,
          _startAyahSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('end_surah_snapshot')) {
      context.handle(
        _endSurahSnapshotMeta,
        endSurahSnapshot.isAcceptableOrUnknown(
          data['end_surah_snapshot']!,
          _endSurahSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('end_ayah_snapshot')) {
      context.handle(
        _endAyahSnapshotMeta,
        endAyahSnapshot.isAcceptableOrUnknown(
          data['end_ayah_snapshot']!,
          _endAyahSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('note_snapshot')) {
      context.handle(
        _noteSnapshotMeta,
        noteSnapshot.isAcceptableOrUnknown(
          data['note_snapshot']!,
          _noteSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('entry_order')) {
      context.handle(
        _entryOrderMeta,
        entryOrder.isAcceptableOrUnknown(data['entry_order']!, _entryOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_entryOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {reportDayId, reportStudentId, entryOrder},
  ];
  @override
  SupportWeeklyReportDayEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupportWeeklyReportDayEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      reportDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}report_day_id'],
      )!,
      reportStudentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}report_student_id'],
      )!,
      attendanceStatusSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attendance_status_snapshot'],
      ),
      achievedQuarterFaces: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}achieved_quarter_faces'],
      )!,
      startSurahSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_surah_snapshot'],
      ),
      startAyahSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ayah_snapshot'],
      ),
      endSurahSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_surah_snapshot'],
      ),
      endAyahSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_ayah_snapshot'],
      ),
      noteSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_snapshot'],
      ),
      entryOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_order'],
      )!,
    );
  }

  @override
  $SupportWeeklyReportDayEntriesTable createAlias(String alias) {
    return $SupportWeeklyReportDayEntriesTable(attachedDatabase, alias);
  }
}

class SupportWeeklyReportDayEntry extends DataClass
    implements Insertable<SupportWeeklyReportDayEntry> {
  final int id;
  final int reportDayId;
  final int reportStudentId;
  final String? attendanceStatusSnapshot;
  final int achievedQuarterFaces;
  final int? startSurahSnapshot;
  final int? startAyahSnapshot;
  final int? endSurahSnapshot;
  final int? endAyahSnapshot;
  final String? noteSnapshot;
  final int entryOrder;
  const SupportWeeklyReportDayEntry({
    required this.id,
    required this.reportDayId,
    required this.reportStudentId,
    this.attendanceStatusSnapshot,
    required this.achievedQuarterFaces,
    this.startSurahSnapshot,
    this.startAyahSnapshot,
    this.endSurahSnapshot,
    this.endAyahSnapshot,
    this.noteSnapshot,
    required this.entryOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['report_day_id'] = Variable<int>(reportDayId);
    map['report_student_id'] = Variable<int>(reportStudentId);
    if (!nullToAbsent || attendanceStatusSnapshot != null) {
      map['attendance_status_snapshot'] = Variable<String>(
        attendanceStatusSnapshot,
      );
    }
    map['achieved_quarter_faces'] = Variable<int>(achievedQuarterFaces);
    if (!nullToAbsent || startSurahSnapshot != null) {
      map['start_surah_snapshot'] = Variable<int>(startSurahSnapshot);
    }
    if (!nullToAbsent || startAyahSnapshot != null) {
      map['start_ayah_snapshot'] = Variable<int>(startAyahSnapshot);
    }
    if (!nullToAbsent || endSurahSnapshot != null) {
      map['end_surah_snapshot'] = Variable<int>(endSurahSnapshot);
    }
    if (!nullToAbsent || endAyahSnapshot != null) {
      map['end_ayah_snapshot'] = Variable<int>(endAyahSnapshot);
    }
    if (!nullToAbsent || noteSnapshot != null) {
      map['note_snapshot'] = Variable<String>(noteSnapshot);
    }
    map['entry_order'] = Variable<int>(entryOrder);
    return map;
  }

  SupportWeeklyReportDayEntriesCompanion toCompanion(bool nullToAbsent) {
    return SupportWeeklyReportDayEntriesCompanion(
      id: Value(id),
      reportDayId: Value(reportDayId),
      reportStudentId: Value(reportStudentId),
      attendanceStatusSnapshot: attendanceStatusSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(attendanceStatusSnapshot),
      achievedQuarterFaces: Value(achievedQuarterFaces),
      startSurahSnapshot: startSurahSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(startSurahSnapshot),
      startAyahSnapshot: startAyahSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(startAyahSnapshot),
      endSurahSnapshot: endSurahSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(endSurahSnapshot),
      endAyahSnapshot: endAyahSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(endAyahSnapshot),
      noteSnapshot: noteSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(noteSnapshot),
      entryOrder: Value(entryOrder),
    );
  }

  factory SupportWeeklyReportDayEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupportWeeklyReportDayEntry(
      id: serializer.fromJson<int>(json['id']),
      reportDayId: serializer.fromJson<int>(json['reportDayId']),
      reportStudentId: serializer.fromJson<int>(json['reportStudentId']),
      attendanceStatusSnapshot: serializer.fromJson<String?>(
        json['attendanceStatusSnapshot'],
      ),
      achievedQuarterFaces: serializer.fromJson<int>(
        json['achievedQuarterFaces'],
      ),
      startSurahSnapshot: serializer.fromJson<int?>(json['startSurahSnapshot']),
      startAyahSnapshot: serializer.fromJson<int?>(json['startAyahSnapshot']),
      endSurahSnapshot: serializer.fromJson<int?>(json['endSurahSnapshot']),
      endAyahSnapshot: serializer.fromJson<int?>(json['endAyahSnapshot']),
      noteSnapshot: serializer.fromJson<String?>(json['noteSnapshot']),
      entryOrder: serializer.fromJson<int>(json['entryOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reportDayId': serializer.toJson<int>(reportDayId),
      'reportStudentId': serializer.toJson<int>(reportStudentId),
      'attendanceStatusSnapshot': serializer.toJson<String?>(
        attendanceStatusSnapshot,
      ),
      'achievedQuarterFaces': serializer.toJson<int>(achievedQuarterFaces),
      'startSurahSnapshot': serializer.toJson<int?>(startSurahSnapshot),
      'startAyahSnapshot': serializer.toJson<int?>(startAyahSnapshot),
      'endSurahSnapshot': serializer.toJson<int?>(endSurahSnapshot),
      'endAyahSnapshot': serializer.toJson<int?>(endAyahSnapshot),
      'noteSnapshot': serializer.toJson<String?>(noteSnapshot),
      'entryOrder': serializer.toJson<int>(entryOrder),
    };
  }

  SupportWeeklyReportDayEntry copyWith({
    int? id,
    int? reportDayId,
    int? reportStudentId,
    Value<String?> attendanceStatusSnapshot = const Value.absent(),
    int? achievedQuarterFaces,
    Value<int?> startSurahSnapshot = const Value.absent(),
    Value<int?> startAyahSnapshot = const Value.absent(),
    Value<int?> endSurahSnapshot = const Value.absent(),
    Value<int?> endAyahSnapshot = const Value.absent(),
    Value<String?> noteSnapshot = const Value.absent(),
    int? entryOrder,
  }) => SupportWeeklyReportDayEntry(
    id: id ?? this.id,
    reportDayId: reportDayId ?? this.reportDayId,
    reportStudentId: reportStudentId ?? this.reportStudentId,
    attendanceStatusSnapshot: attendanceStatusSnapshot.present
        ? attendanceStatusSnapshot.value
        : this.attendanceStatusSnapshot,
    achievedQuarterFaces: achievedQuarterFaces ?? this.achievedQuarterFaces,
    startSurahSnapshot: startSurahSnapshot.present
        ? startSurahSnapshot.value
        : this.startSurahSnapshot,
    startAyahSnapshot: startAyahSnapshot.present
        ? startAyahSnapshot.value
        : this.startAyahSnapshot,
    endSurahSnapshot: endSurahSnapshot.present
        ? endSurahSnapshot.value
        : this.endSurahSnapshot,
    endAyahSnapshot: endAyahSnapshot.present
        ? endAyahSnapshot.value
        : this.endAyahSnapshot,
    noteSnapshot: noteSnapshot.present ? noteSnapshot.value : this.noteSnapshot,
    entryOrder: entryOrder ?? this.entryOrder,
  );
  SupportWeeklyReportDayEntry copyWithCompanion(
    SupportWeeklyReportDayEntriesCompanion data,
  ) {
    return SupportWeeklyReportDayEntry(
      id: data.id.present ? data.id.value : this.id,
      reportDayId: data.reportDayId.present
          ? data.reportDayId.value
          : this.reportDayId,
      reportStudentId: data.reportStudentId.present
          ? data.reportStudentId.value
          : this.reportStudentId,
      attendanceStatusSnapshot: data.attendanceStatusSnapshot.present
          ? data.attendanceStatusSnapshot.value
          : this.attendanceStatusSnapshot,
      achievedQuarterFaces: data.achievedQuarterFaces.present
          ? data.achievedQuarterFaces.value
          : this.achievedQuarterFaces,
      startSurahSnapshot: data.startSurahSnapshot.present
          ? data.startSurahSnapshot.value
          : this.startSurahSnapshot,
      startAyahSnapshot: data.startAyahSnapshot.present
          ? data.startAyahSnapshot.value
          : this.startAyahSnapshot,
      endSurahSnapshot: data.endSurahSnapshot.present
          ? data.endSurahSnapshot.value
          : this.endSurahSnapshot,
      endAyahSnapshot: data.endAyahSnapshot.present
          ? data.endAyahSnapshot.value
          : this.endAyahSnapshot,
      noteSnapshot: data.noteSnapshot.present
          ? data.noteSnapshot.value
          : this.noteSnapshot,
      entryOrder: data.entryOrder.present
          ? data.entryOrder.value
          : this.entryOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupportWeeklyReportDayEntry(')
          ..write('id: $id, ')
          ..write('reportDayId: $reportDayId, ')
          ..write('reportStudentId: $reportStudentId, ')
          ..write('attendanceStatusSnapshot: $attendanceStatusSnapshot, ')
          ..write('achievedQuarterFaces: $achievedQuarterFaces, ')
          ..write('startSurahSnapshot: $startSurahSnapshot, ')
          ..write('startAyahSnapshot: $startAyahSnapshot, ')
          ..write('endSurahSnapshot: $endSurahSnapshot, ')
          ..write('endAyahSnapshot: $endAyahSnapshot, ')
          ..write('noteSnapshot: $noteSnapshot, ')
          ..write('entryOrder: $entryOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    reportDayId,
    reportStudentId,
    attendanceStatusSnapshot,
    achievedQuarterFaces,
    startSurahSnapshot,
    startAyahSnapshot,
    endSurahSnapshot,
    endAyahSnapshot,
    noteSnapshot,
    entryOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupportWeeklyReportDayEntry &&
          other.id == this.id &&
          other.reportDayId == this.reportDayId &&
          other.reportStudentId == this.reportStudentId &&
          other.attendanceStatusSnapshot == this.attendanceStatusSnapshot &&
          other.achievedQuarterFaces == this.achievedQuarterFaces &&
          other.startSurahSnapshot == this.startSurahSnapshot &&
          other.startAyahSnapshot == this.startAyahSnapshot &&
          other.endSurahSnapshot == this.endSurahSnapshot &&
          other.endAyahSnapshot == this.endAyahSnapshot &&
          other.noteSnapshot == this.noteSnapshot &&
          other.entryOrder == this.entryOrder);
}

class SupportWeeklyReportDayEntriesCompanion
    extends UpdateCompanion<SupportWeeklyReportDayEntry> {
  final Value<int> id;
  final Value<int> reportDayId;
  final Value<int> reportStudentId;
  final Value<String?> attendanceStatusSnapshot;
  final Value<int> achievedQuarterFaces;
  final Value<int?> startSurahSnapshot;
  final Value<int?> startAyahSnapshot;
  final Value<int?> endSurahSnapshot;
  final Value<int?> endAyahSnapshot;
  final Value<String?> noteSnapshot;
  final Value<int> entryOrder;
  const SupportWeeklyReportDayEntriesCompanion({
    this.id = const Value.absent(),
    this.reportDayId = const Value.absent(),
    this.reportStudentId = const Value.absent(),
    this.attendanceStatusSnapshot = const Value.absent(),
    this.achievedQuarterFaces = const Value.absent(),
    this.startSurahSnapshot = const Value.absent(),
    this.startAyahSnapshot = const Value.absent(),
    this.endSurahSnapshot = const Value.absent(),
    this.endAyahSnapshot = const Value.absent(),
    this.noteSnapshot = const Value.absent(),
    this.entryOrder = const Value.absent(),
  });
  SupportWeeklyReportDayEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int reportDayId,
    required int reportStudentId,
    this.attendanceStatusSnapshot = const Value.absent(),
    this.achievedQuarterFaces = const Value.absent(),
    this.startSurahSnapshot = const Value.absent(),
    this.startAyahSnapshot = const Value.absent(),
    this.endSurahSnapshot = const Value.absent(),
    this.endAyahSnapshot = const Value.absent(),
    this.noteSnapshot = const Value.absent(),
    required int entryOrder,
  }) : reportDayId = Value(reportDayId),
       reportStudentId = Value(reportStudentId),
       entryOrder = Value(entryOrder);
  static Insertable<SupportWeeklyReportDayEntry> custom({
    Expression<int>? id,
    Expression<int>? reportDayId,
    Expression<int>? reportStudentId,
    Expression<String>? attendanceStatusSnapshot,
    Expression<int>? achievedQuarterFaces,
    Expression<int>? startSurahSnapshot,
    Expression<int>? startAyahSnapshot,
    Expression<int>? endSurahSnapshot,
    Expression<int>? endAyahSnapshot,
    Expression<String>? noteSnapshot,
    Expression<int>? entryOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reportDayId != null) 'report_day_id': reportDayId,
      if (reportStudentId != null) 'report_student_id': reportStudentId,
      if (attendanceStatusSnapshot != null)
        'attendance_status_snapshot': attendanceStatusSnapshot,
      if (achievedQuarterFaces != null)
        'achieved_quarter_faces': achievedQuarterFaces,
      if (startSurahSnapshot != null)
        'start_surah_snapshot': startSurahSnapshot,
      if (startAyahSnapshot != null) 'start_ayah_snapshot': startAyahSnapshot,
      if (endSurahSnapshot != null) 'end_surah_snapshot': endSurahSnapshot,
      if (endAyahSnapshot != null) 'end_ayah_snapshot': endAyahSnapshot,
      if (noteSnapshot != null) 'note_snapshot': noteSnapshot,
      if (entryOrder != null) 'entry_order': entryOrder,
    });
  }

  SupportWeeklyReportDayEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? reportDayId,
    Value<int>? reportStudentId,
    Value<String?>? attendanceStatusSnapshot,
    Value<int>? achievedQuarterFaces,
    Value<int?>? startSurahSnapshot,
    Value<int?>? startAyahSnapshot,
    Value<int?>? endSurahSnapshot,
    Value<int?>? endAyahSnapshot,
    Value<String?>? noteSnapshot,
    Value<int>? entryOrder,
  }) {
    return SupportWeeklyReportDayEntriesCompanion(
      id: id ?? this.id,
      reportDayId: reportDayId ?? this.reportDayId,
      reportStudentId: reportStudentId ?? this.reportStudentId,
      attendanceStatusSnapshot:
          attendanceStatusSnapshot ?? this.attendanceStatusSnapshot,
      achievedQuarterFaces: achievedQuarterFaces ?? this.achievedQuarterFaces,
      startSurahSnapshot: startSurahSnapshot ?? this.startSurahSnapshot,
      startAyahSnapshot: startAyahSnapshot ?? this.startAyahSnapshot,
      endSurahSnapshot: endSurahSnapshot ?? this.endSurahSnapshot,
      endAyahSnapshot: endAyahSnapshot ?? this.endAyahSnapshot,
      noteSnapshot: noteSnapshot ?? this.noteSnapshot,
      entryOrder: entryOrder ?? this.entryOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reportDayId.present) {
      map['report_day_id'] = Variable<int>(reportDayId.value);
    }
    if (reportStudentId.present) {
      map['report_student_id'] = Variable<int>(reportStudentId.value);
    }
    if (attendanceStatusSnapshot.present) {
      map['attendance_status_snapshot'] = Variable<String>(
        attendanceStatusSnapshot.value,
      );
    }
    if (achievedQuarterFaces.present) {
      map['achieved_quarter_faces'] = Variable<int>(achievedQuarterFaces.value);
    }
    if (startSurahSnapshot.present) {
      map['start_surah_snapshot'] = Variable<int>(startSurahSnapshot.value);
    }
    if (startAyahSnapshot.present) {
      map['start_ayah_snapshot'] = Variable<int>(startAyahSnapshot.value);
    }
    if (endSurahSnapshot.present) {
      map['end_surah_snapshot'] = Variable<int>(endSurahSnapshot.value);
    }
    if (endAyahSnapshot.present) {
      map['end_ayah_snapshot'] = Variable<int>(endAyahSnapshot.value);
    }
    if (noteSnapshot.present) {
      map['note_snapshot'] = Variable<String>(noteSnapshot.value);
    }
    if (entryOrder.present) {
      map['entry_order'] = Variable<int>(entryOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupportWeeklyReportDayEntriesCompanion(')
          ..write('id: $id, ')
          ..write('reportDayId: $reportDayId, ')
          ..write('reportStudentId: $reportStudentId, ')
          ..write('attendanceStatusSnapshot: $attendanceStatusSnapshot, ')
          ..write('achievedQuarterFaces: $achievedQuarterFaces, ')
          ..write('startSurahSnapshot: $startSurahSnapshot, ')
          ..write('startAyahSnapshot: $startAyahSnapshot, ')
          ..write('endSurahSnapshot: $endSurahSnapshot, ')
          ..write('endAyahSnapshot: $endAyahSnapshot, ')
          ..write('noteSnapshot: $noteSnapshot, ')
          ..write('entryOrder: $entryOrder')
          ..write(')'))
        .toString();
  }
}

class $SupportMonthlyReportsTable extends SupportMonthlyReports
    with TableInfo<$SupportMonthlyReportsTable, SupportMonthlyReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupportMonthlyReportsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _monthStartDateMeta = const VerificationMeta(
    'monthStartDate',
  );
  @override
  late final GeneratedColumn<String> monthStartDate = GeneratedColumn<String>(
    'month_start_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthEndDateMeta = const VerificationMeta(
    'monthEndDate',
  );
  @override
  late final GeneratedColumn<String> monthEndDate = GeneratedColumn<String>(
    'month_end_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _teacherNameSnapshotMeta =
      const VerificationMeta('teacherNameSnapshot');
  @override
  late final GeneratedColumn<String> teacherNameSnapshot =
      GeneratedColumn<String>(
        'teacher_name_snapshot',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 200,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _halaqahNameSnapshotMeta =
      const VerificationMeta('halaqahNameSnapshot');
  @override
  late final GeneratedColumn<String> halaqahNameSnapshot =
      GeneratedColumn<String>(
        'halaqah_name_snapshot',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 200,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _organizationNameSnapshotMeta =
      const VerificationMeta('organizationNameSnapshot');
  @override
  late final GeneratedColumn<String> organizationNameSnapshot =
      GeneratedColumn<String>(
        'organization_name_snapshot',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 200,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _policyVersionMeta = const VerificationMeta(
    'policyVersion',
  );
  @override
  late final GeneratedColumn<int> policyVersion = GeneratedColumn<int>(
    'policy_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateVersionMeta = const VerificationMeta(
    'templateVersion',
  );
  @override
  late final GeneratedColumn<int> templateVersion = GeneratedColumn<int>(
    'template_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceFingerprintMeta = const VerificationMeta(
    'sourceFingerprint',
  );
  @override
  late final GeneratedColumn<String> sourceFingerprint =
      GeneratedColumn<String>(
        'source_fingerprint',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _approvedAtUtcMeta = const VerificationMeta(
    'approvedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> approvedAtUtc =
      GeneratedColumn<DateTime>(
        'approved_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    halaqahId,
    monthStartDate,
    monthEndDate,
    status,
    teacherNameSnapshot,
    halaqahNameSnapshot,
    organizationNameSnapshot,
    policyVersion,
    templateVersion,
    sourceFingerprint,
    approvedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'support_monthly_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupportMonthlyReport> instance, {
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
    if (data.containsKey('month_start_date')) {
      context.handle(
        _monthStartDateMeta,
        monthStartDate.isAcceptableOrUnknown(
          data['month_start_date']!,
          _monthStartDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthStartDateMeta);
    }
    if (data.containsKey('month_end_date')) {
      context.handle(
        _monthEndDateMeta,
        monthEndDate.isAcceptableOrUnknown(
          data['month_end_date']!,
          _monthEndDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthEndDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('teacher_name_snapshot')) {
      context.handle(
        _teacherNameSnapshotMeta,
        teacherNameSnapshot.isAcceptableOrUnknown(
          data['teacher_name_snapshot']!,
          _teacherNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_teacherNameSnapshotMeta);
    }
    if (data.containsKey('halaqah_name_snapshot')) {
      context.handle(
        _halaqahNameSnapshotMeta,
        halaqahNameSnapshot.isAcceptableOrUnknown(
          data['halaqah_name_snapshot']!,
          _halaqahNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_halaqahNameSnapshotMeta);
    }
    if (data.containsKey('organization_name_snapshot')) {
      context.handle(
        _organizationNameSnapshotMeta,
        organizationNameSnapshot.isAcceptableOrUnknown(
          data['organization_name_snapshot']!,
          _organizationNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationNameSnapshotMeta);
    }
    if (data.containsKey('policy_version')) {
      context.handle(
        _policyVersionMeta,
        policyVersion.isAcceptableOrUnknown(
          data['policy_version']!,
          _policyVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_policyVersionMeta);
    }
    if (data.containsKey('template_version')) {
      context.handle(
        _templateVersionMeta,
        templateVersion.isAcceptableOrUnknown(
          data['template_version']!,
          _templateVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_templateVersionMeta);
    }
    if (data.containsKey('source_fingerprint')) {
      context.handle(
        _sourceFingerprintMeta,
        sourceFingerprint.isAcceptableOrUnknown(
          data['source_fingerprint']!,
          _sourceFingerprintMeta,
        ),
      );
    }
    if (data.containsKey('approved_at_utc')) {
      context.handle(
        _approvedAtUtcMeta,
        approvedAtUtc.isAcceptableOrUnknown(
          data['approved_at_utc']!,
          _approvedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {halaqahId, monthStartDate},
  ];
  @override
  SupportMonthlyReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupportMonthlyReport(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      halaqahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}halaqah_id'],
      )!,
      monthStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month_start_date'],
      )!,
      monthEndDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month_end_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      teacherNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_name_snapshot'],
      )!,
      halaqahNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}halaqah_name_snapshot'],
      )!,
      organizationNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization_name_snapshot'],
      )!,
      policyVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}policy_version'],
      )!,
      templateVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}template_version'],
      )!,
      sourceFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_fingerprint'],
      ),
      approvedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}approved_at_utc'],
      ),
    );
  }

  @override
  $SupportMonthlyReportsTable createAlias(String alias) {
    return $SupportMonthlyReportsTable(attachedDatabase, alias);
  }
}

class SupportMonthlyReport extends DataClass
    implements Insertable<SupportMonthlyReport> {
  final int id;
  final int halaqahId;
  final String monthStartDate;
  final String monthEndDate;
  final String status;
  final String teacherNameSnapshot;
  final String halaqahNameSnapshot;
  final String organizationNameSnapshot;
  final int policyVersion;
  final int templateVersion;
  final String? sourceFingerprint;
  final DateTime? approvedAtUtc;
  const SupportMonthlyReport({
    required this.id,
    required this.halaqahId,
    required this.monthStartDate,
    required this.monthEndDate,
    required this.status,
    required this.teacherNameSnapshot,
    required this.halaqahNameSnapshot,
    required this.organizationNameSnapshot,
    required this.policyVersion,
    required this.templateVersion,
    this.sourceFingerprint,
    this.approvedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['halaqah_id'] = Variable<int>(halaqahId);
    map['month_start_date'] = Variable<String>(monthStartDate);
    map['month_end_date'] = Variable<String>(monthEndDate);
    map['status'] = Variable<String>(status);
    map['teacher_name_snapshot'] = Variable<String>(teacherNameSnapshot);
    map['halaqah_name_snapshot'] = Variable<String>(halaqahNameSnapshot);
    map['organization_name_snapshot'] = Variable<String>(
      organizationNameSnapshot,
    );
    map['policy_version'] = Variable<int>(policyVersion);
    map['template_version'] = Variable<int>(templateVersion);
    if (!nullToAbsent || sourceFingerprint != null) {
      map['source_fingerprint'] = Variable<String>(sourceFingerprint);
    }
    if (!nullToAbsent || approvedAtUtc != null) {
      map['approved_at_utc'] = Variable<DateTime>(approvedAtUtc);
    }
    return map;
  }

  SupportMonthlyReportsCompanion toCompanion(bool nullToAbsent) {
    return SupportMonthlyReportsCompanion(
      id: Value(id),
      halaqahId: Value(halaqahId),
      monthStartDate: Value(monthStartDate),
      monthEndDate: Value(monthEndDate),
      status: Value(status),
      teacherNameSnapshot: Value(teacherNameSnapshot),
      halaqahNameSnapshot: Value(halaqahNameSnapshot),
      organizationNameSnapshot: Value(organizationNameSnapshot),
      policyVersion: Value(policyVersion),
      templateVersion: Value(templateVersion),
      sourceFingerprint: sourceFingerprint == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceFingerprint),
      approvedAtUtc: approvedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedAtUtc),
    );
  }

  factory SupportMonthlyReport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupportMonthlyReport(
      id: serializer.fromJson<int>(json['id']),
      halaqahId: serializer.fromJson<int>(json['halaqahId']),
      monthStartDate: serializer.fromJson<String>(json['monthStartDate']),
      monthEndDate: serializer.fromJson<String>(json['monthEndDate']),
      status: serializer.fromJson<String>(json['status']),
      teacherNameSnapshot: serializer.fromJson<String>(
        json['teacherNameSnapshot'],
      ),
      halaqahNameSnapshot: serializer.fromJson<String>(
        json['halaqahNameSnapshot'],
      ),
      organizationNameSnapshot: serializer.fromJson<String>(
        json['organizationNameSnapshot'],
      ),
      policyVersion: serializer.fromJson<int>(json['policyVersion']),
      templateVersion: serializer.fromJson<int>(json['templateVersion']),
      sourceFingerprint: serializer.fromJson<String?>(
        json['sourceFingerprint'],
      ),
      approvedAtUtc: serializer.fromJson<DateTime?>(json['approvedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'halaqahId': serializer.toJson<int>(halaqahId),
      'monthStartDate': serializer.toJson<String>(monthStartDate),
      'monthEndDate': serializer.toJson<String>(monthEndDate),
      'status': serializer.toJson<String>(status),
      'teacherNameSnapshot': serializer.toJson<String>(teacherNameSnapshot),
      'halaqahNameSnapshot': serializer.toJson<String>(halaqahNameSnapshot),
      'organizationNameSnapshot': serializer.toJson<String>(
        organizationNameSnapshot,
      ),
      'policyVersion': serializer.toJson<int>(policyVersion),
      'templateVersion': serializer.toJson<int>(templateVersion),
      'sourceFingerprint': serializer.toJson<String?>(sourceFingerprint),
      'approvedAtUtc': serializer.toJson<DateTime?>(approvedAtUtc),
    };
  }

  SupportMonthlyReport copyWith({
    int? id,
    int? halaqahId,
    String? monthStartDate,
    String? monthEndDate,
    String? status,
    String? teacherNameSnapshot,
    String? halaqahNameSnapshot,
    String? organizationNameSnapshot,
    int? policyVersion,
    int? templateVersion,
    Value<String?> sourceFingerprint = const Value.absent(),
    Value<DateTime?> approvedAtUtc = const Value.absent(),
  }) => SupportMonthlyReport(
    id: id ?? this.id,
    halaqahId: halaqahId ?? this.halaqahId,
    monthStartDate: monthStartDate ?? this.monthStartDate,
    monthEndDate: monthEndDate ?? this.monthEndDate,
    status: status ?? this.status,
    teacherNameSnapshot: teacherNameSnapshot ?? this.teacherNameSnapshot,
    halaqahNameSnapshot: halaqahNameSnapshot ?? this.halaqahNameSnapshot,
    organizationNameSnapshot:
        organizationNameSnapshot ?? this.organizationNameSnapshot,
    policyVersion: policyVersion ?? this.policyVersion,
    templateVersion: templateVersion ?? this.templateVersion,
    sourceFingerprint: sourceFingerprint.present
        ? sourceFingerprint.value
        : this.sourceFingerprint,
    approvedAtUtc: approvedAtUtc.present
        ? approvedAtUtc.value
        : this.approvedAtUtc,
  );
  SupportMonthlyReport copyWithCompanion(SupportMonthlyReportsCompanion data) {
    return SupportMonthlyReport(
      id: data.id.present ? data.id.value : this.id,
      halaqahId: data.halaqahId.present ? data.halaqahId.value : this.halaqahId,
      monthStartDate: data.monthStartDate.present
          ? data.monthStartDate.value
          : this.monthStartDate,
      monthEndDate: data.monthEndDate.present
          ? data.monthEndDate.value
          : this.monthEndDate,
      status: data.status.present ? data.status.value : this.status,
      teacherNameSnapshot: data.teacherNameSnapshot.present
          ? data.teacherNameSnapshot.value
          : this.teacherNameSnapshot,
      halaqahNameSnapshot: data.halaqahNameSnapshot.present
          ? data.halaqahNameSnapshot.value
          : this.halaqahNameSnapshot,
      organizationNameSnapshot: data.organizationNameSnapshot.present
          ? data.organizationNameSnapshot.value
          : this.organizationNameSnapshot,
      policyVersion: data.policyVersion.present
          ? data.policyVersion.value
          : this.policyVersion,
      templateVersion: data.templateVersion.present
          ? data.templateVersion.value
          : this.templateVersion,
      sourceFingerprint: data.sourceFingerprint.present
          ? data.sourceFingerprint.value
          : this.sourceFingerprint,
      approvedAtUtc: data.approvedAtUtc.present
          ? data.approvedAtUtc.value
          : this.approvedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupportMonthlyReport(')
          ..write('id: $id, ')
          ..write('halaqahId: $halaqahId, ')
          ..write('monthStartDate: $monthStartDate, ')
          ..write('monthEndDate: $monthEndDate, ')
          ..write('status: $status, ')
          ..write('teacherNameSnapshot: $teacherNameSnapshot, ')
          ..write('halaqahNameSnapshot: $halaqahNameSnapshot, ')
          ..write('organizationNameSnapshot: $organizationNameSnapshot, ')
          ..write('policyVersion: $policyVersion, ')
          ..write('templateVersion: $templateVersion, ')
          ..write('sourceFingerprint: $sourceFingerprint, ')
          ..write('approvedAtUtc: $approvedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    halaqahId,
    monthStartDate,
    monthEndDate,
    status,
    teacherNameSnapshot,
    halaqahNameSnapshot,
    organizationNameSnapshot,
    policyVersion,
    templateVersion,
    sourceFingerprint,
    approvedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupportMonthlyReport &&
          other.id == this.id &&
          other.halaqahId == this.halaqahId &&
          other.monthStartDate == this.monthStartDate &&
          other.monthEndDate == this.monthEndDate &&
          other.status == this.status &&
          other.teacherNameSnapshot == this.teacherNameSnapshot &&
          other.halaqahNameSnapshot == this.halaqahNameSnapshot &&
          other.organizationNameSnapshot == this.organizationNameSnapshot &&
          other.policyVersion == this.policyVersion &&
          other.templateVersion == this.templateVersion &&
          other.sourceFingerprint == this.sourceFingerprint &&
          other.approvedAtUtc == this.approvedAtUtc);
}

class SupportMonthlyReportsCompanion
    extends UpdateCompanion<SupportMonthlyReport> {
  final Value<int> id;
  final Value<int> halaqahId;
  final Value<String> monthStartDate;
  final Value<String> monthEndDate;
  final Value<String> status;
  final Value<String> teacherNameSnapshot;
  final Value<String> halaqahNameSnapshot;
  final Value<String> organizationNameSnapshot;
  final Value<int> policyVersion;
  final Value<int> templateVersion;
  final Value<String?> sourceFingerprint;
  final Value<DateTime?> approvedAtUtc;
  const SupportMonthlyReportsCompanion({
    this.id = const Value.absent(),
    this.halaqahId = const Value.absent(),
    this.monthStartDate = const Value.absent(),
    this.monthEndDate = const Value.absent(),
    this.status = const Value.absent(),
    this.teacherNameSnapshot = const Value.absent(),
    this.halaqahNameSnapshot = const Value.absent(),
    this.organizationNameSnapshot = const Value.absent(),
    this.policyVersion = const Value.absent(),
    this.templateVersion = const Value.absent(),
    this.sourceFingerprint = const Value.absent(),
    this.approvedAtUtc = const Value.absent(),
  });
  SupportMonthlyReportsCompanion.insert({
    this.id = const Value.absent(),
    required int halaqahId,
    required String monthStartDate,
    required String monthEndDate,
    required String status,
    required String teacherNameSnapshot,
    required String halaqahNameSnapshot,
    required String organizationNameSnapshot,
    required int policyVersion,
    required int templateVersion,
    this.sourceFingerprint = const Value.absent(),
    this.approvedAtUtc = const Value.absent(),
  }) : halaqahId = Value(halaqahId),
       monthStartDate = Value(monthStartDate),
       monthEndDate = Value(monthEndDate),
       status = Value(status),
       teacherNameSnapshot = Value(teacherNameSnapshot),
       halaqahNameSnapshot = Value(halaqahNameSnapshot),
       organizationNameSnapshot = Value(organizationNameSnapshot),
       policyVersion = Value(policyVersion),
       templateVersion = Value(templateVersion);
  static Insertable<SupportMonthlyReport> custom({
    Expression<int>? id,
    Expression<int>? halaqahId,
    Expression<String>? monthStartDate,
    Expression<String>? monthEndDate,
    Expression<String>? status,
    Expression<String>? teacherNameSnapshot,
    Expression<String>? halaqahNameSnapshot,
    Expression<String>? organizationNameSnapshot,
    Expression<int>? policyVersion,
    Expression<int>? templateVersion,
    Expression<String>? sourceFingerprint,
    Expression<DateTime>? approvedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (halaqahId != null) 'halaqah_id': halaqahId,
      if (monthStartDate != null) 'month_start_date': monthStartDate,
      if (monthEndDate != null) 'month_end_date': monthEndDate,
      if (status != null) 'status': status,
      if (teacherNameSnapshot != null)
        'teacher_name_snapshot': teacherNameSnapshot,
      if (halaqahNameSnapshot != null)
        'halaqah_name_snapshot': halaqahNameSnapshot,
      if (organizationNameSnapshot != null)
        'organization_name_snapshot': organizationNameSnapshot,
      if (policyVersion != null) 'policy_version': policyVersion,
      if (templateVersion != null) 'template_version': templateVersion,
      if (sourceFingerprint != null) 'source_fingerprint': sourceFingerprint,
      if (approvedAtUtc != null) 'approved_at_utc': approvedAtUtc,
    });
  }

  SupportMonthlyReportsCompanion copyWith({
    Value<int>? id,
    Value<int>? halaqahId,
    Value<String>? monthStartDate,
    Value<String>? monthEndDate,
    Value<String>? status,
    Value<String>? teacherNameSnapshot,
    Value<String>? halaqahNameSnapshot,
    Value<String>? organizationNameSnapshot,
    Value<int>? policyVersion,
    Value<int>? templateVersion,
    Value<String?>? sourceFingerprint,
    Value<DateTime?>? approvedAtUtc,
  }) {
    return SupportMonthlyReportsCompanion(
      id: id ?? this.id,
      halaqahId: halaqahId ?? this.halaqahId,
      monthStartDate: monthStartDate ?? this.monthStartDate,
      monthEndDate: monthEndDate ?? this.monthEndDate,
      status: status ?? this.status,
      teacherNameSnapshot: teacherNameSnapshot ?? this.teacherNameSnapshot,
      halaqahNameSnapshot: halaqahNameSnapshot ?? this.halaqahNameSnapshot,
      organizationNameSnapshot:
          organizationNameSnapshot ?? this.organizationNameSnapshot,
      policyVersion: policyVersion ?? this.policyVersion,
      templateVersion: templateVersion ?? this.templateVersion,
      sourceFingerprint: sourceFingerprint ?? this.sourceFingerprint,
      approvedAtUtc: approvedAtUtc ?? this.approvedAtUtc,
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
    if (monthStartDate.present) {
      map['month_start_date'] = Variable<String>(monthStartDate.value);
    }
    if (monthEndDate.present) {
      map['month_end_date'] = Variable<String>(monthEndDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (teacherNameSnapshot.present) {
      map['teacher_name_snapshot'] = Variable<String>(
        teacherNameSnapshot.value,
      );
    }
    if (halaqahNameSnapshot.present) {
      map['halaqah_name_snapshot'] = Variable<String>(
        halaqahNameSnapshot.value,
      );
    }
    if (organizationNameSnapshot.present) {
      map['organization_name_snapshot'] = Variable<String>(
        organizationNameSnapshot.value,
      );
    }
    if (policyVersion.present) {
      map['policy_version'] = Variable<int>(policyVersion.value);
    }
    if (templateVersion.present) {
      map['template_version'] = Variable<int>(templateVersion.value);
    }
    if (sourceFingerprint.present) {
      map['source_fingerprint'] = Variable<String>(sourceFingerprint.value);
    }
    if (approvedAtUtc.present) {
      map['approved_at_utc'] = Variable<DateTime>(approvedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupportMonthlyReportsCompanion(')
          ..write('id: $id, ')
          ..write('halaqahId: $halaqahId, ')
          ..write('monthStartDate: $monthStartDate, ')
          ..write('monthEndDate: $monthEndDate, ')
          ..write('status: $status, ')
          ..write('teacherNameSnapshot: $teacherNameSnapshot, ')
          ..write('halaqahNameSnapshot: $halaqahNameSnapshot, ')
          ..write('organizationNameSnapshot: $organizationNameSnapshot, ')
          ..write('policyVersion: $policyVersion, ')
          ..write('templateVersion: $templateVersion, ')
          ..write('sourceFingerprint: $sourceFingerprint, ')
          ..write('approvedAtUtc: $approvedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $SupportMonthlyReportStudentsTable extends SupportMonthlyReportStudents
    with
        TableInfo<
          $SupportMonthlyReportStudentsTable,
          SupportMonthlyReportStudent
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupportMonthlyReportStudentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _reportIdMeta = const VerificationMeta(
    'reportId',
  );
  @override
  late final GeneratedColumn<int> reportId = GeneratedColumn<int>(
    'report_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES support_monthly_reports (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceStudentIdMeta = const VerificationMeta(
    'sourceStudentId',
  );
  @override
  late final GeneratedColumn<int> sourceStudentId = GeneratedColumn<int>(
    'source_student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _supportStudentNumberSnapshotMeta =
      const VerificationMeta('supportStudentNumberSnapshot');
  @override
  late final GeneratedColumn<String> supportStudentNumberSnapshot =
      GeneratedColumn<String>(
        'support_student_number_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _studentNameSnapshotMeta =
      const VerificationMeta('studentNameSnapshot');
  @override
  late final GeneratedColumn<String> studentNameSnapshot =
      GeneratedColumn<String>(
        'student_name_snapshot',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 200,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _currentJuzSnapshotMeta =
      const VerificationMeta('currentJuzSnapshot');
  @override
  late final GeneratedColumn<int> currentJuzSnapshot = GeneratedColumn<int>(
    'current_juz_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyPlanTextSnapshotMeta =
      const VerificationMeta('dailyPlanTextSnapshot');
  @override
  late final GeneratedColumn<String> dailyPlanTextSnapshot =
      GeneratedColumn<String>(
        'daily_plan_text_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _monthlyGoalQuarterFacesSnapshotMeta =
      const VerificationMeta('monthlyGoalQuarterFacesSnapshot');
  @override
  late final GeneratedColumn<int> monthlyGoalQuarterFacesSnapshot =
      GeneratedColumn<int>(
        'monthly_goal_quarter_faces_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _achievedQuarterFacesMeta =
      const VerificationMeta('achievedQuarterFaces');
  @override
  late final GeneratedColumn<int> achievedQuarterFaces = GeneratedColumn<int>(
    'achieved_quarter_faces',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _absenceDaysMeta = const VerificationMeta(
    'absenceDays',
  );
  @override
  late final GeneratedColumn<int> absenceDays = GeneratedColumn<int>(
    'absence_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalCompletedMeta = const VerificationMeta(
    'goalCompleted',
  );
  @override
  late final GeneratedColumn<bool> goalCompleted = GeneratedColumn<bool>(
    'goal_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("goal_completed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _noteSnapshotMeta = const VerificationMeta(
    'noteSnapshot',
  );
  @override
  late final GeneratedColumn<String> noteSnapshot = GeneratedColumn<String>(
    'note_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayOrderSnapshotMeta =
      const VerificationMeta('displayOrderSnapshot');
  @override
  late final GeneratedColumn<int> displayOrderSnapshot = GeneratedColumn<int>(
    'display_order_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reportId,
    sourceStudentId,
    supportStudentNumberSnapshot,
    studentNameSnapshot,
    currentJuzSnapshot,
    dailyPlanTextSnapshot,
    monthlyGoalQuarterFacesSnapshot,
    achievedQuarterFaces,
    absenceDays,
    goalCompleted,
    noteSnapshot,
    displayOrderSnapshot,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'support_monthly_report_students';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupportMonthlyReportStudent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('report_id')) {
      context.handle(
        _reportIdMeta,
        reportId.isAcceptableOrUnknown(data['report_id']!, _reportIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reportIdMeta);
    }
    if (data.containsKey('source_student_id')) {
      context.handle(
        _sourceStudentIdMeta,
        sourceStudentId.isAcceptableOrUnknown(
          data['source_student_id']!,
          _sourceStudentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceStudentIdMeta);
    }
    if (data.containsKey('support_student_number_snapshot')) {
      context.handle(
        _supportStudentNumberSnapshotMeta,
        supportStudentNumberSnapshot.isAcceptableOrUnknown(
          data['support_student_number_snapshot']!,
          _supportStudentNumberSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('student_name_snapshot')) {
      context.handle(
        _studentNameSnapshotMeta,
        studentNameSnapshot.isAcceptableOrUnknown(
          data['student_name_snapshot']!,
          _studentNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_studentNameSnapshotMeta);
    }
    if (data.containsKey('current_juz_snapshot')) {
      context.handle(
        _currentJuzSnapshotMeta,
        currentJuzSnapshot.isAcceptableOrUnknown(
          data['current_juz_snapshot']!,
          _currentJuzSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('daily_plan_text_snapshot')) {
      context.handle(
        _dailyPlanTextSnapshotMeta,
        dailyPlanTextSnapshot.isAcceptableOrUnknown(
          data['daily_plan_text_snapshot']!,
          _dailyPlanTextSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('monthly_goal_quarter_faces_snapshot')) {
      context.handle(
        _monthlyGoalQuarterFacesSnapshotMeta,
        monthlyGoalQuarterFacesSnapshot.isAcceptableOrUnknown(
          data['monthly_goal_quarter_faces_snapshot']!,
          _monthlyGoalQuarterFacesSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyGoalQuarterFacesSnapshotMeta);
    }
    if (data.containsKey('achieved_quarter_faces')) {
      context.handle(
        _achievedQuarterFacesMeta,
        achievedQuarterFaces.isAcceptableOrUnknown(
          data['achieved_quarter_faces']!,
          _achievedQuarterFacesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_achievedQuarterFacesMeta);
    }
    if (data.containsKey('absence_days')) {
      context.handle(
        _absenceDaysMeta,
        absenceDays.isAcceptableOrUnknown(
          data['absence_days']!,
          _absenceDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_absenceDaysMeta);
    }
    if (data.containsKey('goal_completed')) {
      context.handle(
        _goalCompletedMeta,
        goalCompleted.isAcceptableOrUnknown(
          data['goal_completed']!,
          _goalCompletedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_goalCompletedMeta);
    }
    if (data.containsKey('note_snapshot')) {
      context.handle(
        _noteSnapshotMeta,
        noteSnapshot.isAcceptableOrUnknown(
          data['note_snapshot']!,
          _noteSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('display_order_snapshot')) {
      context.handle(
        _displayOrderSnapshotMeta,
        displayOrderSnapshot.isAcceptableOrUnknown(
          data['display_order_snapshot']!,
          _displayOrderSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayOrderSnapshotMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {reportId, sourceStudentId},
  ];
  @override
  SupportMonthlyReportStudent map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupportMonthlyReportStudent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      reportId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}report_id'],
      )!,
      sourceStudentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_student_id'],
      )!,
      supportStudentNumberSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}support_student_number_snapshot'],
      ),
      studentNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_name_snapshot'],
      )!,
      currentJuzSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_juz_snapshot'],
      ),
      dailyPlanTextSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_plan_text_snapshot'],
      ),
      monthlyGoalQuarterFacesSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_goal_quarter_faces_snapshot'],
      )!,
      achievedQuarterFaces: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}achieved_quarter_faces'],
      )!,
      absenceDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}absence_days'],
      )!,
      goalCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}goal_completed'],
      )!,
      noteSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_snapshot'],
      ),
      displayOrderSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order_snapshot'],
      )!,
    );
  }

  @override
  $SupportMonthlyReportStudentsTable createAlias(String alias) {
    return $SupportMonthlyReportStudentsTable(attachedDatabase, alias);
  }
}

class SupportMonthlyReportStudent extends DataClass
    implements Insertable<SupportMonthlyReportStudent> {
  final int id;
  final int reportId;
  final int sourceStudentId;
  final String? supportStudentNumberSnapshot;
  final String studentNameSnapshot;
  final int? currentJuzSnapshot;
  final String? dailyPlanTextSnapshot;
  final int monthlyGoalQuarterFacesSnapshot;
  final int achievedQuarterFaces;
  final int absenceDays;
  final bool goalCompleted;
  final String? noteSnapshot;
  final int displayOrderSnapshot;
  const SupportMonthlyReportStudent({
    required this.id,
    required this.reportId,
    required this.sourceStudentId,
    this.supportStudentNumberSnapshot,
    required this.studentNameSnapshot,
    this.currentJuzSnapshot,
    this.dailyPlanTextSnapshot,
    required this.monthlyGoalQuarterFacesSnapshot,
    required this.achievedQuarterFaces,
    required this.absenceDays,
    required this.goalCompleted,
    this.noteSnapshot,
    required this.displayOrderSnapshot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['report_id'] = Variable<int>(reportId);
    map['source_student_id'] = Variable<int>(sourceStudentId);
    if (!nullToAbsent || supportStudentNumberSnapshot != null) {
      map['support_student_number_snapshot'] = Variable<String>(
        supportStudentNumberSnapshot,
      );
    }
    map['student_name_snapshot'] = Variable<String>(studentNameSnapshot);
    if (!nullToAbsent || currentJuzSnapshot != null) {
      map['current_juz_snapshot'] = Variable<int>(currentJuzSnapshot);
    }
    if (!nullToAbsent || dailyPlanTextSnapshot != null) {
      map['daily_plan_text_snapshot'] = Variable<String>(dailyPlanTextSnapshot);
    }
    map['monthly_goal_quarter_faces_snapshot'] = Variable<int>(
      monthlyGoalQuarterFacesSnapshot,
    );
    map['achieved_quarter_faces'] = Variable<int>(achievedQuarterFaces);
    map['absence_days'] = Variable<int>(absenceDays);
    map['goal_completed'] = Variable<bool>(goalCompleted);
    if (!nullToAbsent || noteSnapshot != null) {
      map['note_snapshot'] = Variable<String>(noteSnapshot);
    }
    map['display_order_snapshot'] = Variable<int>(displayOrderSnapshot);
    return map;
  }

  SupportMonthlyReportStudentsCompanion toCompanion(bool nullToAbsent) {
    return SupportMonthlyReportStudentsCompanion(
      id: Value(id),
      reportId: Value(reportId),
      sourceStudentId: Value(sourceStudentId),
      supportStudentNumberSnapshot:
          supportStudentNumberSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(supportStudentNumberSnapshot),
      studentNameSnapshot: Value(studentNameSnapshot),
      currentJuzSnapshot: currentJuzSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(currentJuzSnapshot),
      dailyPlanTextSnapshot: dailyPlanTextSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyPlanTextSnapshot),
      monthlyGoalQuarterFacesSnapshot: Value(monthlyGoalQuarterFacesSnapshot),
      achievedQuarterFaces: Value(achievedQuarterFaces),
      absenceDays: Value(absenceDays),
      goalCompleted: Value(goalCompleted),
      noteSnapshot: noteSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(noteSnapshot),
      displayOrderSnapshot: Value(displayOrderSnapshot),
    );
  }

  factory SupportMonthlyReportStudent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupportMonthlyReportStudent(
      id: serializer.fromJson<int>(json['id']),
      reportId: serializer.fromJson<int>(json['reportId']),
      sourceStudentId: serializer.fromJson<int>(json['sourceStudentId']),
      supportStudentNumberSnapshot: serializer.fromJson<String?>(
        json['supportStudentNumberSnapshot'],
      ),
      studentNameSnapshot: serializer.fromJson<String>(
        json['studentNameSnapshot'],
      ),
      currentJuzSnapshot: serializer.fromJson<int?>(json['currentJuzSnapshot']),
      dailyPlanTextSnapshot: serializer.fromJson<String?>(
        json['dailyPlanTextSnapshot'],
      ),
      monthlyGoalQuarterFacesSnapshot: serializer.fromJson<int>(
        json['monthlyGoalQuarterFacesSnapshot'],
      ),
      achievedQuarterFaces: serializer.fromJson<int>(
        json['achievedQuarterFaces'],
      ),
      absenceDays: serializer.fromJson<int>(json['absenceDays']),
      goalCompleted: serializer.fromJson<bool>(json['goalCompleted']),
      noteSnapshot: serializer.fromJson<String?>(json['noteSnapshot']),
      displayOrderSnapshot: serializer.fromJson<int>(
        json['displayOrderSnapshot'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reportId': serializer.toJson<int>(reportId),
      'sourceStudentId': serializer.toJson<int>(sourceStudentId),
      'supportStudentNumberSnapshot': serializer.toJson<String?>(
        supportStudentNumberSnapshot,
      ),
      'studentNameSnapshot': serializer.toJson<String>(studentNameSnapshot),
      'currentJuzSnapshot': serializer.toJson<int?>(currentJuzSnapshot),
      'dailyPlanTextSnapshot': serializer.toJson<String?>(
        dailyPlanTextSnapshot,
      ),
      'monthlyGoalQuarterFacesSnapshot': serializer.toJson<int>(
        monthlyGoalQuarterFacesSnapshot,
      ),
      'achievedQuarterFaces': serializer.toJson<int>(achievedQuarterFaces),
      'absenceDays': serializer.toJson<int>(absenceDays),
      'goalCompleted': serializer.toJson<bool>(goalCompleted),
      'noteSnapshot': serializer.toJson<String?>(noteSnapshot),
      'displayOrderSnapshot': serializer.toJson<int>(displayOrderSnapshot),
    };
  }

  SupportMonthlyReportStudent copyWith({
    int? id,
    int? reportId,
    int? sourceStudentId,
    Value<String?> supportStudentNumberSnapshot = const Value.absent(),
    String? studentNameSnapshot,
    Value<int?> currentJuzSnapshot = const Value.absent(),
    Value<String?> dailyPlanTextSnapshot = const Value.absent(),
    int? monthlyGoalQuarterFacesSnapshot,
    int? achievedQuarterFaces,
    int? absenceDays,
    bool? goalCompleted,
    Value<String?> noteSnapshot = const Value.absent(),
    int? displayOrderSnapshot,
  }) => SupportMonthlyReportStudent(
    id: id ?? this.id,
    reportId: reportId ?? this.reportId,
    sourceStudentId: sourceStudentId ?? this.sourceStudentId,
    supportStudentNumberSnapshot: supportStudentNumberSnapshot.present
        ? supportStudentNumberSnapshot.value
        : this.supportStudentNumberSnapshot,
    studentNameSnapshot: studentNameSnapshot ?? this.studentNameSnapshot,
    currentJuzSnapshot: currentJuzSnapshot.present
        ? currentJuzSnapshot.value
        : this.currentJuzSnapshot,
    dailyPlanTextSnapshot: dailyPlanTextSnapshot.present
        ? dailyPlanTextSnapshot.value
        : this.dailyPlanTextSnapshot,
    monthlyGoalQuarterFacesSnapshot:
        monthlyGoalQuarterFacesSnapshot ?? this.monthlyGoalQuarterFacesSnapshot,
    achievedQuarterFaces: achievedQuarterFaces ?? this.achievedQuarterFaces,
    absenceDays: absenceDays ?? this.absenceDays,
    goalCompleted: goalCompleted ?? this.goalCompleted,
    noteSnapshot: noteSnapshot.present ? noteSnapshot.value : this.noteSnapshot,
    displayOrderSnapshot: displayOrderSnapshot ?? this.displayOrderSnapshot,
  );
  SupportMonthlyReportStudent copyWithCompanion(
    SupportMonthlyReportStudentsCompanion data,
  ) {
    return SupportMonthlyReportStudent(
      id: data.id.present ? data.id.value : this.id,
      reportId: data.reportId.present ? data.reportId.value : this.reportId,
      sourceStudentId: data.sourceStudentId.present
          ? data.sourceStudentId.value
          : this.sourceStudentId,
      supportStudentNumberSnapshot: data.supportStudentNumberSnapshot.present
          ? data.supportStudentNumberSnapshot.value
          : this.supportStudentNumberSnapshot,
      studentNameSnapshot: data.studentNameSnapshot.present
          ? data.studentNameSnapshot.value
          : this.studentNameSnapshot,
      currentJuzSnapshot: data.currentJuzSnapshot.present
          ? data.currentJuzSnapshot.value
          : this.currentJuzSnapshot,
      dailyPlanTextSnapshot: data.dailyPlanTextSnapshot.present
          ? data.dailyPlanTextSnapshot.value
          : this.dailyPlanTextSnapshot,
      monthlyGoalQuarterFacesSnapshot:
          data.monthlyGoalQuarterFacesSnapshot.present
          ? data.monthlyGoalQuarterFacesSnapshot.value
          : this.monthlyGoalQuarterFacesSnapshot,
      achievedQuarterFaces: data.achievedQuarterFaces.present
          ? data.achievedQuarterFaces.value
          : this.achievedQuarterFaces,
      absenceDays: data.absenceDays.present
          ? data.absenceDays.value
          : this.absenceDays,
      goalCompleted: data.goalCompleted.present
          ? data.goalCompleted.value
          : this.goalCompleted,
      noteSnapshot: data.noteSnapshot.present
          ? data.noteSnapshot.value
          : this.noteSnapshot,
      displayOrderSnapshot: data.displayOrderSnapshot.present
          ? data.displayOrderSnapshot.value
          : this.displayOrderSnapshot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupportMonthlyReportStudent(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('sourceStudentId: $sourceStudentId, ')
          ..write(
            'supportStudentNumberSnapshot: $supportStudentNumberSnapshot, ',
          )
          ..write('studentNameSnapshot: $studentNameSnapshot, ')
          ..write('currentJuzSnapshot: $currentJuzSnapshot, ')
          ..write('dailyPlanTextSnapshot: $dailyPlanTextSnapshot, ')
          ..write(
            'monthlyGoalQuarterFacesSnapshot: $monthlyGoalQuarterFacesSnapshot, ',
          )
          ..write('achievedQuarterFaces: $achievedQuarterFaces, ')
          ..write('absenceDays: $absenceDays, ')
          ..write('goalCompleted: $goalCompleted, ')
          ..write('noteSnapshot: $noteSnapshot, ')
          ..write('displayOrderSnapshot: $displayOrderSnapshot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    reportId,
    sourceStudentId,
    supportStudentNumberSnapshot,
    studentNameSnapshot,
    currentJuzSnapshot,
    dailyPlanTextSnapshot,
    monthlyGoalQuarterFacesSnapshot,
    achievedQuarterFaces,
    absenceDays,
    goalCompleted,
    noteSnapshot,
    displayOrderSnapshot,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupportMonthlyReportStudent &&
          other.id == this.id &&
          other.reportId == this.reportId &&
          other.sourceStudentId == this.sourceStudentId &&
          other.supportStudentNumberSnapshot ==
              this.supportStudentNumberSnapshot &&
          other.studentNameSnapshot == this.studentNameSnapshot &&
          other.currentJuzSnapshot == this.currentJuzSnapshot &&
          other.dailyPlanTextSnapshot == this.dailyPlanTextSnapshot &&
          other.monthlyGoalQuarterFacesSnapshot ==
              this.monthlyGoalQuarterFacesSnapshot &&
          other.achievedQuarterFaces == this.achievedQuarterFaces &&
          other.absenceDays == this.absenceDays &&
          other.goalCompleted == this.goalCompleted &&
          other.noteSnapshot == this.noteSnapshot &&
          other.displayOrderSnapshot == this.displayOrderSnapshot);
}

class SupportMonthlyReportStudentsCompanion
    extends UpdateCompanion<SupportMonthlyReportStudent> {
  final Value<int> id;
  final Value<int> reportId;
  final Value<int> sourceStudentId;
  final Value<String?> supportStudentNumberSnapshot;
  final Value<String> studentNameSnapshot;
  final Value<int?> currentJuzSnapshot;
  final Value<String?> dailyPlanTextSnapshot;
  final Value<int> monthlyGoalQuarterFacesSnapshot;
  final Value<int> achievedQuarterFaces;
  final Value<int> absenceDays;
  final Value<bool> goalCompleted;
  final Value<String?> noteSnapshot;
  final Value<int> displayOrderSnapshot;
  const SupportMonthlyReportStudentsCompanion({
    this.id = const Value.absent(),
    this.reportId = const Value.absent(),
    this.sourceStudentId = const Value.absent(),
    this.supportStudentNumberSnapshot = const Value.absent(),
    this.studentNameSnapshot = const Value.absent(),
    this.currentJuzSnapshot = const Value.absent(),
    this.dailyPlanTextSnapshot = const Value.absent(),
    this.monthlyGoalQuarterFacesSnapshot = const Value.absent(),
    this.achievedQuarterFaces = const Value.absent(),
    this.absenceDays = const Value.absent(),
    this.goalCompleted = const Value.absent(),
    this.noteSnapshot = const Value.absent(),
    this.displayOrderSnapshot = const Value.absent(),
  });
  SupportMonthlyReportStudentsCompanion.insert({
    this.id = const Value.absent(),
    required int reportId,
    required int sourceStudentId,
    this.supportStudentNumberSnapshot = const Value.absent(),
    required String studentNameSnapshot,
    this.currentJuzSnapshot = const Value.absent(),
    this.dailyPlanTextSnapshot = const Value.absent(),
    required int monthlyGoalQuarterFacesSnapshot,
    required int achievedQuarterFaces,
    required int absenceDays,
    required bool goalCompleted,
    this.noteSnapshot = const Value.absent(),
    required int displayOrderSnapshot,
  }) : reportId = Value(reportId),
       sourceStudentId = Value(sourceStudentId),
       studentNameSnapshot = Value(studentNameSnapshot),
       monthlyGoalQuarterFacesSnapshot = Value(monthlyGoalQuarterFacesSnapshot),
       achievedQuarterFaces = Value(achievedQuarterFaces),
       absenceDays = Value(absenceDays),
       goalCompleted = Value(goalCompleted),
       displayOrderSnapshot = Value(displayOrderSnapshot);
  static Insertable<SupportMonthlyReportStudent> custom({
    Expression<int>? id,
    Expression<int>? reportId,
    Expression<int>? sourceStudentId,
    Expression<String>? supportStudentNumberSnapshot,
    Expression<String>? studentNameSnapshot,
    Expression<int>? currentJuzSnapshot,
    Expression<String>? dailyPlanTextSnapshot,
    Expression<int>? monthlyGoalQuarterFacesSnapshot,
    Expression<int>? achievedQuarterFaces,
    Expression<int>? absenceDays,
    Expression<bool>? goalCompleted,
    Expression<String>? noteSnapshot,
    Expression<int>? displayOrderSnapshot,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reportId != null) 'report_id': reportId,
      if (sourceStudentId != null) 'source_student_id': sourceStudentId,
      if (supportStudentNumberSnapshot != null)
        'support_student_number_snapshot': supportStudentNumberSnapshot,
      if (studentNameSnapshot != null)
        'student_name_snapshot': studentNameSnapshot,
      if (currentJuzSnapshot != null)
        'current_juz_snapshot': currentJuzSnapshot,
      if (dailyPlanTextSnapshot != null)
        'daily_plan_text_snapshot': dailyPlanTextSnapshot,
      if (monthlyGoalQuarterFacesSnapshot != null)
        'monthly_goal_quarter_faces_snapshot': monthlyGoalQuarterFacesSnapshot,
      if (achievedQuarterFaces != null)
        'achieved_quarter_faces': achievedQuarterFaces,
      if (absenceDays != null) 'absence_days': absenceDays,
      if (goalCompleted != null) 'goal_completed': goalCompleted,
      if (noteSnapshot != null) 'note_snapshot': noteSnapshot,
      if (displayOrderSnapshot != null)
        'display_order_snapshot': displayOrderSnapshot,
    });
  }

  SupportMonthlyReportStudentsCompanion copyWith({
    Value<int>? id,
    Value<int>? reportId,
    Value<int>? sourceStudentId,
    Value<String?>? supportStudentNumberSnapshot,
    Value<String>? studentNameSnapshot,
    Value<int?>? currentJuzSnapshot,
    Value<String?>? dailyPlanTextSnapshot,
    Value<int>? monthlyGoalQuarterFacesSnapshot,
    Value<int>? achievedQuarterFaces,
    Value<int>? absenceDays,
    Value<bool>? goalCompleted,
    Value<String?>? noteSnapshot,
    Value<int>? displayOrderSnapshot,
  }) {
    return SupportMonthlyReportStudentsCompanion(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      sourceStudentId: sourceStudentId ?? this.sourceStudentId,
      supportStudentNumberSnapshot:
          supportStudentNumberSnapshot ?? this.supportStudentNumberSnapshot,
      studentNameSnapshot: studentNameSnapshot ?? this.studentNameSnapshot,
      currentJuzSnapshot: currentJuzSnapshot ?? this.currentJuzSnapshot,
      dailyPlanTextSnapshot:
          dailyPlanTextSnapshot ?? this.dailyPlanTextSnapshot,
      monthlyGoalQuarterFacesSnapshot:
          monthlyGoalQuarterFacesSnapshot ??
          this.monthlyGoalQuarterFacesSnapshot,
      achievedQuarterFaces: achievedQuarterFaces ?? this.achievedQuarterFaces,
      absenceDays: absenceDays ?? this.absenceDays,
      goalCompleted: goalCompleted ?? this.goalCompleted,
      noteSnapshot: noteSnapshot ?? this.noteSnapshot,
      displayOrderSnapshot: displayOrderSnapshot ?? this.displayOrderSnapshot,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reportId.present) {
      map['report_id'] = Variable<int>(reportId.value);
    }
    if (sourceStudentId.present) {
      map['source_student_id'] = Variable<int>(sourceStudentId.value);
    }
    if (supportStudentNumberSnapshot.present) {
      map['support_student_number_snapshot'] = Variable<String>(
        supportStudentNumberSnapshot.value,
      );
    }
    if (studentNameSnapshot.present) {
      map['student_name_snapshot'] = Variable<String>(
        studentNameSnapshot.value,
      );
    }
    if (currentJuzSnapshot.present) {
      map['current_juz_snapshot'] = Variable<int>(currentJuzSnapshot.value);
    }
    if (dailyPlanTextSnapshot.present) {
      map['daily_plan_text_snapshot'] = Variable<String>(
        dailyPlanTextSnapshot.value,
      );
    }
    if (monthlyGoalQuarterFacesSnapshot.present) {
      map['monthly_goal_quarter_faces_snapshot'] = Variable<int>(
        monthlyGoalQuarterFacesSnapshot.value,
      );
    }
    if (achievedQuarterFaces.present) {
      map['achieved_quarter_faces'] = Variable<int>(achievedQuarterFaces.value);
    }
    if (absenceDays.present) {
      map['absence_days'] = Variable<int>(absenceDays.value);
    }
    if (goalCompleted.present) {
      map['goal_completed'] = Variable<bool>(goalCompleted.value);
    }
    if (noteSnapshot.present) {
      map['note_snapshot'] = Variable<String>(noteSnapshot.value);
    }
    if (displayOrderSnapshot.present) {
      map['display_order_snapshot'] = Variable<int>(displayOrderSnapshot.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupportMonthlyReportStudentsCompanion(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('sourceStudentId: $sourceStudentId, ')
          ..write(
            'supportStudentNumberSnapshot: $supportStudentNumberSnapshot, ',
          )
          ..write('studentNameSnapshot: $studentNameSnapshot, ')
          ..write('currentJuzSnapshot: $currentJuzSnapshot, ')
          ..write('dailyPlanTextSnapshot: $dailyPlanTextSnapshot, ')
          ..write(
            'monthlyGoalQuarterFacesSnapshot: $monthlyGoalQuarterFacesSnapshot, ',
          )
          ..write('achievedQuarterFaces: $achievedQuarterFaces, ')
          ..write('absenceDays: $absenceDays, ')
          ..write('goalCompleted: $goalCompleted, ')
          ..write('noteSnapshot: $noteSnapshot, ')
          ..write('displayOrderSnapshot: $displayOrderSnapshot')
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
  late final $HalaqahDaysTable halaqahDays = $HalaqahDaysTable(this);
  late final $AttendanceRecordsTable attendanceRecords =
      $AttendanceRecordsTable(this);
  late final $RecitationsTable recitations = $RecitationsTable(this);
  late final $ParentFollowUpsTable parentFollowUps = $ParentFollowUpsTable(
    this,
  );
  late final $SupportWeeklyReportsTable supportWeeklyReports =
      $SupportWeeklyReportsTable(this);
  late final $SupportWeeklyReportStudentsTable supportWeeklyReportStudents =
      $SupportWeeklyReportStudentsTable(this);
  late final $SupportWeeklyReportDaysTable supportWeeklyReportDays =
      $SupportWeeklyReportDaysTable(this);
  late final $SupportWeeklyReportDayEntriesTable supportWeeklyReportDayEntries =
      $SupportWeeklyReportDayEntriesTable(this);
  late final $SupportMonthlyReportsTable supportMonthlyReports =
      $SupportMonthlyReportsTable(this);
  late final $SupportMonthlyReportStudentsTable supportMonthlyReportStudents =
      $SupportMonthlyReportStudentsTable(this);
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
    halaqahDays,
    attendanceRecords,
    recitations,
    parentFollowUps,
    supportWeeklyReports,
    supportWeeklyReportStudents,
    supportWeeklyReportDays,
    supportWeeklyReportDayEntries,
    supportMonthlyReports,
    supportMonthlyReportStudents,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'support_weekly_reports',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('support_weekly_report_students', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'support_weekly_reports',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('support_weekly_report_days', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'support_weekly_report_days',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate(
          'support_weekly_report_day_entries',
          kind: UpdateKind.delete,
        ),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'support_weekly_report_students',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate(
          'support_weekly_report_day_entries',
          kind: UpdateKind.delete,
        ),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'support_monthly_reports',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('support_monthly_report_students', kind: UpdateKind.delete),
      ],
    ),
  ]);
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

  static MultiTypedResultKey<$HalaqahDaysTable, List<HalaqahDay>>
  _halaqahDaysRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.halaqahDays,
    aliasName: 'halaqahs__id__halaqah_days__halaqah_id',
  );

  $$HalaqahDaysTableProcessedTableManager get halaqahDaysRefs {
    final manager = $$HalaqahDaysTableTableManager(
      $_db,
      $_db.halaqahDays,
    ).filter((f) => f.halaqahId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_halaqahDaysRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SupportWeeklyReportsTable,
    List<SupportWeeklyReport>
  >
  _supportWeeklyReportsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.supportWeeklyReports,
        aliasName: 'halaqahs__id__support_weekly_reports__halaqah_id',
      );

  $$SupportWeeklyReportsTableProcessedTableManager
  get supportWeeklyReportsRefs {
    final manager = $$SupportWeeklyReportsTableTableManager(
      $_db,
      $_db.supportWeeklyReports,
    ).filter((f) => f.halaqahId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supportWeeklyReportsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SupportMonthlyReportsTable,
    List<SupportMonthlyReport>
  >
  _supportMonthlyReportsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.supportMonthlyReports,
        aliasName: 'halaqahs__id__support_monthly_reports__halaqah_id',
      );

  $$SupportMonthlyReportsTableProcessedTableManager
  get supportMonthlyReportsRefs {
    final manager = $$SupportMonthlyReportsTableTableManager(
      $_db,
      $_db.supportMonthlyReports,
    ).filter((f) => f.halaqahId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supportMonthlyReportsRefsTable($_db),
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

  Expression<bool> halaqahDaysRefs(
    Expression<bool> Function($$HalaqahDaysTableFilterComposer f) f,
  ) {
    final $$HalaqahDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.halaqahDays,
      getReferencedColumn: (t) => t.halaqahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HalaqahDaysTableFilterComposer(
            $db: $db,
            $table: $db.halaqahDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supportWeeklyReportsRefs(
    Expression<bool> Function($$SupportWeeklyReportsTableFilterComposer f) f,
  ) {
    final $$SupportWeeklyReportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supportWeeklyReports,
      getReferencedColumn: (t) => t.halaqahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupportWeeklyReportsTableFilterComposer(
            $db: $db,
            $table: $db.supportWeeklyReports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supportMonthlyReportsRefs(
    Expression<bool> Function($$SupportMonthlyReportsTableFilterComposer f) f,
  ) {
    final $$SupportMonthlyReportsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportMonthlyReports,
          getReferencedColumn: (t) => t.halaqahId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportMonthlyReportsTableFilterComposer(
                $db: $db,
                $table: $db.supportMonthlyReports,
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

  Expression<T> halaqahDaysRefs<T extends Object>(
    Expression<T> Function($$HalaqahDaysTableAnnotationComposer a) f,
  ) {
    final $$HalaqahDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.halaqahDays,
      getReferencedColumn: (t) => t.halaqahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HalaqahDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.halaqahDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supportWeeklyReportsRefs<T extends Object>(
    Expression<T> Function($$SupportWeeklyReportsTableAnnotationComposer a) f,
  ) {
    final $$SupportWeeklyReportsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportWeeklyReports,
          getReferencedColumn: (t) => t.halaqahId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportsTableAnnotationComposer(
                $db: $db,
                $table: $db.supportWeeklyReports,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> supportMonthlyReportsRefs<T extends Object>(
    Expression<T> Function($$SupportMonthlyReportsTableAnnotationComposer a) f,
  ) {
    final $$SupportMonthlyReportsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportMonthlyReports,
          getReferencedColumn: (t) => t.halaqahId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportMonthlyReportsTableAnnotationComposer(
                $db: $db,
                $table: $db.supportMonthlyReports,
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
            bool halaqahDaysRefs,
            bool supportWeeklyReportsRefs,
            bool supportMonthlyReportsRefs,
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
                halaqahDaysRefs = false,
                supportWeeklyReportsRefs = false,
                supportMonthlyReportsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (supportProgramSettingsRefs) db.supportProgramSettings,
                    if (supportProgramPeriodsRefs) db.supportProgramPeriods,
                    if (studentsRefs) db.students,
                    if (halaqahDaysRefs) db.halaqahDays,
                    if (supportWeeklyReportsRefs) db.supportWeeklyReports,
                    if (supportMonthlyReportsRefs) db.supportMonthlyReports,
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
                      if (halaqahDaysRefs)
                        await $_getPrefetchedData<
                          Halaqah,
                          $HalaqahsTable,
                          HalaqahDay
                        >(
                          currentTable: table,
                          referencedTable: $$HalaqahsTableReferences
                              ._halaqahDaysRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HalaqahsTableReferences(
                                db,
                                table,
                                p0,
                              ).halaqahDaysRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.halaqahId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supportWeeklyReportsRefs)
                        await $_getPrefetchedData<
                          Halaqah,
                          $HalaqahsTable,
                          SupportWeeklyReport
                        >(
                          currentTable: table,
                          referencedTable: $$HalaqahsTableReferences
                              ._supportWeeklyReportsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HalaqahsTableReferences(
                                db,
                                table,
                                p0,
                              ).supportWeeklyReportsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.halaqahId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supportMonthlyReportsRefs)
                        await $_getPrefetchedData<
                          Halaqah,
                          $HalaqahsTable,
                          SupportMonthlyReport
                        >(
                          currentTable: table,
                          referencedTable: $$HalaqahsTableReferences
                              ._supportMonthlyReportsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HalaqahsTableReferences(
                                db,
                                table,
                                p0,
                              ).supportMonthlyReportsRefs,
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
        bool halaqahDaysRefs,
        bool supportWeeklyReportsRefs,
        bool supportMonthlyReportsRefs,
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

  static MultiTypedResultKey<$AttendanceRecordsTable, List<AttendanceRecord>>
  _attendanceRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.attendanceRecords,
        aliasName: 'students__id__attendance_records__student_id',
      );

  $$AttendanceRecordsTableProcessedTableManager get attendanceRecordsRefs {
    final manager = $$AttendanceRecordsTableTableManager(
      $_db,
      $_db.attendanceRecords,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _attendanceRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecitationsTable, List<Recitation>>
  _recitationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recitations,
    aliasName: 'students__id__recitations__student_id',
  );

  $$RecitationsTableProcessedTableManager get recitationsRefs {
    final manager = $$RecitationsTableTableManager(
      $_db,
      $_db.recitations,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_recitationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ParentFollowUpsTable, List<ParentFollowUp>>
  _parentFollowUpsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.parentFollowUps,
    aliasName: 'students__id__parent_follow_ups__student_id',
  );

  $$ParentFollowUpsTableProcessedTableManager get parentFollowUpsRefs {
    final manager = $$ParentFollowUpsTableTableManager(
      $_db,
      $_db.parentFollowUps,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _parentFollowUpsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SupportWeeklyReportStudentsTable,
    List<SupportWeeklyReportStudent>
  >
  _supportWeeklyReportStudentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.supportWeeklyReportStudents,
        aliasName:
            'students__id__support_weekly_report_students__source_student_id',
      );

  $$SupportWeeklyReportStudentsTableProcessedTableManager
  get supportWeeklyReportStudentsRefs {
    final manager = $$SupportWeeklyReportStudentsTableTableManager(
      $_db,
      $_db.supportWeeklyReportStudents,
    ).filter((f) => f.sourceStudentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supportWeeklyReportStudentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SupportMonthlyReportStudentsTable,
    List<SupportMonthlyReportStudent>
  >
  _supportMonthlyReportStudentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.supportMonthlyReportStudents,
        aliasName:
            'students__id__support_monthly_report_students__source_student_id',
      );

  $$SupportMonthlyReportStudentsTableProcessedTableManager
  get supportMonthlyReportStudentsRefs {
    final manager = $$SupportMonthlyReportStudentsTableTableManager(
      $_db,
      $_db.supportMonthlyReportStudents,
    ).filter((f) => f.sourceStudentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supportMonthlyReportStudentsRefsTable($_db),
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

  Expression<bool> attendanceRecordsRefs(
    Expression<bool> Function($$AttendanceRecordsTableFilterComposer f) f,
  ) {
    final $$AttendanceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceRecords,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recitationsRefs(
    Expression<bool> Function($$RecitationsTableFilterComposer f) f,
  ) {
    final $$RecitationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recitations,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecitationsTableFilterComposer(
            $db: $db,
            $table: $db.recitations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> parentFollowUpsRefs(
    Expression<bool> Function($$ParentFollowUpsTableFilterComposer f) f,
  ) {
    final $$ParentFollowUpsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.parentFollowUps,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParentFollowUpsTableFilterComposer(
            $db: $db,
            $table: $db.parentFollowUps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supportWeeklyReportStudentsRefs(
    Expression<bool> Function(
      $$SupportWeeklyReportStudentsTableFilterComposer f,
    )
    f,
  ) {
    final $$SupportWeeklyReportStudentsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportWeeklyReportStudents,
          getReferencedColumn: (t) => t.sourceStudentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportStudentsTableFilterComposer(
                $db: $db,
                $table: $db.supportWeeklyReportStudents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> supportMonthlyReportStudentsRefs(
    Expression<bool> Function(
      $$SupportMonthlyReportStudentsTableFilterComposer f,
    )
    f,
  ) {
    final $$SupportMonthlyReportStudentsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportMonthlyReportStudents,
          getReferencedColumn: (t) => t.sourceStudentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportMonthlyReportStudentsTableFilterComposer(
                $db: $db,
                $table: $db.supportMonthlyReportStudents,
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

  Expression<T> attendanceRecordsRefs<T extends Object>(
    Expression<T> Function($$AttendanceRecordsTableAnnotationComposer a) f,
  ) {
    final $$AttendanceRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.attendanceRecords,
          getReferencedColumn: (t) => t.studentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttendanceRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.attendanceRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> recitationsRefs<T extends Object>(
    Expression<T> Function($$RecitationsTableAnnotationComposer a) f,
  ) {
    final $$RecitationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recitations,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecitationsTableAnnotationComposer(
            $db: $db,
            $table: $db.recitations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> parentFollowUpsRefs<T extends Object>(
    Expression<T> Function($$ParentFollowUpsTableAnnotationComposer a) f,
  ) {
    final $$ParentFollowUpsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.parentFollowUps,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParentFollowUpsTableAnnotationComposer(
            $db: $db,
            $table: $db.parentFollowUps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supportWeeklyReportStudentsRefs<T extends Object>(
    Expression<T> Function(
      $$SupportWeeklyReportStudentsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$SupportWeeklyReportStudentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportWeeklyReportStudents,
          getReferencedColumn: (t) => t.sourceStudentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportStudentsTableAnnotationComposer(
                $db: $db,
                $table: $db.supportWeeklyReportStudents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> supportMonthlyReportStudentsRefs<T extends Object>(
    Expression<T> Function(
      $$SupportMonthlyReportStudentsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$SupportMonthlyReportStudentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportMonthlyReportStudents,
          getReferencedColumn: (t) => t.sourceStudentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportMonthlyReportStudentsTableAnnotationComposer(
                $db: $db,
                $table: $db.supportMonthlyReportStudents,
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
            bool attendanceRecordsRefs,
            bool recitationsRefs,
            bool parentFollowUpsRefs,
            bool supportWeeklyReportStudentsRefs,
            bool supportMonthlyReportStudentsRefs,
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
                attendanceRecordsRefs = false,
                recitationsRefs = false,
                parentFollowUpsRefs = false,
                supportWeeklyReportStudentsRefs = false,
                supportMonthlyReportStudentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (studentProgressPlansRefs) db.studentProgressPlans,
                    if (studentActivityPeriodsRefs) db.studentActivityPeriods,
                    if (attendanceRecordsRefs) db.attendanceRecords,
                    if (recitationsRefs) db.recitations,
                    if (parentFollowUpsRefs) db.parentFollowUps,
                    if (supportWeeklyReportStudentsRefs)
                      db.supportWeeklyReportStudents,
                    if (supportMonthlyReportStudentsRefs)
                      db.supportMonthlyReportStudents,
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
                      if (attendanceRecordsRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          AttendanceRecord
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._attendanceRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).attendanceRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recitationsRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          Recitation
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._recitationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).recitationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (parentFollowUpsRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          ParentFollowUp
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._parentFollowUpsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).parentFollowUpsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supportWeeklyReportStudentsRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          SupportWeeklyReportStudent
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._supportWeeklyReportStudentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).supportWeeklyReportStudentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceStudentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supportMonthlyReportStudentsRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          SupportMonthlyReportStudent
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._supportMonthlyReportStudentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).supportMonthlyReportStudentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceStudentId == item.id,
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
        bool attendanceRecordsRefs,
        bool recitationsRefs,
        bool parentFollowUpsRefs,
        bool supportWeeklyReportStudentsRefs,
        bool supportMonthlyReportStudentsRefs,
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
typedef $$HalaqahDaysTableCreateCompanionBuilder =
    HalaqahDaysCompanion Function({
      Value<int> id,
      required int halaqahId,
      required String dayDate,
      required String status,
    });
typedef $$HalaqahDaysTableUpdateCompanionBuilder =
    HalaqahDaysCompanion Function({
      Value<int> id,
      Value<int> halaqahId,
      Value<String> dayDate,
      Value<String> status,
    });

final class $$HalaqahDaysTableReferences
    extends BaseReferences<_$AppDatabase, $HalaqahDaysTable, HalaqahDay> {
  $$HalaqahDaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HalaqahsTable _halaqahIdTable(_$AppDatabase db) =>
      db.halaqahs.createAlias('halaqah_days__halaqah_id__halaqahs__id');

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

  static MultiTypedResultKey<$AttendanceRecordsTable, List<AttendanceRecord>>
  _attendanceRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.attendanceRecords,
        aliasName: 'halaqah_days__id__attendance_records__day_id',
      );

  $$AttendanceRecordsTableProcessedTableManager get attendanceRecordsRefs {
    final manager = $$AttendanceRecordsTableTableManager(
      $_db,
      $_db.attendanceRecords,
    ).filter((f) => f.dayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _attendanceRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecitationsTable, List<Recitation>>
  _recitationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recitations,
    aliasName: 'halaqah_days__id__recitations__day_id',
  );

  $$RecitationsTableProcessedTableManager get recitationsRefs {
    final manager = $$RecitationsTableTableManager(
      $_db,
      $_db.recitations,
    ).filter((f) => f.dayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_recitationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ParentFollowUpsTable, List<ParentFollowUp>>
  _parentFollowUpsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.parentFollowUps,
    aliasName: 'halaqah_days__id__parent_follow_ups__day_id',
  );

  $$ParentFollowUpsTableProcessedTableManager get parentFollowUpsRefs {
    final manager = $$ParentFollowUpsTableTableManager(
      $_db,
      $_db.parentFollowUps,
    ).filter((f) => f.dayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _parentFollowUpsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HalaqahDaysTableFilterComposer
    extends Composer<_$AppDatabase, $HalaqahDaysTable> {
  $$HalaqahDaysTableFilterComposer({
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

  ColumnFilters<String> get dayDate => $composableBuilder(
    column: $table.dayDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  Expression<bool> attendanceRecordsRefs(
    Expression<bool> Function($$AttendanceRecordsTableFilterComposer f) f,
  ) {
    final $$AttendanceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceRecords,
      getReferencedColumn: (t) => t.dayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recitationsRefs(
    Expression<bool> Function($$RecitationsTableFilterComposer f) f,
  ) {
    final $$RecitationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recitations,
      getReferencedColumn: (t) => t.dayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecitationsTableFilterComposer(
            $db: $db,
            $table: $db.recitations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> parentFollowUpsRefs(
    Expression<bool> Function($$ParentFollowUpsTableFilterComposer f) f,
  ) {
    final $$ParentFollowUpsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.parentFollowUps,
      getReferencedColumn: (t) => t.dayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParentFollowUpsTableFilterComposer(
            $db: $db,
            $table: $db.parentFollowUps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HalaqahDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $HalaqahDaysTable> {
  $$HalaqahDaysTableOrderingComposer({
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

  ColumnOrderings<String> get dayDate => $composableBuilder(
    column: $table.dayDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

class $$HalaqahDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $HalaqahDaysTable> {
  $$HalaqahDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dayDate =>
      $composableBuilder(column: $table.dayDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

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

  Expression<T> attendanceRecordsRefs<T extends Object>(
    Expression<T> Function($$AttendanceRecordsTableAnnotationComposer a) f,
  ) {
    final $$AttendanceRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.attendanceRecords,
          getReferencedColumn: (t) => t.dayId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttendanceRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.attendanceRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> recitationsRefs<T extends Object>(
    Expression<T> Function($$RecitationsTableAnnotationComposer a) f,
  ) {
    final $$RecitationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recitations,
      getReferencedColumn: (t) => t.dayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecitationsTableAnnotationComposer(
            $db: $db,
            $table: $db.recitations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> parentFollowUpsRefs<T extends Object>(
    Expression<T> Function($$ParentFollowUpsTableAnnotationComposer a) f,
  ) {
    final $$ParentFollowUpsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.parentFollowUps,
      getReferencedColumn: (t) => t.dayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParentFollowUpsTableAnnotationComposer(
            $db: $db,
            $table: $db.parentFollowUps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HalaqahDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HalaqahDaysTable,
          HalaqahDay,
          $$HalaqahDaysTableFilterComposer,
          $$HalaqahDaysTableOrderingComposer,
          $$HalaqahDaysTableAnnotationComposer,
          $$HalaqahDaysTableCreateCompanionBuilder,
          $$HalaqahDaysTableUpdateCompanionBuilder,
          (HalaqahDay, $$HalaqahDaysTableReferences),
          HalaqahDay,
          PrefetchHooks Function({
            bool halaqahId,
            bool attendanceRecordsRefs,
            bool recitationsRefs,
            bool parentFollowUpsRefs,
          })
        > {
  $$HalaqahDaysTableTableManager(_$AppDatabase db, $HalaqahDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HalaqahDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HalaqahDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HalaqahDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> halaqahId = const Value.absent(),
                Value<String> dayDate = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => HalaqahDaysCompanion(
                id: id,
                halaqahId: halaqahId,
                dayDate: dayDate,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int halaqahId,
                required String dayDate,
                required String status,
              }) => HalaqahDaysCompanion.insert(
                id: id,
                halaqahId: halaqahId,
                dayDate: dayDate,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HalaqahDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                halaqahId = false,
                attendanceRecordsRefs = false,
                recitationsRefs = false,
                parentFollowUpsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attendanceRecordsRefs) db.attendanceRecords,
                    if (recitationsRefs) db.recitations,
                    if (parentFollowUpsRefs) db.parentFollowUps,
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
                                    referencedTable:
                                        $$HalaqahDaysTableReferences
                                            ._halaqahIdTable(db),
                                    referencedColumn:
                                        $$HalaqahDaysTableReferences
                                            ._halaqahIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attendanceRecordsRefs)
                        await $_getPrefetchedData<
                          HalaqahDay,
                          $HalaqahDaysTable,
                          AttendanceRecord
                        >(
                          currentTable: table,
                          referencedTable: $$HalaqahDaysTableReferences
                              ._attendanceRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HalaqahDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).attendanceRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.dayId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recitationsRefs)
                        await $_getPrefetchedData<
                          HalaqahDay,
                          $HalaqahDaysTable,
                          Recitation
                        >(
                          currentTable: table,
                          referencedTable: $$HalaqahDaysTableReferences
                              ._recitationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HalaqahDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).recitationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.dayId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (parentFollowUpsRefs)
                        await $_getPrefetchedData<
                          HalaqahDay,
                          $HalaqahDaysTable,
                          ParentFollowUp
                        >(
                          currentTable: table,
                          referencedTable: $$HalaqahDaysTableReferences
                              ._parentFollowUpsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HalaqahDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).parentFollowUpsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.dayId == item.id,
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

typedef $$HalaqahDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HalaqahDaysTable,
      HalaqahDay,
      $$HalaqahDaysTableFilterComposer,
      $$HalaqahDaysTableOrderingComposer,
      $$HalaqahDaysTableAnnotationComposer,
      $$HalaqahDaysTableCreateCompanionBuilder,
      $$HalaqahDaysTableUpdateCompanionBuilder,
      (HalaqahDay, $$HalaqahDaysTableReferences),
      HalaqahDay,
      PrefetchHooks Function({
        bool halaqahId,
        bool attendanceRecordsRefs,
        bool recitationsRefs,
        bool parentFollowUpsRefs,
      })
    >;
typedef $$AttendanceRecordsTableCreateCompanionBuilder =
    AttendanceRecordsCompanion Function({
      Value<int> id,
      required int dayId,
      required int studentId,
      required String status,
    });
typedef $$AttendanceRecordsTableUpdateCompanionBuilder =
    AttendanceRecordsCompanion Function({
      Value<int> id,
      Value<int> dayId,
      Value<int> studentId,
      Value<String> status,
    });

final class $$AttendanceRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AttendanceRecordsTable,
          AttendanceRecord
        > {
  $$AttendanceRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HalaqahDaysTable _dayIdTable(_$AppDatabase db) => db.halaqahDays
      .createAlias('attendance_records__day_id__halaqah_days__id');

  $$HalaqahDaysTableProcessedTableManager get dayId {
    final $_column = $_itemColumn<int>('day_id')!;

    final manager = $$HalaqahDaysTableTableManager(
      $_db,
      $_db.halaqahDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('attendance_records__student_id__students__id');

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

class $$AttendanceRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableFilterComposer({
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

  $$HalaqahDaysTableFilterComposer get dayId {
    final $$HalaqahDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.halaqahDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HalaqahDaysTableFilterComposer(
            $db: $db,
            $table: $db.halaqahDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

class $$AttendanceRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableOrderingComposer({
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

  $$HalaqahDaysTableOrderingComposer get dayId {
    final $$HalaqahDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.halaqahDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HalaqahDaysTableOrderingComposer(
            $db: $db,
            $table: $db.halaqahDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

class $$AttendanceRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableAnnotationComposer({
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

  $$HalaqahDaysTableAnnotationComposer get dayId {
    final $$HalaqahDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.halaqahDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HalaqahDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.halaqahDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

class $$AttendanceRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceRecordsTable,
          AttendanceRecord,
          $$AttendanceRecordsTableFilterComposer,
          $$AttendanceRecordsTableOrderingComposer,
          $$AttendanceRecordsTableAnnotationComposer,
          $$AttendanceRecordsTableCreateCompanionBuilder,
          $$AttendanceRecordsTableUpdateCompanionBuilder,
          (AttendanceRecord, $$AttendanceRecordsTableReferences),
          AttendanceRecord,
          PrefetchHooks Function({bool dayId, bool studentId})
        > {
  $$AttendanceRecordsTableTableManager(
    _$AppDatabase db,
    $AttendanceRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dayId = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => AttendanceRecordsCompanion(
                id: id,
                dayId: dayId,
                studentId: studentId,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int dayId,
                required int studentId,
                required String status,
              }) => AttendanceRecordsCompanion.insert(
                id: id,
                dayId: dayId,
                studentId: studentId,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttendanceRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dayId = false, studentId = false}) {
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
                    if (dayId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.dayId,
                                referencedTable:
                                    $$AttendanceRecordsTableReferences
                                        ._dayIdTable(db),
                                referencedColumn:
                                    $$AttendanceRecordsTableReferences
                                        ._dayIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable:
                                    $$AttendanceRecordsTableReferences
                                        ._studentIdTable(db),
                                referencedColumn:
                                    $$AttendanceRecordsTableReferences
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

typedef $$AttendanceRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceRecordsTable,
      AttendanceRecord,
      $$AttendanceRecordsTableFilterComposer,
      $$AttendanceRecordsTableOrderingComposer,
      $$AttendanceRecordsTableAnnotationComposer,
      $$AttendanceRecordsTableCreateCompanionBuilder,
      $$AttendanceRecordsTableUpdateCompanionBuilder,
      (AttendanceRecord, $$AttendanceRecordsTableReferences),
      AttendanceRecord,
      PrefetchHooks Function({bool dayId, bool studentId})
    >;
typedef $$RecitationsTableCreateCompanionBuilder =
    RecitationsCompanion Function({
      Value<int> id,
      required int dayId,
      required int studentId,
      required String type,
      required int startSurah,
      required int startAyah,
      required int endSurah,
      required int endAyah,
      required int facesQuarterAchieved,
      required String evaluation,
      Value<int> errorCount,
      Value<String?> note,
      Value<int?> plannedStartSurah,
      Value<int?> plannedStartAyah,
      Value<int?> plannedEndSurah,
      Value<int?> plannedEndAyah,
    });
typedef $$RecitationsTableUpdateCompanionBuilder =
    RecitationsCompanion Function({
      Value<int> id,
      Value<int> dayId,
      Value<int> studentId,
      Value<String> type,
      Value<int> startSurah,
      Value<int> startAyah,
      Value<int> endSurah,
      Value<int> endAyah,
      Value<int> facesQuarterAchieved,
      Value<String> evaluation,
      Value<int> errorCount,
      Value<String?> note,
      Value<int?> plannedStartSurah,
      Value<int?> plannedStartAyah,
      Value<int?> plannedEndSurah,
      Value<int?> plannedEndAyah,
    });

final class $$RecitationsTableReferences
    extends BaseReferences<_$AppDatabase, $RecitationsTable, Recitation> {
  $$RecitationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HalaqahDaysTable _dayIdTable(_$AppDatabase db) =>
      db.halaqahDays.createAlias('recitations__day_id__halaqah_days__id');

  $$HalaqahDaysTableProcessedTableManager get dayId {
    final $_column = $_itemColumn<int>('day_id')!;

    final manager = $$HalaqahDaysTableTableManager(
      $_db,
      $_db.halaqahDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('recitations__student_id__students__id');

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

class $$RecitationsTableFilterComposer
    extends Composer<_$AppDatabase, $RecitationsTable> {
  $$RecitationsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startSurah => $composableBuilder(
    column: $table.startSurah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startAyah => $composableBuilder(
    column: $table.startAyah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endSurah => $composableBuilder(
    column: $table.endSurah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endAyah => $composableBuilder(
    column: $table.endAyah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get facesQuarterAchieved => $composableBuilder(
    column: $table.facesQuarterAchieved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evaluation => $composableBuilder(
    column: $table.evaluation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedStartSurah => $composableBuilder(
    column: $table.plannedStartSurah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedStartAyah => $composableBuilder(
    column: $table.plannedStartAyah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedEndSurah => $composableBuilder(
    column: $table.plannedEndSurah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedEndAyah => $composableBuilder(
    column: $table.plannedEndAyah,
    builder: (column) => ColumnFilters(column),
  );

  $$HalaqahDaysTableFilterComposer get dayId {
    final $$HalaqahDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.halaqahDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HalaqahDaysTableFilterComposer(
            $db: $db,
            $table: $db.halaqahDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

class $$RecitationsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecitationsTable> {
  $$RecitationsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startSurah => $composableBuilder(
    column: $table.startSurah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startAyah => $composableBuilder(
    column: $table.startAyah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endSurah => $composableBuilder(
    column: $table.endSurah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endAyah => $composableBuilder(
    column: $table.endAyah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get facesQuarterAchieved => $composableBuilder(
    column: $table.facesQuarterAchieved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evaluation => $composableBuilder(
    column: $table.evaluation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedStartSurah => $composableBuilder(
    column: $table.plannedStartSurah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedStartAyah => $composableBuilder(
    column: $table.plannedStartAyah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedEndSurah => $composableBuilder(
    column: $table.plannedEndSurah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedEndAyah => $composableBuilder(
    column: $table.plannedEndAyah,
    builder: (column) => ColumnOrderings(column),
  );

  $$HalaqahDaysTableOrderingComposer get dayId {
    final $$HalaqahDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.halaqahDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HalaqahDaysTableOrderingComposer(
            $db: $db,
            $table: $db.halaqahDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

class $$RecitationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecitationsTable> {
  $$RecitationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get startSurah => $composableBuilder(
    column: $table.startSurah,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startAyah =>
      $composableBuilder(column: $table.startAyah, builder: (column) => column);

  GeneratedColumn<int> get endSurah =>
      $composableBuilder(column: $table.endSurah, builder: (column) => column);

  GeneratedColumn<int> get endAyah =>
      $composableBuilder(column: $table.endAyah, builder: (column) => column);

  GeneratedColumn<int> get facesQuarterAchieved => $composableBuilder(
    column: $table.facesQuarterAchieved,
    builder: (column) => column,
  );

  GeneratedColumn<String> get evaluation => $composableBuilder(
    column: $table.evaluation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get plannedStartSurah => $composableBuilder(
    column: $table.plannedStartSurah,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedStartAyah => $composableBuilder(
    column: $table.plannedStartAyah,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedEndSurah => $composableBuilder(
    column: $table.plannedEndSurah,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedEndAyah => $composableBuilder(
    column: $table.plannedEndAyah,
    builder: (column) => column,
  );

  $$HalaqahDaysTableAnnotationComposer get dayId {
    final $$HalaqahDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.halaqahDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HalaqahDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.halaqahDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

class $$RecitationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecitationsTable,
          Recitation,
          $$RecitationsTableFilterComposer,
          $$RecitationsTableOrderingComposer,
          $$RecitationsTableAnnotationComposer,
          $$RecitationsTableCreateCompanionBuilder,
          $$RecitationsTableUpdateCompanionBuilder,
          (Recitation, $$RecitationsTableReferences),
          Recitation,
          PrefetchHooks Function({bool dayId, bool studentId})
        > {
  $$RecitationsTableTableManager(_$AppDatabase db, $RecitationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecitationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecitationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecitationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dayId = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> startSurah = const Value.absent(),
                Value<int> startAyah = const Value.absent(),
                Value<int> endSurah = const Value.absent(),
                Value<int> endAyah = const Value.absent(),
                Value<int> facesQuarterAchieved = const Value.absent(),
                Value<String> evaluation = const Value.absent(),
                Value<int> errorCount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> plannedStartSurah = const Value.absent(),
                Value<int?> plannedStartAyah = const Value.absent(),
                Value<int?> plannedEndSurah = const Value.absent(),
                Value<int?> plannedEndAyah = const Value.absent(),
              }) => RecitationsCompanion(
                id: id,
                dayId: dayId,
                studentId: studentId,
                type: type,
                startSurah: startSurah,
                startAyah: startAyah,
                endSurah: endSurah,
                endAyah: endAyah,
                facesQuarterAchieved: facesQuarterAchieved,
                evaluation: evaluation,
                errorCount: errorCount,
                note: note,
                plannedStartSurah: plannedStartSurah,
                plannedStartAyah: plannedStartAyah,
                plannedEndSurah: plannedEndSurah,
                plannedEndAyah: plannedEndAyah,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int dayId,
                required int studentId,
                required String type,
                required int startSurah,
                required int startAyah,
                required int endSurah,
                required int endAyah,
                required int facesQuarterAchieved,
                required String evaluation,
                Value<int> errorCount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> plannedStartSurah = const Value.absent(),
                Value<int?> plannedStartAyah = const Value.absent(),
                Value<int?> plannedEndSurah = const Value.absent(),
                Value<int?> plannedEndAyah = const Value.absent(),
              }) => RecitationsCompanion.insert(
                id: id,
                dayId: dayId,
                studentId: studentId,
                type: type,
                startSurah: startSurah,
                startAyah: startAyah,
                endSurah: endSurah,
                endAyah: endAyah,
                facesQuarterAchieved: facesQuarterAchieved,
                evaluation: evaluation,
                errorCount: errorCount,
                note: note,
                plannedStartSurah: plannedStartSurah,
                plannedStartAyah: plannedStartAyah,
                plannedEndSurah: plannedEndSurah,
                plannedEndAyah: plannedEndAyah,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecitationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dayId = false, studentId = false}) {
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
                    if (dayId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.dayId,
                                referencedTable: $$RecitationsTableReferences
                                    ._dayIdTable(db),
                                referencedColumn: $$RecitationsTableReferences
                                    ._dayIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable: $$RecitationsTableReferences
                                    ._studentIdTable(db),
                                referencedColumn: $$RecitationsTableReferences
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

typedef $$RecitationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecitationsTable,
      Recitation,
      $$RecitationsTableFilterComposer,
      $$RecitationsTableOrderingComposer,
      $$RecitationsTableAnnotationComposer,
      $$RecitationsTableCreateCompanionBuilder,
      $$RecitationsTableUpdateCompanionBuilder,
      (Recitation, $$RecitationsTableReferences),
      Recitation,
      PrefetchHooks Function({bool dayId, bool studentId})
    >;
typedef $$ParentFollowUpsTableCreateCompanionBuilder =
    ParentFollowUpsCompanion Function({
      Value<int> id,
      required int dayId,
      required int studentId,
      required String type,
      Value<String> status,
      Value<int?> correctsFollowUpId,
      Value<String?> attendanceStatusSnapshot,
      Value<String?> snapshotMessage,
      Value<String?> channelSnapshot,
      Value<String?> recipientSnapshot,
    });
typedef $$ParentFollowUpsTableUpdateCompanionBuilder =
    ParentFollowUpsCompanion Function({
      Value<int> id,
      Value<int> dayId,
      Value<int> studentId,
      Value<String> type,
      Value<String> status,
      Value<int?> correctsFollowUpId,
      Value<String?> attendanceStatusSnapshot,
      Value<String?> snapshotMessage,
      Value<String?> channelSnapshot,
      Value<String?> recipientSnapshot,
    });

final class $$ParentFollowUpsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ParentFollowUpsTable, ParentFollowUp> {
  $$ParentFollowUpsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HalaqahDaysTable _dayIdTable(_$AppDatabase db) =>
      db.halaqahDays.createAlias('parent_follow_ups__day_id__halaqah_days__id');

  $$HalaqahDaysTableProcessedTableManager get dayId {
    final $_column = $_itemColumn<int>('day_id')!;

    final manager = $$HalaqahDaysTableTableManager(
      $_db,
      $_db.halaqahDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias('parent_follow_ups__student_id__students__id');

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

  static $ParentFollowUpsTable _correctsFollowUpIdTable(_$AppDatabase db) =>
      db.parentFollowUps.createAlias(
        'parent_follow_ups__corrects_follow_up_id__parent_follow_ups__id',
      );

  $$ParentFollowUpsTableProcessedTableManager? get correctsFollowUpId {
    final $_column = $_itemColumn<int>('corrects_follow_up_id');
    if ($_column == null) return null;
    final manager = $$ParentFollowUpsTableTableManager(
      $_db,
      $_db.parentFollowUps,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_correctsFollowUpIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ParentFollowUpsTableFilterComposer
    extends Composer<_$AppDatabase, $ParentFollowUpsTable> {
  $$ParentFollowUpsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attendanceStatusSnapshot => $composableBuilder(
    column: $table.attendanceStatusSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshotMessage => $composableBuilder(
    column: $table.snapshotMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channelSnapshot => $composableBuilder(
    column: $table.channelSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipientSnapshot => $composableBuilder(
    column: $table.recipientSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  $$HalaqahDaysTableFilterComposer get dayId {
    final $$HalaqahDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.halaqahDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HalaqahDaysTableFilterComposer(
            $db: $db,
            $table: $db.halaqahDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  $$ParentFollowUpsTableFilterComposer get correctsFollowUpId {
    final $$ParentFollowUpsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.correctsFollowUpId,
      referencedTable: $db.parentFollowUps,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParentFollowUpsTableFilterComposer(
            $db: $db,
            $table: $db.parentFollowUps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ParentFollowUpsTableOrderingComposer
    extends Composer<_$AppDatabase, $ParentFollowUpsTable> {
  $$ParentFollowUpsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attendanceStatusSnapshot => $composableBuilder(
    column: $table.attendanceStatusSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshotMessage => $composableBuilder(
    column: $table.snapshotMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channelSnapshot => $composableBuilder(
    column: $table.channelSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipientSnapshot => $composableBuilder(
    column: $table.recipientSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  $$HalaqahDaysTableOrderingComposer get dayId {
    final $$HalaqahDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.halaqahDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HalaqahDaysTableOrderingComposer(
            $db: $db,
            $table: $db.halaqahDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  $$ParentFollowUpsTableOrderingComposer get correctsFollowUpId {
    final $$ParentFollowUpsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.correctsFollowUpId,
      referencedTable: $db.parentFollowUps,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParentFollowUpsTableOrderingComposer(
            $db: $db,
            $table: $db.parentFollowUps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ParentFollowUpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParentFollowUpsTable> {
  $$ParentFollowUpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get attendanceStatusSnapshot => $composableBuilder(
    column: $table.attendanceStatusSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snapshotMessage => $composableBuilder(
    column: $table.snapshotMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get channelSnapshot => $composableBuilder(
    column: $table.channelSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recipientSnapshot => $composableBuilder(
    column: $table.recipientSnapshot,
    builder: (column) => column,
  );

  $$HalaqahDaysTableAnnotationComposer get dayId {
    final $$HalaqahDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.halaqahDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HalaqahDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.halaqahDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  $$ParentFollowUpsTableAnnotationComposer get correctsFollowUpId {
    final $$ParentFollowUpsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.correctsFollowUpId,
      referencedTable: $db.parentFollowUps,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParentFollowUpsTableAnnotationComposer(
            $db: $db,
            $table: $db.parentFollowUps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ParentFollowUpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ParentFollowUpsTable,
          ParentFollowUp,
          $$ParentFollowUpsTableFilterComposer,
          $$ParentFollowUpsTableOrderingComposer,
          $$ParentFollowUpsTableAnnotationComposer,
          $$ParentFollowUpsTableCreateCompanionBuilder,
          $$ParentFollowUpsTableUpdateCompanionBuilder,
          (ParentFollowUp, $$ParentFollowUpsTableReferences),
          ParentFollowUp,
          PrefetchHooks Function({
            bool dayId,
            bool studentId,
            bool correctsFollowUpId,
          })
        > {
  $$ParentFollowUpsTableTableManager(
    _$AppDatabase db,
    $ParentFollowUpsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParentFollowUpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParentFollowUpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParentFollowUpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dayId = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> correctsFollowUpId = const Value.absent(),
                Value<String?> attendanceStatusSnapshot = const Value.absent(),
                Value<String?> snapshotMessage = const Value.absent(),
                Value<String?> channelSnapshot = const Value.absent(),
                Value<String?> recipientSnapshot = const Value.absent(),
              }) => ParentFollowUpsCompanion(
                id: id,
                dayId: dayId,
                studentId: studentId,
                type: type,
                status: status,
                correctsFollowUpId: correctsFollowUpId,
                attendanceStatusSnapshot: attendanceStatusSnapshot,
                snapshotMessage: snapshotMessage,
                channelSnapshot: channelSnapshot,
                recipientSnapshot: recipientSnapshot,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int dayId,
                required int studentId,
                required String type,
                Value<String> status = const Value.absent(),
                Value<int?> correctsFollowUpId = const Value.absent(),
                Value<String?> attendanceStatusSnapshot = const Value.absent(),
                Value<String?> snapshotMessage = const Value.absent(),
                Value<String?> channelSnapshot = const Value.absent(),
                Value<String?> recipientSnapshot = const Value.absent(),
              }) => ParentFollowUpsCompanion.insert(
                id: id,
                dayId: dayId,
                studentId: studentId,
                type: type,
                status: status,
                correctsFollowUpId: correctsFollowUpId,
                attendanceStatusSnapshot: attendanceStatusSnapshot,
                snapshotMessage: snapshotMessage,
                channelSnapshot: channelSnapshot,
                recipientSnapshot: recipientSnapshot,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ParentFollowUpsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({dayId = false, studentId = false, correctsFollowUpId = false}) {
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
                        if (dayId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.dayId,
                                    referencedTable:
                                        $$ParentFollowUpsTableReferences
                                            ._dayIdTable(db),
                                    referencedColumn:
                                        $$ParentFollowUpsTableReferences
                                            ._dayIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (studentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.studentId,
                                    referencedTable:
                                        $$ParentFollowUpsTableReferences
                                            ._studentIdTable(db),
                                    referencedColumn:
                                        $$ParentFollowUpsTableReferences
                                            ._studentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (correctsFollowUpId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.correctsFollowUpId,
                                    referencedTable:
                                        $$ParentFollowUpsTableReferences
                                            ._correctsFollowUpIdTable(db),
                                    referencedColumn:
                                        $$ParentFollowUpsTableReferences
                                            ._correctsFollowUpIdTable(db)
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

typedef $$ParentFollowUpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ParentFollowUpsTable,
      ParentFollowUp,
      $$ParentFollowUpsTableFilterComposer,
      $$ParentFollowUpsTableOrderingComposer,
      $$ParentFollowUpsTableAnnotationComposer,
      $$ParentFollowUpsTableCreateCompanionBuilder,
      $$ParentFollowUpsTableUpdateCompanionBuilder,
      (ParentFollowUp, $$ParentFollowUpsTableReferences),
      ParentFollowUp,
      PrefetchHooks Function({
        bool dayId,
        bool studentId,
        bool correctsFollowUpId,
      })
    >;
typedef $$SupportWeeklyReportsTableCreateCompanionBuilder =
    SupportWeeklyReportsCompanion Function({
      Value<int> id,
      required int halaqahId,
      required String weekStartDate,
      required String weekEndDate,
      required String status,
      required String teacherNameSnapshot,
      required String halaqahNameSnapshot,
      required String organizationNameSnapshot,
      required int policyVersion,
      required int templateVersion,
      Value<String?> sourceFingerprint,
      Value<DateTime?> approvedAtUtc,
    });
typedef $$SupportWeeklyReportsTableUpdateCompanionBuilder =
    SupportWeeklyReportsCompanion Function({
      Value<int> id,
      Value<int> halaqahId,
      Value<String> weekStartDate,
      Value<String> weekEndDate,
      Value<String> status,
      Value<String> teacherNameSnapshot,
      Value<String> halaqahNameSnapshot,
      Value<String> organizationNameSnapshot,
      Value<int> policyVersion,
      Value<int> templateVersion,
      Value<String?> sourceFingerprint,
      Value<DateTime?> approvedAtUtc,
    });

final class $$SupportWeeklyReportsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SupportWeeklyReportsTable,
          SupportWeeklyReport
        > {
  $$SupportWeeklyReportsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HalaqahsTable _halaqahIdTable(_$AppDatabase db) => db.halaqahs
      .createAlias('support_weekly_reports__halaqah_id__halaqahs__id');

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
    $SupportWeeklyReportStudentsTable,
    List<SupportWeeklyReportStudent>
  >
  _supportWeeklyReportStudentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.supportWeeklyReportStudents,
    aliasName:
        'support_weekly_reports__id__support_weekly_report_students__report_id',
  );

  $$SupportWeeklyReportStudentsTableProcessedTableManager
  get supportWeeklyReportStudentsRefs {
    final manager = $$SupportWeeklyReportStudentsTableTableManager(
      $_db,
      $_db.supportWeeklyReportStudents,
    ).filter((f) => f.reportId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supportWeeklyReportStudentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SupportWeeklyReportDaysTable,
    List<SupportWeeklyReportDay>
  >
  _supportWeeklyReportDaysRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.supportWeeklyReportDays,
        aliasName:
            'support_weekly_reports__id__support_weekly_report_days__report_id',
      );

  $$SupportWeeklyReportDaysTableProcessedTableManager
  get supportWeeklyReportDaysRefs {
    final manager = $$SupportWeeklyReportDaysTableTableManager(
      $_db,
      $_db.supportWeeklyReportDays,
    ).filter((f) => f.reportId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supportWeeklyReportDaysRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SupportWeeklyReportsTableFilterComposer
    extends Composer<_$AppDatabase, $SupportWeeklyReportsTable> {
  $$SupportWeeklyReportsTableFilterComposer({
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

  ColumnFilters<String> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekEndDate => $composableBuilder(
    column: $table.weekEndDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherNameSnapshot => $composableBuilder(
    column: $table.teacherNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get halaqahNameSnapshot => $composableBuilder(
    column: $table.halaqahNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organizationNameSnapshot => $composableBuilder(
    column: $table.organizationNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get policyVersion => $composableBuilder(
    column: $table.policyVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get templateVersion => $composableBuilder(
    column: $table.templateVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFingerprint => $composableBuilder(
    column: $table.sourceFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get approvedAtUtc => $composableBuilder(
    column: $table.approvedAtUtc,
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

  Expression<bool> supportWeeklyReportStudentsRefs(
    Expression<bool> Function(
      $$SupportWeeklyReportStudentsTableFilterComposer f,
    )
    f,
  ) {
    final $$SupportWeeklyReportStudentsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportWeeklyReportStudents,
          getReferencedColumn: (t) => t.reportId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportStudentsTableFilterComposer(
                $db: $db,
                $table: $db.supportWeeklyReportStudents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> supportWeeklyReportDaysRefs(
    Expression<bool> Function($$SupportWeeklyReportDaysTableFilterComposer f) f,
  ) {
    final $$SupportWeeklyReportDaysTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportWeeklyReportDays,
          getReferencedColumn: (t) => t.reportId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportDaysTableFilterComposer(
                $db: $db,
                $table: $db.supportWeeklyReportDays,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SupportWeeklyReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupportWeeklyReportsTable> {
  $$SupportWeeklyReportsTableOrderingComposer({
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

  ColumnOrderings<String> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekEndDate => $composableBuilder(
    column: $table.weekEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherNameSnapshot => $composableBuilder(
    column: $table.teacherNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get halaqahNameSnapshot => $composableBuilder(
    column: $table.halaqahNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organizationNameSnapshot => $composableBuilder(
    column: $table.organizationNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get policyVersion => $composableBuilder(
    column: $table.policyVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get templateVersion => $composableBuilder(
    column: $table.templateVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFingerprint => $composableBuilder(
    column: $table.sourceFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get approvedAtUtc => $composableBuilder(
    column: $table.approvedAtUtc,
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

class $$SupportWeeklyReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupportWeeklyReportsTable> {
  $$SupportWeeklyReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weekEndDate => $composableBuilder(
    column: $table.weekEndDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get teacherNameSnapshot => $composableBuilder(
    column: $table.teacherNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get halaqahNameSnapshot => $composableBuilder(
    column: $table.halaqahNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get organizationNameSnapshot => $composableBuilder(
    column: $table.organizationNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get policyVersion => $composableBuilder(
    column: $table.policyVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get templateVersion => $composableBuilder(
    column: $table.templateVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceFingerprint => $composableBuilder(
    column: $table.sourceFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get approvedAtUtc => $composableBuilder(
    column: $table.approvedAtUtc,
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

  Expression<T> supportWeeklyReportStudentsRefs<T extends Object>(
    Expression<T> Function(
      $$SupportWeeklyReportStudentsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$SupportWeeklyReportStudentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportWeeklyReportStudents,
          getReferencedColumn: (t) => t.reportId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportStudentsTableAnnotationComposer(
                $db: $db,
                $table: $db.supportWeeklyReportStudents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> supportWeeklyReportDaysRefs<T extends Object>(
    Expression<T> Function($$SupportWeeklyReportDaysTableAnnotationComposer a)
    f,
  ) {
    final $$SupportWeeklyReportDaysTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportWeeklyReportDays,
          getReferencedColumn: (t) => t.reportId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportDaysTableAnnotationComposer(
                $db: $db,
                $table: $db.supportWeeklyReportDays,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SupportWeeklyReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupportWeeklyReportsTable,
          SupportWeeklyReport,
          $$SupportWeeklyReportsTableFilterComposer,
          $$SupportWeeklyReportsTableOrderingComposer,
          $$SupportWeeklyReportsTableAnnotationComposer,
          $$SupportWeeklyReportsTableCreateCompanionBuilder,
          $$SupportWeeklyReportsTableUpdateCompanionBuilder,
          (SupportWeeklyReport, $$SupportWeeklyReportsTableReferences),
          SupportWeeklyReport,
          PrefetchHooks Function({
            bool halaqahId,
            bool supportWeeklyReportStudentsRefs,
            bool supportWeeklyReportDaysRefs,
          })
        > {
  $$SupportWeeklyReportsTableTableManager(
    _$AppDatabase db,
    $SupportWeeklyReportsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupportWeeklyReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupportWeeklyReportsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SupportWeeklyReportsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> halaqahId = const Value.absent(),
                Value<String> weekStartDate = const Value.absent(),
                Value<String> weekEndDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> teacherNameSnapshot = const Value.absent(),
                Value<String> halaqahNameSnapshot = const Value.absent(),
                Value<String> organizationNameSnapshot = const Value.absent(),
                Value<int> policyVersion = const Value.absent(),
                Value<int> templateVersion = const Value.absent(),
                Value<String?> sourceFingerprint = const Value.absent(),
                Value<DateTime?> approvedAtUtc = const Value.absent(),
              }) => SupportWeeklyReportsCompanion(
                id: id,
                halaqahId: halaqahId,
                weekStartDate: weekStartDate,
                weekEndDate: weekEndDate,
                status: status,
                teacherNameSnapshot: teacherNameSnapshot,
                halaqahNameSnapshot: halaqahNameSnapshot,
                organizationNameSnapshot: organizationNameSnapshot,
                policyVersion: policyVersion,
                templateVersion: templateVersion,
                sourceFingerprint: sourceFingerprint,
                approvedAtUtc: approvedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int halaqahId,
                required String weekStartDate,
                required String weekEndDate,
                required String status,
                required String teacherNameSnapshot,
                required String halaqahNameSnapshot,
                required String organizationNameSnapshot,
                required int policyVersion,
                required int templateVersion,
                Value<String?> sourceFingerprint = const Value.absent(),
                Value<DateTime?> approvedAtUtc = const Value.absent(),
              }) => SupportWeeklyReportsCompanion.insert(
                id: id,
                halaqahId: halaqahId,
                weekStartDate: weekStartDate,
                weekEndDate: weekEndDate,
                status: status,
                teacherNameSnapshot: teacherNameSnapshot,
                halaqahNameSnapshot: halaqahNameSnapshot,
                organizationNameSnapshot: organizationNameSnapshot,
                policyVersion: policyVersion,
                templateVersion: templateVersion,
                sourceFingerprint: sourceFingerprint,
                approvedAtUtc: approvedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SupportWeeklyReportsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                halaqahId = false,
                supportWeeklyReportStudentsRefs = false,
                supportWeeklyReportDaysRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (supportWeeklyReportStudentsRefs)
                      db.supportWeeklyReportStudents,
                    if (supportWeeklyReportDaysRefs) db.supportWeeklyReportDays,
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
                                    referencedTable:
                                        $$SupportWeeklyReportsTableReferences
                                            ._halaqahIdTable(db),
                                    referencedColumn:
                                        $$SupportWeeklyReportsTableReferences
                                            ._halaqahIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (supportWeeklyReportStudentsRefs)
                        await $_getPrefetchedData<
                          SupportWeeklyReport,
                          $SupportWeeklyReportsTable,
                          SupportWeeklyReportStudent
                        >(
                          currentTable: table,
                          referencedTable: $$SupportWeeklyReportsTableReferences
                              ._supportWeeklyReportStudentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SupportWeeklyReportsTableReferences(
                                db,
                                table,
                                p0,
                              ).supportWeeklyReportStudentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.reportId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supportWeeklyReportDaysRefs)
                        await $_getPrefetchedData<
                          SupportWeeklyReport,
                          $SupportWeeklyReportsTable,
                          SupportWeeklyReportDay
                        >(
                          currentTable: table,
                          referencedTable: $$SupportWeeklyReportsTableReferences
                              ._supportWeeklyReportDaysRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SupportWeeklyReportsTableReferences(
                                db,
                                table,
                                p0,
                              ).supportWeeklyReportDaysRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.reportId == item.id,
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

typedef $$SupportWeeklyReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupportWeeklyReportsTable,
      SupportWeeklyReport,
      $$SupportWeeklyReportsTableFilterComposer,
      $$SupportWeeklyReportsTableOrderingComposer,
      $$SupportWeeklyReportsTableAnnotationComposer,
      $$SupportWeeklyReportsTableCreateCompanionBuilder,
      $$SupportWeeklyReportsTableUpdateCompanionBuilder,
      (SupportWeeklyReport, $$SupportWeeklyReportsTableReferences),
      SupportWeeklyReport,
      PrefetchHooks Function({
        bool halaqahId,
        bool supportWeeklyReportStudentsRefs,
        bool supportWeeklyReportDaysRefs,
      })
    >;
typedef $$SupportWeeklyReportStudentsTableCreateCompanionBuilder =
    SupportWeeklyReportStudentsCompanion Function({
      Value<int> id,
      required int reportId,
      required int sourceStudentId,
      Value<String?> supportStudentNumberSnapshot,
      required String studentNameSnapshot,
      Value<int?> currentJuzSnapshot,
      Value<String?> dailyPlanTextSnapshot,
      required int monthlyGoalQuarterFacesSnapshot,
      Value<String?> studentNoteSnapshot,
      required int displayOrderSnapshot,
    });
typedef $$SupportWeeklyReportStudentsTableUpdateCompanionBuilder =
    SupportWeeklyReportStudentsCompanion Function({
      Value<int> id,
      Value<int> reportId,
      Value<int> sourceStudentId,
      Value<String?> supportStudentNumberSnapshot,
      Value<String> studentNameSnapshot,
      Value<int?> currentJuzSnapshot,
      Value<String?> dailyPlanTextSnapshot,
      Value<int> monthlyGoalQuarterFacesSnapshot,
      Value<String?> studentNoteSnapshot,
      Value<int> displayOrderSnapshot,
    });

final class $$SupportWeeklyReportStudentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SupportWeeklyReportStudentsTable,
          SupportWeeklyReportStudent
        > {
  $$SupportWeeklyReportStudentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SupportWeeklyReportsTable _reportIdTable(_$AppDatabase db) =>
      db.supportWeeklyReports.createAlias(
        'support_weekly_report_students__report_id__support_weekly_reports__id',
      );

  $$SupportWeeklyReportsTableProcessedTableManager get reportId {
    final $_column = $_itemColumn<int>('report_id')!;

    final manager = $$SupportWeeklyReportsTableTableManager(
      $_db,
      $_db.supportWeeklyReports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reportIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudentsTable _sourceStudentIdTable(_$AppDatabase db) =>
      db.students.createAlias(
        'support_weekly_report_students__source_student_id__students__id',
      );

  $$StudentsTableProcessedTableManager get sourceStudentId {
    final $_column = $_itemColumn<int>('source_student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceStudentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $SupportWeeklyReportDayEntriesTable,
    List<SupportWeeklyReportDayEntry>
  >
  _supportWeeklyReportDayEntriesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.supportWeeklyReportDayEntries,
    aliasName:
        'support_weekly_report_students__id__support_weekly_report_day_entries__report_student_id',
  );

  $$SupportWeeklyReportDayEntriesTableProcessedTableManager
  get supportWeeklyReportDayEntriesRefs {
    final manager = $$SupportWeeklyReportDayEntriesTableTableManager(
      $_db,
      $_db.supportWeeklyReportDayEntries,
    ).filter((f) => f.reportStudentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supportWeeklyReportDayEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SupportWeeklyReportStudentsTableFilterComposer
    extends Composer<_$AppDatabase, $SupportWeeklyReportStudentsTable> {
  $$SupportWeeklyReportStudentsTableFilterComposer({
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

  ColumnFilters<String> get supportStudentNumberSnapshot => $composableBuilder(
    column: $table.supportStudentNumberSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentNameSnapshot => $composableBuilder(
    column: $table.studentNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentJuzSnapshot => $composableBuilder(
    column: $table.currentJuzSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dailyPlanTextSnapshot => $composableBuilder(
    column: $table.dailyPlanTextSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyGoalQuarterFacesSnapshot => $composableBuilder(
    column: $table.monthlyGoalQuarterFacesSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentNoteSnapshot => $composableBuilder(
    column: $table.studentNoteSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayOrderSnapshot => $composableBuilder(
    column: $table.displayOrderSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  $$SupportWeeklyReportsTableFilterComposer get reportId {
    final $$SupportWeeklyReportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reportId,
      referencedTable: $db.supportWeeklyReports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupportWeeklyReportsTableFilterComposer(
            $db: $db,
            $table: $db.supportWeeklyReports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableFilterComposer get sourceStudentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceStudentId,
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

  Expression<bool> supportWeeklyReportDayEntriesRefs(
    Expression<bool> Function(
      $$SupportWeeklyReportDayEntriesTableFilterComposer f,
    )
    f,
  ) {
    final $$SupportWeeklyReportDayEntriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportWeeklyReportDayEntries,
          getReferencedColumn: (t) => t.reportStudentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportDayEntriesTableFilterComposer(
                $db: $db,
                $table: $db.supportWeeklyReportDayEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SupportWeeklyReportStudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupportWeeklyReportStudentsTable> {
  $$SupportWeeklyReportStudentsTableOrderingComposer({
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

  ColumnOrderings<String> get supportStudentNumberSnapshot =>
      $composableBuilder(
        column: $table.supportStudentNumberSnapshot,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get studentNameSnapshot => $composableBuilder(
    column: $table.studentNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentJuzSnapshot => $composableBuilder(
    column: $table.currentJuzSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dailyPlanTextSnapshot => $composableBuilder(
    column: $table.dailyPlanTextSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyGoalQuarterFacesSnapshot =>
      $composableBuilder(
        column: $table.monthlyGoalQuarterFacesSnapshot,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get studentNoteSnapshot => $composableBuilder(
    column: $table.studentNoteSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayOrderSnapshot => $composableBuilder(
    column: $table.displayOrderSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  $$SupportWeeklyReportsTableOrderingComposer get reportId {
    final $$SupportWeeklyReportsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.reportId,
          referencedTable: $db.supportWeeklyReports,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportsTableOrderingComposer(
                $db: $db,
                $table: $db.supportWeeklyReports,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$StudentsTableOrderingComposer get sourceStudentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceStudentId,
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

class $$SupportWeeklyReportStudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupportWeeklyReportStudentsTable> {
  $$SupportWeeklyReportStudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get supportStudentNumberSnapshot =>
      $composableBuilder(
        column: $table.supportStudentNumberSnapshot,
        builder: (column) => column,
      );

  GeneratedColumn<String> get studentNameSnapshot => $composableBuilder(
    column: $table.studentNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentJuzSnapshot => $composableBuilder(
    column: $table.currentJuzSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dailyPlanTextSnapshot => $composableBuilder(
    column: $table.dailyPlanTextSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monthlyGoalQuarterFacesSnapshot =>
      $composableBuilder(
        column: $table.monthlyGoalQuarterFacesSnapshot,
        builder: (column) => column,
      );

  GeneratedColumn<String> get studentNoteSnapshot => $composableBuilder(
    column: $table.studentNoteSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get displayOrderSnapshot => $composableBuilder(
    column: $table.displayOrderSnapshot,
    builder: (column) => column,
  );

  $$SupportWeeklyReportsTableAnnotationComposer get reportId {
    final $$SupportWeeklyReportsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.reportId,
          referencedTable: $db.supportWeeklyReports,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportsTableAnnotationComposer(
                $db: $db,
                $table: $db.supportWeeklyReports,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$StudentsTableAnnotationComposer get sourceStudentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceStudentId,
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

  Expression<T> supportWeeklyReportDayEntriesRefs<T extends Object>(
    Expression<T> Function(
      $$SupportWeeklyReportDayEntriesTableAnnotationComposer a,
    )
    f,
  ) {
    final $$SupportWeeklyReportDayEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportWeeklyReportDayEntries,
          getReferencedColumn: (t) => t.reportStudentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportDayEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.supportWeeklyReportDayEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SupportWeeklyReportStudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupportWeeklyReportStudentsTable,
          SupportWeeklyReportStudent,
          $$SupportWeeklyReportStudentsTableFilterComposer,
          $$SupportWeeklyReportStudentsTableOrderingComposer,
          $$SupportWeeklyReportStudentsTableAnnotationComposer,
          $$SupportWeeklyReportStudentsTableCreateCompanionBuilder,
          $$SupportWeeklyReportStudentsTableUpdateCompanionBuilder,
          (
            SupportWeeklyReportStudent,
            $$SupportWeeklyReportStudentsTableReferences,
          ),
          SupportWeeklyReportStudent,
          PrefetchHooks Function({
            bool reportId,
            bool sourceStudentId,
            bool supportWeeklyReportDayEntriesRefs,
          })
        > {
  $$SupportWeeklyReportStudentsTableTableManager(
    _$AppDatabase db,
    $SupportWeeklyReportStudentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupportWeeklyReportStudentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SupportWeeklyReportStudentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SupportWeeklyReportStudentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> reportId = const Value.absent(),
                Value<int> sourceStudentId = const Value.absent(),
                Value<String?> supportStudentNumberSnapshot =
                    const Value.absent(),
                Value<String> studentNameSnapshot = const Value.absent(),
                Value<int?> currentJuzSnapshot = const Value.absent(),
                Value<String?> dailyPlanTextSnapshot = const Value.absent(),
                Value<int> monthlyGoalQuarterFacesSnapshot =
                    const Value.absent(),
                Value<String?> studentNoteSnapshot = const Value.absent(),
                Value<int> displayOrderSnapshot = const Value.absent(),
              }) => SupportWeeklyReportStudentsCompanion(
                id: id,
                reportId: reportId,
                sourceStudentId: sourceStudentId,
                supportStudentNumberSnapshot: supportStudentNumberSnapshot,
                studentNameSnapshot: studentNameSnapshot,
                currentJuzSnapshot: currentJuzSnapshot,
                dailyPlanTextSnapshot: dailyPlanTextSnapshot,
                monthlyGoalQuarterFacesSnapshot:
                    monthlyGoalQuarterFacesSnapshot,
                studentNoteSnapshot: studentNoteSnapshot,
                displayOrderSnapshot: displayOrderSnapshot,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int reportId,
                required int sourceStudentId,
                Value<String?> supportStudentNumberSnapshot =
                    const Value.absent(),
                required String studentNameSnapshot,
                Value<int?> currentJuzSnapshot = const Value.absent(),
                Value<String?> dailyPlanTextSnapshot = const Value.absent(),
                required int monthlyGoalQuarterFacesSnapshot,
                Value<String?> studentNoteSnapshot = const Value.absent(),
                required int displayOrderSnapshot,
              }) => SupportWeeklyReportStudentsCompanion.insert(
                id: id,
                reportId: reportId,
                sourceStudentId: sourceStudentId,
                supportStudentNumberSnapshot: supportStudentNumberSnapshot,
                studentNameSnapshot: studentNameSnapshot,
                currentJuzSnapshot: currentJuzSnapshot,
                dailyPlanTextSnapshot: dailyPlanTextSnapshot,
                monthlyGoalQuarterFacesSnapshot:
                    monthlyGoalQuarterFacesSnapshot,
                studentNoteSnapshot: studentNoteSnapshot,
                displayOrderSnapshot: displayOrderSnapshot,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SupportWeeklyReportStudentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                reportId = false,
                sourceStudentId = false,
                supportWeeklyReportDayEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (supportWeeklyReportDayEntriesRefs)
                      db.supportWeeklyReportDayEntries,
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
                        if (reportId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.reportId,
                                    referencedTable:
                                        $$SupportWeeklyReportStudentsTableReferences
                                            ._reportIdTable(db),
                                    referencedColumn:
                                        $$SupportWeeklyReportStudentsTableReferences
                                            ._reportIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sourceStudentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceStudentId,
                                    referencedTable:
                                        $$SupportWeeklyReportStudentsTableReferences
                                            ._sourceStudentIdTable(db),
                                    referencedColumn:
                                        $$SupportWeeklyReportStudentsTableReferences
                                            ._sourceStudentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (supportWeeklyReportDayEntriesRefs)
                        await $_getPrefetchedData<
                          SupportWeeklyReportStudent,
                          $SupportWeeklyReportStudentsTable,
                          SupportWeeklyReportDayEntry
                        >(
                          currentTable: table,
                          referencedTable:
                              $$SupportWeeklyReportStudentsTableReferences
                                  ._supportWeeklyReportDayEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SupportWeeklyReportStudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).supportWeeklyReportDayEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.reportStudentId == item.id,
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

typedef $$SupportWeeklyReportStudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupportWeeklyReportStudentsTable,
      SupportWeeklyReportStudent,
      $$SupportWeeklyReportStudentsTableFilterComposer,
      $$SupportWeeklyReportStudentsTableOrderingComposer,
      $$SupportWeeklyReportStudentsTableAnnotationComposer,
      $$SupportWeeklyReportStudentsTableCreateCompanionBuilder,
      $$SupportWeeklyReportStudentsTableUpdateCompanionBuilder,
      (
        SupportWeeklyReportStudent,
        $$SupportWeeklyReportStudentsTableReferences,
      ),
      SupportWeeklyReportStudent,
      PrefetchHooks Function({
        bool reportId,
        bool sourceStudentId,
        bool supportWeeklyReportDayEntriesRefs,
      })
    >;
typedef $$SupportWeeklyReportDaysTableCreateCompanionBuilder =
    SupportWeeklyReportDaysCompanion Function({
      Value<int> id,
      required int reportId,
      required String dayDate,
      required String dayKind,
    });
typedef $$SupportWeeklyReportDaysTableUpdateCompanionBuilder =
    SupportWeeklyReportDaysCompanion Function({
      Value<int> id,
      Value<int> reportId,
      Value<String> dayDate,
      Value<String> dayKind,
    });

final class $$SupportWeeklyReportDaysTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SupportWeeklyReportDaysTable,
          SupportWeeklyReportDay
        > {
  $$SupportWeeklyReportDaysTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SupportWeeklyReportsTable _reportIdTable(_$AppDatabase db) =>
      db.supportWeeklyReports.createAlias(
        'support_weekly_report_days__report_id__support_weekly_reports__id',
      );

  $$SupportWeeklyReportsTableProcessedTableManager get reportId {
    final $_column = $_itemColumn<int>('report_id')!;

    final manager = $$SupportWeeklyReportsTableTableManager(
      $_db,
      $_db.supportWeeklyReports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reportIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $SupportWeeklyReportDayEntriesTable,
    List<SupportWeeklyReportDayEntry>
  >
  _supportWeeklyReportDayEntriesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.supportWeeklyReportDayEntries,
    aliasName:
        'support_weekly_report_days__id__support_weekly_report_day_entries__report_day_id',
  );

  $$SupportWeeklyReportDayEntriesTableProcessedTableManager
  get supportWeeklyReportDayEntriesRefs {
    final manager = $$SupportWeeklyReportDayEntriesTableTableManager(
      $_db,
      $_db.supportWeeklyReportDayEntries,
    ).filter((f) => f.reportDayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supportWeeklyReportDayEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SupportWeeklyReportDaysTableFilterComposer
    extends Composer<_$AppDatabase, $SupportWeeklyReportDaysTable> {
  $$SupportWeeklyReportDaysTableFilterComposer({
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

  ColumnFilters<String> get dayDate => $composableBuilder(
    column: $table.dayDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayKind => $composableBuilder(
    column: $table.dayKind,
    builder: (column) => ColumnFilters(column),
  );

  $$SupportWeeklyReportsTableFilterComposer get reportId {
    final $$SupportWeeklyReportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reportId,
      referencedTable: $db.supportWeeklyReports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupportWeeklyReportsTableFilterComposer(
            $db: $db,
            $table: $db.supportWeeklyReports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> supportWeeklyReportDayEntriesRefs(
    Expression<bool> Function(
      $$SupportWeeklyReportDayEntriesTableFilterComposer f,
    )
    f,
  ) {
    final $$SupportWeeklyReportDayEntriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportWeeklyReportDayEntries,
          getReferencedColumn: (t) => t.reportDayId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportDayEntriesTableFilterComposer(
                $db: $db,
                $table: $db.supportWeeklyReportDayEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SupportWeeklyReportDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $SupportWeeklyReportDaysTable> {
  $$SupportWeeklyReportDaysTableOrderingComposer({
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

  ColumnOrderings<String> get dayDate => $composableBuilder(
    column: $table.dayDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayKind => $composableBuilder(
    column: $table.dayKind,
    builder: (column) => ColumnOrderings(column),
  );

  $$SupportWeeklyReportsTableOrderingComposer get reportId {
    final $$SupportWeeklyReportsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.reportId,
          referencedTable: $db.supportWeeklyReports,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportsTableOrderingComposer(
                $db: $db,
                $table: $db.supportWeeklyReports,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SupportWeeklyReportDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupportWeeklyReportDaysTable> {
  $$SupportWeeklyReportDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dayDate =>
      $composableBuilder(column: $table.dayDate, builder: (column) => column);

  GeneratedColumn<String> get dayKind =>
      $composableBuilder(column: $table.dayKind, builder: (column) => column);

  $$SupportWeeklyReportsTableAnnotationComposer get reportId {
    final $$SupportWeeklyReportsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.reportId,
          referencedTable: $db.supportWeeklyReports,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportsTableAnnotationComposer(
                $db: $db,
                $table: $db.supportWeeklyReports,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> supportWeeklyReportDayEntriesRefs<T extends Object>(
    Expression<T> Function(
      $$SupportWeeklyReportDayEntriesTableAnnotationComposer a,
    )
    f,
  ) {
    final $$SupportWeeklyReportDayEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportWeeklyReportDayEntries,
          getReferencedColumn: (t) => t.reportDayId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportDayEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.supportWeeklyReportDayEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SupportWeeklyReportDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupportWeeklyReportDaysTable,
          SupportWeeklyReportDay,
          $$SupportWeeklyReportDaysTableFilterComposer,
          $$SupportWeeklyReportDaysTableOrderingComposer,
          $$SupportWeeklyReportDaysTableAnnotationComposer,
          $$SupportWeeklyReportDaysTableCreateCompanionBuilder,
          $$SupportWeeklyReportDaysTableUpdateCompanionBuilder,
          (SupportWeeklyReportDay, $$SupportWeeklyReportDaysTableReferences),
          SupportWeeklyReportDay,
          PrefetchHooks Function({
            bool reportId,
            bool supportWeeklyReportDayEntriesRefs,
          })
        > {
  $$SupportWeeklyReportDaysTableTableManager(
    _$AppDatabase db,
    $SupportWeeklyReportDaysTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupportWeeklyReportDaysTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SupportWeeklyReportDaysTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SupportWeeklyReportDaysTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> reportId = const Value.absent(),
                Value<String> dayDate = const Value.absent(),
                Value<String> dayKind = const Value.absent(),
              }) => SupportWeeklyReportDaysCompanion(
                id: id,
                reportId: reportId,
                dayDate: dayDate,
                dayKind: dayKind,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int reportId,
                required String dayDate,
                required String dayKind,
              }) => SupportWeeklyReportDaysCompanion.insert(
                id: id,
                reportId: reportId,
                dayDate: dayDate,
                dayKind: dayKind,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SupportWeeklyReportDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({reportId = false, supportWeeklyReportDayEntriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (supportWeeklyReportDayEntriesRefs)
                      db.supportWeeklyReportDayEntries,
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
                        if (reportId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.reportId,
                                    referencedTable:
                                        $$SupportWeeklyReportDaysTableReferences
                                            ._reportIdTable(db),
                                    referencedColumn:
                                        $$SupportWeeklyReportDaysTableReferences
                                            ._reportIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (supportWeeklyReportDayEntriesRefs)
                        await $_getPrefetchedData<
                          SupportWeeklyReportDay,
                          $SupportWeeklyReportDaysTable,
                          SupportWeeklyReportDayEntry
                        >(
                          currentTable: table,
                          referencedTable:
                              $$SupportWeeklyReportDaysTableReferences
                                  ._supportWeeklyReportDayEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SupportWeeklyReportDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).supportWeeklyReportDayEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.reportDayId == item.id,
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

typedef $$SupportWeeklyReportDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupportWeeklyReportDaysTable,
      SupportWeeklyReportDay,
      $$SupportWeeklyReportDaysTableFilterComposer,
      $$SupportWeeklyReportDaysTableOrderingComposer,
      $$SupportWeeklyReportDaysTableAnnotationComposer,
      $$SupportWeeklyReportDaysTableCreateCompanionBuilder,
      $$SupportWeeklyReportDaysTableUpdateCompanionBuilder,
      (SupportWeeklyReportDay, $$SupportWeeklyReportDaysTableReferences),
      SupportWeeklyReportDay,
      PrefetchHooks Function({
        bool reportId,
        bool supportWeeklyReportDayEntriesRefs,
      })
    >;
typedef $$SupportWeeklyReportDayEntriesTableCreateCompanionBuilder =
    SupportWeeklyReportDayEntriesCompanion Function({
      Value<int> id,
      required int reportDayId,
      required int reportStudentId,
      Value<String?> attendanceStatusSnapshot,
      Value<int> achievedQuarterFaces,
      Value<int?> startSurahSnapshot,
      Value<int?> startAyahSnapshot,
      Value<int?> endSurahSnapshot,
      Value<int?> endAyahSnapshot,
      Value<String?> noteSnapshot,
      required int entryOrder,
    });
typedef $$SupportWeeklyReportDayEntriesTableUpdateCompanionBuilder =
    SupportWeeklyReportDayEntriesCompanion Function({
      Value<int> id,
      Value<int> reportDayId,
      Value<int> reportStudentId,
      Value<String?> attendanceStatusSnapshot,
      Value<int> achievedQuarterFaces,
      Value<int?> startSurahSnapshot,
      Value<int?> startAyahSnapshot,
      Value<int?> endSurahSnapshot,
      Value<int?> endAyahSnapshot,
      Value<String?> noteSnapshot,
      Value<int> entryOrder,
    });

final class $$SupportWeeklyReportDayEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SupportWeeklyReportDayEntriesTable,
          SupportWeeklyReportDayEntry
        > {
  $$SupportWeeklyReportDayEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SupportWeeklyReportDaysTable _reportDayIdTable(
    _$AppDatabase db,
  ) => db.supportWeeklyReportDays.createAlias(
    'support_weekly_report_day_entries__report_day_id__support_weekly_report_days__id',
  );

  $$SupportWeeklyReportDaysTableProcessedTableManager get reportDayId {
    final $_column = $_itemColumn<int>('report_day_id')!;

    final manager = $$SupportWeeklyReportDaysTableTableManager(
      $_db,
      $_db.supportWeeklyReportDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reportDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SupportWeeklyReportStudentsTable _reportStudentIdTable(
    _$AppDatabase db,
  ) => db.supportWeeklyReportStudents.createAlias(
    'support_weekly_report_day_entries__report_student_id__support_weekly_report_students__id',
  );

  $$SupportWeeklyReportStudentsTableProcessedTableManager get reportStudentId {
    final $_column = $_itemColumn<int>('report_student_id')!;

    final manager = $$SupportWeeklyReportStudentsTableTableManager(
      $_db,
      $_db.supportWeeklyReportStudents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reportStudentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SupportWeeklyReportDayEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SupportWeeklyReportDayEntriesTable> {
  $$SupportWeeklyReportDayEntriesTableFilterComposer({
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

  ColumnFilters<String> get attendanceStatusSnapshot => $composableBuilder(
    column: $table.attendanceStatusSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get achievedQuarterFaces => $composableBuilder(
    column: $table.achievedQuarterFaces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startSurahSnapshot => $composableBuilder(
    column: $table.startSurahSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startAyahSnapshot => $composableBuilder(
    column: $table.startAyahSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endSurahSnapshot => $composableBuilder(
    column: $table.endSurahSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endAyahSnapshot => $composableBuilder(
    column: $table.endAyahSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteSnapshot => $composableBuilder(
    column: $table.noteSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entryOrder => $composableBuilder(
    column: $table.entryOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$SupportWeeklyReportDaysTableFilterComposer get reportDayId {
    final $$SupportWeeklyReportDaysTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.reportDayId,
          referencedTable: $db.supportWeeklyReportDays,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportDaysTableFilterComposer(
                $db: $db,
                $table: $db.supportWeeklyReportDays,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$SupportWeeklyReportStudentsTableFilterComposer get reportStudentId {
    final $$SupportWeeklyReportStudentsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.reportStudentId,
          referencedTable: $db.supportWeeklyReportStudents,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportStudentsTableFilterComposer(
                $db: $db,
                $table: $db.supportWeeklyReportStudents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SupportWeeklyReportDayEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SupportWeeklyReportDayEntriesTable> {
  $$SupportWeeklyReportDayEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get attendanceStatusSnapshot => $composableBuilder(
    column: $table.attendanceStatusSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get achievedQuarterFaces => $composableBuilder(
    column: $table.achievedQuarterFaces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startSurahSnapshot => $composableBuilder(
    column: $table.startSurahSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startAyahSnapshot => $composableBuilder(
    column: $table.startAyahSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endSurahSnapshot => $composableBuilder(
    column: $table.endSurahSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endAyahSnapshot => $composableBuilder(
    column: $table.endAyahSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteSnapshot => $composableBuilder(
    column: $table.noteSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entryOrder => $composableBuilder(
    column: $table.entryOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$SupportWeeklyReportDaysTableOrderingComposer get reportDayId {
    final $$SupportWeeklyReportDaysTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.reportDayId,
          referencedTable: $db.supportWeeklyReportDays,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportDaysTableOrderingComposer(
                $db: $db,
                $table: $db.supportWeeklyReportDays,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$SupportWeeklyReportStudentsTableOrderingComposer get reportStudentId {
    final $$SupportWeeklyReportStudentsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.reportStudentId,
          referencedTable: $db.supportWeeklyReportStudents,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportStudentsTableOrderingComposer(
                $db: $db,
                $table: $db.supportWeeklyReportStudents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SupportWeeklyReportDayEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupportWeeklyReportDayEntriesTable> {
  $$SupportWeeklyReportDayEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get attendanceStatusSnapshot => $composableBuilder(
    column: $table.attendanceStatusSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get achievedQuarterFaces => $composableBuilder(
    column: $table.achievedQuarterFaces,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startSurahSnapshot => $composableBuilder(
    column: $table.startSurahSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startAyahSnapshot => $composableBuilder(
    column: $table.startAyahSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endSurahSnapshot => $composableBuilder(
    column: $table.endSurahSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endAyahSnapshot => $composableBuilder(
    column: $table.endAyahSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get noteSnapshot => $composableBuilder(
    column: $table.noteSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entryOrder => $composableBuilder(
    column: $table.entryOrder,
    builder: (column) => column,
  );

  $$SupportWeeklyReportDaysTableAnnotationComposer get reportDayId {
    final $$SupportWeeklyReportDaysTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.reportDayId,
          referencedTable: $db.supportWeeklyReportDays,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportDaysTableAnnotationComposer(
                $db: $db,
                $table: $db.supportWeeklyReportDays,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$SupportWeeklyReportStudentsTableAnnotationComposer get reportStudentId {
    final $$SupportWeeklyReportStudentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.reportStudentId,
          referencedTable: $db.supportWeeklyReportStudents,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportWeeklyReportStudentsTableAnnotationComposer(
                $db: $db,
                $table: $db.supportWeeklyReportStudents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SupportWeeklyReportDayEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupportWeeklyReportDayEntriesTable,
          SupportWeeklyReportDayEntry,
          $$SupportWeeklyReportDayEntriesTableFilterComposer,
          $$SupportWeeklyReportDayEntriesTableOrderingComposer,
          $$SupportWeeklyReportDayEntriesTableAnnotationComposer,
          $$SupportWeeklyReportDayEntriesTableCreateCompanionBuilder,
          $$SupportWeeklyReportDayEntriesTableUpdateCompanionBuilder,
          (
            SupportWeeklyReportDayEntry,
            $$SupportWeeklyReportDayEntriesTableReferences,
          ),
          SupportWeeklyReportDayEntry,
          PrefetchHooks Function({bool reportDayId, bool reportStudentId})
        > {
  $$SupportWeeklyReportDayEntriesTableTableManager(
    _$AppDatabase db,
    $SupportWeeklyReportDayEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupportWeeklyReportDayEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SupportWeeklyReportDayEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SupportWeeklyReportDayEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> reportDayId = const Value.absent(),
                Value<int> reportStudentId = const Value.absent(),
                Value<String?> attendanceStatusSnapshot = const Value.absent(),
                Value<int> achievedQuarterFaces = const Value.absent(),
                Value<int?> startSurahSnapshot = const Value.absent(),
                Value<int?> startAyahSnapshot = const Value.absent(),
                Value<int?> endSurahSnapshot = const Value.absent(),
                Value<int?> endAyahSnapshot = const Value.absent(),
                Value<String?> noteSnapshot = const Value.absent(),
                Value<int> entryOrder = const Value.absent(),
              }) => SupportWeeklyReportDayEntriesCompanion(
                id: id,
                reportDayId: reportDayId,
                reportStudentId: reportStudentId,
                attendanceStatusSnapshot: attendanceStatusSnapshot,
                achievedQuarterFaces: achievedQuarterFaces,
                startSurahSnapshot: startSurahSnapshot,
                startAyahSnapshot: startAyahSnapshot,
                endSurahSnapshot: endSurahSnapshot,
                endAyahSnapshot: endAyahSnapshot,
                noteSnapshot: noteSnapshot,
                entryOrder: entryOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int reportDayId,
                required int reportStudentId,
                Value<String?> attendanceStatusSnapshot = const Value.absent(),
                Value<int> achievedQuarterFaces = const Value.absent(),
                Value<int?> startSurahSnapshot = const Value.absent(),
                Value<int?> startAyahSnapshot = const Value.absent(),
                Value<int?> endSurahSnapshot = const Value.absent(),
                Value<int?> endAyahSnapshot = const Value.absent(),
                Value<String?> noteSnapshot = const Value.absent(),
                required int entryOrder,
              }) => SupportWeeklyReportDayEntriesCompanion.insert(
                id: id,
                reportDayId: reportDayId,
                reportStudentId: reportStudentId,
                attendanceStatusSnapshot: attendanceStatusSnapshot,
                achievedQuarterFaces: achievedQuarterFaces,
                startSurahSnapshot: startSurahSnapshot,
                startAyahSnapshot: startAyahSnapshot,
                endSurahSnapshot: endSurahSnapshot,
                endAyahSnapshot: endAyahSnapshot,
                noteSnapshot: noteSnapshot,
                entryOrder: entryOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SupportWeeklyReportDayEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reportDayId = false, reportStudentId = false}) {
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
                    if (reportDayId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.reportDayId,
                                referencedTable:
                                    $$SupportWeeklyReportDayEntriesTableReferences
                                        ._reportDayIdTable(db),
                                referencedColumn:
                                    $$SupportWeeklyReportDayEntriesTableReferences
                                        ._reportDayIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (reportStudentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.reportStudentId,
                                referencedTable:
                                    $$SupportWeeklyReportDayEntriesTableReferences
                                        ._reportStudentIdTable(db),
                                referencedColumn:
                                    $$SupportWeeklyReportDayEntriesTableReferences
                                        ._reportStudentIdTable(db)
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

typedef $$SupportWeeklyReportDayEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupportWeeklyReportDayEntriesTable,
      SupportWeeklyReportDayEntry,
      $$SupportWeeklyReportDayEntriesTableFilterComposer,
      $$SupportWeeklyReportDayEntriesTableOrderingComposer,
      $$SupportWeeklyReportDayEntriesTableAnnotationComposer,
      $$SupportWeeklyReportDayEntriesTableCreateCompanionBuilder,
      $$SupportWeeklyReportDayEntriesTableUpdateCompanionBuilder,
      (
        SupportWeeklyReportDayEntry,
        $$SupportWeeklyReportDayEntriesTableReferences,
      ),
      SupportWeeklyReportDayEntry,
      PrefetchHooks Function({bool reportDayId, bool reportStudentId})
    >;
typedef $$SupportMonthlyReportsTableCreateCompanionBuilder =
    SupportMonthlyReportsCompanion Function({
      Value<int> id,
      required int halaqahId,
      required String monthStartDate,
      required String monthEndDate,
      required String status,
      required String teacherNameSnapshot,
      required String halaqahNameSnapshot,
      required String organizationNameSnapshot,
      required int policyVersion,
      required int templateVersion,
      Value<String?> sourceFingerprint,
      Value<DateTime?> approvedAtUtc,
    });
typedef $$SupportMonthlyReportsTableUpdateCompanionBuilder =
    SupportMonthlyReportsCompanion Function({
      Value<int> id,
      Value<int> halaqahId,
      Value<String> monthStartDate,
      Value<String> monthEndDate,
      Value<String> status,
      Value<String> teacherNameSnapshot,
      Value<String> halaqahNameSnapshot,
      Value<String> organizationNameSnapshot,
      Value<int> policyVersion,
      Value<int> templateVersion,
      Value<String?> sourceFingerprint,
      Value<DateTime?> approvedAtUtc,
    });

final class $$SupportMonthlyReportsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SupportMonthlyReportsTable,
          SupportMonthlyReport
        > {
  $$SupportMonthlyReportsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HalaqahsTable _halaqahIdTable(_$AppDatabase db) => db.halaqahs
      .createAlias('support_monthly_reports__halaqah_id__halaqahs__id');

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
    $SupportMonthlyReportStudentsTable,
    List<SupportMonthlyReportStudent>
  >
  _supportMonthlyReportStudentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.supportMonthlyReportStudents,
    aliasName:
        'support_monthly_reports__id__support_monthly_report_students__report_id',
  );

  $$SupportMonthlyReportStudentsTableProcessedTableManager
  get supportMonthlyReportStudentsRefs {
    final manager = $$SupportMonthlyReportStudentsTableTableManager(
      $_db,
      $_db.supportMonthlyReportStudents,
    ).filter((f) => f.reportId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supportMonthlyReportStudentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SupportMonthlyReportsTableFilterComposer
    extends Composer<_$AppDatabase, $SupportMonthlyReportsTable> {
  $$SupportMonthlyReportsTableFilterComposer({
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

  ColumnFilters<String> get monthStartDate => $composableBuilder(
    column: $table.monthStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monthEndDate => $composableBuilder(
    column: $table.monthEndDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherNameSnapshot => $composableBuilder(
    column: $table.teacherNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get halaqahNameSnapshot => $composableBuilder(
    column: $table.halaqahNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organizationNameSnapshot => $composableBuilder(
    column: $table.organizationNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get policyVersion => $composableBuilder(
    column: $table.policyVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get templateVersion => $composableBuilder(
    column: $table.templateVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFingerprint => $composableBuilder(
    column: $table.sourceFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get approvedAtUtc => $composableBuilder(
    column: $table.approvedAtUtc,
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

  Expression<bool> supportMonthlyReportStudentsRefs(
    Expression<bool> Function(
      $$SupportMonthlyReportStudentsTableFilterComposer f,
    )
    f,
  ) {
    final $$SupportMonthlyReportStudentsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportMonthlyReportStudents,
          getReferencedColumn: (t) => t.reportId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportMonthlyReportStudentsTableFilterComposer(
                $db: $db,
                $table: $db.supportMonthlyReportStudents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SupportMonthlyReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupportMonthlyReportsTable> {
  $$SupportMonthlyReportsTableOrderingComposer({
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

  ColumnOrderings<String> get monthStartDate => $composableBuilder(
    column: $table.monthStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monthEndDate => $composableBuilder(
    column: $table.monthEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherNameSnapshot => $composableBuilder(
    column: $table.teacherNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get halaqahNameSnapshot => $composableBuilder(
    column: $table.halaqahNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organizationNameSnapshot => $composableBuilder(
    column: $table.organizationNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get policyVersion => $composableBuilder(
    column: $table.policyVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get templateVersion => $composableBuilder(
    column: $table.templateVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFingerprint => $composableBuilder(
    column: $table.sourceFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get approvedAtUtc => $composableBuilder(
    column: $table.approvedAtUtc,
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

class $$SupportMonthlyReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupportMonthlyReportsTable> {
  $$SupportMonthlyReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get monthStartDate => $composableBuilder(
    column: $table.monthStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get monthEndDate => $composableBuilder(
    column: $table.monthEndDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get teacherNameSnapshot => $composableBuilder(
    column: $table.teacherNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get halaqahNameSnapshot => $composableBuilder(
    column: $table.halaqahNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get organizationNameSnapshot => $composableBuilder(
    column: $table.organizationNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get policyVersion => $composableBuilder(
    column: $table.policyVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get templateVersion => $composableBuilder(
    column: $table.templateVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceFingerprint => $composableBuilder(
    column: $table.sourceFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get approvedAtUtc => $composableBuilder(
    column: $table.approvedAtUtc,
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

  Expression<T> supportMonthlyReportStudentsRefs<T extends Object>(
    Expression<T> Function(
      $$SupportMonthlyReportStudentsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$SupportMonthlyReportStudentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supportMonthlyReportStudents,
          getReferencedColumn: (t) => t.reportId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportMonthlyReportStudentsTableAnnotationComposer(
                $db: $db,
                $table: $db.supportMonthlyReportStudents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SupportMonthlyReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupportMonthlyReportsTable,
          SupportMonthlyReport,
          $$SupportMonthlyReportsTableFilterComposer,
          $$SupportMonthlyReportsTableOrderingComposer,
          $$SupportMonthlyReportsTableAnnotationComposer,
          $$SupportMonthlyReportsTableCreateCompanionBuilder,
          $$SupportMonthlyReportsTableUpdateCompanionBuilder,
          (SupportMonthlyReport, $$SupportMonthlyReportsTableReferences),
          SupportMonthlyReport,
          PrefetchHooks Function({
            bool halaqahId,
            bool supportMonthlyReportStudentsRefs,
          })
        > {
  $$SupportMonthlyReportsTableTableManager(
    _$AppDatabase db,
    $SupportMonthlyReportsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupportMonthlyReportsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SupportMonthlyReportsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SupportMonthlyReportsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> halaqahId = const Value.absent(),
                Value<String> monthStartDate = const Value.absent(),
                Value<String> monthEndDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> teacherNameSnapshot = const Value.absent(),
                Value<String> halaqahNameSnapshot = const Value.absent(),
                Value<String> organizationNameSnapshot = const Value.absent(),
                Value<int> policyVersion = const Value.absent(),
                Value<int> templateVersion = const Value.absent(),
                Value<String?> sourceFingerprint = const Value.absent(),
                Value<DateTime?> approvedAtUtc = const Value.absent(),
              }) => SupportMonthlyReportsCompanion(
                id: id,
                halaqahId: halaqahId,
                monthStartDate: monthStartDate,
                monthEndDate: monthEndDate,
                status: status,
                teacherNameSnapshot: teacherNameSnapshot,
                halaqahNameSnapshot: halaqahNameSnapshot,
                organizationNameSnapshot: organizationNameSnapshot,
                policyVersion: policyVersion,
                templateVersion: templateVersion,
                sourceFingerprint: sourceFingerprint,
                approvedAtUtc: approvedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int halaqahId,
                required String monthStartDate,
                required String monthEndDate,
                required String status,
                required String teacherNameSnapshot,
                required String halaqahNameSnapshot,
                required String organizationNameSnapshot,
                required int policyVersion,
                required int templateVersion,
                Value<String?> sourceFingerprint = const Value.absent(),
                Value<DateTime?> approvedAtUtc = const Value.absent(),
              }) => SupportMonthlyReportsCompanion.insert(
                id: id,
                halaqahId: halaqahId,
                monthStartDate: monthStartDate,
                monthEndDate: monthEndDate,
                status: status,
                teacherNameSnapshot: teacherNameSnapshot,
                halaqahNameSnapshot: halaqahNameSnapshot,
                organizationNameSnapshot: organizationNameSnapshot,
                policyVersion: policyVersion,
                templateVersion: templateVersion,
                sourceFingerprint: sourceFingerprint,
                approvedAtUtc: approvedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SupportMonthlyReportsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({halaqahId = false, supportMonthlyReportStudentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (supportMonthlyReportStudentsRefs)
                      db.supportMonthlyReportStudents,
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
                                    referencedTable:
                                        $$SupportMonthlyReportsTableReferences
                                            ._halaqahIdTable(db),
                                    referencedColumn:
                                        $$SupportMonthlyReportsTableReferences
                                            ._halaqahIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (supportMonthlyReportStudentsRefs)
                        await $_getPrefetchedData<
                          SupportMonthlyReport,
                          $SupportMonthlyReportsTable,
                          SupportMonthlyReportStudent
                        >(
                          currentTable: table,
                          referencedTable:
                              $$SupportMonthlyReportsTableReferences
                                  ._supportMonthlyReportStudentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SupportMonthlyReportsTableReferences(
                                db,
                                table,
                                p0,
                              ).supportMonthlyReportStudentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.reportId == item.id,
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

typedef $$SupportMonthlyReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupportMonthlyReportsTable,
      SupportMonthlyReport,
      $$SupportMonthlyReportsTableFilterComposer,
      $$SupportMonthlyReportsTableOrderingComposer,
      $$SupportMonthlyReportsTableAnnotationComposer,
      $$SupportMonthlyReportsTableCreateCompanionBuilder,
      $$SupportMonthlyReportsTableUpdateCompanionBuilder,
      (SupportMonthlyReport, $$SupportMonthlyReportsTableReferences),
      SupportMonthlyReport,
      PrefetchHooks Function({
        bool halaqahId,
        bool supportMonthlyReportStudentsRefs,
      })
    >;
typedef $$SupportMonthlyReportStudentsTableCreateCompanionBuilder =
    SupportMonthlyReportStudentsCompanion Function({
      Value<int> id,
      required int reportId,
      required int sourceStudentId,
      Value<String?> supportStudentNumberSnapshot,
      required String studentNameSnapshot,
      Value<int?> currentJuzSnapshot,
      Value<String?> dailyPlanTextSnapshot,
      required int monthlyGoalQuarterFacesSnapshot,
      required int achievedQuarterFaces,
      required int absenceDays,
      required bool goalCompleted,
      Value<String?> noteSnapshot,
      required int displayOrderSnapshot,
    });
typedef $$SupportMonthlyReportStudentsTableUpdateCompanionBuilder =
    SupportMonthlyReportStudentsCompanion Function({
      Value<int> id,
      Value<int> reportId,
      Value<int> sourceStudentId,
      Value<String?> supportStudentNumberSnapshot,
      Value<String> studentNameSnapshot,
      Value<int?> currentJuzSnapshot,
      Value<String?> dailyPlanTextSnapshot,
      Value<int> monthlyGoalQuarterFacesSnapshot,
      Value<int> achievedQuarterFaces,
      Value<int> absenceDays,
      Value<bool> goalCompleted,
      Value<String?> noteSnapshot,
      Value<int> displayOrderSnapshot,
    });

final class $$SupportMonthlyReportStudentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SupportMonthlyReportStudentsTable,
          SupportMonthlyReportStudent
        > {
  $$SupportMonthlyReportStudentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SupportMonthlyReportsTable _reportIdTable(
    _$AppDatabase db,
  ) => db.supportMonthlyReports.createAlias(
    'support_monthly_report_students__report_id__support_monthly_reports__id',
  );

  $$SupportMonthlyReportsTableProcessedTableManager get reportId {
    final $_column = $_itemColumn<int>('report_id')!;

    final manager = $$SupportMonthlyReportsTableTableManager(
      $_db,
      $_db.supportMonthlyReports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reportIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudentsTable _sourceStudentIdTable(_$AppDatabase db) =>
      db.students.createAlias(
        'support_monthly_report_students__source_student_id__students__id',
      );

  $$StudentsTableProcessedTableManager get sourceStudentId {
    final $_column = $_itemColumn<int>('source_student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceStudentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SupportMonthlyReportStudentsTableFilterComposer
    extends Composer<_$AppDatabase, $SupportMonthlyReportStudentsTable> {
  $$SupportMonthlyReportStudentsTableFilterComposer({
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

  ColumnFilters<String> get supportStudentNumberSnapshot => $composableBuilder(
    column: $table.supportStudentNumberSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentNameSnapshot => $composableBuilder(
    column: $table.studentNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentJuzSnapshot => $composableBuilder(
    column: $table.currentJuzSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dailyPlanTextSnapshot => $composableBuilder(
    column: $table.dailyPlanTextSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyGoalQuarterFacesSnapshot => $composableBuilder(
    column: $table.monthlyGoalQuarterFacesSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get achievedQuarterFaces => $composableBuilder(
    column: $table.achievedQuarterFaces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get absenceDays => $composableBuilder(
    column: $table.absenceDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get goalCompleted => $composableBuilder(
    column: $table.goalCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteSnapshot => $composableBuilder(
    column: $table.noteSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayOrderSnapshot => $composableBuilder(
    column: $table.displayOrderSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  $$SupportMonthlyReportsTableFilterComposer get reportId {
    final $$SupportMonthlyReportsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.reportId,
          referencedTable: $db.supportMonthlyReports,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportMonthlyReportsTableFilterComposer(
                $db: $db,
                $table: $db.supportMonthlyReports,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$StudentsTableFilterComposer get sourceStudentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceStudentId,
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

class $$SupportMonthlyReportStudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupportMonthlyReportStudentsTable> {
  $$SupportMonthlyReportStudentsTableOrderingComposer({
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

  ColumnOrderings<String> get supportStudentNumberSnapshot =>
      $composableBuilder(
        column: $table.supportStudentNumberSnapshot,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get studentNameSnapshot => $composableBuilder(
    column: $table.studentNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentJuzSnapshot => $composableBuilder(
    column: $table.currentJuzSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dailyPlanTextSnapshot => $composableBuilder(
    column: $table.dailyPlanTextSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyGoalQuarterFacesSnapshot =>
      $composableBuilder(
        column: $table.monthlyGoalQuarterFacesSnapshot,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get achievedQuarterFaces => $composableBuilder(
    column: $table.achievedQuarterFaces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get absenceDays => $composableBuilder(
    column: $table.absenceDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get goalCompleted => $composableBuilder(
    column: $table.goalCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteSnapshot => $composableBuilder(
    column: $table.noteSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayOrderSnapshot => $composableBuilder(
    column: $table.displayOrderSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  $$SupportMonthlyReportsTableOrderingComposer get reportId {
    final $$SupportMonthlyReportsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.reportId,
          referencedTable: $db.supportMonthlyReports,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportMonthlyReportsTableOrderingComposer(
                $db: $db,
                $table: $db.supportMonthlyReports,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$StudentsTableOrderingComposer get sourceStudentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceStudentId,
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

class $$SupportMonthlyReportStudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupportMonthlyReportStudentsTable> {
  $$SupportMonthlyReportStudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get supportStudentNumberSnapshot =>
      $composableBuilder(
        column: $table.supportStudentNumberSnapshot,
        builder: (column) => column,
      );

  GeneratedColumn<String> get studentNameSnapshot => $composableBuilder(
    column: $table.studentNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentJuzSnapshot => $composableBuilder(
    column: $table.currentJuzSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dailyPlanTextSnapshot => $composableBuilder(
    column: $table.dailyPlanTextSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monthlyGoalQuarterFacesSnapshot =>
      $composableBuilder(
        column: $table.monthlyGoalQuarterFacesSnapshot,
        builder: (column) => column,
      );

  GeneratedColumn<int> get achievedQuarterFaces => $composableBuilder(
    column: $table.achievedQuarterFaces,
    builder: (column) => column,
  );

  GeneratedColumn<int> get absenceDays => $composableBuilder(
    column: $table.absenceDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get goalCompleted => $composableBuilder(
    column: $table.goalCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get noteSnapshot => $composableBuilder(
    column: $table.noteSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get displayOrderSnapshot => $composableBuilder(
    column: $table.displayOrderSnapshot,
    builder: (column) => column,
  );

  $$SupportMonthlyReportsTableAnnotationComposer get reportId {
    final $$SupportMonthlyReportsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.reportId,
          referencedTable: $db.supportMonthlyReports,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupportMonthlyReportsTableAnnotationComposer(
                $db: $db,
                $table: $db.supportMonthlyReports,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$StudentsTableAnnotationComposer get sourceStudentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceStudentId,
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

class $$SupportMonthlyReportStudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupportMonthlyReportStudentsTable,
          SupportMonthlyReportStudent,
          $$SupportMonthlyReportStudentsTableFilterComposer,
          $$SupportMonthlyReportStudentsTableOrderingComposer,
          $$SupportMonthlyReportStudentsTableAnnotationComposer,
          $$SupportMonthlyReportStudentsTableCreateCompanionBuilder,
          $$SupportMonthlyReportStudentsTableUpdateCompanionBuilder,
          (
            SupportMonthlyReportStudent,
            $$SupportMonthlyReportStudentsTableReferences,
          ),
          SupportMonthlyReportStudent,
          PrefetchHooks Function({bool reportId, bool sourceStudentId})
        > {
  $$SupportMonthlyReportStudentsTableTableManager(
    _$AppDatabase db,
    $SupportMonthlyReportStudentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupportMonthlyReportStudentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SupportMonthlyReportStudentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SupportMonthlyReportStudentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> reportId = const Value.absent(),
                Value<int> sourceStudentId = const Value.absent(),
                Value<String?> supportStudentNumberSnapshot =
                    const Value.absent(),
                Value<String> studentNameSnapshot = const Value.absent(),
                Value<int?> currentJuzSnapshot = const Value.absent(),
                Value<String?> dailyPlanTextSnapshot = const Value.absent(),
                Value<int> monthlyGoalQuarterFacesSnapshot =
                    const Value.absent(),
                Value<int> achievedQuarterFaces = const Value.absent(),
                Value<int> absenceDays = const Value.absent(),
                Value<bool> goalCompleted = const Value.absent(),
                Value<String?> noteSnapshot = const Value.absent(),
                Value<int> displayOrderSnapshot = const Value.absent(),
              }) => SupportMonthlyReportStudentsCompanion(
                id: id,
                reportId: reportId,
                sourceStudentId: sourceStudentId,
                supportStudentNumberSnapshot: supportStudentNumberSnapshot,
                studentNameSnapshot: studentNameSnapshot,
                currentJuzSnapshot: currentJuzSnapshot,
                dailyPlanTextSnapshot: dailyPlanTextSnapshot,
                monthlyGoalQuarterFacesSnapshot:
                    monthlyGoalQuarterFacesSnapshot,
                achievedQuarterFaces: achievedQuarterFaces,
                absenceDays: absenceDays,
                goalCompleted: goalCompleted,
                noteSnapshot: noteSnapshot,
                displayOrderSnapshot: displayOrderSnapshot,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int reportId,
                required int sourceStudentId,
                Value<String?> supportStudentNumberSnapshot =
                    const Value.absent(),
                required String studentNameSnapshot,
                Value<int?> currentJuzSnapshot = const Value.absent(),
                Value<String?> dailyPlanTextSnapshot = const Value.absent(),
                required int monthlyGoalQuarterFacesSnapshot,
                required int achievedQuarterFaces,
                required int absenceDays,
                required bool goalCompleted,
                Value<String?> noteSnapshot = const Value.absent(),
                required int displayOrderSnapshot,
              }) => SupportMonthlyReportStudentsCompanion.insert(
                id: id,
                reportId: reportId,
                sourceStudentId: sourceStudentId,
                supportStudentNumberSnapshot: supportStudentNumberSnapshot,
                studentNameSnapshot: studentNameSnapshot,
                currentJuzSnapshot: currentJuzSnapshot,
                dailyPlanTextSnapshot: dailyPlanTextSnapshot,
                monthlyGoalQuarterFacesSnapshot:
                    monthlyGoalQuarterFacesSnapshot,
                achievedQuarterFaces: achievedQuarterFaces,
                absenceDays: absenceDays,
                goalCompleted: goalCompleted,
                noteSnapshot: noteSnapshot,
                displayOrderSnapshot: displayOrderSnapshot,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SupportMonthlyReportStudentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reportId = false, sourceStudentId = false}) {
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
                    if (reportId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.reportId,
                                referencedTable:
                                    $$SupportMonthlyReportStudentsTableReferences
                                        ._reportIdTable(db),
                                referencedColumn:
                                    $$SupportMonthlyReportStudentsTableReferences
                                        ._reportIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (sourceStudentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sourceStudentId,
                                referencedTable:
                                    $$SupportMonthlyReportStudentsTableReferences
                                        ._sourceStudentIdTable(db),
                                referencedColumn:
                                    $$SupportMonthlyReportStudentsTableReferences
                                        ._sourceStudentIdTable(db)
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

typedef $$SupportMonthlyReportStudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupportMonthlyReportStudentsTable,
      SupportMonthlyReportStudent,
      $$SupportMonthlyReportStudentsTableFilterComposer,
      $$SupportMonthlyReportStudentsTableOrderingComposer,
      $$SupportMonthlyReportStudentsTableAnnotationComposer,
      $$SupportMonthlyReportStudentsTableCreateCompanionBuilder,
      $$SupportMonthlyReportStudentsTableUpdateCompanionBuilder,
      (
        SupportMonthlyReportStudent,
        $$SupportMonthlyReportStudentsTableReferences,
      ),
      SupportMonthlyReportStudent,
      PrefetchHooks Function({bool reportId, bool sourceStudentId})
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
  $$HalaqahDaysTableTableManager get halaqahDays =>
      $$HalaqahDaysTableTableManager(_db, _db.halaqahDays);
  $$AttendanceRecordsTableTableManager get attendanceRecords =>
      $$AttendanceRecordsTableTableManager(_db, _db.attendanceRecords);
  $$RecitationsTableTableManager get recitations =>
      $$RecitationsTableTableManager(_db, _db.recitations);
  $$ParentFollowUpsTableTableManager get parentFollowUps =>
      $$ParentFollowUpsTableTableManager(_db, _db.parentFollowUps);
  $$SupportWeeklyReportsTableTableManager get supportWeeklyReports =>
      $$SupportWeeklyReportsTableTableManager(_db, _db.supportWeeklyReports);
  $$SupportWeeklyReportStudentsTableTableManager
  get supportWeeklyReportStudents =>
      $$SupportWeeklyReportStudentsTableTableManager(
        _db,
        _db.supportWeeklyReportStudents,
      );
  $$SupportWeeklyReportDaysTableTableManager get supportWeeklyReportDays =>
      $$SupportWeeklyReportDaysTableTableManager(
        _db,
        _db.supportWeeklyReportDays,
      );
  $$SupportWeeklyReportDayEntriesTableTableManager
  get supportWeeklyReportDayEntries =>
      $$SupportWeeklyReportDayEntriesTableTableManager(
        _db,
        _db.supportWeeklyReportDayEntries,
      );
  $$SupportMonthlyReportsTableTableManager get supportMonthlyReports =>
      $$SupportMonthlyReportsTableTableManager(_db, _db.supportMonthlyReports);
  $$SupportMonthlyReportStudentsTableTableManager
  get supportMonthlyReportStudents =>
      $$SupportMonthlyReportStudentsTableTableManager(
        _db,
        _db.supportMonthlyReportStudents,
      );
}

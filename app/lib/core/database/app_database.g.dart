// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarPresetMeta = const VerificationMeta(
    'avatarPreset',
  );
  @override
  late final GeneratedColumn<int> avatarPreset = GeneratedColumn<int>(
    'avatar_preset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avatarImageMeta = const VerificationMeta(
    'avatarImage',
  );
  @override
  late final GeneratedColumn<Uint8List> avatarImage =
      GeneratedColumn<Uint8List>(
        'avatar_image',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deleted,
    name,
    avatarPreset,
    avatarImage,
    pinHash,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar_preset')) {
      context.handle(
        _avatarPresetMeta,
        avatarPreset.isAcceptableOrUnknown(
          data['avatar_preset']!,
          _avatarPresetMeta,
        ),
      );
    }
    if (data.containsKey('avatar_image')) {
      context.handle(
        _avatarImageMeta,
        avatarImage.isAcceptableOrUnknown(
          data['avatar_image']!,
          _avatarImageMeta,
        ),
      );
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatarPreset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avatar_preset'],
      )!,
      avatarImage: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}avatar_image'],
      ),
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final String name;

  /// Index into the bundled avatar set. Used when [avatarImage] is null.
  final int avatarPreset;

  /// Custom avatar as a small PNG, stored in the database so it works on the
  /// web and can be synchronized like any other value.
  final Uint8List? avatarImage;

  /// Salted hash of the optional profile PIN.
  final String? pinHash;
  final int sortOrder;
  const ProfileRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.name,
    required this.avatarPreset,
    this.avatarImage,
    this.pinHash,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['avatar_preset'] = Variable<int>(avatarPreset);
    if (!nullToAbsent || avatarImage != null) {
      map['avatar_image'] = Variable<Uint8List>(avatarImage);
    }
    if (!nullToAbsent || pinHash != null) {
      map['pin_hash'] = Variable<String>(pinHash);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      name: Value(name),
      avatarPreset: Value(avatarPreset),
      avatarImage: avatarImage == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarImage),
      pinHash: pinHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pinHash),
      sortOrder: Value(sortOrder),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      avatarPreset: serializer.fromJson<int>(json['avatarPreset']),
      avatarImage: serializer.fromJson<Uint8List?>(json['avatarImage']),
      pinHash: serializer.fromJson<String?>(json['pinHash']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'avatarPreset': serializer.toJson<int>(avatarPreset),
      'avatarImage': serializer.toJson<Uint8List?>(avatarImage),
      'pinHash': serializer.toJson<String?>(pinHash),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ProfileRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? deleted,
    String? name,
    int? avatarPreset,
    Value<Uint8List?> avatarImage = const Value.absent(),
    Value<String?> pinHash = const Value.absent(),
    int? sortOrder,
  }) => ProfileRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    name: name ?? this.name,
    avatarPreset: avatarPreset ?? this.avatarPreset,
    avatarImage: avatarImage.present ? avatarImage.value : this.avatarImage,
    pinHash: pinHash.present ? pinHash.value : this.pinHash,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      avatarPreset: data.avatarPreset.present
          ? data.avatarPreset.value
          : this.avatarPreset,
      avatarImage: data.avatarImage.present
          ? data.avatarImage.value
          : this.avatarImage,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('avatarPreset: $avatarPreset, ')
          ..write('avatarImage: $avatarImage, ')
          ..write('pinHash: $pinHash, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deleted,
    name,
    avatarPreset,
    $driftBlobEquality.hash(avatarImage),
    pinHash,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.avatarPreset == this.avatarPreset &&
          $driftBlobEquality.equals(other.avatarImage, this.avatarImage) &&
          other.pinHash == this.pinHash &&
          other.sortOrder == this.sortOrder);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<int> avatarPreset;
  final Value<Uint8List?> avatarImage;
  final Value<String?> pinHash;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarPreset = const Value.absent(),
    this.avatarImage = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    required String name,
    this.avatarPreset = const Value.absent(),
    this.avatarImage = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<ProfileRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<int>? avatarPreset,
    Expression<Uint8List>? avatarImage,
    Expression<String>? pinHash,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (avatarPreset != null) 'avatar_preset': avatarPreset,
      if (avatarImage != null) 'avatar_image': avatarImage,
      if (pinHash != null) 'pin_hash': pinHash,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? name,
    Value<int>? avatarPreset,
    Value<Uint8List?>? avatarImage,
    Value<String?>? pinHash,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      avatarPreset: avatarPreset ?? this.avatarPreset,
      avatarImage: avatarImage ?? this.avatarImage,
      pinHash: pinHash ?? this.pinHash,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatarPreset.present) {
      map['avatar_preset'] = Variable<int>(avatarPreset.value);
    }
    if (avatarImage.present) {
      map['avatar_image'] = Variable<Uint8List>(avatarImage.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('avatarPreset: $avatarPreset, ')
          ..write('avatarImage: $avatarImage, ')
          ..write('pinHash: $pinHash, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, PlaylistRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PlaylistType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PlaylistType>($PlaylistsTable.$convertertype);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverUrlMeta = const VerificationMeta(
    'serverUrl',
  );
  @override
  late final GeneratedColumn<String> serverUrl = GeneratedColumn<String>(
    'server_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _accountStatusMeta = const VerificationMeta(
    'accountStatus',
  );
  @override
  late final GeneratedColumn<String> accountStatus = GeneratedColumn<String>(
    'account_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountCheckedAtMeta = const VerificationMeta(
    'accountCheckedAt',
  );
  @override
  late final GeneratedColumn<DateTime> accountCheckedAt =
      GeneratedColumn<DateTime>(
        'account_checked_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _accountExpiresAtMeta = const VerificationMeta(
    'accountExpiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> accountExpiresAt =
      GeneratedColumn<DateTime>(
        'account_expires_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _accountMaxConnectionsMeta =
      const VerificationMeta('accountMaxConnections');
  @override
  late final GeneratedColumn<int> accountMaxConnections = GeneratedColumn<int>(
    'account_max_connections',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountActiveConnectionsMeta =
      const VerificationMeta('accountActiveConnections');
  @override
  late final GeneratedColumn<int> accountActiveConnections =
      GeneratedColumn<int>(
        'account_active_connections',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deleted,
    profileId,
    type,
    name,
    serverUrl,
    username,
    sortOrder,
    accountStatus,
    accountCheckedAt,
    accountExpiresAt,
    accountMaxConnections,
    accountActiveConnections,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistRow> instance, {
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('server_url')) {
      context.handle(
        _serverUrlMeta,
        serverUrl.isAcceptableOrUnknown(data['server_url']!, _serverUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_serverUrlMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('account_status')) {
      context.handle(
        _accountStatusMeta,
        accountStatus.isAcceptableOrUnknown(
          data['account_status']!,
          _accountStatusMeta,
        ),
      );
    }
    if (data.containsKey('account_checked_at')) {
      context.handle(
        _accountCheckedAtMeta,
        accountCheckedAt.isAcceptableOrUnknown(
          data['account_checked_at']!,
          _accountCheckedAtMeta,
        ),
      );
    }
    if (data.containsKey('account_expires_at')) {
      context.handle(
        _accountExpiresAtMeta,
        accountExpiresAt.isAcceptableOrUnknown(
          data['account_expires_at']!,
          _accountExpiresAtMeta,
        ),
      );
    }
    if (data.containsKey('account_max_connections')) {
      context.handle(
        _accountMaxConnectionsMeta,
        accountMaxConnections.isAcceptableOrUnknown(
          data['account_max_connections']!,
          _accountMaxConnectionsMeta,
        ),
      );
    }
    if (data.containsKey('account_active_connections')) {
      context.handle(
        _accountActiveConnectionsMeta,
        accountActiveConnections.isAcceptableOrUnknown(
          data['account_active_connections']!,
          _accountActiveConnectionsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      type: $PlaylistsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      serverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_url'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      accountStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_status'],
      ),
      accountCheckedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}account_checked_at'],
      ),
      accountExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}account_expires_at'],
      ),
      accountMaxConnections: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_max_connections'],
      ),
      accountActiveConnections: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_active_connections'],
      ),
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PlaylistType, String, String> $convertertype =
      const EnumNameConverter<PlaylistType>(PlaylistType.values);
}

class PlaylistRow extends DataClass implements Insertable<PlaylistRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final String profileId;
  final PlaylistType type;
  final String name;
  final String serverUrl;
  final String username;
  final int sortOrder;
  final String? accountStatus;
  final DateTime? accountCheckedAt;
  final DateTime? accountExpiresAt;
  final int? accountMaxConnections;
  final int? accountActiveConnections;
  const PlaylistRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.profileId,
    required this.type,
    required this.name,
    required this.serverUrl,
    required this.username,
    required this.sortOrder,
    this.accountStatus,
    this.accountCheckedAt,
    this.accountExpiresAt,
    this.accountMaxConnections,
    this.accountActiveConnections,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['profile_id'] = Variable<String>(profileId);
    {
      map['type'] = Variable<String>(
        $PlaylistsTable.$convertertype.toSql(type),
      );
    }
    map['name'] = Variable<String>(name);
    map['server_url'] = Variable<String>(serverUrl);
    map['username'] = Variable<String>(username);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || accountStatus != null) {
      map['account_status'] = Variable<String>(accountStatus);
    }
    if (!nullToAbsent || accountCheckedAt != null) {
      map['account_checked_at'] = Variable<DateTime>(accountCheckedAt);
    }
    if (!nullToAbsent || accountExpiresAt != null) {
      map['account_expires_at'] = Variable<DateTime>(accountExpiresAt);
    }
    if (!nullToAbsent || accountMaxConnections != null) {
      map['account_max_connections'] = Variable<int>(accountMaxConnections);
    }
    if (!nullToAbsent || accountActiveConnections != null) {
      map['account_active_connections'] = Variable<int>(
        accountActiveConnections,
      );
    }
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      profileId: Value(profileId),
      type: Value(type),
      name: Value(name),
      serverUrl: Value(serverUrl),
      username: Value(username),
      sortOrder: Value(sortOrder),
      accountStatus: accountStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(accountStatus),
      accountCheckedAt: accountCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(accountCheckedAt),
      accountExpiresAt: accountExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(accountExpiresAt),
      accountMaxConnections: accountMaxConnections == null && nullToAbsent
          ? const Value.absent()
          : Value(accountMaxConnections),
      accountActiveConnections: accountActiveConnections == null && nullToAbsent
          ? const Value.absent()
          : Value(accountActiveConnections),
    );
  }

  factory PlaylistRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      profileId: serializer.fromJson<String>(json['profileId']),
      type: $PlaylistsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      name: serializer.fromJson<String>(json['name']),
      serverUrl: serializer.fromJson<String>(json['serverUrl']),
      username: serializer.fromJson<String>(json['username']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      accountStatus: serializer.fromJson<String?>(json['accountStatus']),
      accountCheckedAt: serializer.fromJson<DateTime?>(
        json['accountCheckedAt'],
      ),
      accountExpiresAt: serializer.fromJson<DateTime?>(
        json['accountExpiresAt'],
      ),
      accountMaxConnections: serializer.fromJson<int?>(
        json['accountMaxConnections'],
      ),
      accountActiveConnections: serializer.fromJson<int?>(
        json['accountActiveConnections'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'profileId': serializer.toJson<String>(profileId),
      'type': serializer.toJson<String>(
        $PlaylistsTable.$convertertype.toJson(type),
      ),
      'name': serializer.toJson<String>(name),
      'serverUrl': serializer.toJson<String>(serverUrl),
      'username': serializer.toJson<String>(username),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'accountStatus': serializer.toJson<String?>(accountStatus),
      'accountCheckedAt': serializer.toJson<DateTime?>(accountCheckedAt),
      'accountExpiresAt': serializer.toJson<DateTime?>(accountExpiresAt),
      'accountMaxConnections': serializer.toJson<int?>(accountMaxConnections),
      'accountActiveConnections': serializer.toJson<int?>(
        accountActiveConnections,
      ),
    };
  }

  PlaylistRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? deleted,
    String? profileId,
    PlaylistType? type,
    String? name,
    String? serverUrl,
    String? username,
    int? sortOrder,
    Value<String?> accountStatus = const Value.absent(),
    Value<DateTime?> accountCheckedAt = const Value.absent(),
    Value<DateTime?> accountExpiresAt = const Value.absent(),
    Value<int?> accountMaxConnections = const Value.absent(),
    Value<int?> accountActiveConnections = const Value.absent(),
  }) => PlaylistRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    profileId: profileId ?? this.profileId,
    type: type ?? this.type,
    name: name ?? this.name,
    serverUrl: serverUrl ?? this.serverUrl,
    username: username ?? this.username,
    sortOrder: sortOrder ?? this.sortOrder,
    accountStatus: accountStatus.present
        ? accountStatus.value
        : this.accountStatus,
    accountCheckedAt: accountCheckedAt.present
        ? accountCheckedAt.value
        : this.accountCheckedAt,
    accountExpiresAt: accountExpiresAt.present
        ? accountExpiresAt.value
        : this.accountExpiresAt,
    accountMaxConnections: accountMaxConnections.present
        ? accountMaxConnections.value
        : this.accountMaxConnections,
    accountActiveConnections: accountActiveConnections.present
        ? accountActiveConnections.value
        : this.accountActiveConnections,
  );
  PlaylistRow copyWithCompanion(PlaylistsCompanion data) {
    return PlaylistRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      serverUrl: data.serverUrl.present ? data.serverUrl.value : this.serverUrl,
      username: data.username.present ? data.username.value : this.username,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      accountStatus: data.accountStatus.present
          ? data.accountStatus.value
          : this.accountStatus,
      accountCheckedAt: data.accountCheckedAt.present
          ? data.accountCheckedAt.value
          : this.accountCheckedAt,
      accountExpiresAt: data.accountExpiresAt.present
          ? data.accountExpiresAt.value
          : this.accountExpiresAt,
      accountMaxConnections: data.accountMaxConnections.present
          ? data.accountMaxConnections.value
          : this.accountMaxConnections,
      accountActiveConnections: data.accountActiveConnections.present
          ? data.accountActiveConnections.value
          : this.accountActiveConnections,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('profileId: $profileId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('username: $username, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('accountStatus: $accountStatus, ')
          ..write('accountCheckedAt: $accountCheckedAt, ')
          ..write('accountExpiresAt: $accountExpiresAt, ')
          ..write('accountMaxConnections: $accountMaxConnections, ')
          ..write('accountActiveConnections: $accountActiveConnections')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deleted,
    profileId,
    type,
    name,
    serverUrl,
    username,
    sortOrder,
    accountStatus,
    accountCheckedAt,
    accountExpiresAt,
    accountMaxConnections,
    accountActiveConnections,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.profileId == this.profileId &&
          other.type == this.type &&
          other.name == this.name &&
          other.serverUrl == this.serverUrl &&
          other.username == this.username &&
          other.sortOrder == this.sortOrder &&
          other.accountStatus == this.accountStatus &&
          other.accountCheckedAt == this.accountCheckedAt &&
          other.accountExpiresAt == this.accountExpiresAt &&
          other.accountMaxConnections == this.accountMaxConnections &&
          other.accountActiveConnections == this.accountActiveConnections);
}

class PlaylistsCompanion extends UpdateCompanion<PlaylistRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> profileId;
  final Value<PlaylistType> type;
  final Value<String> name;
  final Value<String> serverUrl;
  final Value<String> username;
  final Value<int> sortOrder;
  final Value<String?> accountStatus;
  final Value<DateTime?> accountCheckedAt;
  final Value<DateTime?> accountExpiresAt;
  final Value<int?> accountMaxConnections;
  final Value<int?> accountActiveConnections;
  final Value<int> rowid;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.profileId = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.serverUrl = const Value.absent(),
    this.username = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.accountStatus = const Value.absent(),
    this.accountCheckedAt = const Value.absent(),
    this.accountExpiresAt = const Value.absent(),
    this.accountMaxConnections = const Value.absent(),
    this.accountActiveConnections = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    required String profileId,
    required PlaylistType type,
    required String name,
    required String serverUrl,
    required String username,
    this.sortOrder = const Value.absent(),
    this.accountStatus = const Value.absent(),
    this.accountCheckedAt = const Value.absent(),
    this.accountExpiresAt = const Value.absent(),
    this.accountMaxConnections = const Value.absent(),
    this.accountActiveConnections = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       profileId = Value(profileId),
       type = Value(type),
       name = Value(name),
       serverUrl = Value(serverUrl),
       username = Value(username);
  static Insertable<PlaylistRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? profileId,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? serverUrl,
    Expression<String>? username,
    Expression<int>? sortOrder,
    Expression<String>? accountStatus,
    Expression<DateTime>? accountCheckedAt,
    Expression<DateTime>? accountExpiresAt,
    Expression<int>? accountMaxConnections,
    Expression<int>? accountActiveConnections,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (profileId != null) 'profile_id': profileId,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (serverUrl != null) 'server_url': serverUrl,
      if (username != null) 'username': username,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (accountStatus != null) 'account_status': accountStatus,
      if (accountCheckedAt != null) 'account_checked_at': accountCheckedAt,
      if (accountExpiresAt != null) 'account_expires_at': accountExpiresAt,
      if (accountMaxConnections != null)
        'account_max_connections': accountMaxConnections,
      if (accountActiveConnections != null)
        'account_active_connections': accountActiveConnections,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? profileId,
    Value<PlaylistType>? type,
    Value<String>? name,
    Value<String>? serverUrl,
    Value<String>? username,
    Value<int>? sortOrder,
    Value<String?>? accountStatus,
    Value<DateTime?>? accountCheckedAt,
    Value<DateTime?>? accountExpiresAt,
    Value<int?>? accountMaxConnections,
    Value<int?>? accountActiveConnections,
    Value<int>? rowid,
  }) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      profileId: profileId ?? this.profileId,
      type: type ?? this.type,
      name: name ?? this.name,
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      sortOrder: sortOrder ?? this.sortOrder,
      accountStatus: accountStatus ?? this.accountStatus,
      accountCheckedAt: accountCheckedAt ?? this.accountCheckedAt,
      accountExpiresAt: accountExpiresAt ?? this.accountExpiresAt,
      accountMaxConnections:
          accountMaxConnections ?? this.accountMaxConnections,
      accountActiveConnections:
          accountActiveConnections ?? this.accountActiveConnections,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $PlaylistsTable.$convertertype.toSql(type.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (serverUrl.present) {
      map['server_url'] = Variable<String>(serverUrl.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (accountStatus.present) {
      map['account_status'] = Variable<String>(accountStatus.value);
    }
    if (accountCheckedAt.present) {
      map['account_checked_at'] = Variable<DateTime>(accountCheckedAt.value);
    }
    if (accountExpiresAt.present) {
      map['account_expires_at'] = Variable<DateTime>(accountExpiresAt.value);
    }
    if (accountMaxConnections.present) {
      map['account_max_connections'] = Variable<int>(
        accountMaxConnections.value,
      );
    }
    if (accountActiveConnections.present) {
      map['account_active_connections'] = Variable<int>(
        accountActiveConnections.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('profileId: $profileId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('username: $username, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('accountStatus: $accountStatus, ')
          ..write('accountCheckedAt: $accountCheckedAt, ')
          ..write('accountExpiresAt: $accountExpiresAt, ')
          ..write('accountMaxConnections: $accountMaxConnections, ')
          ..write('accountActiveConnections: $accountActiveConnections, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfileSettingEntriesTable extends ProfileSettingEntries
    with TableInfo<$ProfileSettingEntriesTable, ProfileSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileSettingEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deleted,
    profileId,
    key,
    value,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_setting_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileSettingRow> instance, {
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileSettingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $ProfileSettingEntriesTable createAlias(String alias) {
    return $ProfileSettingEntriesTable(attachedDatabase, alias);
  }
}

class ProfileSettingRow extends DataClass
    implements Insertable<ProfileSettingRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final String profileId;
  final String key;
  final String value;
  const ProfileSettingRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.profileId,
    required this.key,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['profile_id'] = Variable<String>(profileId);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  ProfileSettingEntriesCompanion toCompanion(bool nullToAbsent) {
    return ProfileSettingEntriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      profileId: Value(profileId),
      key: Value(key),
      value: Value(value),
    );
  }

  factory ProfileSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileSettingRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      profileId: serializer.fromJson<String>(json['profileId']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'profileId': serializer.toJson<String>(profileId),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  ProfileSettingRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? deleted,
    String? profileId,
    String? key,
    String? value,
  }) => ProfileSettingRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    profileId: profileId ?? this.profileId,
    key: key ?? this.key,
    value: value ?? this.value,
  );
  ProfileSettingRow copyWithCompanion(ProfileSettingEntriesCompanion data) {
    return ProfileSettingRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileSettingRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('profileId: $profileId, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, deleted, profileId, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileSettingRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.profileId == this.profileId &&
          other.key == this.key &&
          other.value == this.value);
}

class ProfileSettingEntriesCompanion
    extends UpdateCompanion<ProfileSettingRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> profileId;
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const ProfileSettingEntriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.profileId = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileSettingEntriesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    required String profileId,
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       profileId = Value(profileId),
       key = Value(key),
       value = Value(value);
  static Insertable<ProfileSettingRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? profileId,
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (profileId != null) 'profile_id': profileId,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileSettingEntriesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? profileId,
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return ProfileSettingEntriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      profileId: profileId ?? this.profileId,
      key: key ?? this.key,
      value: value ?? this.value,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileSettingEntriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('profileId: $profileId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceSettingEntriesTable extends DeviceSettingEntries
    with TableInfo<$DeviceSettingEntriesTable, DeviceSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceSettingEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_setting_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  DeviceSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $DeviceSettingEntriesTable createAlias(String alias) {
    return $DeviceSettingEntriesTable(attachedDatabase, alias);
  }
}

class DeviceSettingRow extends DataClass
    implements Insertable<DeviceSettingRow> {
  final String key;
  final String value;
  const DeviceSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  DeviceSettingEntriesCompanion toCompanion(bool nullToAbsent) {
    return DeviceSettingEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory DeviceSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  DeviceSettingRow copyWith({String? key, String? value}) =>
      DeviceSettingRow(key: key ?? this.key, value: value ?? this.value);
  DeviceSettingRow copyWithCompanion(DeviceSettingEntriesCompanion data) {
    return DeviceSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class DeviceSettingEntriesCompanion extends UpdateCompanion<DeviceSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const DeviceSettingEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceSettingEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<DeviceSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceSettingEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return DeviceSettingEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceSettingEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LiveCategoriesTable extends LiveCategories
    with TableInfo<$LiveCategoriesTable, LiveCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LiveCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id)',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    playlistId,
    categoryId,
    name,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'live_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<LiveCategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, categoryId};
  @override
  LiveCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LiveCategoryRow(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $LiveCategoriesTable createAlias(String alias) {
    return $LiveCategoriesTable(attachedDatabase, alias);
  }
}

class LiveCategoryRow extends DataClass implements Insertable<LiveCategoryRow> {
  final String playlistId;
  final String categoryId;
  final String name;
  final int sortOrder;
  const LiveCategoryRow({
    required this.playlistId,
    required this.categoryId,
    required this.name,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['category_id'] = Variable<String>(categoryId);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LiveCategoriesCompanion toCompanion(bool nullToAbsent) {
    return LiveCategoriesCompanion(
      playlistId: Value(playlistId),
      categoryId: Value(categoryId),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }

  factory LiveCategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LiveCategoryRow(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'categoryId': serializer.toJson<String>(categoryId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LiveCategoryRow copyWith({
    String? playlistId,
    String? categoryId,
    String? name,
    int? sortOrder,
  }) => LiveCategoryRow(
    playlistId: playlistId ?? this.playlistId,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LiveCategoryRow copyWithCompanion(LiveCategoriesCompanion data) {
    return LiveCategoryRow(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LiveCategoryRow(')
          ..write('playlistId: $playlistId, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, categoryId, name, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LiveCategoryRow &&
          other.playlistId == this.playlistId &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder);
}

class LiveCategoriesCompanion extends UpdateCompanion<LiveCategoryRow> {
  final Value<String> playlistId;
  final Value<String> categoryId;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LiveCategoriesCompanion({
    this.playlistId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LiveCategoriesCompanion.insert({
    required String playlistId,
    required String categoryId,
    required String name,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       categoryId = Value(categoryId),
       name = Value(name),
       sortOrder = Value(sortOrder);
  static Insertable<LiveCategoryRow> custom({
    Expression<String>? playlistId,
    Expression<String>? categoryId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LiveCategoriesCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? categoryId,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return LiveCategoriesCompanion(
      playlistId: playlistId ?? this.playlistId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LiveCategoriesCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LiveChannelsTable extends LiveChannels
    with TableInfo<$LiveChannelsTable, LiveChannelRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LiveChannelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id)',
    ),
  );
  static const VerificationMeta _streamIdMeta = const VerificationMeta(
    'streamId',
  );
  @override
  late final GeneratedColumn<int> streamId = GeneratedColumn<int>(
    'stream_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logoUrlMeta = const VerificationMeta(
    'logoUrl',
  );
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
    'logo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _epgChannelIdMeta = const VerificationMeta(
    'epgChannelId',
  );
  @override
  late final GeneratedColumn<String> epgChannelId = GeneratedColumn<String>(
    'epg_channel_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archiveDaysMeta = const VerificationMeta(
    'archiveDays',
  );
  @override
  late final GeneratedColumn<int> archiveDays = GeneratedColumn<int>(
    'archive_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _seenInLoadMeta = const VerificationMeta(
    'seenInLoad',
  );
  @override
  late final GeneratedColumn<DateTime> seenInLoad = GeneratedColumn<DateTime>(
    'seen_in_load',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    playlistId,
    streamId,
    number,
    name,
    logoUrl,
    epgChannelId,
    categoryId,
    archiveDays,
    seenInLoad,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'live_channels';
  @override
  VerificationContext validateIntegrity(
    Insertable<LiveChannelRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('stream_id')) {
      context.handle(
        _streamIdMeta,
        streamId.isAcceptableOrUnknown(data['stream_id']!, _streamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_streamIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    }
    if (data.containsKey('epg_channel_id')) {
      context.handle(
        _epgChannelIdMeta,
        epgChannelId.isAcceptableOrUnknown(
          data['epg_channel_id']!,
          _epgChannelIdMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('archive_days')) {
      context.handle(
        _archiveDaysMeta,
        archiveDays.isAcceptableOrUnknown(
          data['archive_days']!,
          _archiveDaysMeta,
        ),
      );
    }
    if (data.containsKey('seen_in_load')) {
      context.handle(
        _seenInLoadMeta,
        seenInLoad.isAcceptableOrUnknown(
          data['seen_in_load']!,
          _seenInLoadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_seenInLoadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, streamId};
  @override
  LiveChannelRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LiveChannelRow(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      streamId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stream_id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      ),
      epgChannelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}epg_channel_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      archiveDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archive_days'],
      )!,
      seenInLoad: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}seen_in_load'],
      )!,
    );
  }

  @override
  $LiveChannelsTable createAlias(String alias) {
    return $LiveChannelsTable(attachedDatabase, alias);
  }
}

class LiveChannelRow extends DataClass implements Insertable<LiveChannelRow> {
  final String playlistId;
  final int streamId;
  final int number;
  final String name;
  final String? logoUrl;
  final String? epgChannelId;
  final String? categoryId;
  final int archiveDays;

  /// Start time of the load that last delivered this channel. Channels from
  /// older loads are removed when a load completes.
  final DateTime seenInLoad;
  const LiveChannelRow({
    required this.playlistId,
    required this.streamId,
    required this.number,
    required this.name,
    this.logoUrl,
    this.epgChannelId,
    this.categoryId,
    required this.archiveDays,
    required this.seenInLoad,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['stream_id'] = Variable<int>(streamId);
    map['number'] = Variable<int>(number);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    if (!nullToAbsent || epgChannelId != null) {
      map['epg_channel_id'] = Variable<String>(epgChannelId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['archive_days'] = Variable<int>(archiveDays);
    map['seen_in_load'] = Variable<DateTime>(seenInLoad);
    return map;
  }

  LiveChannelsCompanion toCompanion(bool nullToAbsent) {
    return LiveChannelsCompanion(
      playlistId: Value(playlistId),
      streamId: Value(streamId),
      number: Value(number),
      name: Value(name),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
      epgChannelId: epgChannelId == null && nullToAbsent
          ? const Value.absent()
          : Value(epgChannelId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      archiveDays: Value(archiveDays),
      seenInLoad: Value(seenInLoad),
    );
  }

  factory LiveChannelRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LiveChannelRow(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      streamId: serializer.fromJson<int>(json['streamId']),
      number: serializer.fromJson<int>(json['number']),
      name: serializer.fromJson<String>(json['name']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      epgChannelId: serializer.fromJson<String?>(json['epgChannelId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      archiveDays: serializer.fromJson<int>(json['archiveDays']),
      seenInLoad: serializer.fromJson<DateTime>(json['seenInLoad']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'streamId': serializer.toJson<int>(streamId),
      'number': serializer.toJson<int>(number),
      'name': serializer.toJson<String>(name),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'epgChannelId': serializer.toJson<String?>(epgChannelId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'archiveDays': serializer.toJson<int>(archiveDays),
      'seenInLoad': serializer.toJson<DateTime>(seenInLoad),
    };
  }

  LiveChannelRow copyWith({
    String? playlistId,
    int? streamId,
    int? number,
    String? name,
    Value<String?> logoUrl = const Value.absent(),
    Value<String?> epgChannelId = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    int? archiveDays,
    DateTime? seenInLoad,
  }) => LiveChannelRow(
    playlistId: playlistId ?? this.playlistId,
    streamId: streamId ?? this.streamId,
    number: number ?? this.number,
    name: name ?? this.name,
    logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
    epgChannelId: epgChannelId.present ? epgChannelId.value : this.epgChannelId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    archiveDays: archiveDays ?? this.archiveDays,
    seenInLoad: seenInLoad ?? this.seenInLoad,
  );
  LiveChannelRow copyWithCompanion(LiveChannelsCompanion data) {
    return LiveChannelRow(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      streamId: data.streamId.present ? data.streamId.value : this.streamId,
      number: data.number.present ? data.number.value : this.number,
      name: data.name.present ? data.name.value : this.name,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      epgChannelId: data.epgChannelId.present
          ? data.epgChannelId.value
          : this.epgChannelId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      archiveDays: data.archiveDays.present
          ? data.archiveDays.value
          : this.archiveDays,
      seenInLoad: data.seenInLoad.present
          ? data.seenInLoad.value
          : this.seenInLoad,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LiveChannelRow(')
          ..write('playlistId: $playlistId, ')
          ..write('streamId: $streamId, ')
          ..write('number: $number, ')
          ..write('name: $name, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('epgChannelId: $epgChannelId, ')
          ..write('categoryId: $categoryId, ')
          ..write('archiveDays: $archiveDays, ')
          ..write('seenInLoad: $seenInLoad')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    playlistId,
    streamId,
    number,
    name,
    logoUrl,
    epgChannelId,
    categoryId,
    archiveDays,
    seenInLoad,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LiveChannelRow &&
          other.playlistId == this.playlistId &&
          other.streamId == this.streamId &&
          other.number == this.number &&
          other.name == this.name &&
          other.logoUrl == this.logoUrl &&
          other.epgChannelId == this.epgChannelId &&
          other.categoryId == this.categoryId &&
          other.archiveDays == this.archiveDays &&
          other.seenInLoad == this.seenInLoad);
}

class LiveChannelsCompanion extends UpdateCompanion<LiveChannelRow> {
  final Value<String> playlistId;
  final Value<int> streamId;
  final Value<int> number;
  final Value<String> name;
  final Value<String?> logoUrl;
  final Value<String?> epgChannelId;
  final Value<String?> categoryId;
  final Value<int> archiveDays;
  final Value<DateTime> seenInLoad;
  final Value<int> rowid;
  const LiveChannelsCompanion({
    this.playlistId = const Value.absent(),
    this.streamId = const Value.absent(),
    this.number = const Value.absent(),
    this.name = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.epgChannelId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.archiveDays = const Value.absent(),
    this.seenInLoad = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LiveChannelsCompanion.insert({
    required String playlistId,
    required int streamId,
    required int number,
    required String name,
    this.logoUrl = const Value.absent(),
    this.epgChannelId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.archiveDays = const Value.absent(),
    required DateTime seenInLoad,
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       streamId = Value(streamId),
       number = Value(number),
       name = Value(name),
       seenInLoad = Value(seenInLoad);
  static Insertable<LiveChannelRow> custom({
    Expression<String>? playlistId,
    Expression<int>? streamId,
    Expression<int>? number,
    Expression<String>? name,
    Expression<String>? logoUrl,
    Expression<String>? epgChannelId,
    Expression<String>? categoryId,
    Expression<int>? archiveDays,
    Expression<DateTime>? seenInLoad,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (streamId != null) 'stream_id': streamId,
      if (number != null) 'number': number,
      if (name != null) 'name': name,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (epgChannelId != null) 'epg_channel_id': epgChannelId,
      if (categoryId != null) 'category_id': categoryId,
      if (archiveDays != null) 'archive_days': archiveDays,
      if (seenInLoad != null) 'seen_in_load': seenInLoad,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LiveChannelsCompanion copyWith({
    Value<String>? playlistId,
    Value<int>? streamId,
    Value<int>? number,
    Value<String>? name,
    Value<String?>? logoUrl,
    Value<String?>? epgChannelId,
    Value<String?>? categoryId,
    Value<int>? archiveDays,
    Value<DateTime>? seenInLoad,
    Value<int>? rowid,
  }) {
    return LiveChannelsCompanion(
      playlistId: playlistId ?? this.playlistId,
      streamId: streamId ?? this.streamId,
      number: number ?? this.number,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      epgChannelId: epgChannelId ?? this.epgChannelId,
      categoryId: categoryId ?? this.categoryId,
      archiveDays: archiveDays ?? this.archiveDays,
      seenInLoad: seenInLoad ?? this.seenInLoad,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (streamId.present) {
      map['stream_id'] = Variable<int>(streamId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (epgChannelId.present) {
      map['epg_channel_id'] = Variable<String>(epgChannelId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (archiveDays.present) {
      map['archive_days'] = Variable<int>(archiveDays.value);
    }
    if (seenInLoad.present) {
      map['seen_in_load'] = Variable<DateTime>(seenInLoad.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LiveChannelsCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('streamId: $streamId, ')
          ..write('number: $number, ')
          ..write('name: $name, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('epgChannelId: $epgChannelId, ')
          ..write('categoryId: $categoryId, ')
          ..write('archiveDays: $archiveDays, ')
          ..write('seenInLoad: $seenInLoad, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogStatesTable extends CatalogStates
    with TableInfo<$CatalogStatesTable, CatalogStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id)',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loadedAtMeta = const VerificationMeta(
    'loadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loadedAt = GeneratedColumn<DateTime>(
    'loaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [playlistId, kind, loadedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('loaded_at')) {
      context.handle(
        _loadedAtMeta,
        loadedAt.isAcceptableOrUnknown(data['loaded_at']!, _loadedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loadedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, kind};
  @override
  CatalogStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogStateRow(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      loadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}loaded_at'],
      )!,
    );
  }

  @override
  $CatalogStatesTable createAlias(String alias) {
    return $CatalogStatesTable(attachedDatabase, alias);
  }
}

class CatalogStateRow extends DataClass implements Insertable<CatalogStateRow> {
  final String playlistId;
  final String kind;
  final DateTime loadedAt;
  const CatalogStateRow({
    required this.playlistId,
    required this.kind,
    required this.loadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['kind'] = Variable<String>(kind);
    map['loaded_at'] = Variable<DateTime>(loadedAt);
    return map;
  }

  CatalogStatesCompanion toCompanion(bool nullToAbsent) {
    return CatalogStatesCompanion(
      playlistId: Value(playlistId),
      kind: Value(kind),
      loadedAt: Value(loadedAt),
    );
  }

  factory CatalogStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogStateRow(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      kind: serializer.fromJson<String>(json['kind']),
      loadedAt: serializer.fromJson<DateTime>(json['loadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'kind': serializer.toJson<String>(kind),
      'loadedAt': serializer.toJson<DateTime>(loadedAt),
    };
  }

  CatalogStateRow copyWith({
    String? playlistId,
    String? kind,
    DateTime? loadedAt,
  }) => CatalogStateRow(
    playlistId: playlistId ?? this.playlistId,
    kind: kind ?? this.kind,
    loadedAt: loadedAt ?? this.loadedAt,
  );
  CatalogStateRow copyWithCompanion(CatalogStatesCompanion data) {
    return CatalogStateRow(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      kind: data.kind.present ? data.kind.value : this.kind,
      loadedAt: data.loadedAt.present ? data.loadedAt.value : this.loadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogStateRow(')
          ..write('playlistId: $playlistId, ')
          ..write('kind: $kind, ')
          ..write('loadedAt: $loadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, kind, loadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogStateRow &&
          other.playlistId == this.playlistId &&
          other.kind == this.kind &&
          other.loadedAt == this.loadedAt);
}

class CatalogStatesCompanion extends UpdateCompanion<CatalogStateRow> {
  final Value<String> playlistId;
  final Value<String> kind;
  final Value<DateTime> loadedAt;
  final Value<int> rowid;
  const CatalogStatesCompanion({
    this.playlistId = const Value.absent(),
    this.kind = const Value.absent(),
    this.loadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogStatesCompanion.insert({
    required String playlistId,
    required String kind,
    required DateTime loadedAt,
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       kind = Value(kind),
       loadedAt = Value(loadedAt);
  static Insertable<CatalogStateRow> custom({
    Expression<String>? playlistId,
    Expression<String>? kind,
    Expression<DateTime>? loadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (kind != null) 'kind': kind,
      if (loadedAt != null) 'loaded_at': loadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogStatesCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? kind,
    Value<DateTime>? loadedAt,
    Value<int>? rowid,
  }) {
    return CatalogStatesCompanion(
      playlistId: playlistId ?? this.playlistId,
      kind: kind ?? this.kind,
      loadedAt: loadedAt ?? this.loadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (loadedAt.present) {
      map['loaded_at'] = Variable<DateTime>(loadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogStatesCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('kind: $kind, ')
          ..write('loadedAt: $loadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EpgProgrammesTable extends EpgProgrammes
    with TableInfo<$EpgProgrammesTable, EpgProgrammeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpgProgrammesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id)',
    ),
  );
  static const VerificationMeta _channelKeyMeta = const VerificationMeta(
    'channelKey',
  );
  @override
  late final GeneratedColumn<String> channelKey = GeneratedColumn<String>(
    'channel_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startsAtMeta = const VerificationMeta(
    'startsAt',
  );
  @override
  late final GeneratedColumn<int> startsAt = GeneratedColumn<int>(
    'starts_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsAtMeta = const VerificationMeta('endsAt');
  @override
  late final GeneratedColumn<int> endsAt = GeneratedColumn<int>(
    'ends_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seenInLoadMeta = const VerificationMeta(
    'seenInLoad',
  );
  @override
  late final GeneratedColumn<int> seenInLoad = GeneratedColumn<int>(
    'seen_in_load',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    playlistId,
    channelKey,
    startsAt,
    endsAt,
    title,
    description,
    seenInLoad,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'epg_programmes';
  @override
  VerificationContext validateIntegrity(
    Insertable<EpgProgrammeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('channel_key')) {
      context.handle(
        _channelKeyMeta,
        channelKey.isAcceptableOrUnknown(data['channel_key']!, _channelKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_channelKeyMeta);
    }
    if (data.containsKey('starts_at')) {
      context.handle(
        _startsAtMeta,
        startsAt.isAcceptableOrUnknown(data['starts_at']!, _startsAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startsAtMeta);
    }
    if (data.containsKey('ends_at')) {
      context.handle(
        _endsAtMeta,
        endsAt.isAcceptableOrUnknown(data['ends_at']!, _endsAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endsAtMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('seen_in_load')) {
      context.handle(
        _seenInLoadMeta,
        seenInLoad.isAcceptableOrUnknown(
          data['seen_in_load']!,
          _seenInLoadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_seenInLoadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, channelKey, startsAt};
  @override
  EpgProgrammeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EpgProgrammeRow(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      channelKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_key'],
      )!,
      startsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}starts_at'],
      )!,
      endsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ends_at'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      seenInLoad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seen_in_load'],
      )!,
    );
  }

  @override
  $EpgProgrammesTable createAlias(String alias) {
    return $EpgProgrammesTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class EpgProgrammeRow extends DataClass implements Insertable<EpgProgrammeRow> {
  final String playlistId;
  final String channelKey;
  final int startsAt;
  final int endsAt;
  final String title;
  final String? description;

  /// Start time (milliseconds) of the load that last delivered this
  /// programme.
  final int seenInLoad;
  const EpgProgrammeRow({
    required this.playlistId,
    required this.channelKey,
    required this.startsAt,
    required this.endsAt,
    required this.title,
    this.description,
    required this.seenInLoad,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['channel_key'] = Variable<String>(channelKey);
    map['starts_at'] = Variable<int>(startsAt);
    map['ends_at'] = Variable<int>(endsAt);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['seen_in_load'] = Variable<int>(seenInLoad);
    return map;
  }

  EpgProgrammesCompanion toCompanion(bool nullToAbsent) {
    return EpgProgrammesCompanion(
      playlistId: Value(playlistId),
      channelKey: Value(channelKey),
      startsAt: Value(startsAt),
      endsAt: Value(endsAt),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      seenInLoad: Value(seenInLoad),
    );
  }

  factory EpgProgrammeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EpgProgrammeRow(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      channelKey: serializer.fromJson<String>(json['channelKey']),
      startsAt: serializer.fromJson<int>(json['startsAt']),
      endsAt: serializer.fromJson<int>(json['endsAt']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      seenInLoad: serializer.fromJson<int>(json['seenInLoad']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'channelKey': serializer.toJson<String>(channelKey),
      'startsAt': serializer.toJson<int>(startsAt),
      'endsAt': serializer.toJson<int>(endsAt),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'seenInLoad': serializer.toJson<int>(seenInLoad),
    };
  }

  EpgProgrammeRow copyWith({
    String? playlistId,
    String? channelKey,
    int? startsAt,
    int? endsAt,
    String? title,
    Value<String?> description = const Value.absent(),
    int? seenInLoad,
  }) => EpgProgrammeRow(
    playlistId: playlistId ?? this.playlistId,
    channelKey: channelKey ?? this.channelKey,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt ?? this.endsAt,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    seenInLoad: seenInLoad ?? this.seenInLoad,
  );
  EpgProgrammeRow copyWithCompanion(EpgProgrammesCompanion data) {
    return EpgProgrammeRow(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      channelKey: data.channelKey.present
          ? data.channelKey.value
          : this.channelKey,
      startsAt: data.startsAt.present ? data.startsAt.value : this.startsAt,
      endsAt: data.endsAt.present ? data.endsAt.value : this.endsAt,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      seenInLoad: data.seenInLoad.present
          ? data.seenInLoad.value
          : this.seenInLoad,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EpgProgrammeRow(')
          ..write('playlistId: $playlistId, ')
          ..write('channelKey: $channelKey, ')
          ..write('startsAt: $startsAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('seenInLoad: $seenInLoad')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    playlistId,
    channelKey,
    startsAt,
    endsAt,
    title,
    description,
    seenInLoad,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EpgProgrammeRow &&
          other.playlistId == this.playlistId &&
          other.channelKey == this.channelKey &&
          other.startsAt == this.startsAt &&
          other.endsAt == this.endsAt &&
          other.title == this.title &&
          other.description == this.description &&
          other.seenInLoad == this.seenInLoad);
}

class EpgProgrammesCompanion extends UpdateCompanion<EpgProgrammeRow> {
  final Value<String> playlistId;
  final Value<String> channelKey;
  final Value<int> startsAt;
  final Value<int> endsAt;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> seenInLoad;
  const EpgProgrammesCompanion({
    this.playlistId = const Value.absent(),
    this.channelKey = const Value.absent(),
    this.startsAt = const Value.absent(),
    this.endsAt = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.seenInLoad = const Value.absent(),
  });
  EpgProgrammesCompanion.insert({
    required String playlistId,
    required String channelKey,
    required int startsAt,
    required int endsAt,
    required String title,
    this.description = const Value.absent(),
    required int seenInLoad,
  }) : playlistId = Value(playlistId),
       channelKey = Value(channelKey),
       startsAt = Value(startsAt),
       endsAt = Value(endsAt),
       title = Value(title),
       seenInLoad = Value(seenInLoad);
  static Insertable<EpgProgrammeRow> custom({
    Expression<String>? playlistId,
    Expression<String>? channelKey,
    Expression<int>? startsAt,
    Expression<int>? endsAt,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? seenInLoad,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (channelKey != null) 'channel_key': channelKey,
      if (startsAt != null) 'starts_at': startsAt,
      if (endsAt != null) 'ends_at': endsAt,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (seenInLoad != null) 'seen_in_load': seenInLoad,
    });
  }

  EpgProgrammesCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? channelKey,
    Value<int>? startsAt,
    Value<int>? endsAt,
    Value<String>? title,
    Value<String?>? description,
    Value<int>? seenInLoad,
  }) {
    return EpgProgrammesCompanion(
      playlistId: playlistId ?? this.playlistId,
      channelKey: channelKey ?? this.channelKey,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      title: title ?? this.title,
      description: description ?? this.description,
      seenInLoad: seenInLoad ?? this.seenInLoad,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (channelKey.present) {
      map['channel_key'] = Variable<String>(channelKey.value);
    }
    if (startsAt.present) {
      map['starts_at'] = Variable<int>(startsAt.value);
    }
    if (endsAt.present) {
      map['ends_at'] = Variable<int>(endsAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (seenInLoad.present) {
      map['seen_in_load'] = Variable<int>(seenInLoad.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpgProgrammesCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('channelKey: $channelKey, ')
          ..write('startsAt: $startsAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('seenInLoad: $seenInLoad')
          ..write(')'))
        .toString();
  }
}

class $MovieCategoriesTable extends MovieCategories
    with TableInfo<$MovieCategoriesTable, MovieCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovieCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id)',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    playlistId,
    categoryId,
    name,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movie_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovieCategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, categoryId};
  @override
  MovieCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovieCategoryRow(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $MovieCategoriesTable createAlias(String alias) {
    return $MovieCategoriesTable(attachedDatabase, alias);
  }
}

class MovieCategoryRow extends DataClass
    implements Insertable<MovieCategoryRow> {
  final String playlistId;
  final String categoryId;
  final String name;
  final int sortOrder;
  const MovieCategoryRow({
    required this.playlistId,
    required this.categoryId,
    required this.name,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['category_id'] = Variable<String>(categoryId);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  MovieCategoriesCompanion toCompanion(bool nullToAbsent) {
    return MovieCategoriesCompanion(
      playlistId: Value(playlistId),
      categoryId: Value(categoryId),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }

  factory MovieCategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovieCategoryRow(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'categoryId': serializer.toJson<String>(categoryId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  MovieCategoryRow copyWith({
    String? playlistId,
    String? categoryId,
    String? name,
    int? sortOrder,
  }) => MovieCategoryRow(
    playlistId: playlistId ?? this.playlistId,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  MovieCategoryRow copyWithCompanion(MovieCategoriesCompanion data) {
    return MovieCategoryRow(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovieCategoryRow(')
          ..write('playlistId: $playlistId, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, categoryId, name, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovieCategoryRow &&
          other.playlistId == this.playlistId &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder);
}

class MovieCategoriesCompanion extends UpdateCompanion<MovieCategoryRow> {
  final Value<String> playlistId;
  final Value<String> categoryId;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const MovieCategoriesCompanion({
    this.playlistId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovieCategoriesCompanion.insert({
    required String playlistId,
    required String categoryId,
    required String name,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       categoryId = Value(categoryId),
       name = Value(name),
       sortOrder = Value(sortOrder);
  static Insertable<MovieCategoryRow> custom({
    Expression<String>? playlistId,
    Expression<String>? categoryId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovieCategoriesCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? categoryId,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return MovieCategoriesCompanion(
      playlistId: playlistId ?? this.playlistId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovieCategoriesCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MoviesTable extends Movies with TableInfo<$MoviesTable, MovieRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoviesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id)',
    ),
  );
  static const VerificationMeta _streamIdMeta = const VerificationMeta(
    'streamId',
  );
  @override
  late final GeneratedColumn<int> streamId = GeneratedColumn<int>(
    'stream_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posterUrlMeta = const VerificationMeta(
    'posterUrl',
  );
  @override
  late final GeneratedColumn<String> posterUrl = GeneratedColumn<String>(
    'poster_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _containerExtensionMeta =
      const VerificationMeta('containerExtension');
  @override
  late final GeneratedColumn<String> containerExtension =
      GeneratedColumn<String>(
        'container_extension',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _seenInLoadMeta = const VerificationMeta(
    'seenInLoad',
  );
  @override
  late final GeneratedColumn<DateTime> seenInLoad = GeneratedColumn<DateTime>(
    'seen_in_load',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    playlistId,
    streamId,
    name,
    position,
    posterUrl,
    rating,
    addedAt,
    categoryId,
    containerExtension,
    seenInLoad,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movies';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovieRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('stream_id')) {
      context.handle(
        _streamIdMeta,
        streamId.isAcceptableOrUnknown(data['stream_id']!, _streamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_streamIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('poster_url')) {
      context.handle(
        _posterUrlMeta,
        posterUrl.isAcceptableOrUnknown(data['poster_url']!, _posterUrlMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('container_extension')) {
      context.handle(
        _containerExtensionMeta,
        containerExtension.isAcceptableOrUnknown(
          data['container_extension']!,
          _containerExtensionMeta,
        ),
      );
    }
    if (data.containsKey('seen_in_load')) {
      context.handle(
        _seenInLoadMeta,
        seenInLoad.isAcceptableOrUnknown(
          data['seen_in_load']!,
          _seenInLoadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_seenInLoadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, streamId};
  @override
  MovieRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovieRow(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      streamId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stream_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      posterUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_url'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      containerExtension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}container_extension'],
      ),
      seenInLoad: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}seen_in_load'],
      )!,
    );
  }

  @override
  $MoviesTable createAlias(String alias) {
    return $MoviesTable(attachedDatabase, alias);
  }
}

class MovieRow extends DataClass implements Insertable<MovieRow> {
  final String playlistId;
  final int streamId;
  final String name;
  final int position;
  final String? posterUrl;
  final double? rating;
  final DateTime? addedAt;
  final String? categoryId;
  final String? containerExtension;

  /// Start time of the load that last delivered this movie. Movies from
  /// older loads are removed when a load completes.
  final DateTime seenInLoad;
  const MovieRow({
    required this.playlistId,
    required this.streamId,
    required this.name,
    required this.position,
    this.posterUrl,
    this.rating,
    this.addedAt,
    this.categoryId,
    this.containerExtension,
    required this.seenInLoad,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['stream_id'] = Variable<int>(streamId);
    map['name'] = Variable<String>(name);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || posterUrl != null) {
      map['poster_url'] = Variable<String>(posterUrl);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    if (!nullToAbsent || addedAt != null) {
      map['added_at'] = Variable<DateTime>(addedAt);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || containerExtension != null) {
      map['container_extension'] = Variable<String>(containerExtension);
    }
    map['seen_in_load'] = Variable<DateTime>(seenInLoad);
    return map;
  }

  MoviesCompanion toCompanion(bool nullToAbsent) {
    return MoviesCompanion(
      playlistId: Value(playlistId),
      streamId: Value(streamId),
      name: Value(name),
      position: Value(position),
      posterUrl: posterUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(posterUrl),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      addedAt: addedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(addedAt),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      containerExtension: containerExtension == null && nullToAbsent
          ? const Value.absent()
          : Value(containerExtension),
      seenInLoad: Value(seenInLoad),
    );
  }

  factory MovieRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovieRow(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      streamId: serializer.fromJson<int>(json['streamId']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<int>(json['position']),
      posterUrl: serializer.fromJson<String?>(json['posterUrl']),
      rating: serializer.fromJson<double?>(json['rating']),
      addedAt: serializer.fromJson<DateTime?>(json['addedAt']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      containerExtension: serializer.fromJson<String?>(
        json['containerExtension'],
      ),
      seenInLoad: serializer.fromJson<DateTime>(json['seenInLoad']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'streamId': serializer.toJson<int>(streamId),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<int>(position),
      'posterUrl': serializer.toJson<String?>(posterUrl),
      'rating': serializer.toJson<double?>(rating),
      'addedAt': serializer.toJson<DateTime?>(addedAt),
      'categoryId': serializer.toJson<String?>(categoryId),
      'containerExtension': serializer.toJson<String?>(containerExtension),
      'seenInLoad': serializer.toJson<DateTime>(seenInLoad),
    };
  }

  MovieRow copyWith({
    String? playlistId,
    int? streamId,
    String? name,
    int? position,
    Value<String?> posterUrl = const Value.absent(),
    Value<double?> rating = const Value.absent(),
    Value<DateTime?> addedAt = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    Value<String?> containerExtension = const Value.absent(),
    DateTime? seenInLoad,
  }) => MovieRow(
    playlistId: playlistId ?? this.playlistId,
    streamId: streamId ?? this.streamId,
    name: name ?? this.name,
    position: position ?? this.position,
    posterUrl: posterUrl.present ? posterUrl.value : this.posterUrl,
    rating: rating.present ? rating.value : this.rating,
    addedAt: addedAt.present ? addedAt.value : this.addedAt,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    containerExtension: containerExtension.present
        ? containerExtension.value
        : this.containerExtension,
    seenInLoad: seenInLoad ?? this.seenInLoad,
  );
  MovieRow copyWithCompanion(MoviesCompanion data) {
    return MovieRow(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      streamId: data.streamId.present ? data.streamId.value : this.streamId,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
      posterUrl: data.posterUrl.present ? data.posterUrl.value : this.posterUrl,
      rating: data.rating.present ? data.rating.value : this.rating,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      containerExtension: data.containerExtension.present
          ? data.containerExtension.value
          : this.containerExtension,
      seenInLoad: data.seenInLoad.present
          ? data.seenInLoad.value
          : this.seenInLoad,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovieRow(')
          ..write('playlistId: $playlistId, ')
          ..write('streamId: $streamId, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('posterUrl: $posterUrl, ')
          ..write('rating: $rating, ')
          ..write('addedAt: $addedAt, ')
          ..write('categoryId: $categoryId, ')
          ..write('containerExtension: $containerExtension, ')
          ..write('seenInLoad: $seenInLoad')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    playlistId,
    streamId,
    name,
    position,
    posterUrl,
    rating,
    addedAt,
    categoryId,
    containerExtension,
    seenInLoad,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovieRow &&
          other.playlistId == this.playlistId &&
          other.streamId == this.streamId &&
          other.name == this.name &&
          other.position == this.position &&
          other.posterUrl == this.posterUrl &&
          other.rating == this.rating &&
          other.addedAt == this.addedAt &&
          other.categoryId == this.categoryId &&
          other.containerExtension == this.containerExtension &&
          other.seenInLoad == this.seenInLoad);
}

class MoviesCompanion extends UpdateCompanion<MovieRow> {
  final Value<String> playlistId;
  final Value<int> streamId;
  final Value<String> name;
  final Value<int> position;
  final Value<String?> posterUrl;
  final Value<double?> rating;
  final Value<DateTime?> addedAt;
  final Value<String?> categoryId;
  final Value<String?> containerExtension;
  final Value<DateTime> seenInLoad;
  final Value<int> rowid;
  const MoviesCompanion({
    this.playlistId = const Value.absent(),
    this.streamId = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
    this.posterUrl = const Value.absent(),
    this.rating = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.containerExtension = const Value.absent(),
    this.seenInLoad = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoviesCompanion.insert({
    required String playlistId,
    required int streamId,
    required String name,
    required int position,
    this.posterUrl = const Value.absent(),
    this.rating = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.containerExtension = const Value.absent(),
    required DateTime seenInLoad,
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       streamId = Value(streamId),
       name = Value(name),
       position = Value(position),
       seenInLoad = Value(seenInLoad);
  static Insertable<MovieRow> custom({
    Expression<String>? playlistId,
    Expression<int>? streamId,
    Expression<String>? name,
    Expression<int>? position,
    Expression<String>? posterUrl,
    Expression<double>? rating,
    Expression<DateTime>? addedAt,
    Expression<String>? categoryId,
    Expression<String>? containerExtension,
    Expression<DateTime>? seenInLoad,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (streamId != null) 'stream_id': streamId,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
      if (posterUrl != null) 'poster_url': posterUrl,
      if (rating != null) 'rating': rating,
      if (addedAt != null) 'added_at': addedAt,
      if (categoryId != null) 'category_id': categoryId,
      if (containerExtension != null) 'container_extension': containerExtension,
      if (seenInLoad != null) 'seen_in_load': seenInLoad,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoviesCompanion copyWith({
    Value<String>? playlistId,
    Value<int>? streamId,
    Value<String>? name,
    Value<int>? position,
    Value<String?>? posterUrl,
    Value<double?>? rating,
    Value<DateTime?>? addedAt,
    Value<String?>? categoryId,
    Value<String?>? containerExtension,
    Value<DateTime>? seenInLoad,
    Value<int>? rowid,
  }) {
    return MoviesCompanion(
      playlistId: playlistId ?? this.playlistId,
      streamId: streamId ?? this.streamId,
      name: name ?? this.name,
      position: position ?? this.position,
      posterUrl: posterUrl ?? this.posterUrl,
      rating: rating ?? this.rating,
      addedAt: addedAt ?? this.addedAt,
      categoryId: categoryId ?? this.categoryId,
      containerExtension: containerExtension ?? this.containerExtension,
      seenInLoad: seenInLoad ?? this.seenInLoad,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (streamId.present) {
      map['stream_id'] = Variable<int>(streamId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (posterUrl.present) {
      map['poster_url'] = Variable<String>(posterUrl.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (containerExtension.present) {
      map['container_extension'] = Variable<String>(containerExtension.value);
    }
    if (seenInLoad.present) {
      map['seen_in_load'] = Variable<DateTime>(seenInLoad.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoviesCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('streamId: $streamId, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('posterUrl: $posterUrl, ')
          ..write('rating: $rating, ')
          ..write('addedAt: $addedAt, ')
          ..write('categoryId: $categoryId, ')
          ..write('containerExtension: $containerExtension, ')
          ..write('seenInLoad: $seenInLoad, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MovieStatesTable extends MovieStates
    with TableInfo<$MovieStatesTable, MovieStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovieStatesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id)',
    ),
  );
  static const VerificationMeta _streamIdMeta = const VerificationMeta(
    'streamId',
  );
  @override
  late final GeneratedColumn<int> streamId = GeneratedColumn<int>(
    'stream_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionSecondsMeta = const VerificationMeta(
    'positionSeconds',
  );
  @override
  late final GeneratedColumn<int> positionSeconds = GeneratedColumn<int>(
    'position_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _watchedMeta = const VerificationMeta(
    'watched',
  );
  @override
  late final GeneratedColumn<bool> watched = GeneratedColumn<bool>(
    'watched',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("watched" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastWatchedAtMeta = const VerificationMeta(
    'lastWatchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastWatchedAt =
      GeneratedColumn<DateTime>(
        'last_watched_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deleted,
    profileId,
    playlistId,
    streamId,
    positionSeconds,
    durationSeconds,
    watched,
    favorite,
    lastWatchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movie_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovieStateRow> instance, {
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('stream_id')) {
      context.handle(
        _streamIdMeta,
        streamId.isAcceptableOrUnknown(data['stream_id']!, _streamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_streamIdMeta);
    }
    if (data.containsKey('position_seconds')) {
      context.handle(
        _positionSecondsMeta,
        positionSeconds.isAcceptableOrUnknown(
          data['position_seconds']!,
          _positionSecondsMeta,
        ),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('watched')) {
      context.handle(
        _watchedMeta,
        watched.isAcceptableOrUnknown(data['watched']!, _watchedMeta),
      );
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('last_watched_at')) {
      context.handle(
        _lastWatchedAtMeta,
        lastWatchedAt.isAcceptableOrUnknown(
          data['last_watched_at']!,
          _lastWatchedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MovieStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovieStateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      streamId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stream_id'],
      )!,
      positionSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_seconds'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      watched: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}watched'],
      )!,
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      lastWatchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_watched_at'],
      ),
    );
  }

  @override
  $MovieStatesTable createAlias(String alias) {
    return $MovieStatesTable(attachedDatabase, alias);
  }
}

class MovieStateRow extends DataClass implements Insertable<MovieStateRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final String profileId;
  final String playlistId;
  final int streamId;
  final int positionSeconds;
  final int? durationSeconds;
  final bool watched;
  final bool favorite;
  final DateTime? lastWatchedAt;
  const MovieStateRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.profileId,
    required this.playlistId,
    required this.streamId,
    required this.positionSeconds,
    this.durationSeconds,
    required this.watched,
    required this.favorite,
    this.lastWatchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['profile_id'] = Variable<String>(profileId);
    map['playlist_id'] = Variable<String>(playlistId);
    map['stream_id'] = Variable<int>(streamId);
    map['position_seconds'] = Variable<int>(positionSeconds);
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    map['watched'] = Variable<bool>(watched);
    map['favorite'] = Variable<bool>(favorite);
    if (!nullToAbsent || lastWatchedAt != null) {
      map['last_watched_at'] = Variable<DateTime>(lastWatchedAt);
    }
    return map;
  }

  MovieStatesCompanion toCompanion(bool nullToAbsent) {
    return MovieStatesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      profileId: Value(profileId),
      playlistId: Value(playlistId),
      streamId: Value(streamId),
      positionSeconds: Value(positionSeconds),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      watched: Value(watched),
      favorite: Value(favorite),
      lastWatchedAt: lastWatchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastWatchedAt),
    );
  }

  factory MovieStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovieStateRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      profileId: serializer.fromJson<String>(json['profileId']),
      playlistId: serializer.fromJson<String>(json['playlistId']),
      streamId: serializer.fromJson<int>(json['streamId']),
      positionSeconds: serializer.fromJson<int>(json['positionSeconds']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      watched: serializer.fromJson<bool>(json['watched']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      lastWatchedAt: serializer.fromJson<DateTime?>(json['lastWatchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'profileId': serializer.toJson<String>(profileId),
      'playlistId': serializer.toJson<String>(playlistId),
      'streamId': serializer.toJson<int>(streamId),
      'positionSeconds': serializer.toJson<int>(positionSeconds),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'watched': serializer.toJson<bool>(watched),
      'favorite': serializer.toJson<bool>(favorite),
      'lastWatchedAt': serializer.toJson<DateTime?>(lastWatchedAt),
    };
  }

  MovieStateRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? deleted,
    String? profileId,
    String? playlistId,
    int? streamId,
    int? positionSeconds,
    Value<int?> durationSeconds = const Value.absent(),
    bool? watched,
    bool? favorite,
    Value<DateTime?> lastWatchedAt = const Value.absent(),
  }) => MovieStateRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    profileId: profileId ?? this.profileId,
    playlistId: playlistId ?? this.playlistId,
    streamId: streamId ?? this.streamId,
    positionSeconds: positionSeconds ?? this.positionSeconds,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    watched: watched ?? this.watched,
    favorite: favorite ?? this.favorite,
    lastWatchedAt: lastWatchedAt.present
        ? lastWatchedAt.value
        : this.lastWatchedAt,
  );
  MovieStateRow copyWithCompanion(MovieStatesCompanion data) {
    return MovieStateRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      streamId: data.streamId.present ? data.streamId.value : this.streamId,
      positionSeconds: data.positionSeconds.present
          ? data.positionSeconds.value
          : this.positionSeconds,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      watched: data.watched.present ? data.watched.value : this.watched,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      lastWatchedAt: data.lastWatchedAt.present
          ? data.lastWatchedAt.value
          : this.lastWatchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovieStateRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('profileId: $profileId, ')
          ..write('playlistId: $playlistId, ')
          ..write('streamId: $streamId, ')
          ..write('positionSeconds: $positionSeconds, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('watched: $watched, ')
          ..write('favorite: $favorite, ')
          ..write('lastWatchedAt: $lastWatchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deleted,
    profileId,
    playlistId,
    streamId,
    positionSeconds,
    durationSeconds,
    watched,
    favorite,
    lastWatchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovieStateRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.profileId == this.profileId &&
          other.playlistId == this.playlistId &&
          other.streamId == this.streamId &&
          other.positionSeconds == this.positionSeconds &&
          other.durationSeconds == this.durationSeconds &&
          other.watched == this.watched &&
          other.favorite == this.favorite &&
          other.lastWatchedAt == this.lastWatchedAt);
}

class MovieStatesCompanion extends UpdateCompanion<MovieStateRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> profileId;
  final Value<String> playlistId;
  final Value<int> streamId;
  final Value<int> positionSeconds;
  final Value<int?> durationSeconds;
  final Value<bool> watched;
  final Value<bool> favorite;
  final Value<DateTime?> lastWatchedAt;
  final Value<int> rowid;
  const MovieStatesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.profileId = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.streamId = const Value.absent(),
    this.positionSeconds = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.watched = const Value.absent(),
    this.favorite = const Value.absent(),
    this.lastWatchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovieStatesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    required String profileId,
    required String playlistId,
    required int streamId,
    this.positionSeconds = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.watched = const Value.absent(),
    this.favorite = const Value.absent(),
    this.lastWatchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       profileId = Value(profileId),
       playlistId = Value(playlistId),
       streamId = Value(streamId);
  static Insertable<MovieStateRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? profileId,
    Expression<String>? playlistId,
    Expression<int>? streamId,
    Expression<int>? positionSeconds,
    Expression<int>? durationSeconds,
    Expression<bool>? watched,
    Expression<bool>? favorite,
    Expression<DateTime>? lastWatchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (profileId != null) 'profile_id': profileId,
      if (playlistId != null) 'playlist_id': playlistId,
      if (streamId != null) 'stream_id': streamId,
      if (positionSeconds != null) 'position_seconds': positionSeconds,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (watched != null) 'watched': watched,
      if (favorite != null) 'favorite': favorite,
      if (lastWatchedAt != null) 'last_watched_at': lastWatchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovieStatesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? profileId,
    Value<String>? playlistId,
    Value<int>? streamId,
    Value<int>? positionSeconds,
    Value<int?>? durationSeconds,
    Value<bool>? watched,
    Value<bool>? favorite,
    Value<DateTime?>? lastWatchedAt,
    Value<int>? rowid,
  }) {
    return MovieStatesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      profileId: profileId ?? this.profileId,
      playlistId: playlistId ?? this.playlistId,
      streamId: streamId ?? this.streamId,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      watched: watched ?? this.watched,
      favorite: favorite ?? this.favorite,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (streamId.present) {
      map['stream_id'] = Variable<int>(streamId.value);
    }
    if (positionSeconds.present) {
      map['position_seconds'] = Variable<int>(positionSeconds.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (watched.present) {
      map['watched'] = Variable<bool>(watched.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (lastWatchedAt.present) {
      map['last_watched_at'] = Variable<DateTime>(lastWatchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovieStatesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('profileId: $profileId, ')
          ..write('playlistId: $playlistId, ')
          ..write('streamId: $streamId, ')
          ..write('positionSeconds: $positionSeconds, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('watched: $watched, ')
          ..write('favorite: $favorite, ')
          ..write('lastWatchedAt: $lastWatchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $ProfileSettingEntriesTable profileSettingEntries =
      $ProfileSettingEntriesTable(this);
  late final $DeviceSettingEntriesTable deviceSettingEntries =
      $DeviceSettingEntriesTable(this);
  late final $LiveCategoriesTable liveCategories = $LiveCategoriesTable(this);
  late final $LiveChannelsTable liveChannels = $LiveChannelsTable(this);
  late final $CatalogStatesTable catalogStates = $CatalogStatesTable(this);
  late final $EpgProgrammesTable epgProgrammes = $EpgProgrammesTable(this);
  late final $MovieCategoriesTable movieCategories = $MovieCategoriesTable(
    this,
  );
  late final $MoviesTable movies = $MoviesTable(this);
  late final $MovieStatesTable movieStates = $MovieStatesTable(this);
  late final Index liveChannelsByCategory = Index(
    'live_channels_by_category',
    'CREATE INDEX live_channels_by_category ON live_channels (playlist_id, category_id, number)',
  );
  late final Index liveChannelsByNumber = Index(
    'live_channels_by_number',
    'CREATE INDEX live_channels_by_number ON live_channels (playlist_id, number)',
  );
  late final Index moviesByCategory = Index(
    'movies_by_category',
    'CREATE INDEX movies_by_category ON movies (playlist_id, category_id, position)',
  );
  late final Index moviesByPosition = Index(
    'movies_by_position',
    'CREATE INDEX movies_by_position ON movies (playlist_id, position)',
  );
  late final Index movieStatesByMovie = Index(
    'movie_states_by_movie',
    'CREATE UNIQUE INDEX movie_states_by_movie ON movie_states (profile_id, playlist_id, stream_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    playlists,
    profileSettingEntries,
    deviceSettingEntries,
    liveCategories,
    liveChannels,
    catalogStates,
    epgProgrammes,
    movieCategories,
    movies,
    movieStates,
    liveChannelsByCategory,
    liveChannelsByNumber,
    moviesByCategory,
    moviesByPosition,
    movieStatesByMovie,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> deleted,
  required String name,
  Value<int> avatarPreset,
  Value<Uint8List?> avatarImage,
  Value<String?> pinHash,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> deleted,
  Value<String> name,
  Value<int> avatarPreset,
  Value<Uint8List?> avatarImage,
  Value<String?> pinHash,
  Value<int> sortOrder,
  Value<int> rowid,
});

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistsTable, List<PlaylistRow>>
  _playlistsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playlists,
    aliasName: 'profiles__id__playlists__profile_id',
  );

  $$PlaylistsTableProcessedTableManager get playlistsRefs {
    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProfileSettingEntriesTable,
    List<ProfileSettingRow>
  >
  _profileSettingEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.profileSettingEntries,
        aliasName: 'profiles__id__profile_setting_entries__profile_id',
      );

  $$ProfileSettingEntriesTableProcessedTableManager
  get profileSettingEntriesRefs {
    final manager = $$ProfileSettingEntriesTableTableManager(
      $_db,
      $_db.profileSettingEntries,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _profileSettingEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MovieStatesTable, List<MovieStateRow>>
  _movieStatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.movieStates,
    aliasName: 'profiles__id__movie_states__profile_id',
  );

  $$MovieStatesTableProcessedTableManager get movieStatesRefs {
    final manager = $$MovieStatesTableTableManager(
      $_db,
      $_db.movieStates,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_movieStatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avatarPreset => $composableBuilder(
    column: $table.avatarPreset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get avatarImage => $composableBuilder(
    column: $table.avatarImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistsRefs(
    Expression<bool> Function($$PlaylistsTableFilterComposer f) f,
  ) {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> profileSettingEntriesRefs(
    Expression<bool> Function($$ProfileSettingEntriesTableFilterComposer f) f,
  ) {
    final $$ProfileSettingEntriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.profileSettingEntries,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProfileSettingEntriesTableFilterComposer(
                $db: $db,
                $table: $db.profileSettingEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> movieStatesRefs(
    Expression<bool> Function($$MovieStatesTableFilterComposer f) f,
  ) {
    final $$MovieStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movieStates,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovieStatesTableFilterComposer(
            $db: $db,
            $table: $db.movieStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avatarPreset => $composableBuilder(
    column: $table.avatarPreset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get avatarImage => $composableBuilder(
    column: $table.avatarImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get avatarPreset => $composableBuilder(
    column: $table.avatarPreset,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get avatarImage => $composableBuilder(
    column: $table.avatarImage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> playlistsRefs<T extends Object>(
    Expression<T> Function($$PlaylistsTableAnnotationComposer a) f,
  ) {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> profileSettingEntriesRefs<T extends Object>(
    Expression<T> Function($$ProfileSettingEntriesTableAnnotationComposer a) f,
  ) {
    final $$ProfileSettingEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.profileSettingEntries,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProfileSettingEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.profileSettingEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> movieStatesRefs<T extends Object>(
    Expression<T> Function($$MovieStatesTableAnnotationComposer a) f,
  ) {
    final $$MovieStatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movieStates,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovieStatesTableAnnotationComposer(
            $db: $db,
            $table: $db.movieStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          ProfileRow,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (ProfileRow, $$ProfilesTableReferences),
          ProfileRow,
          PrefetchHooks Function({
            bool playlistsRefs,
            bool profileSettingEntriesRefs,
            bool movieStatesRefs,
          })
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> avatarPreset = const Value.absent(),
                Value<Uint8List?> avatarImage = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                avatarPreset: avatarPreset,
                avatarImage: avatarImage,
                pinHash: pinHash,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String name,
                Value<int> avatarPreset = const Value.absent(),
                Value<Uint8List?> avatarImage = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                avatarPreset: avatarPreset,
                avatarImage: avatarImage,
                pinHash: pinHash,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, ProfileRow>(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                playlistsRefs = false,
                profileSettingEntriesRefs = false,
                movieStatesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playlistsRefs) db.playlists,
                    if (profileSettingEntriesRefs) db.profileSettingEntries,
                    if (movieStatesRefs) db.movieStates,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playlistsRefs)
                        await $_getPrefetchedDataByColumns<
                          ProfileRow,
                          $ProfilesTable,
                          PlaylistRow,
                          $PlaylistsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._playlistsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'profile_id',
                          typedResults: items,
                        ),
                      if (profileSettingEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          ProfileRow,
                          $ProfilesTable,
                          ProfileSettingRow,
                          $ProfileSettingEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._profileSettingEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).profileSettingEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'profile_id',
                          typedResults: items,
                        ),
                      if (movieStatesRefs)
                        await $_getPrefetchedDataByColumns<
                          ProfileRow,
                          $ProfilesTable,
                          MovieStateRow,
                          $MovieStatesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._movieStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).movieStatesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'profile_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      ProfileRow,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfileRow, $$ProfilesTableReferences),
      ProfileRow,
      PrefetchHooks Function({
        bool playlistsRefs,
        bool profileSettingEntriesRefs,
        bool movieStatesRefs,
      })
    >;
typedef $$PlaylistsTableCreateCompanionBuilder = PlaylistsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> deleted,
  required String profileId,
  required PlaylistType type,
  required String name,
  required String serverUrl,
  required String username,
  Value<int> sortOrder,
  Value<String?> accountStatus,
  Value<DateTime?> accountCheckedAt,
  Value<DateTime?> accountExpiresAt,
  Value<int?> accountMaxConnections,
  Value<int?> accountActiveConnections,
  Value<int> rowid,
});
typedef $$PlaylistsTableUpdateCompanionBuilder = PlaylistsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> deleted,
  Value<String> profileId,
  Value<PlaylistType> type,
  Value<String> name,
  Value<String> serverUrl,
  Value<String> username,
  Value<int> sortOrder,
  Value<String?> accountStatus,
  Value<DateTime?> accountCheckedAt,
  Value<DateTime?> accountExpiresAt,
  Value<int?> accountMaxConnections,
  Value<int?> accountActiveConnections,
  Value<int> rowid,
});

final class $$PlaylistsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistsTable, PlaylistRow> {
  $$PlaylistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('playlists__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LiveCategoriesTable, List<LiveCategoryRow>>
  _liveCategoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.liveCategories,
    aliasName: 'playlists__id__live_categories__playlist_id',
  );

  $$LiveCategoriesTableProcessedTableManager get liveCategoriesRefs {
    final manager = $$LiveCategoriesTableTableManager(
      $_db,
      $_db.liveCategories,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_liveCategoriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LiveChannelsTable, List<LiveChannelRow>>
  _liveChannelsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.liveChannels,
    aliasName: 'playlists__id__live_channels__playlist_id',
  );

  $$LiveChannelsTableProcessedTableManager get liveChannelsRefs {
    final manager = $$LiveChannelsTableTableManager(
      $_db,
      $_db.liveChannels,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_liveChannelsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CatalogStatesTable, List<CatalogStateRow>>
  _catalogStatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.catalogStates,
    aliasName: 'playlists__id__catalog_states__playlist_id',
  );

  $$CatalogStatesTableProcessedTableManager get catalogStatesRefs {
    final manager = $$CatalogStatesTableTableManager(
      $_db,
      $_db.catalogStates,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_catalogStatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EpgProgrammesTable, List<EpgProgrammeRow>>
  _epgProgrammesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.epgProgrammes,
    aliasName: 'playlists__id__epg_programmes__playlist_id',
  );

  $$EpgProgrammesTableProcessedTableManager get epgProgrammesRefs {
    final manager = $$EpgProgrammesTableTableManager(
      $_db,
      $_db.epgProgrammes,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_epgProgrammesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MovieCategoriesTable, List<MovieCategoryRow>>
  _movieCategoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.movieCategories,
    aliasName: 'playlists__id__movie_categories__playlist_id',
  );

  $$MovieCategoriesTableProcessedTableManager get movieCategoriesRefs {
    final manager = $$MovieCategoriesTableTableManager(
      $_db,
      $_db.movieCategories,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _movieCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MoviesTable, List<MovieRow>> _moviesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.movies,
    aliasName: 'playlists__id__movies__playlist_id',
  );

  $$MoviesTableProcessedTableManager get moviesRefs {
    final manager = $$MoviesTableTableManager(
      $_db,
      $_db.movies,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_moviesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MovieStatesTable, List<MovieStateRow>>
  _movieStatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.movieStates,
    aliasName: 'playlists__id__movie_states__playlist_id',
  );

  $$MovieStatesTableProcessedTableManager get movieStatesRefs {
    final manager = $$MovieStatesTableTableManager(
      $_db,
      $_db.movieStates,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_movieStatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PlaylistType, PlaylistType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverUrl => $composableBuilder(
    column: $table.serverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountStatus => $composableBuilder(
    column: $table.accountStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get accountCheckedAt => $composableBuilder(
    column: $table.accountCheckedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get accountExpiresAt => $composableBuilder(
    column: $table.accountExpiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accountMaxConnections => $composableBuilder(
    column: $table.accountMaxConnections,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accountActiveConnections => $composableBuilder(
    column: $table.accountActiveConnections,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> liveCategoriesRefs(
    Expression<bool> Function($$LiveCategoriesTableFilterComposer f) f,
  ) {
    final $$LiveCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.liveCategories,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LiveCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.liveCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> liveChannelsRefs(
    Expression<bool> Function($$LiveChannelsTableFilterComposer f) f,
  ) {
    final $$LiveChannelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.liveChannels,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LiveChannelsTableFilterComposer(
            $db: $db,
            $table: $db.liveChannels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> catalogStatesRefs(
    Expression<bool> Function($$CatalogStatesTableFilterComposer f) f,
  ) {
    final $$CatalogStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.catalogStates,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogStatesTableFilterComposer(
            $db: $db,
            $table: $db.catalogStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> epgProgrammesRefs(
    Expression<bool> Function($$EpgProgrammesTableFilterComposer f) f,
  ) {
    final $$EpgProgrammesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.epgProgrammes,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpgProgrammesTableFilterComposer(
            $db: $db,
            $table: $db.epgProgrammes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> movieCategoriesRefs(
    Expression<bool> Function($$MovieCategoriesTableFilterComposer f) f,
  ) {
    final $$MovieCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movieCategories,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovieCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.movieCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> moviesRefs(
    Expression<bool> Function($$MoviesTableFilterComposer f) f,
  ) {
    final $$MoviesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movies,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoviesTableFilterComposer(
            $db: $db,
            $table: $db.movies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> movieStatesRefs(
    Expression<bool> Function($$MovieStatesTableFilterComposer f) f,
  ) {
    final $$MovieStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movieStates,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovieStatesTableFilterComposer(
            $db: $db,
            $table: $db.movieStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverUrl => $composableBuilder(
    column: $table.serverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountStatus => $composableBuilder(
    column: $table.accountStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get accountCheckedAt => $composableBuilder(
    column: $table.accountCheckedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get accountExpiresAt => $composableBuilder(
    column: $table.accountExpiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accountMaxConnections => $composableBuilder(
    column: $table.accountMaxConnections,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accountActiveConnections => $composableBuilder(
    column: $table.accountActiveConnections,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PlaylistType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get serverUrl =>
      $composableBuilder(column: $table.serverUrl, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get accountStatus => $composableBuilder(
    column: $table.accountStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get accountCheckedAt => $composableBuilder(
    column: $table.accountCheckedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get accountExpiresAt => $composableBuilder(
    column: $table.accountExpiresAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accountMaxConnections => $composableBuilder(
    column: $table.accountMaxConnections,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accountActiveConnections => $composableBuilder(
    column: $table.accountActiveConnections,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> liveCategoriesRefs<T extends Object>(
    Expression<T> Function($$LiveCategoriesTableAnnotationComposer a) f,
  ) {
    final $$LiveCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.liveCategories,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LiveCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.liveCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> liveChannelsRefs<T extends Object>(
    Expression<T> Function($$LiveChannelsTableAnnotationComposer a) f,
  ) {
    final $$LiveChannelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.liveChannels,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LiveChannelsTableAnnotationComposer(
            $db: $db,
            $table: $db.liveChannels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> catalogStatesRefs<T extends Object>(
    Expression<T> Function($$CatalogStatesTableAnnotationComposer a) f,
  ) {
    final $$CatalogStatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.catalogStates,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogStatesTableAnnotationComposer(
            $db: $db,
            $table: $db.catalogStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> epgProgrammesRefs<T extends Object>(
    Expression<T> Function($$EpgProgrammesTableAnnotationComposer a) f,
  ) {
    final $$EpgProgrammesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.epgProgrammes,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpgProgrammesTableAnnotationComposer(
            $db: $db,
            $table: $db.epgProgrammes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> movieCategoriesRefs<T extends Object>(
    Expression<T> Function($$MovieCategoriesTableAnnotationComposer a) f,
  ) {
    final $$MovieCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movieCategories,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovieCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.movieCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> moviesRefs<T extends Object>(
    Expression<T> Function($$MoviesTableAnnotationComposer a) f,
  ) {
    final $$MoviesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movies,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoviesTableAnnotationComposer(
            $db: $db,
            $table: $db.movies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> movieStatesRefs<T extends Object>(
    Expression<T> Function($$MovieStatesTableAnnotationComposer a) f,
  ) {
    final $$MovieStatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movieStates,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovieStatesTableAnnotationComposer(
            $db: $db,
            $table: $db.movieStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistsTable,
          PlaylistRow,
          $$PlaylistsTableFilterComposer,
          $$PlaylistsTableOrderingComposer,
          $$PlaylistsTableAnnotationComposer,
          $$PlaylistsTableCreateCompanionBuilder,
          $$PlaylistsTableUpdateCompanionBuilder,
          (PlaylistRow, $$PlaylistsTableReferences),
          PlaylistRow,
          PrefetchHooks Function({
            bool profileId,
            bool liveCategoriesRefs,
            bool liveChannelsRefs,
            bool catalogStatesRefs,
            bool epgProgrammesRefs,
            bool movieCategoriesRefs,
            bool moviesRefs,
            bool movieStatesRefs,
          })
        > {
  $$PlaylistsTableTableManager(_$AppDatabase db, $PlaylistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<PlaylistType> type = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> serverUrl = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> accountStatus = const Value.absent(),
                Value<DateTime?> accountCheckedAt = const Value.absent(),
                Value<DateTime?> accountExpiresAt = const Value.absent(),
                Value<int?> accountMaxConnections = const Value.absent(),
                Value<int?> accountActiveConnections = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                profileId: profileId,
                type: type,
                name: name,
                serverUrl: serverUrl,
                username: username,
                sortOrder: sortOrder,
                accountStatus: accountStatus,
                accountCheckedAt: accountCheckedAt,
                accountExpiresAt: accountExpiresAt,
                accountMaxConnections: accountMaxConnections,
                accountActiveConnections: accountActiveConnections,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String profileId,
                required PlaylistType type,
                required String name,
                required String serverUrl,
                required String username,
                Value<int> sortOrder = const Value.absent(),
                Value<String?> accountStatus = const Value.absent(),
                Value<DateTime?> accountCheckedAt = const Value.absent(),
                Value<DateTime?> accountExpiresAt = const Value.absent(),
                Value<int?> accountMaxConnections = const Value.absent(),
                Value<int?> accountActiveConnections = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                profileId: profileId,
                type: type,
                name: name,
                serverUrl: serverUrl,
                username: username,
                sortOrder: sortOrder,
                accountStatus: accountStatus,
                accountCheckedAt: accountCheckedAt,
                accountExpiresAt: accountExpiresAt,
                accountMaxConnections: accountMaxConnections,
                accountActiveConnections: accountActiveConnections,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaylistsTable, PlaylistRow>(table),
                  $$PlaylistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                profileId = false,
                liveCategoriesRefs = false,
                liveChannelsRefs = false,
                catalogStatesRefs = false,
                epgProgrammesRefs = false,
                movieCategoriesRefs = false,
                moviesRefs = false,
                movieStatesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (liveCategoriesRefs) db.liveCategories,
                    if (liveChannelsRefs) db.liveChannels,
                    if (catalogStatesRefs) db.catalogStates,
                    if (epgProgrammesRefs) db.epgProgrammes,
                    if (movieCategoriesRefs) db.movieCategories,
                    if (moviesRefs) db.movies,
                    if (movieStatesRefs) db.movieStates,
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
                        if (profileId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.profileId,
                            referencedTable: $$PlaylistsTableReferences
                                ._profileIdTable(db),
                            referencedColumn: $$PlaylistsTableReferences
                                ._profileIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (liveCategoriesRefs)
                        await $_getPrefetchedDataByColumns<
                          PlaylistRow,
                          $PlaylistsTable,
                          LiveCategoryRow,
                          $LiveCategoriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PlaylistsTableReferences
                              ._liveCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlaylistsTableReferences(
                                db,
                                table,
                                p0,
                              ).liveCategoriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'playlist_id',
                          typedResults: items,
                        ),
                      if (liveChannelsRefs)
                        await $_getPrefetchedDataByColumns<
                          PlaylistRow,
                          $PlaylistsTable,
                          LiveChannelRow,
                          $LiveChannelsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PlaylistsTableReferences
                              ._liveChannelsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlaylistsTableReferences(
                                db,
                                table,
                                p0,
                              ).liveChannelsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'playlist_id',
                          typedResults: items,
                        ),
                      if (catalogStatesRefs)
                        await $_getPrefetchedDataByColumns<
                          PlaylistRow,
                          $PlaylistsTable,
                          CatalogStateRow,
                          $CatalogStatesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PlaylistsTableReferences
                              ._catalogStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlaylistsTableReferences(
                                db,
                                table,
                                p0,
                              ).catalogStatesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'playlist_id',
                          typedResults: items,
                        ),
                      if (epgProgrammesRefs)
                        await $_getPrefetchedDataByColumns<
                          PlaylistRow,
                          $PlaylistsTable,
                          EpgProgrammeRow,
                          $EpgProgrammesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PlaylistsTableReferences
                              ._epgProgrammesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlaylistsTableReferences(
                                db,
                                table,
                                p0,
                              ).epgProgrammesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'playlist_id',
                          typedResults: items,
                        ),
                      if (movieCategoriesRefs)
                        await $_getPrefetchedDataByColumns<
                          PlaylistRow,
                          $PlaylistsTable,
                          MovieCategoryRow,
                          $MovieCategoriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PlaylistsTableReferences
                              ._movieCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlaylistsTableReferences(
                                db,
                                table,
                                p0,
                              ).movieCategoriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'playlist_id',
                          typedResults: items,
                        ),
                      if (moviesRefs)
                        await $_getPrefetchedDataByColumns<
                          PlaylistRow,
                          $PlaylistsTable,
                          MovieRow,
                          $MoviesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PlaylistsTableReferences
                              ._moviesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlaylistsTableReferences(
                                db,
                                table,
                                p0,
                              ).moviesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'playlist_id',
                          typedResults: items,
                        ),
                      if (movieStatesRefs)
                        await $_getPrefetchedDataByColumns<
                          PlaylistRow,
                          $PlaylistsTable,
                          MovieStateRow,
                          $MovieStatesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PlaylistsTableReferences
                              ._movieStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlaylistsTableReferences(
                                db,
                                table,
                                p0,
                              ).movieStatesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'playlist_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistsTable,
      PlaylistRow,
      $$PlaylistsTableFilterComposer,
      $$PlaylistsTableOrderingComposer,
      $$PlaylistsTableAnnotationComposer,
      $$PlaylistsTableCreateCompanionBuilder,
      $$PlaylistsTableUpdateCompanionBuilder,
      (PlaylistRow, $$PlaylistsTableReferences),
      PlaylistRow,
      PrefetchHooks Function({
        bool profileId,
        bool liveCategoriesRefs,
        bool liveChannelsRefs,
        bool catalogStatesRefs,
        bool epgProgrammesRefs,
        bool movieCategoriesRefs,
        bool moviesRefs,
        bool movieStatesRefs,
      })
    >;
typedef $$ProfileSettingEntriesTableCreateCompanionBuilder =
    ProfileSettingEntriesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> deleted,
      required String profileId,
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$ProfileSettingEntriesTableUpdateCompanionBuilder =
    ProfileSettingEntriesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> profileId,
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

final class $$ProfileSettingEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProfileSettingEntriesTable,
          ProfileSettingRow
        > {
  $$ProfileSettingEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) => db.profiles
      .createAlias('profile_setting_entries__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProfileSettingEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileSettingEntriesTable> {
  $$ProfileSettingEntriesTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileSettingEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileSettingEntriesTable> {
  $$ProfileSettingEntriesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileSettingEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileSettingEntriesTable> {
  $$ProfileSettingEntriesTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileSettingEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfileSettingEntriesTable,
          ProfileSettingRow,
          $$ProfileSettingEntriesTableFilterComposer,
          $$ProfileSettingEntriesTableOrderingComposer,
          $$ProfileSettingEntriesTableAnnotationComposer,
          $$ProfileSettingEntriesTableCreateCompanionBuilder,
          $$ProfileSettingEntriesTableUpdateCompanionBuilder,
          (ProfileSettingRow, $$ProfileSettingEntriesTableReferences),
          ProfileSettingRow,
          PrefetchHooks Function({bool profileId})
        > {
  $$ProfileSettingEntriesTableTableManager(
    _$AppDatabase db,
    $ProfileSettingEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileSettingEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProfileSettingEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProfileSettingEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileSettingEntriesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                profileId: profileId,
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String profileId,
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => ProfileSettingEntriesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                profileId: profileId,
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfileSettingEntriesTable, ProfileSettingRow>(
                    table,
                  ),
                  $$ProfileSettingEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$ProfileSettingEntriesTableReferences
                            ._profileIdTable(db),
                        referencedColumn: $$ProfileSettingEntriesTableReferences
                            ._profileIdTable(db)
                            .id,
                      ) as T;
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

typedef $$ProfileSettingEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfileSettingEntriesTable,
      ProfileSettingRow,
      $$ProfileSettingEntriesTableFilterComposer,
      $$ProfileSettingEntriesTableOrderingComposer,
      $$ProfileSettingEntriesTableAnnotationComposer,
      $$ProfileSettingEntriesTableCreateCompanionBuilder,
      $$ProfileSettingEntriesTableUpdateCompanionBuilder,
      (ProfileSettingRow, $$ProfileSettingEntriesTableReferences),
      ProfileSettingRow,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$DeviceSettingEntriesTableCreateCompanionBuilder =
    DeviceSettingEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$DeviceSettingEntriesTableUpdateCompanionBuilder =
    DeviceSettingEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$DeviceSettingEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceSettingEntriesTable> {
  $$DeviceSettingEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeviceSettingEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceSettingEntriesTable> {
  $$DeviceSettingEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeviceSettingEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceSettingEntriesTable> {
  $$DeviceSettingEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$DeviceSettingEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeviceSettingEntriesTable,
          DeviceSettingRow,
          $$DeviceSettingEntriesTableFilterComposer,
          $$DeviceSettingEntriesTableOrderingComposer,
          $$DeviceSettingEntriesTableAnnotationComposer,
          $$DeviceSettingEntriesTableCreateCompanionBuilder,
          $$DeviceSettingEntriesTableUpdateCompanionBuilder,
          (
            DeviceSettingRow,
            BaseReferences<
              _$AppDatabase,
              $DeviceSettingEntriesTable,
              DeviceSettingRow
            >,
          ),
          DeviceSettingRow,
          PrefetchHooks Function()
        > {
  $$DeviceSettingEntriesTableTableManager(
    _$AppDatabase db,
    $DeviceSettingEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceSettingEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceSettingEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DeviceSettingEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviceSettingEntriesCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => DeviceSettingEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DeviceSettingEntriesTable, DeviceSettingRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $DeviceSettingEntriesTable,
                    DeviceSettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeviceSettingEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeviceSettingEntriesTable,
      DeviceSettingRow,
      $$DeviceSettingEntriesTableFilterComposer,
      $$DeviceSettingEntriesTableOrderingComposer,
      $$DeviceSettingEntriesTableAnnotationComposer,
      $$DeviceSettingEntriesTableCreateCompanionBuilder,
      $$DeviceSettingEntriesTableUpdateCompanionBuilder,
      (
        DeviceSettingRow,
        BaseReferences<
          _$AppDatabase,
          $DeviceSettingEntriesTable,
          DeviceSettingRow
        >,
      ),
      DeviceSettingRow,
      PrefetchHooks Function()
    >;
typedef $$LiveCategoriesTableCreateCompanionBuilder =
    LiveCategoriesCompanion Function({
      required String playlistId,
      required String categoryId,
      required String name,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$LiveCategoriesTableUpdateCompanionBuilder =
    LiveCategoriesCompanion Function({
      Value<String> playlistId,
      Value<String> categoryId,
      Value<String> name,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$LiveCategoriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $LiveCategoriesTable, LiveCategoryRow> {
  $$LiveCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias('live_categories__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LiveCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $LiveCategoriesTable> {
  $$LiveCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LiveCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LiveCategoriesTable> {
  $$LiveCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LiveCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LiveCategoriesTable> {
  $$LiveCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LiveCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LiveCategoriesTable,
          LiveCategoryRow,
          $$LiveCategoriesTableFilterComposer,
          $$LiveCategoriesTableOrderingComposer,
          $$LiveCategoriesTableAnnotationComposer,
          $$LiveCategoriesTableCreateCompanionBuilder,
          $$LiveCategoriesTableUpdateCompanionBuilder,
          (LiveCategoryRow, $$LiveCategoriesTableReferences),
          LiveCategoryRow,
          PrefetchHooks Function({bool playlistId})
        > {
  $$LiveCategoriesTableTableManager(
    _$AppDatabase db,
    $LiveCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LiveCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LiveCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LiveCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LiveCategoriesCompanion(
                playlistId: playlistId,
                categoryId: categoryId,
                name: name,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String categoryId,
                required String name,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => LiveCategoriesCompanion.insert(
                playlistId: playlistId,
                categoryId: categoryId,
                name: name,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LiveCategoriesTable, LiveCategoryRow>(table),
                  $$LiveCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false}) {
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
                    if (playlistId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playlistId,
                        referencedTable: $$LiveCategoriesTableReferences
                            ._playlistIdTable(db),
                        referencedColumn: $$LiveCategoriesTableReferences
                            ._playlistIdTable(db)
                            .id,
                      ) as T;
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

typedef $$LiveCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LiveCategoriesTable,
      LiveCategoryRow,
      $$LiveCategoriesTableFilterComposer,
      $$LiveCategoriesTableOrderingComposer,
      $$LiveCategoriesTableAnnotationComposer,
      $$LiveCategoriesTableCreateCompanionBuilder,
      $$LiveCategoriesTableUpdateCompanionBuilder,
      (LiveCategoryRow, $$LiveCategoriesTableReferences),
      LiveCategoryRow,
      PrefetchHooks Function({bool playlistId})
    >;
typedef $$LiveChannelsTableCreateCompanionBuilder =
    LiveChannelsCompanion Function({
      required String playlistId,
      required int streamId,
      required int number,
      required String name,
      Value<String?> logoUrl,
      Value<String?> epgChannelId,
      Value<String?> categoryId,
      Value<int> archiveDays,
      required DateTime seenInLoad,
      Value<int> rowid,
    });
typedef $$LiveChannelsTableUpdateCompanionBuilder =
    LiveChannelsCompanion Function({
      Value<String> playlistId,
      Value<int> streamId,
      Value<int> number,
      Value<String> name,
      Value<String?> logoUrl,
      Value<String?> epgChannelId,
      Value<String?> categoryId,
      Value<int> archiveDays,
      Value<DateTime> seenInLoad,
      Value<int> rowid,
    });

final class $$LiveChannelsTableReferences
    extends BaseReferences<_$AppDatabase, $LiveChannelsTable, LiveChannelRow> {
  $$LiveChannelsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias('live_channels__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LiveChannelsTableFilterComposer
    extends Composer<_$AppDatabase, $LiveChannelsTable> {
  $$LiveChannelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get streamId => $composableBuilder(
    column: $table.streamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get epgChannelId => $composableBuilder(
    column: $table.epgChannelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get archiveDays => $composableBuilder(
    column: $table.archiveDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get seenInLoad => $composableBuilder(
    column: $table.seenInLoad,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LiveChannelsTableOrderingComposer
    extends Composer<_$AppDatabase, $LiveChannelsTable> {
  $$LiveChannelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get streamId => $composableBuilder(
    column: $table.streamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get epgChannelId => $composableBuilder(
    column: $table.epgChannelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archiveDays => $composableBuilder(
    column: $table.archiveDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get seenInLoad => $composableBuilder(
    column: $table.seenInLoad,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LiveChannelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LiveChannelsTable> {
  $$LiveChannelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get streamId =>
      $composableBuilder(column: $table.streamId, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<String> get epgChannelId => $composableBuilder(
    column: $table.epgChannelId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get archiveDays => $composableBuilder(
    column: $table.archiveDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get seenInLoad => $composableBuilder(
    column: $table.seenInLoad,
    builder: (column) => column,
  );

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LiveChannelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LiveChannelsTable,
          LiveChannelRow,
          $$LiveChannelsTableFilterComposer,
          $$LiveChannelsTableOrderingComposer,
          $$LiveChannelsTableAnnotationComposer,
          $$LiveChannelsTableCreateCompanionBuilder,
          $$LiveChannelsTableUpdateCompanionBuilder,
          (LiveChannelRow, $$LiveChannelsTableReferences),
          LiveChannelRow,
          PrefetchHooks Function({bool playlistId})
        > {
  $$LiveChannelsTableTableManager(_$AppDatabase db, $LiveChannelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LiveChannelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LiveChannelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LiveChannelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<int> streamId = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<String?> epgChannelId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int> archiveDays = const Value.absent(),
                Value<DateTime> seenInLoad = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LiveChannelsCompanion(
                playlistId: playlistId,
                streamId: streamId,
                number: number,
                name: name,
                logoUrl: logoUrl,
                epgChannelId: epgChannelId,
                categoryId: categoryId,
                archiveDays: archiveDays,
                seenInLoad: seenInLoad,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required int streamId,
                required int number,
                required String name,
                Value<String?> logoUrl = const Value.absent(),
                Value<String?> epgChannelId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int> archiveDays = const Value.absent(),
                required DateTime seenInLoad,
                Value<int> rowid = const Value.absent(),
              }) => LiveChannelsCompanion.insert(
                playlistId: playlistId,
                streamId: streamId,
                number: number,
                name: name,
                logoUrl: logoUrl,
                epgChannelId: epgChannelId,
                categoryId: categoryId,
                archiveDays: archiveDays,
                seenInLoad: seenInLoad,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LiveChannelsTable, LiveChannelRow>(table),
                  $$LiveChannelsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false}) {
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
                    if (playlistId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playlistId,
                        referencedTable: $$LiveChannelsTableReferences
                            ._playlistIdTable(db),
                        referencedColumn: $$LiveChannelsTableReferences
                            ._playlistIdTable(db)
                            .id,
                      ) as T;
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

typedef $$LiveChannelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LiveChannelsTable,
      LiveChannelRow,
      $$LiveChannelsTableFilterComposer,
      $$LiveChannelsTableOrderingComposer,
      $$LiveChannelsTableAnnotationComposer,
      $$LiveChannelsTableCreateCompanionBuilder,
      $$LiveChannelsTableUpdateCompanionBuilder,
      (LiveChannelRow, $$LiveChannelsTableReferences),
      LiveChannelRow,
      PrefetchHooks Function({bool playlistId})
    >;
typedef $$CatalogStatesTableCreateCompanionBuilder =
    CatalogStatesCompanion Function({
      required String playlistId,
      required String kind,
      required DateTime loadedAt,
      Value<int> rowid,
    });
typedef $$CatalogStatesTableUpdateCompanionBuilder =
    CatalogStatesCompanion Function({
      Value<String> playlistId,
      Value<String> kind,
      Value<DateTime> loadedAt,
      Value<int> rowid,
    });

final class $$CatalogStatesTableReferences
    extends
        BaseReferences<_$AppDatabase, $CatalogStatesTable, CatalogStateRow> {
  $$CatalogStatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias('catalog_states__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CatalogStatesTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogStatesTable> {
  $$CatalogStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loadedAt => $composableBuilder(
    column: $table.loadedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatalogStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogStatesTable> {
  $$CatalogStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loadedAt => $composableBuilder(
    column: $table.loadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatalogStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogStatesTable> {
  $$CatalogStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get loadedAt =>
      $composableBuilder(column: $table.loadedAt, builder: (column) => column);

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatalogStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogStatesTable,
          CatalogStateRow,
          $$CatalogStatesTableFilterComposer,
          $$CatalogStatesTableOrderingComposer,
          $$CatalogStatesTableAnnotationComposer,
          $$CatalogStatesTableCreateCompanionBuilder,
          $$CatalogStatesTableUpdateCompanionBuilder,
          (CatalogStateRow, $$CatalogStatesTableReferences),
          CatalogStateRow,
          PrefetchHooks Function({bool playlistId})
        > {
  $$CatalogStatesTableTableManager(_$AppDatabase db, $CatalogStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<DateTime> loadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogStatesCompanion(
                playlistId: playlistId,
                kind: kind,
                loadedAt: loadedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String kind,
                required DateTime loadedAt,
                Value<int> rowid = const Value.absent(),
              }) => CatalogStatesCompanion.insert(
                playlistId: playlistId,
                kind: kind,
                loadedAt: loadedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatalogStatesTable, CatalogStateRow>(table),
                  $$CatalogStatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false}) {
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
                    if (playlistId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playlistId,
                        referencedTable: $$CatalogStatesTableReferences
                            ._playlistIdTable(db),
                        referencedColumn: $$CatalogStatesTableReferences
                            ._playlistIdTable(db)
                            .id,
                      ) as T;
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

typedef $$CatalogStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogStatesTable,
      CatalogStateRow,
      $$CatalogStatesTableFilterComposer,
      $$CatalogStatesTableOrderingComposer,
      $$CatalogStatesTableAnnotationComposer,
      $$CatalogStatesTableCreateCompanionBuilder,
      $$CatalogStatesTableUpdateCompanionBuilder,
      (CatalogStateRow, $$CatalogStatesTableReferences),
      CatalogStateRow,
      PrefetchHooks Function({bool playlistId})
    >;
typedef $$EpgProgrammesTableCreateCompanionBuilder =
    EpgProgrammesCompanion Function({
      required String playlistId,
      required String channelKey,
      required int startsAt,
      required int endsAt,
      required String title,
      Value<String?> description,
      required int seenInLoad,
    });
typedef $$EpgProgrammesTableUpdateCompanionBuilder =
    EpgProgrammesCompanion Function({
      Value<String> playlistId,
      Value<String> channelKey,
      Value<int> startsAt,
      Value<int> endsAt,
      Value<String> title,
      Value<String?> description,
      Value<int> seenInLoad,
    });

final class $$EpgProgrammesTableReferences
    extends
        BaseReferences<_$AppDatabase, $EpgProgrammesTable, EpgProgrammeRow> {
  $$EpgProgrammesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias('epg_programmes__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EpgProgrammesTableFilterComposer
    extends Composer<_$AppDatabase, $EpgProgrammesTable> {
  $$EpgProgrammesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get channelKey => $composableBuilder(
    column: $table.channelKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seenInLoad => $composableBuilder(
    column: $table.seenInLoad,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpgProgrammesTableOrderingComposer
    extends Composer<_$AppDatabase, $EpgProgrammesTable> {
  $$EpgProgrammesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get channelKey => $composableBuilder(
    column: $table.channelKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seenInLoad => $composableBuilder(
    column: $table.seenInLoad,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpgProgrammesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EpgProgrammesTable> {
  $$EpgProgrammesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get channelKey => $composableBuilder(
    column: $table.channelKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startsAt =>
      $composableBuilder(column: $table.startsAt, builder: (column) => column);

  GeneratedColumn<int> get endsAt =>
      $composableBuilder(column: $table.endsAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seenInLoad => $composableBuilder(
    column: $table.seenInLoad,
    builder: (column) => column,
  );

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpgProgrammesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EpgProgrammesTable,
          EpgProgrammeRow,
          $$EpgProgrammesTableFilterComposer,
          $$EpgProgrammesTableOrderingComposer,
          $$EpgProgrammesTableAnnotationComposer,
          $$EpgProgrammesTableCreateCompanionBuilder,
          $$EpgProgrammesTableUpdateCompanionBuilder,
          (EpgProgrammeRow, $$EpgProgrammesTableReferences),
          EpgProgrammeRow,
          PrefetchHooks Function({bool playlistId})
        > {
  $$EpgProgrammesTableTableManager(_$AppDatabase db, $EpgProgrammesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpgProgrammesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpgProgrammesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpgProgrammesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> channelKey = const Value.absent(),
                Value<int> startsAt = const Value.absent(),
                Value<int> endsAt = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> seenInLoad = const Value.absent(),
              }) => EpgProgrammesCompanion(
                playlistId: playlistId,
                channelKey: channelKey,
                startsAt: startsAt,
                endsAt: endsAt,
                title: title,
                description: description,
                seenInLoad: seenInLoad,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String channelKey,
                required int startsAt,
                required int endsAt,
                required String title,
                Value<String?> description = const Value.absent(),
                required int seenInLoad,
              }) => EpgProgrammesCompanion.insert(
                playlistId: playlistId,
                channelKey: channelKey,
                startsAt: startsAt,
                endsAt: endsAt,
                title: title,
                description: description,
                seenInLoad: seenInLoad,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EpgProgrammesTable, EpgProgrammeRow>(table),
                  $$EpgProgrammesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false}) {
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
                    if (playlistId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playlistId,
                        referencedTable: $$EpgProgrammesTableReferences
                            ._playlistIdTable(db),
                        referencedColumn: $$EpgProgrammesTableReferences
                            ._playlistIdTable(db)
                            .id,
                      ) as T;
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

typedef $$EpgProgrammesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EpgProgrammesTable,
      EpgProgrammeRow,
      $$EpgProgrammesTableFilterComposer,
      $$EpgProgrammesTableOrderingComposer,
      $$EpgProgrammesTableAnnotationComposer,
      $$EpgProgrammesTableCreateCompanionBuilder,
      $$EpgProgrammesTableUpdateCompanionBuilder,
      (EpgProgrammeRow, $$EpgProgrammesTableReferences),
      EpgProgrammeRow,
      PrefetchHooks Function({bool playlistId})
    >;
typedef $$MovieCategoriesTableCreateCompanionBuilder =
    MovieCategoriesCompanion Function({
      required String playlistId,
      required String categoryId,
      required String name,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$MovieCategoriesTableUpdateCompanionBuilder =
    MovieCategoriesCompanion Function({
      Value<String> playlistId,
      Value<String> categoryId,
      Value<String> name,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$MovieCategoriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $MovieCategoriesTable, MovieCategoryRow> {
  $$MovieCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias('movie_categories__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MovieCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $MovieCategoriesTable> {
  $$MovieCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovieCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MovieCategoriesTable> {
  $$MovieCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovieCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovieCategoriesTable> {
  $$MovieCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovieCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovieCategoriesTable,
          MovieCategoryRow,
          $$MovieCategoriesTableFilterComposer,
          $$MovieCategoriesTableOrderingComposer,
          $$MovieCategoriesTableAnnotationComposer,
          $$MovieCategoriesTableCreateCompanionBuilder,
          $$MovieCategoriesTableUpdateCompanionBuilder,
          (MovieCategoryRow, $$MovieCategoriesTableReferences),
          MovieCategoryRow,
          PrefetchHooks Function({bool playlistId})
        > {
  $$MovieCategoriesTableTableManager(
    _$AppDatabase db,
    $MovieCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovieCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovieCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovieCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovieCategoriesCompanion(
                playlistId: playlistId,
                categoryId: categoryId,
                name: name,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String categoryId,
                required String name,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => MovieCategoriesCompanion.insert(
                playlistId: playlistId,
                categoryId: categoryId,
                name: name,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MovieCategoriesTable, MovieCategoryRow>(table),
                  $$MovieCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false}) {
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
                    if (playlistId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playlistId,
                        referencedTable: $$MovieCategoriesTableReferences
                            ._playlistIdTable(db),
                        referencedColumn: $$MovieCategoriesTableReferences
                            ._playlistIdTable(db)
                            .id,
                      ) as T;
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

typedef $$MovieCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovieCategoriesTable,
      MovieCategoryRow,
      $$MovieCategoriesTableFilterComposer,
      $$MovieCategoriesTableOrderingComposer,
      $$MovieCategoriesTableAnnotationComposer,
      $$MovieCategoriesTableCreateCompanionBuilder,
      $$MovieCategoriesTableUpdateCompanionBuilder,
      (MovieCategoryRow, $$MovieCategoriesTableReferences),
      MovieCategoryRow,
      PrefetchHooks Function({bool playlistId})
    >;
typedef $$MoviesTableCreateCompanionBuilder = MoviesCompanion Function({
  required String playlistId,
  required int streamId,
  required String name,
  required int position,
  Value<String?> posterUrl,
  Value<double?> rating,
  Value<DateTime?> addedAt,
  Value<String?> categoryId,
  Value<String?> containerExtension,
  required DateTime seenInLoad,
  Value<int> rowid,
});
typedef $$MoviesTableUpdateCompanionBuilder = MoviesCompanion Function({
  Value<String> playlistId,
  Value<int> streamId,
  Value<String> name,
  Value<int> position,
  Value<String?> posterUrl,
  Value<double?> rating,
  Value<DateTime?> addedAt,
  Value<String?> categoryId,
  Value<String?> containerExtension,
  Value<DateTime> seenInLoad,
  Value<int> rowid,
});

final class $$MoviesTableReferences
    extends BaseReferences<_$AppDatabase, $MoviesTable, MovieRow> {
  $$MoviesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias('movies__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MoviesTableFilterComposer
    extends Composer<_$AppDatabase, $MoviesTable> {
  $$MoviesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get streamId => $composableBuilder(
    column: $table.streamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterUrl => $composableBuilder(
    column: $table.posterUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get containerExtension => $composableBuilder(
    column: $table.containerExtension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get seenInLoad => $composableBuilder(
    column: $table.seenInLoad,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoviesTableOrderingComposer
    extends Composer<_$AppDatabase, $MoviesTable> {
  $$MoviesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get streamId => $composableBuilder(
    column: $table.streamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterUrl => $composableBuilder(
    column: $table.posterUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get containerExtension => $composableBuilder(
    column: $table.containerExtension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get seenInLoad => $composableBuilder(
    column: $table.seenInLoad,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoviesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoviesTable> {
  $$MoviesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get streamId =>
      $composableBuilder(column: $table.streamId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get posterUrl =>
      $composableBuilder(column: $table.posterUrl, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get containerExtension => $composableBuilder(
    column: $table.containerExtension,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get seenInLoad => $composableBuilder(
    column: $table.seenInLoad,
    builder: (column) => column,
  );

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoviesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoviesTable,
          MovieRow,
          $$MoviesTableFilterComposer,
          $$MoviesTableOrderingComposer,
          $$MoviesTableAnnotationComposer,
          $$MoviesTableCreateCompanionBuilder,
          $$MoviesTableUpdateCompanionBuilder,
          (MovieRow, $$MoviesTableReferences),
          MovieRow,
          PrefetchHooks Function({bool playlistId})
        > {
  $$MoviesTableTableManager(_$AppDatabase db, $MoviesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoviesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoviesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoviesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<int> streamId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> posterUrl = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> containerExtension = const Value.absent(),
                Value<DateTime> seenInLoad = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoviesCompanion(
                playlistId: playlistId,
                streamId: streamId,
                name: name,
                position: position,
                posterUrl: posterUrl,
                rating: rating,
                addedAt: addedAt,
                categoryId: categoryId,
                containerExtension: containerExtension,
                seenInLoad: seenInLoad,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required int streamId,
                required String name,
                required int position,
                Value<String?> posterUrl = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> containerExtension = const Value.absent(),
                required DateTime seenInLoad,
                Value<int> rowid = const Value.absent(),
              }) => MoviesCompanion.insert(
                playlistId: playlistId,
                streamId: streamId,
                name: name,
                position: position,
                posterUrl: posterUrl,
                rating: rating,
                addedAt: addedAt,
                categoryId: categoryId,
                containerExtension: containerExtension,
                seenInLoad: seenInLoad,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MoviesTable, MovieRow>(table),
                  $$MoviesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false}) {
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
                    if (playlistId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playlistId,
                        referencedTable: $$MoviesTableReferences
                            ._playlistIdTable(db),
                        referencedColumn: $$MoviesTableReferences
                            ._playlistIdTable(db)
                            .id,
                      ) as T;
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

typedef $$MoviesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoviesTable,
      MovieRow,
      $$MoviesTableFilterComposer,
      $$MoviesTableOrderingComposer,
      $$MoviesTableAnnotationComposer,
      $$MoviesTableCreateCompanionBuilder,
      $$MoviesTableUpdateCompanionBuilder,
      (MovieRow, $$MoviesTableReferences),
      MovieRow,
      PrefetchHooks Function({bool playlistId})
    >;
typedef $$MovieStatesTableCreateCompanionBuilder =
    MovieStatesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> deleted,
      required String profileId,
      required String playlistId,
      required int streamId,
      Value<int> positionSeconds,
      Value<int?> durationSeconds,
      Value<bool> watched,
      Value<bool> favorite,
      Value<DateTime?> lastWatchedAt,
      Value<int> rowid,
    });
typedef $$MovieStatesTableUpdateCompanionBuilder =
    MovieStatesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> profileId,
      Value<String> playlistId,
      Value<int> streamId,
      Value<int> positionSeconds,
      Value<int?> durationSeconds,
      Value<bool> watched,
      Value<bool> favorite,
      Value<DateTime?> lastWatchedAt,
      Value<int> rowid,
    });

final class $$MovieStatesTableReferences
    extends BaseReferences<_$AppDatabase, $MovieStatesTable, MovieStateRow> {
  $$MovieStatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('movie_states__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias('movie_states__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MovieStatesTableFilterComposer
    extends Composer<_$AppDatabase, $MovieStatesTable> {
  $$MovieStatesTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streamId => $composableBuilder(
    column: $table.streamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionSeconds => $composableBuilder(
    column: $table.positionSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get watched => $composableBuilder(
    column: $table.watched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastWatchedAt => $composableBuilder(
    column: $table.lastWatchedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovieStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $MovieStatesTable> {
  $$MovieStatesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streamId => $composableBuilder(
    column: $table.streamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionSeconds => $composableBuilder(
    column: $table.positionSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get watched => $composableBuilder(
    column: $table.watched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastWatchedAt => $composableBuilder(
    column: $table.lastWatchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovieStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovieStatesTable> {
  $$MovieStatesTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<int> get streamId =>
      $composableBuilder(column: $table.streamId, builder: (column) => column);

  GeneratedColumn<int> get positionSeconds => $composableBuilder(
    column: $table.positionSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get watched =>
      $composableBuilder(column: $table.watched, builder: (column) => column);

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<DateTime> get lastWatchedAt => $composableBuilder(
    column: $table.lastWatchedAt,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovieStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovieStatesTable,
          MovieStateRow,
          $$MovieStatesTableFilterComposer,
          $$MovieStatesTableOrderingComposer,
          $$MovieStatesTableAnnotationComposer,
          $$MovieStatesTableCreateCompanionBuilder,
          $$MovieStatesTableUpdateCompanionBuilder,
          (MovieStateRow, $$MovieStatesTableReferences),
          MovieStateRow,
          PrefetchHooks Function({bool profileId, bool playlistId})
        > {
  $$MovieStatesTableTableManager(_$AppDatabase db, $MovieStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovieStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovieStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovieStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> playlistId = const Value.absent(),
                Value<int> streamId = const Value.absent(),
                Value<int> positionSeconds = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<bool> watched = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<DateTime?> lastWatchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovieStatesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                profileId: profileId,
                playlistId: playlistId,
                streamId: streamId,
                positionSeconds: positionSeconds,
                durationSeconds: durationSeconds,
                watched: watched,
                favorite: favorite,
                lastWatchedAt: lastWatchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String profileId,
                required String playlistId,
                required int streamId,
                Value<int> positionSeconds = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<bool> watched = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<DateTime?> lastWatchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovieStatesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                profileId: profileId,
                playlistId: playlistId,
                streamId: streamId,
                positionSeconds: positionSeconds,
                durationSeconds: durationSeconds,
                watched: watched,
                favorite: favorite,
                lastWatchedAt: lastWatchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MovieStatesTable, MovieStateRow>(table),
                  $$MovieStatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false, playlistId = false}) {
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
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$MovieStatesTableReferences
                            ._profileIdTable(db),
                        referencedColumn: $$MovieStatesTableReferences
                            ._profileIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (playlistId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playlistId,
                        referencedTable: $$MovieStatesTableReferences
                            ._playlistIdTable(db),
                        referencedColumn: $$MovieStatesTableReferences
                            ._playlistIdTable(db)
                            .id,
                      ) as T;
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

typedef $$MovieStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovieStatesTable,
      MovieStateRow,
      $$MovieStatesTableFilterComposer,
      $$MovieStatesTableOrderingComposer,
      $$MovieStatesTableAnnotationComposer,
      $$MovieStatesTableCreateCompanionBuilder,
      $$MovieStatesTableUpdateCompanionBuilder,
      (MovieStateRow, $$MovieStatesTableReferences),
      MovieStateRow,
      PrefetchHooks Function({bool profileId, bool playlistId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$ProfileSettingEntriesTableTableManager get profileSettingEntries =>
      $$ProfileSettingEntriesTableTableManager(_db, _db.profileSettingEntries);
  $$DeviceSettingEntriesTableTableManager get deviceSettingEntries =>
      $$DeviceSettingEntriesTableTableManager(_db, _db.deviceSettingEntries);
  $$LiveCategoriesTableTableManager get liveCategories =>
      $$LiveCategoriesTableTableManager(_db, _db.liveCategories);
  $$LiveChannelsTableTableManager get liveChannels =>
      $$LiveChannelsTableTableManager(_db, _db.liveChannels);
  $$CatalogStatesTableTableManager get catalogStates =>
      $$CatalogStatesTableTableManager(_db, _db.catalogStates);
  $$EpgProgrammesTableTableManager get epgProgrammes =>
      $$EpgProgrammesTableTableManager(_db, _db.epgProgrammes);
  $$MovieCategoriesTableTableManager get movieCategories =>
      $$MovieCategoriesTableTableManager(_db, _db.movieCategories);
  $$MoviesTableTableManager get movies =>
      $$MoviesTableTableManager(_db, _db.movies);
  $$MovieStatesTableTableManager get movieStates =>
      $$MovieStatesTableTableManager(_db, _db.movieStates);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'44154e51c3f3079ee293d8ad0ebd1e17cca871ed';

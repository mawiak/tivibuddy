import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../domain/profile_repository.dart';
import 'avatar_image_source.dart';
import 'drift_profile_repository.dart';

part 'profile_data_providers.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) =>
    DriftProfileRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
AvatarImageSource avatarImageSource(Ref ref) => AvatarImageSource();

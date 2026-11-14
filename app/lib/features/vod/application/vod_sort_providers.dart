import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../settings/data/settings_data_providers.dart';
import '../domain/vod_sort.dart';

part 'vod_sort_providers.g.dart';

enum VodSection { movies, series }

/// Orders each VOD section offers; the provider lists only carry the
/// fields these need.
const vodSortChoices = {
  VodSection.movies: [
    VodSort.provider,
    VodSort.added,
    VodSort.nameAscending,
    VodSort.nameDescending,
    VodSort.rating,
  ],
  VodSection.series: [
    VodSort.provider,
    VodSort.year,
    VodSort.nameAscending,
    VodSort.nameDescending,
    VodSort.rating,
  ],
};

/// Sort order of one list of a VOD section, like common IPTV players sort
/// per category. Kept as a device setting.
@Riverpod(keepAlive: true)
class VodSortSelection extends _$VodSortSelection {
  String get _key => 'vod.sort.${section.name}.$listKey';

  /// [listKey] is [VodFilter.key] of the list.
  @override
  VodSort build(VodSection section, String listKey) {
    final subscription = ref
        .watch(deviceSettingsRepositoryProvider)
        .watchValue(_key)
        .listen((value) {
          final sort = VodSort.values.asNameMap()[value] ?? VodSort.provider;
          if (sort != stateOrNull) state = sort;
        });
    ref.onDispose(subscription.cancel);
    return VodSort.provider;
  }

  Future<void> select(VodSort sort) async {
    state = sort;
    await ref.read(deviceSettingsRepositoryProvider).setValue(_key, sort.name);
  }
}

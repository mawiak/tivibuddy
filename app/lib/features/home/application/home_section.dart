import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_section.g.dart';

/// Top-level areas reachable from the navigation menu.
enum HomeSection { liveTv, guide, movies, series, search, settings }

@riverpod
class SelectedHomeSection extends _$SelectedHomeSection {
  @override
  HomeSection build() => HomeSection.liveTv;

  void select(HomeSection section) => state = section;
}

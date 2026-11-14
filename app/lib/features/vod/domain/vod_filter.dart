// Which titles a VOD grid shows, shared by movies and series.

/// Lists the grid can show besides the provider categories.
enum VodList { all, favorites, continueWatching }

/// Which titles a grid shows: a provider category or one of [VodList].
class VodFilter {
  const VodFilter.list(VodList this.list) : categoryId = null;

  const VodFilter.category(String this.categoryId) : list = null;

  static const all = VodFilter.list(VodList.all);

  final VodList? list;
  final String? categoryId;

  /// Continue watching and favorites keep their own order (most recent
  /// first); all other lists can be sorted.
  bool get sortable =>
      list != VodList.continueWatching && list != VodList.favorites;

  /// Stable text form, for example to store settings per list.
  String get key => categoryId == null ? list!.name : 'category:$categoryId';

  @override
  bool operator ==(Object other) =>
      other is VodFilter &&
      other.list == list &&
      other.categoryId == categoryId;

  @override
  int get hashCode => Object.hash(list, categoryId);
}

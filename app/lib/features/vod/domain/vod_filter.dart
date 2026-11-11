// Which titles a VOD grid shows, shared by movies and series.

/// Lists the grid can show besides the provider categories.
enum VodList { all, favorites, continueWatching }

/// Which movies a grid shows: a provider category or one of [VodList].
class VodFilter {
  const VodFilter.list(VodList this.list) : categoryId = null;

  const VodFilter.category(String this.categoryId) : list = null;

  static const all = VodFilter.list(VodList.all);

  final VodList? list;
  final String? categoryId;

  @override
  bool operator ==(Object other) =>
      other is VodFilter &&
      other.list == list &&
      other.categoryId == categoryId;

  @override
  int get hashCode => Object.hash(list, categoryId);
}

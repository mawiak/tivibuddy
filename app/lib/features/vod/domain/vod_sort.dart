/// Orders of a VOD grid (VOD-1). Continue watching and favorites keep their
/// own order (most recent first).
enum VodSort {
  /// The order of the provider list.
  provider,

  /// Newest additions of the provider first.
  added,
  nameAscending,
  nameDescending,

  /// Best rated first.
  rating,

  /// Newest releases first.
  year,
}

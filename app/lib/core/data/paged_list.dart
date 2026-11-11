import 'package:flutter/foundation.dart';

typedef PageLoader<T> = Future<List<T>> Function(int offset, int limit);

/// A list of known [length] whose items are loaded page by page on demand
/// and evicted again when they have not been used recently (RES-1, RES-3).
///
/// Lists call [itemAt] while building rows. It returns null for items that
/// are not loaded yet and loads their page in the background; listeners are
/// notified when the page arrives.
class PagedList<T> extends ChangeNotifier {
  PagedList({
    required this.length,
    required this.loader,
    this.pageSize = 100,
    this.maxPages = 8,
  });

  final int length;
  final int pageSize;
  final int maxPages;
  final PageLoader<T> loader;

  /// Loaded pages in least recently used order (map literals keep insertion
  /// order).
  final _pages = <int, List<T>>{};
  final _loading = <int, Future<List<T>>>{};
  bool _disposed = false;

  T? itemAt(int index) {
    if (index < 0 || index >= length) return null;
    final page = _touch(index ~/ pageSize);
    if (page == null) {
      // A failed page stays a placeholder; it is retried on the next build.
      _loadPage(index ~/ pageSize).ignore();
      return null;
    }
    final offset = index % pageSize;
    return offset < page.length ? page[offset] : null;
  }

  /// Loads the item at [index] if necessary.
  Future<T?> fetch(int index) async {
    if (index < 0 || index >= length) return null;
    final pageIndex = index ~/ pageSize;
    final page = _touch(pageIndex) ?? await _loadPage(pageIndex);
    final offset = index % pageSize;
    return offset < page.length ? page[offset] : null;
  }

  List<T>? _touch(int pageIndex) {
    final page = _pages.remove(pageIndex);
    if (page != null) _pages[pageIndex] = page;
    return page;
  }

  Future<List<T>> _loadPage(int pageIndex) =>
      _loading[pageIndex] ??= loader(pageIndex * pageSize, pageSize)
          .then((items) {
            _loading.remove(pageIndex);
            if (_disposed) return items;
            _pages[pageIndex] = items;
            while (_pages.length > maxPages) {
              _pages.remove(_pages.keys.first);
            }
            notifyListeners();
            return items;
          })
          .catchError((Object error) {
            _loading.remove(pageIndex);
            throw error;
          });

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

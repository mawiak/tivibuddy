/// Escape character for [likePattern], to pass as `escapeChar`.
const likeEscape = r'\';

/// SQL LIKE pattern that finds [query] anywhere, with the wildcards `%`
/// and `_` in it escaped. SQLite compares ASCII letters case-insensitively.
String likePattern(String query) {
  final escaped = query
      .trim()
      .replaceAll(likeEscape, '$likeEscape$likeEscape')
      .replaceAll('%', '$likeEscape%')
      .replaceAll('_', '${likeEscape}_');
  return '%$escaped%';
}

// Providers deliver numbers as strings or ints and empty strings for missing
// values; these helpers tolerate that.

int? xtreamInt(Object? value) => switch (value) {
  final int v => v,
  final num v => v.toInt(),
  final String v => int.tryParse(v.trim()),
  _ => null,
};

double? xtreamDouble(Object? value) => switch (value) {
  final num v => v.toDouble(),
  final String v => double.tryParse(v.trim()),
  _ => null,
};

String? xtreamText(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

/// First category of an entry; newer panels send `category_ids` only.
String? xtreamCategoryId(Map<String, Object?> json) {
  final categoryIds = json['category_ids'];
  return xtreamText(json['category_id']) ??
      (categoryIds is List && categoryIds.isNotEmpty
          ? xtreamText(categoryIds.first)
          : null);
}

/// Unix timestamp in seconds as UTC time.
DateTime? xtreamTime(Object? value) {
  final seconds = xtreamInt(value);
  if (seconds == null || seconds <= 0) return null;
  return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
}

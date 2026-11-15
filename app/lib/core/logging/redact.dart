/// Removes credentials from a log line before it is kept or written out.
///
/// Xtream Codes puts the account into every stream path
/// (`/live/<user>/<password>/<id>.ts`) and into API queries
/// (`?username=<user>&password=<password>`).
String redactCredentials(String text) => text
    .replaceAllMapped(_streamPath, (match) => '/${match[1]}/***/***/')
    .replaceAllMapped(_queryCredential, (match) => '${match[1]}=***');

final _streamPath = RegExp(
  r'/(live|movie|series|timeshift)/[^/\s?#]+/[^/\s?#]+/',
);
final _queryCredential = RegExp(
  r'\b(username|password)=[^&\s#]+',
  caseSensitive: false,
);

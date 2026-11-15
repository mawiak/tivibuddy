/// Delivers a diagnostic report to the developers.
abstract interface class LogReportSender {
  /// Whether this build can send reports at all.
  bool get isConfigured;

  /// Sends [report] as a text file named [fileName] with a short [caption].
  /// Throws [LogReportException] when it could not be delivered.
  Future<void> send({
    required String fileName,
    required String report,
    required String caption,
  });
}

class LogReportException implements Exception {
  const LogReportException(this.message);

  final String message;

  @override
  String toString() => 'LogReportException: $message';
}

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/connection_test.dart';
import '../domain/playlist.dart';

/// One line summary of a provider account, for lists and the editor.
String describeAccount(BuildContext context, AccountInfo? account) {
  final l10n = AppLocalizations.of(context);
  if (account == null) return l10n.playlistAccountUnknown;

  final locale = Localizations.localeOf(context).toLanguageTag();
  final expiresAt = account.expiresAt;
  final parts = [
    l10n.playlistAccountStatus(account.status),
    if (expiresAt == null)
      l10n.playlistAccountUnlimited
    else
      l10n.playlistAccountExpires(
        DateFormat.yMd(locale).format(expiresAt.toLocal()),
      ),
    if (account.maxConnections case final max?)
      l10n.playlistAccountConnections(account.activeConnections ?? 0, max),
  ];
  return parts.join('  ·  ');
}

String describeConnectionError(
  AppLocalizations l10n,
  ConnectionResult result,
) => switch (result) {
  ConnectionOk() => l10n.playlistTestOk,
  ConnectionUnauthorized() => l10n.playlistTestUnauthorized,
  ConnectionFailed(reason: ConnectionFailure.unreachable) =>
    l10n.playlistTestUnreachable,
  ConnectionFailed(reason: ConnectionFailure.timeout) =>
    l10n.playlistTestTimeout,
  ConnectionFailed(reason: ConnectionFailure.invalidResponse) =>
    l10n.playlistTestInvalid,
};

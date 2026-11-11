import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/marquee_text.dart';
import '../../../shared/widgets/tv_focusable.dart';
import '../domain/live_channel.dart';

/// Height of a channel row. Fixed, so lists can use `itemExtent` and jump to
/// any index without measuring (UI-3).
const channelRowHeight = 56.0;

class ChannelLogo extends StatelessWidget {
  const ChannelLogo({super.key, required this.url, required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    final fallback = Icon(
      Icons.live_tv,
      size: size * 0.6,
      color: AppColors.textSecondary,
    );
    return SizedBox.square(
      dimension: size,
      child: url == null
          ? fallback
          : Image.network(
              url,
              fit: BoxFit.contain,
              // Decode at display size (RES-2).
              cacheWidth: (size * MediaQuery.devicePixelRatioOf(context))
                  .round(),
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}

/// One row of a channel list. [channel] is null while its page loads.
class ChannelRow extends StatelessWidget {
  const ChannelRow({
    super.key,
    required this.channel,
    required this.onSelect,
    this.onFocusChange,
    this.autofocus = false,
    this.current = false,
  });

  final LiveChannel? channel;
  final VoidCallback onSelect;
  final ValueChanged<bool>? onFocusChange;
  final bool autofocus;

  /// Marks the channel that is playing.
  final bool current;

  @override
  Widget build(BuildContext context) {
    final channel = this.channel;
    final textTheme = Theme.of(context).textTheme;
    return TvFocusable(
      autofocus: autofocus,
      onSelect: channel == null ? null : onSelect,
      onFocusChange: onFocusChange,
      builder: (context, focused) => Container(
        height: channelRowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: focused ? AppColors.focusFill : null,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: focused ? AppColors.focusBorder : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                channel == null ? '' : '${channel.number}',
                style: textTheme.bodySmall?.copyWith(
                  color: current ? AppColors.accent : null,
                ),
              ),
            ),
            ChannelLogo(url: channel?.logoUrl, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: channel == null
                  ? const SizedBox.shrink()
                  : MarqueeText(
                      channel.name,
                      active: focused,
                      style: textTheme.titleMedium?.copyWith(
                        color: current ? AppColors.accent : null,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Clock time of an EPG entry in the local time zone, for example 20:15.
String formatTime(BuildContext context, DateTime time) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(time.toLocal()),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

/// Now and next programme of [nowNext], used in the info panel and the OSD.
class NowNextView extends StatelessWidget {
  const NowNextView({
    super.key,
    required this.nowNext,
    this.showDescription = false,
  });

  final NowNext? nowNext;
  final bool showDescription;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final now = nowNext?.now;
    final next = nowNext?.next;

    if (now == null && next == null) {
      return Text(l10n.liveNoProgramme, style: textTheme.bodySmall);
    }

    String range(EpgEntry entry) =>
        '${formatTime(context, entry.start)} - ${formatTime(context, entry.end)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (now != null) ...[
          Text(
            '${l10n.liveNow}  ${range(now)}',
            style: textTheme.bodySmall?.copyWith(color: AppColors.accent),
          ),
          const SizedBox(height: 2),
          Text(
            now.title,
            style: textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: now.progressAt(DateTime.now().toUtc()),
              minHeight: 3,
              backgroundColor: AppColors.surfaceRaised,
            ),
          ),
          if (showDescription && now.description != null) ...[
            const SizedBox(height: 8),
            Text(
              now.description!,
              style: textTheme.bodySmall,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
        ],
        if (next != null) ...[
          Text('${l10n.liveNext}  ${range(next)}', style: textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(
            next.title,
            style: textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

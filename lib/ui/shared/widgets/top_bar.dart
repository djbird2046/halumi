import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../../core/localization/app_localizations.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    this.onSettings,
    this.enableDragToMove = false,
    this.title = '',
    this.reserveNativeButtonsSpace = false,
    this.showSettingsButton = false,
    this.showTitle = false,
    this.height = 48,
  });

  final VoidCallback? onSettings;
  final bool enableDragToMove;
  final String title;
  final bool reserveNativeButtonsSpace;
  final bool showSettingsButton;
  final bool showTitle;
  final double height;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final titleWidget = showTitle
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
            ),
          )
        : const SizedBox.shrink();

    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            bottom: BorderSide(color: colorScheme.surfaceContainerHighest),
          ),
        ),
        child: Row(
          children: [
            if (reserveNativeButtonsSpace) const SizedBox(width: 72),
            Expanded(
              child: enableDragToMove
                  ? DragToMoveArea(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: titleWidget,
                      ),
                    )
                  : Align(alignment: Alignment.centerLeft, child: titleWidget),
            ),
            if (showSettingsButton && onSettings != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextButton(
                  onPressed: onSettings,
                  child: Text(l10n.commonSettings),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

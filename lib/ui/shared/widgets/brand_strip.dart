import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';

class BrandStrip extends StatelessWidget {
  const BrandStrip({super.key, required this.onAddProject});

  final VoidCallback onAddProject;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isLight = colorScheme.brightness == Brightness.light;
    final titleAsset = isLight
        ? 'assets/images/title_black.png'
        : 'assets/images/title_white.png';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.surfaceContainerHighest),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          ClipRect(
            child: SizedBox(
              height: 36,
              width: 72,
              child: Image.asset(
                titleAsset,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.commonAdd,
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
            ),
            onPressed: onAddProject,
          ),
        ],
      ),
    );
  }
}

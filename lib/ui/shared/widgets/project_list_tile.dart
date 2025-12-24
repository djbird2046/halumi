import 'package:flutter/material.dart';

import '../../../core/models/project.dart';

class ProjectListTile extends StatelessWidget {
  const ProjectListTile({
    super.key,
    required this.project,
    required this.selected,
    required this.editing,
    required this.controller,
    this.focusNode,
    required this.onTap,
    required this.onSubmitted,
    required this.onFocusLost,
    required this.onContextMenu,
  });

  final Project project;
  final bool selected;
  final bool editing;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback onTap;
  final VoidCallback onSubmitted;
  final VoidCallback onFocusLost;
  final ValueChanged<Offset> onContextMenu;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = selected
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: onTap,
        onSecondaryTapDown: (details) => onContextMenu(details.globalPosition),
        child: Container(
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? colorScheme.outline : Colors.transparent,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: editing
              ? Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) onFocusLost();
                  },
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    onSubmitted: (_) => onSubmitted(),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                    ),
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 18,
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        project.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: selected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

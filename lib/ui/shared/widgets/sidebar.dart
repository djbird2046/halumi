import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/project.dart';
import 'brand_strip.dart';
import 'project_list_tile.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    this.width = 200,
    required this.projects,
    required this.selectedProjectId,
    required this.viewingSettings,
    required this.editingProjectId,
    required this.controllers,
    required this.focusNodes,
    required this.onSelect,
    required this.onStartRename,
    required this.onCommitRename,
    required this.onAddProject,
    required this.onContextMenu,
    required this.onOpenSettings,
  });

  final double width;
  final List<Project> projects;
  final String? selectedProjectId;
  final bool viewingSettings;
  final String? editingProjectId;
  final Map<String, TextEditingController> controllers;
  final Map<String, FocusNode> focusNodes;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onStartRename;
  final ValueChanged<String> onCommitRename;
  final VoidCallback onAddProject;
  final void Function(Offset position, Project project) onContextMenu;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Container(
      width: width,
      color: colorScheme.surface,
      child: Column(
        children: [
          BrandStrip(onAddProject: onAddProject),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemBuilder: (context, index) {
                final project = projects[index];
                final selected =
                    selectedProjectId == project.id && !viewingSettings;
                final editing = editingProjectId == project.id;
                final controller = controllers.putIfAbsent(
                  project.id,
                  () => TextEditingController(text: project.name),
                );
                return ProjectListTile(
                  project: project,
                  selected: selected,
                  editing: editing,
                  controller: controller,
                  focusNode: focusNodes[project.id],
                  onTap: () {
                    if (selected) {
                      onStartRename(project.id);
                    } else {
                      onSelect(project.id);
                    }
                  },
                  onSubmitted: () => onCommitRename(project.id),
                  onFocusLost: () => onCommitRename(project.id),
                  onContextMenu: (position) => onContextMenu(position, project),
                );
              },
              separatorBuilder: (context, _) => const SizedBox(height: 4),
              itemCount: projects.length,
            ),
          ),
          Divider(height: 1, color: colorScheme.surfaceContainerHighest),
          InkWell(
            onTap: onOpenSettings,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: viewingSettings
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.surface,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.settings_outlined,
                    size: 18,
                    color: viewingSettings
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.commonSettings,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: viewingSettings
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

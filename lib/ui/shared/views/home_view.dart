import 'package:flutter/material.dart';

import '../../../core/models/project.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/repositories/project_repository.dart';
import '../../../core/repositories/settings_repository.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';
import 'project_view.dart';
import 'settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.projectRepository,
    required this.settingsRepository,
    this.enableDragToMove = false,
    this.reserveNativeButtonsSpace = false,
    this.topBarHeight = 48,
    this.topBarTrailing,
  });

  final ProjectRepository projectRepository;
  final SettingsRepository settingsRepository;
  final bool enableDragToMove;
  final bool reserveNativeButtonsSpace;
  final double topBarHeight;
  final Widget? topBarTrailing;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const double _minSidebarWidth = 220;
  static const double _minContentWidth = 360;
  static const double _sidebarResizerWidth = 6;

  double _sidebarWidth = 220;
  List<Project> projects = [];
  String? selectedProjectId;
  String? editingProjectId;
  bool viewingSettings = false;
  SettingsSection settingsSection = SettingsSection.general;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    final loaded = widget.projectRepository.loadProjects();
    setState(() {
      projects = loaded;
      selectedProjectId = loaded.isNotEmpty ? loaded.first.id : null;
      viewingSettings = loaded.isEmpty;
    });
  }

  Future<void> _addProject() async {
    final result = await _showCreateProjectDialog();
    if (result == null) return;
    if (result.openAddModel) {
      setState(() {
        viewingSettings = true;
        selectedProjectId = null;
        editingProjectId = null;
        settingsSection = SettingsSection.aiModel;
      });
      return;
    }

    final updated = await widget.projectRepository.addProject(result.name);
    setState(() {
      projects = updated;
      selectedProjectId = updated.first.id;
      viewingSettings = false;
    });
    await widget.settingsRepository.updateAiModel(result.modelId!);
  }

  void _selectProject(String projectId) {
    setState(() {
      viewingSettings = false;
      selectedProjectId = projectId;
      editingProjectId = null;
    });
  }

  void _openSettings() {
    setState(() {
      viewingSettings = true;
      selectedProjectId = null;
      editingProjectId = null;
      settingsSection = SettingsSection.general;
    });
  }

  void _startRenaming(String projectId) {
    setState(() {
      editingProjectId = projectId;
      _controllers.putIfAbsent(
        projectId,
        () => TextEditingController(
          text: projects.firstWhere((p) => p.id == projectId).name,
        ),
      );
      _focusNodes.putIfAbsent(projectId, () => FocusNode());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[projectId]?.requestFocus();
      _controllers[projectId]?.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controllers[projectId]?.text.length ?? 0,
      );
    });
  }

  Future<void> _commitRename(String projectId) async {
    final controller = _controllers[projectId];
    if (controller == null) return;
    final updated = await widget.projectRepository.renameProject(
      id: projectId,
      name: controller.text,
    );
    setState(() {
      projects = updated;
      editingProjectId = null;
    });
  }

  Future<void> _confirmDelete(Project project) async {
    final l10n = AppLocalizations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.homeDeleteProjectTitle),
        content: Text(l10n.homeDeleteProjectMessage(project.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final updated = await widget.projectRepository.deleteProject(project.id);
    setState(() {
      projects = updated;
      if (selectedProjectId == project.id) {
        selectedProjectId = updated.isNotEmpty ? updated.first.id : null;
      }
      if (updated.isEmpty) {
        viewingSettings = true;
      }
    });
    _controllers.remove(project.id)?.dispose();
    _focusNodes.remove(project.id)?.dispose();
  }

  Future<void> _showProjectContextMenu(Offset position, Project project) async {
    final l10n = AppLocalizations.of(context);
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'delete',
          child: Text(
            l10n.commonDelete,
            style: TextStyle(color: Colors.red.shade600),
          ),
        ),
      ],
    );

    if (result == 'delete') {
      await _confirmDelete(project);
    }
  }

  Future<_CreateProjectDialogResult?> _showCreateProjectDialog() async {
    final l10n = AppLocalizations.of(context);
    final models = widget.settingsRepository.loadAiModels();
    final defaultModelId = models.isNotEmpty
        ? widget.settingsRepository.loadAiModel()
        : null;
    final controller = TextEditingController(text: l10n.commonNewProject);
    String? selectedModelId = models.isNotEmpty
        ? (models.any((m) => m.id == defaultModelId)
              ? defaultModelId
              : models.first.id)
        : null;

    return showDialog<_CreateProjectDialogResult>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final canConfirm =
                controller.text.trim().isNotEmpty && selectedModelId != null;
            return AlertDialog(
              title: Text(l10n.createProjectTitle),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: l10n.createProjectNameLabel,
                      ),
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedModelId,
                            decoration: InputDecoration(
                              labelText: l10n.createProjectModelLabel,
                            ),
                            hint: Text(l10n.createProjectModelEmpty),
                            items: models
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m.id,
                                    child: Text('${m.name} · ${m.provider}'),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (models.isEmpty) return;
                              setState(() {
                                selectedModelId = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(
                            _CreateProjectDialogResult(openAddModel: true),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(l10n.createProjectAddModelLink),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonCancel),
                ),
                FilledButton(
                  onPressed: canConfirm
                      ? () => Navigator.of(context).pop(
                          _CreateProjectDialogResult(
                            name: controller.text.trim(),
                            modelId: selectedModelId!,
                          ),
                        )
                      : null,
                  child: Text(l10n.commonAdd),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasProjects = projects.isNotEmpty;
    final selectedProject = hasProjects
        ? projects.firstWhere(
            (p) => p.id == selectedProjectId,
            orElse: () => projects.first,
          )
        : null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          TopBar(
            enableDragToMove: widget.enableDragToMove,
            reserveNativeButtonsSpace: widget.reserveNativeButtonsSpace,
            showSettingsButton: false,
            showTitle: false,
            height: widget.topBarHeight,
            trailing: widget.topBarTrailing,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxSidebarWidth = (constraints.maxWidth -
                        _minContentWidth -
                        _sidebarResizerWidth)
                    .clamp(_minSidebarWidth, constraints.maxWidth)
                    .toDouble();
                final sidebarWidth = _sidebarWidth
                    .clamp(_minSidebarWidth, maxSidebarWidth)
                    .toDouble();

                return Row(
                  children: [
                    Sidebar(
                      width: sidebarWidth,
                      projects: projects,
                      selectedProjectId: selectedProjectId,
                      viewingSettings: viewingSettings,
                      editingProjectId: editingProjectId,
                      controllers: _controllers,
                      focusNodes: _focusNodes,
                      onSelect: _selectProject,
                      onStartRename: _startRenaming,
                      onCommitRename: _commitRename,
                      onAddProject: _addProject,
                      onContextMenu: _showProjectContextMenu,
                      onOpenSettings: _openSettings,
                    ),
                    _SidebarResizer(
                      colorScheme: colorScheme,
                      onDragUpdate: (delta) {
                        setState(() {
                          _sidebarWidth = (_sidebarWidth + delta)
                              .clamp(_minSidebarWidth, maxSidebarWidth)
                              .toDouble();
                        });
                      },
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                        ),
                        child: viewingSettings || !hasProjects
                            ? SettingsView(
                                settingsRepository: widget.settingsRepository,
                                section: settingsSection,
                                onSectionChanged: (section) {
                                  setState(() => settingsSection = section);
                                },
                              )
                            : ProjectView(
                                project: selectedProject!,
                                settingsRepository: widget.settingsRepository,
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }
}

class _SidebarResizer extends StatelessWidget {
  const _SidebarResizer({
    required this.colorScheme,
    required this.onDragUpdate,
  });

  final ColorScheme colorScheme;
  final ValueChanged<double> onDragUpdate;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) => onDragUpdate(details.delta.dx),
        child: SizedBox(
          width: _HomeViewState._sidebarResizerWidth,
          child: Center(
            child: Container(
              width: 1,
              color: colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateProjectDialogResult {
  _CreateProjectDialogResult({
    this.name = '',
    this.modelId,
    this.openAddModel = false,
  });

  final String name;
  final String? modelId;
  final bool openAddModel;
}

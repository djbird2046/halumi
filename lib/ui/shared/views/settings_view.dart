// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/ai_model_config.dart';
import '../../../core/persistence/hive_boxes.dart';
import '../../../core/repositories/settings_repository.dart';

enum SettingsSection { general, aiModel }

class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.settingsRepository,
    required this.section,
    required this.onSectionChanged,
  });

  final SettingsRepository settingsRepository;
  final SettingsSection section;
  final ValueChanged<SettingsSection> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<Box>(
      valueListenable: settingsRepository.listenable(),
      builder: (context, box, _) {
        final themeModeValue =
            box.get(HiveKeys.themeMode, defaultValue: 'system') as String;
        final languageValue =
            box.get(
                  HiveKeys.language,
                  defaultValue: AppLanguage.system.storageValue,
                )
                as String;
        final language = appLanguageFromStorage(languageValue);
        final outputDirectory = settingsRepository.loadOutputDirectory();
        final selectedModelId =
            box.get(HiveKeys.aiModel, defaultValue: '') as String;
        final models = settingsRepository.loadAiModels();
        if (selectedModelId.isEmpty && models.isNotEmpty) {
          settingsRepository.updateAiModel(models.first.id);
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              SegmentedButton<SettingsSection>(
                segments: [
                  ButtonSegment(
                    value: SettingsSection.general,
                    label: Text(l10n.settingsTabGeneral),
                  ),
                  ButtonSegment(
                    value: SettingsSection.aiModel,
                    label: Text(l10n.settingsTabAiModel),
                  ),
                ],
                selected: {section},
                onSelectionChanged: (value) => onSectionChanged(value.first),
                showSelectedIcon: false,
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return colorScheme.onSurface;
                    }
                    return colorScheme.onSurfaceVariant;
                  }),
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return colorScheme.surfaceContainerHighest;
                    }
                    return colorScheme.surface;
                  }),
                  side: WidgetStateProperty.all(
                    BorderSide(color: colorScheme.outline),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (section == SettingsSection.general)
                _GeneralSettingsSection(
                  themeModeValue: themeModeValue,
                  language: language,
                  outputDirectory: outputDirectory,
                  settingsRepository: settingsRepository,
                  colorScheme: colorScheme,
                  l10n: l10n,
                )
              else
                _AiModelSection(
                  models: models,
                  selectedModelId: selectedModelId,
                  settingsRepository: settingsRepository,
                  l10n: l10n,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GeneralSettingsSection extends StatelessWidget {
  const _GeneralSettingsSection({
    required this.themeModeValue,
    required this.language,
    required this.outputDirectory,
    required this.settingsRepository,
    required this.colorScheme,
    required this.l10n,
  });

  final String themeModeValue;
  final AppLanguage language;
  final String outputDirectory;
  final SettingsRepository settingsRepository;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.surfaceContainerHighest),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsAppearanceHeader,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _SettingsRow(
            title: l10n.settingsLanguageLabel,
            description: l10n.settingsLanguageDescription,
            trailing: DropdownButton<AppLanguage>(
              value: language,
              dropdownColor: colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              style: TextStyle(color: colorScheme.onSurface),
              onChanged: (selection) {
                if (selection != null) {
                  settingsRepository.updateLanguage(selection);
                }
              },
              items: [
                DropdownMenuItem(
                  value: AppLanguage.system,
                  child: Text(l10n.settingsLanguageSystem),
                ),
                DropdownMenuItem(
                  value: AppLanguage.chinese,
                  child: Text(l10n.settingsLanguageChinese),
                ),
                DropdownMenuItem(
                  value: AppLanguage.english,
                  child: Text(l10n.settingsLanguageEnglish),
                ),
              ],
            ),
          ),
          Divider(color: colorScheme.surfaceContainerHighest),
          _SettingsRow(
            title: l10n.settingsThemeLabel,
            description: l10n.settingsThemeDescription,
            trailing: DropdownButton<String>(
              value: themeModeValue,
              dropdownColor: colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              style: TextStyle(color: colorScheme.onSurface),
              onChanged: (selection) {
                if (selection != null) {
                  settingsRepository.updateThemeMode(selection);
                }
              },
              items: [
                DropdownMenuItem(
                  value: 'system',
                  child: Text(l10n.settingsThemeSystem),
                ),
                DropdownMenuItem(
                  value: 'light',
                  child: Text(l10n.settingsThemeLight),
                ),
                DropdownMenuItem(
                  value: 'dark',
                  child: Text(l10n.settingsThemeDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: colorScheme.surfaceContainerHighest),
          Text(
            l10n.settingsOutputTitle,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsOutputDescription,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.surfaceContainerHighest),
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            child: Text(
              outputDirectory,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _pickOutputDirectory,
                icon: const Icon(Icons.folder_open),
                label: Text(l10n.settingsOutputChange),
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(
                    colorScheme.onSurface,
                  ),
                  side: WidgetStateProperty.all(
                    BorderSide(color: colorScheme.outline),
                  ),
                  splashFactory: NoSplash.splashFactory,
                  enableFeedback: false,
                  overlayColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.pressed)) {
                      return colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.85,
                      );
                    }
                    if (states.contains(WidgetState.hovered) ||
                        states.contains(WidgetState.focused)) {
                      return colorScheme.surfaceContainerHighest;
                    }
                    return Colors.transparent;
                  }),
                ),
              ),
              TextButton(
                onPressed: _resetOutputDirectory,
                child: Text(l10n.settingsOutputReset),
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(
                    colorScheme.primary,
                  ),
                  splashFactory: NoSplash.splashFactory,
                  enableFeedback: false,
                  overlayColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.pressed)) {
                      return colorScheme.primary.withValues(alpha: 0.18);
                    }
                    if (states.contains(WidgetState.hovered) ||
                        states.contains(WidgetState.focused)) {
                      return colorScheme.primary.withValues(alpha: 0.12);
                    }
                    return Colors.transparent;
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: colorScheme.surfaceContainerHighest),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _pickOutputDirectory() async {
    final selected = await FilePicker.platform.getDirectoryPath();
    if (selected == null || selected.trim().isEmpty) return;
    await settingsRepository.updateOutputDirectory(selected);
  }

  Future<void> _resetOutputDirectory() async {
    final resolved = await settingsRepository.resolveDefaultOutputDirectory();
    await settingsRepository.updateOutputDirectory(resolved);
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.description,
    required this.trailing,
  });

  final String title;
  final String description;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class _AiModelSection extends StatelessWidget {
  const _AiModelSection({
    required this.models,
    required this.selectedModelId,
    required this.settingsRepository,
    required this.l10n,
  });

  final List<AiModelConfig> models;
  final String selectedModelId;
  final SettingsRepository settingsRepository;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.surfaceContainerHighest),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.settingsTabAiModel,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    _showModelDialog(context, settingsRepository, l10n),
                icon: const Icon(Icons.add),
                label: Text(l10n.settingsAddModel),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (models.isEmpty)
            Text(
              l10n.settingsNoModels,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            )
          else
            Column(
              children: models.map((m) {
                final selected = selectedModelId == m.id;
                final providerLabel = _providerDisplayName(l10n, m.provider);
                final displayModel = _displayModelIdForProvider(
                  m.provider,
                  m.model,
                );
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => settingsRepository.updateAiModel(m.id),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: _RadioDot(selected: selected),
                    ),
                  ),
                  title: Text(m.name),
                  subtitle: Text(
                    '$providerLabel${displayModel != null && displayModel.isNotEmpty ? ' · $displayModel' : ''}',
                  ),
                  trailing: IconButton(
                    onPressed: () => _showModelDialog(
                      context,
                      settingsRepository,
                      l10n,
                      existing: m,
                    ),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  onTap: () => _showModelDialog(
                    context,
                    settingsRepository,
                    l10n,
                    existing: m,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

Future<void> _showModelDialog(
  BuildContext context,
  SettingsRepository settingsRepository,
  AppLocalizations l10n, {
  AiModelConfig? existing,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) => _AiModelDialog(
      settingsRepository: settingsRepository,
      l10n: l10n,
      existing: existing,
    ),
  );
}

class _AiModelDialog extends StatefulWidget {
  const _AiModelDialog({
    required this.settingsRepository,
    required this.l10n,
    this.existing,
  });

  final SettingsRepository settingsRepository;
  final AppLocalizations l10n;
  final AiModelConfig? existing;

  @override
  State<_AiModelDialog> createState() => _AiModelDialogState();
}

class _AiModelDialogState extends State<_AiModelDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? provider;
  List<String> modelOptions = const [];
  String? modelId;

  late TextEditingController controllerName;
  late TextEditingController controllerApiKey;
  late TextEditingController controllerBaseUrl;
  late TextEditingController controllerSecret;
  late TextEditingController controllerProjectId;
  late TextEditingController controllerLocation;
  late TextEditingController controllerStorageUri;

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    provider = existing?.provider;
    modelOptions = _modelOptionsForProvider(provider);
    modelId = _displayModelIdForProvider(provider, existing?.model);
    if (modelOptions.isNotEmpty &&
        (modelId == null || !modelOptions.contains(modelId))) {
      modelId = modelOptions.first;
    }

    controllerName = TextEditingController(text: existing?.name ?? '');
    controllerApiKey = TextEditingController(text: existing?.apiKey ?? '');
    controllerBaseUrl = TextEditingController(text: existing?.baseUrl ?? '');
    controllerSecret = TextEditingController(text: existing?.secretKey ?? '');
    controllerProjectId = TextEditingController(
      text: existing?.projectId ?? '',
    );
    controllerLocation = TextEditingController(
      text: existing?.location ?? 'us-central1',
    );
    controllerStorageUri = TextEditingController(
      text: existing?.storageUri ?? '',
    );
  }

  @override
  void dispose() {
    controllerName.dispose();
    controllerApiKey.dispose();
    controllerBaseUrl.dispose();
    controllerSecret.dispose();
    controllerProjectId.dispose();
    controllerLocation.dispose();
    controllerStorageUri.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(
        isEditing
            ? l10n.settingsDialogEditModelTitle
            : l10n.settingsDialogAddModelTitle,
      ),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 480, maxWidth: 640),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: provider,
                  decoration: InputDecoration(
                    labelText: l10n.settingsDialogProviderLabel,
                  ),
                  items: ['sora2', 'veo', 'wanxiang', 'jimeng', 'kling']
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(_providerDisplayName(l10n, p)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      provider = value;
                      modelOptions = _modelOptionsForProvider(provider);
                      modelId =
                          modelOptions.isNotEmpty ? modelOptions.first : null;
                      controllerBaseUrl.text =
                          _defaultBaseUrlForProvider(provider);
                    });
                  },
                  validator: (v) => v == null || v.isEmpty
                      ? l10n.settingsDialogProviderRequired
                      : null,
                ),
                TextFormField(
                  controller: controllerName,
                  decoration: InputDecoration(
                    labelText: l10n.settingsDialogNameLabel,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? l10n.settingsDialogNameValidation
                      : null,
                ),
                TextFormField(
                  controller: controllerApiKey,
                  decoration: InputDecoration(
                    labelText: l10n.settingsDialogApiKeyLabel,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? l10n.settingsDialogApiKeyValidation
                      : null,
                ),
                if (modelOptions.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: modelId,
                    decoration: InputDecoration(
                      labelText: l10n.settingsDialogModelIdLabel,
                    ),
                    items: modelOptions
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(m),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => modelId = value),
                    validator: (v) => v == null || v.isEmpty
                        ? l10n.settingsDialogModelRequired
                        : null,
                  ),
                if (_providerNeedsSecretKey(provider))
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.settingsDialogSecretKeyLabel,
                    ),
                    controller: controllerSecret,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? l10n.settingsDialogApiKeyValidation
                        : null,
                  ),
                if (provider == 'veo') ...[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.settingsDialogProjectIdLabel,
                    ),
                    controller: controllerProjectId,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? l10n.settingsDialogNameValidation
                        : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.settingsDialogLocationLabel,
                    ),
                    controller: controllerLocation,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? l10n.settingsDialogNameValidation
                        : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.settingsDialogStorageUriLabel,
                    ),
                    controller: controllerStorageUri,
                  ),
                ],
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.settingsDialogBaseUrlLabel,
                  ),
                  controller: controllerBaseUrl,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () async {
            if (provider == null || provider!.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.settingsDialogProviderRequired),
                ),
              );
              return;
            }
            if (!(formKey.currentState?.validate() ?? false)) return;
            final resolvedModel = _normalizeModelId(provider!, modelId);
            final needsSecret = _providerNeedsSecretKey(provider);
            final useVeoFields = provider == 'veo';
            final nameValue = controllerName.text.trim();
            final apiKeyValue = controllerApiKey.text.trim();
            final baseUrlValue = controllerBaseUrl.text.trim();
            final secretValue =
                needsSecret ? controllerSecret.text.trim() : '';
            final projectIdValue =
                useVeoFields ? controllerProjectId.text.trim() : '';
            final locationValue =
                useVeoFields ? controllerLocation.text.trim() : '';
            final storageUriValue =
                useVeoFields ? controllerStorageUri.text.trim() : '';
            final newConfig = AiModelConfig(
              id:
                  widget.existing?.id ??
                  '${provider}_${DateTime.now().millisecondsSinceEpoch}',
              name: nameValue.isEmpty ? provider! : nameValue,
              provider: provider!,
              apiKey: apiKeyValue,
              baseUrl: baseUrlValue.isEmpty ? null : baseUrlValue,
              model: resolvedModel?.isEmpty ?? true ? null : resolvedModel,
              secretKey:
                  needsSecret && secretValue.isNotEmpty ? secretValue : null,
              projectId:
                  useVeoFields && projectIdValue.isNotEmpty
                      ? projectIdValue
                      : null,
              location:
                  useVeoFields && locationValue.isNotEmpty
                      ? locationValue
                      : null,
              storageUri: storageUriValue.isEmpty ? null : storageUriValue,
            );
            if (isEditing) {
              await widget.settingsRepository.updateAiModelConfig(newConfig);
            } else {
              await widget.settingsRepository.addAiModel(newConfig);
            }
            if (!mounted) return;
            Navigator.of(context).pop();
          },
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          width: 2,
        ),
        color: selected ? colorScheme.primary : Colors.transparent,
      ),
    );
  }
}

String _providerDisplayName(AppLocalizations l10n, String provider) {
  final isZh = l10n.locale.languageCode.toLowerCase().startsWith('zh');
  switch (provider) {
    case 'veo':
      return isZh ? '谷歌-Veo' : 'Google-Veo';
    case 'sora2':
      return 'OpenAI-Sora';
    case 'jimeng':
      return isZh ? '字节-即梦' : 'ByteDance-JiMeng';
    case 'kling':
    case 'keling':
      return isZh ? '快手-可灵' : 'Kwai-Kling';
    case 'wanxiang':
      return isZh ? '阿里-万相' : 'Alibaba-WanXiang';
    default:
      return provider;
  }
}

String _defaultBaseUrlForProvider(String? provider) {
  switch (provider) {
    case 'veo':
      return 'https://us-central1-aiplatform.googleapis.com';
    case 'sora2':
      return 'https://api.openai.com';
    case 'jimeng':
      return 'https://visual.volcengineapi.com';
    case 'kling':
    case 'keling':
      return 'https://api-beijing.klingai.com';
    case 'wanxiang':
      return 'https://dashscope.aliyuncs.com';
    default:
      return '';
  }
}

List<String> _modelOptionsForProvider(String? provider) {
  switch (provider) {
    case 'sora2':
      return const ['sora-2', 'sora-2-pro'];
    case 'veo':
      return const [
        'veo-3.1-generate-001',
        'veo-3.1-fast-generate-001',
        'veo-3.1-generate-preview',
      ];
    case 'wanxiang':
      return const [
        'wan2.6-i2v',
        'wan2.5-i2v-preview',
        'wan2.2-i2v-flash',
        'wan2.2-i2v-plus',
        'wanx2.1-i2v-turbo',
        'wanx2.1-i2v-plus',
      ];
    case 'jimeng':
      return const ['JiMeng3-720p', 'JiMeng3-1080p', 'JiMeng3-Pro'];
    case 'kling':
      return const ['kling-v2-1', 'kling-v2-5-turbo', 'kling-v2-master'];
    default:
      return const [];
  }
}

bool _providerNeedsSecretKey(String? provider) {
  switch (provider) {
    case 'jimeng':
    case 'kling':
    case 'keling':
      return true;
    default:
      return false;
  }
}

String? _displayModelIdForProvider(String? provider, String? value) {
  if (value == null || value.isEmpty) return null;
  switch (provider) {
    case 'jimeng':
      switch (value) {
        case 'jimeng_i2v_first_v30':
          return 'JiMeng3-720p';
        case 'jimeng_i2v_first_v30_1080':
          return 'JiMeng3-1080p';
        case 'jimeng_ti2v_v30_pro':
          return 'JiMeng3-Pro';
        default:
          return value;
      }
    default:
      return value;
  }
}

String? _normalizeModelId(String provider, String? value) {
  if (value == null || value.isEmpty) return null;
  switch (provider) {
    case 'jimeng':
      switch (value) {
        case 'JiMeng3-720p':
          return 'jimeng_i2v_first_v30';
        case 'JiMeng3-1080p':
          return 'jimeng_i2v_first_v30_1080';
        case 'JiMeng3-Pro':
          return 'jimeng_ti2v_v30_pro';
        default:
          return value;
      }
    case 'kling':
      // 保留原值，常用型号写全。
      return value;
    default:
      return value;
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:ai_video_gen_dart/ai_video_gen_dart.dart';
import 'package:ai_video_gen_dart/src/model.dart' show GeneratorCapabilities;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/ai_model_config.dart';
import '../../../core/models/project.dart';
import '../../../core/repositories/settings_repository.dart';
import '../../../core/services/video_generation_service.dart';

class ProjectView extends StatefulWidget {
  const ProjectView({
    super.key,
    required this.project,
    required this.settingsRepository,
  });

  final Project project;
  final SettingsRepository settingsRepository;

  @override
  State<ProjectView> createState() => _ProjectViewState();
}

class _ProjectViewState extends State<ProjectView> {
  static const double _minParamsWidth = 240;
  static const double _panelGap = 16;

  final TextEditingController _promptController = TextEditingController();
  final List<PlatformFile> _selectedImages = [];
  bool _isGenerating = false;
  String? _aspectRatio;
  String? _resolution;
  int? _durationSeconds;
  GenerationResult? _latestResult;
  String? _errorMessage;
  String? _downloadedPath;
  late final VideoGenerationService _generationService;

  AppLocalizations get l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _generationService = VideoGenerationService();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  String _resolveOutputDir() {
    final base = widget.settingsRepository.loadOutputDirectory();
    final sanitizedBase =
        base.endsWith(Platform.pathSeparator) && base.length > 1
            ? base.substring(0, base.length - 1)
            : base;
    final safeName = widget.project.name
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9_\\-]'), '_')
        .replaceAll(RegExp('_+'), '_');
    final trimmedName = safeName.replaceAll(RegExp(r'^_+|_+$'), '');
    final suffix = _stableHash(widget.project.name);
    final projectFolder =
        trimmedName.isEmpty ? 'project_$suffix' : '${trimmedName}_$suffix';

    return [sanitizedBase, projectFolder].join(Platform.pathSeparator);
  }

  String get _outputDirectory => _resolveOutputDir();

  String _stableHash(String input) {
    const int fnvPrime = 16777619;
    int hash = 0x811c9dc5;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * fnvPrime) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  AiModelConfig? _matchSelectedModel(
    String selectedId,
    List<AiModelConfig> models,
  ) {
    for (final model in models) {
      if (model.id == selectedId) return model;
    }
    return null;
  }

  _ModelCapability _capabilityForModel(AiModelConfig? model) {
    if (model == null) return _defaultCapability;
    final provider = model.provider.toLowerCase();
    final generatorCaps = _generationService.capabilitiesFor(model);
    switch (provider) {
      case 'sora':
      case 'sora2':
        return _mergeCapabilities(_soraCapability, generatorCaps);
      case 'veo':
        return _mergeCapabilities(_veoCapability, generatorCaps);
      case 'jimeng':
        return _mergeCapabilities(_jimengCapability, generatorCaps);
      case 'kling':
      case 'keling':
        return _mergeCapabilities(_klingCapability, generatorCaps);
      case 'wanxiang':
        return _mergeCapabilities(
          _wanxiangCapability(model.model),
          generatorCaps,
          modelId: model.model,
        );
      default:
        return _mergeCapabilities(_defaultCapability, generatorCaps);
    }
  }

  _ModelCapability _mergeCapabilities(
    _ModelCapability base,
    GeneratorCapabilities? capabilities, {
    String? modelId,
  }) {
    if (capabilities == null) {
      return _ModelCapability(
        supportsImage: base.supportsImage,
        imageRequired: base.imageRequired,
        supportsMultiImage: base.supportsMultiImage,
        maxImages: base.maxImages,
        aspectRatios: const [],
        resolutions: const [],
        durations: const [],
      );
    }
    final aspectRatios = _resolveAspectRatios(capabilities);
    final resolutions = _resolveResolutions(capabilities, modelId);
    final durations = _resolveDurations(capabilities, modelId);

    return _ModelCapability(
      supportsImage: base.supportsImage,
      imageRequired: base.imageRequired,
      supportsMultiImage: base.supportsMultiImage,
      maxImages: base.maxImages,
      aspectRatios: aspectRatios,
      resolutions: resolutions,
      durations: durations,
    );
  }

  List<String> _resolveAspectRatios(GeneratorCapabilities capabilities) {
    final ratios = _cleanStringOptions(capabilities.aspectRatios);
    if (ratios.isNotEmpty) return ratios;
    final sizes = capabilities.sizesByAspectRatio;
    if (sizes != null && sizes.isNotEmpty) {
      return sizes.keys.where((key) => key.trim().isNotEmpty).toList();
    }
    return const [];
  }

  List<String> _resolveResolutions(
    GeneratorCapabilities capabilities,
    String? modelId,
  ) {
    List<String> resolutions = [];
    final byModel = capabilities.resolutionsByModel;
    if (byModel != null && byModel.isNotEmpty) {
      final modelKey = _normalizeModelKey(modelId);
      final lowerKey = _lowerKey(modelKey);
      final modelResolutions =
          (modelKey != null ? byModel[modelKey] : null) ??
          (lowerKey != null ? byModel[lowerKey] : null);
      if (modelResolutions != null && modelResolutions.isNotEmpty) {
        resolutions = _cleanStringOptions(modelResolutions);
      } else {
        resolutions = byModel.values
            .expand((values) => values)
            .where((value) => value.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      }
    } else {
      resolutions = _cleanStringOptions(capabilities.resolutions);
    }

    return resolutions;
  }

  List<int> _resolveDurations(
    GeneratorCapabilities capabilities,
    String? modelId,
  ) {
    List<int> durations = [];
    final byModel = capabilities.durationsByModel;
    if (byModel != null && byModel.isNotEmpty) {
      final modelKey = _normalizeModelKey(modelId);
      final lowerKey = _lowerKey(modelKey);
      final modelDurations =
          (modelKey != null ? byModel[modelKey] : null) ??
          (lowerKey != null ? byModel[lowerKey] : null);
      if (modelDurations != null && modelDurations.isNotEmpty) {
        durations = List<int>.from(modelDurations);
      } else {
        durations = byModel.values.expand((values) => values).toSet().toList()
          ..sort();
      }
    } else if (capabilities.durationsSeconds != null &&
        capabilities.durationsSeconds!.isNotEmpty) {
      durations = List<int>.from(capabilities.durationsSeconds!);
    }

    return durations;
  }

  List<String> _cleanStringOptions(List<String>? options) {
    if (options == null || options.isEmpty) return const [];
    return options
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  String? _normalizeModelKey(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _lowerKey(String? value) {
    if (value == null) return null;
    return value.toLowerCase();
  }

  void _syncSelections(_ModelCapability capability) {
    if (capability.aspectRatios.isEmpty) {
      _aspectRatio = null;
    } else if (_aspectRatio == null ||
        !capability.aspectRatios.contains(_aspectRatio)) {
      _aspectRatio = capability.aspectRatios.first;
    }

    if (capability.resolutions.isEmpty) {
      _resolution = null;
    } else if (_resolution == null ||
        !capability.resolutions.contains(_resolution)) {
      _resolution = capability.resolutions.first;
    }

    if (capability.durations.isEmpty) {
      _durationSeconds = null;
    } else if (_durationSeconds == null ||
        !capability.durations.contains(_durationSeconds)) {
      _durationSeconds = capability.durations.first;
    }
  }

  Future<void> _pickImages(_ModelCapability capability) async {
    if (!capability.supportsImage) return;
    try {
      final result = await FilePicker.platform
          .pickFiles(
            allowMultiple: capability.supportsMultiImage,
            type: FileType.image,
          )
          .timeout(const Duration(seconds: 15));
      if (result == null || result.files.isEmpty) {
        return;
      }

      final picked = capability.supportsMultiImage
          ? result.files
          : (result.files.isNotEmpty ? [result.files.first] : <PlatformFile>[]);
      final limit = capability.maxImages <= 0
          ? picked.length
          : capability.maxImages;
      final trimmed = _takeWithinLimit(picked, limit);

      setState(() {
        _selectedImages
          ..clear()
          ..addAll(trimmed);
      });

      if (capability.maxImages > 0 && picked.length > capability.maxImages) {
        _showSnack(l10n.projectImagesTrimmed(capability.maxImages));
      }
    } on TimeoutException {
      _showSnack(l10n.projectPickImagesTimeout);
    } catch (e) {
      _showSnack(l10n.projectPickImagesFailed('$e'));
    }
  }

  List<PlatformFile> _takeWithinLimit(List<PlatformFile> files, int limit) {
    if (limit <= 0 || files.length <= limit) {
      return List<PlatformFile>.from(files);
    }
    return files.take(limit).toList();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  String _displayOption(String value) {
    if (value == '自动') return l10n.projectOptionAuto;
    return value;
  }

  String _statusText(GenerationStatus status) {
    switch (status) {
      case GenerationStatus.queued:
        return l10n.projectStatusQueued;
      case GenerationStatus.processing:
        return l10n.projectStatusProcessing;
      case GenerationStatus.streaming:
        return l10n.projectStatusStreaming;
      case GenerationStatus.succeeded:
        return l10n.projectStatusSucceeded;
      case GenerationStatus.failed:
        return l10n.projectStatusFailed;
    }
  }

  Future<void> _startGenerate(
    AiModelConfig? model,
    _ModelCapability capability,
  ) async {
    if (_isGenerating) return;
    final prompt = _promptController.text.trim();
    if (model == null) {
      _showSnack(l10n.projectAddModelHint);
      return;
    }
    if (prompt.isEmpty) {
      _showSnack(l10n.projectEnterPrompt);
      return;
    }
    if (capability.imageRequired && _selectedImages.isEmpty) {
      _showSnack(
        capability.supportsMultiImage
            ? l10n.projectSelectImagesMulti
            : l10n.projectSelectImageSingle,
      );
      return;
    }

    final imagePaths = _selectedImages
        .map((file) => file.path)
        .whereType<String>()
        .toList();

    setState(() => _isGenerating = true);
    setState(() {
      _errorMessage = null;
      _downloadedPath = null;
      _latestResult = null;
    });

    try {
      final result = await _generationService.generate(
        model: model,
        prompt: prompt,
        imagePaths: imagePaths,
        outputDir: _outputDirectory,
        aspectRatio: _aspectRatio,
        resolution: _resolution,
        durationSeconds: _durationSeconds,
        onProgress: (status) {
          if (!mounted) return;
          setState(() {
            _latestResult = status;
            _downloadedPath = status.localFilePath ?? _downloadedPath;
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _latestResult = result;
        _downloadedPath = result.localFilePath ?? _downloadedPath;
      });
      if (result.status == GenerationStatus.succeeded) {
        _showSnack(l10n.projectGenerationSucceeded);
      } else if (result.status == GenerationStatus.failed) {
        _showSnack(
          l10n.projectGenerationFailed(
            result.errorMessage ?? l10n.projectStatusFailed,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '$error';
        _latestResult = GenerationResult(
          requestId: '',
          status: GenerationStatus.failed,
          errorMessage: _errorMessage,
        );
      });
      _showSnack(l10n.projectGenerationFailed('$error'));
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _openOutputDirectory() async {
    final dir = Directory(_outputDirectory);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    try {
      if (Platform.isMacOS) {
        await Process.run('open', [dir.path]);
      } else if (Platform.isWindows) {
        await Process.run('explorer', [dir.path]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [dir.path]);
      } else {
        _showSnack(l10n.projectOpenDirUnsupported);
      }
    } catch (e) {
      _showSnack(l10n.projectOpenDirFailed('$e'));
    }
  }

  void _removeImage(PlatformFile file) {
    setState(() {
      _selectedImages.remove(file);
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(colorScheme),
          const SizedBox(height: 16),
          Expanded(
            child: ValueListenableBuilder<Box>(
              valueListenable: widget.settingsRepository.listenable(),
              builder: (context, box, _) {
                final models = widget.settingsRepository.loadAiModels();
                final selectedId = widget.settingsRepository.loadAiModel();
                var selectedModel = _matchSelectedModel(selectedId, models);
                if ((selectedId.isEmpty || selectedModel == null) &&
                    models.isNotEmpty) {
                  selectedModel = models.first;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.settingsRepository.updateAiModel(selectedModel!.id);
                  });
                }
                final capability = _capabilityForModel(selectedModel);
                _syncSelections(capability);

                final promptGuideUrl = selectedModel == null
                    ? null
                    : _generationService.promptGuideUrlFor(selectedModel);

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth =
                        (constraints.maxWidth - _panelGap).toDouble();
                    final desiredRightWidth = availableWidth * 2 / 7;
                    final rightWidth = availableWidth <= _minParamsWidth
                        ? availableWidth
                        : math.max(_minParamsWidth, desiredRightWidth);
                    final leftWidth = math.max(
                      0.0,
                      availableWidth - rightWidth,
                    );

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: leftWidth,
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              _buildImagePickerCard(capability),
                              const SizedBox(height: 12),
                              _buildPromptCard(
                                promptGuideUrl: promptGuideUrl,
                              ),
                              const SizedBox(height: 12),
                              _buildGenerateBar(
                                model: selectedModel,
                                capability: capability,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: _panelGap),
                        SizedBox(
                          width: rightWidth,
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              _buildModelSelector(
                                models: models,
                                selectedModel: selectedModel,
                                capability: capability,
                              ),
                              const SizedBox(height: 12),
                              _buildOptionsCard(capability),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        Text(
          widget.project.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.play_circle_outline,
            size: 16,
            color: colorScheme.primary,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildModelSelector({
    required List<AiModelConfig> models,
    required AiModelConfig? selectedModel,
    required _ModelCapability capability,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                l10n.projectAiModel,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (selectedModel == null)
                _InfoPill(
                  icon: Icons.warning_amber_rounded,
                  label: l10n.projectAddModelCta,
                  tone: InfoTone.warning,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (models.isEmpty)
            Text(
              l10n.projectNoModelsHelp,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: selectedModel?.id,
              items: models
                  .map(
                    (m) => DropdownMenuItem(value: m.id, child: Text(m.name)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.settingsRepository.updateAiModel(value);
                }
              },
              decoration: InputDecoration(
                labelText: l10n.projectSelectModelLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPromptCard({String? promptGuideUrl}) {
    final colorScheme = Theme.of(context).colorScheme;
    final guideUrl =
        (promptGuideUrl == null || promptGuideUrl.trim().isEmpty)
            ? null
            : promptGuideUrl.trim();
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.projectPromptTitle,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (guideUrl != null) ...[
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () => _openPromptGuideUrl(guideUrl),
                  icon: const Icon(Icons.description_outlined, size: 16),
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all(
                      colorScheme.primary,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                    minimumSize: WidgetStateProperty.all(
                      const Size(24, 24),
                    ),
                    overlayColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered) ||
                          states.contains(WidgetState.focused)) {
                        return colorScheme.primary.withValues(alpha: 0.12);
                      }
                      if (states.contains(WidgetState.pressed)) {
                        return colorScheme.primary.withValues(alpha: 0.2);
                      }
                      return Colors.transparent;
                    }),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _promptController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: l10n.projectPromptHint,
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsCard(_ModelCapability capability) {
    final colorScheme = Theme.of(context).colorScheme;
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.projectParamsTitle,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  initialValue: _aspectRatio,
                  items: capability.aspectRatios
                      .map(
                        (ratio) => DropdownMenuItem(
                          value: ratio,
                          child: Text(_displayOption(ratio)),
                        ),
                      )
                      .toList(),
                  onChanged: capability.aspectRatios.isEmpty
                      ? null
                      : (value) => setState(() => _aspectRatio = value),
                  decoration: InputDecoration(
                    labelText: l10n.projectAspectRatioLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  initialValue: _resolution,
                  items: capability.resolutions
                      .map(
                        (res) => DropdownMenuItem(
                          value: res,
                          child: Text(_displayOption(res)),
                        ),
                      )
                      .toList(),
                  onChanged: capability.resolutions.isEmpty
                      ? null
                      : (value) => setState(() => _resolution = value),
                  decoration: InputDecoration(
                    labelText: l10n.projectResolutionLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              if (capability.durations.isNotEmpty)
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<int>(
                    initialValue: _durationSeconds,
                    items: capability.durations
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text('$value s'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _durationSeconds = value),
                    decoration: InputDecoration(
                      labelText: l10n.projectDurationLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateBar({
    required AiModelConfig? model,
    required _ModelCapability capability,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final canGenerate = !_isGenerating && model != null;
    final status = _latestResult?.status;
    final progress = _latestResult?.progress;

    return _SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(Icons.play_circle_outline, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.projectGenerateTitle,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                _buildGenerateDescription(model, colorScheme),
                if (status != null || _errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            status != null
                                ? l10n.projectStatusLabel(_statusText(status))
                                : l10n.projectGenerationFailed(
                                    _errorMessage ?? '',
                                  ),
                            style: TextStyle(
                              color: status == GenerationStatus.failed ||
                                      _errorMessage != null
                                  ? Colors.red.shade600
                                  : colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if ((_errorMessage ?? '').isNotEmpty)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            iconSize: 18,
                            tooltip: l10n.commonCopy,
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: _errorMessage!),
                              );
                              _showSnack(l10n.commonCopied);
                            },
                            icon: const Icon(Icons.copy_outlined),
                          ),
                      ],
                    ),
                  ),
                if (progress != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 6,
                    ),
                  ),
                if (_downloadedPath != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      l10n.projectDownloadedFile(
                        _fileNameFromPath(_downloadedPath!),
                      ),
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
          ),
          FilledButton(
            onPressed: canGenerate
                ? () => _startGenerate(model, capability)
                : null,
            child: _isGenerating
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : Text(l10n.commonGenerate),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerCard(_ModelCapability capability) {
    final colorScheme = Theme.of(context).colorScheme;
    final supportsImage = capability.supportsImage;
    final limitLabel = capability.supportsMultiImage
        ? '(${capability.maxImages <= 0 ? l10n.projectMultiImageUnlimited : l10n.projectMultiImageLimit(capability.maxImages)})'
        : '(${l10n.projectSingleOnly})';

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.projectReferenceImagesTitle,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              _InfoPill(
                icon: Icons.photo_library_outlined,
                label: supportsImage
                    ? limitLabel
                    : l10n.projectNoImagesRequired,
                tone: supportsImage
                    ? (capability.imageRequired
                          ? InfoTone.warning
                          : InfoTone.normal)
                    : InfoTone.muted,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!supportsImage)
            Text(
              l10n.projectNoImagesDescription,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            )
          else ...[
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickImages(capability),
                  icon: const Icon(Icons.folder_open),
                  label: Text(
                    capability.supportsMultiImage
                        ? l10n.projectPickMultiple
                        : l10n.projectPickSingle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  capability.supportsMultiImage
                      ? l10n.projectMultiImageNote
                      : l10n.projectSingleImageNote,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_selectedImages.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                ),
                child: Text(
                  l10n.projectNoImagesSelected,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedImages.map((file) {
                  return Chip(
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(file.name, overflow: TextOverflow.ellipsis),
                        Text(
                          _formatFileSize(file.size),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    onDeleted: () => _removeImage(file),
                  );
                }).toList(),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildGenerateDescription(
    AiModelConfig? model,
    ColorScheme colorScheme,
  ) {
    final textStyle = TextStyle(color: colorScheme.onSurfaceVariant);
    if (model == null) {
      return Text(l10n.projectSelectModelFirst, style: textStyle);
    }

    final description =
        l10n.projectGenerateDescription(model.name, _outputDirectory);
    final linkText = _outputDirectory;
    final index = description.indexOf(linkText);
    if (index == -1) {
      return Text(description, style: textStyle);
    }

    final before = description.substring(0, index);
    final after = description.substring(index + linkText.length);
    final linkStyle = textStyle.copyWith(
      color: colorScheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: colorScheme.primary,
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (before.isNotEmpty) Text(before, style: textStyle),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _openOutputDirectory,
            child: Text(linkText, style: linkStyle),
          ),
        ),
        if (after.isNotEmpty) Text(after, style: textStyle),
      ],
    );
  }

  Future<void> _openPromptGuideUrl(String url) async {
    try {
      if (Platform.isMacOS) {
        await Process.run('open', [url]);
      } else if (Platform.isWindows) {
        await Process.run('explorer', [url]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [url]);
      } else {
        _showSnack(l10n.projectOpenLinkUnsupported);
      }
    } catch (e) {
      _showSnack(l10n.projectOpenLinkFailed('$e'));
    }
  }

  String _fileNameFromPath(String path) {
    var normalized = path.replaceAll('\\', '/');
    normalized = normalized.replaceAll(RegExp(r'/+$'), '');
    final parts = normalized.split('/');
    return parts.isNotEmpty ? parts.last : path;
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.surfaceContainerHighest),
      ),
      child: child,
    );
  }
}

enum InfoTone { normal, warning, muted }

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    this.tone = InfoTone.normal,
  });

  final IconData icon;
  final String label;
  final InfoTone tone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color fg;
    Color bg;
    switch (tone) {
      case InfoTone.warning:
        fg = Colors.orange.shade800;
        bg = Colors.orange.shade100.withValues(alpha: 0.5);
        break;
      case InfoTone.muted:
        fg = colorScheme.onSurfaceVariant;
        bg = colorScheme.surfaceContainerHighest;
        break;
      case InfoTone.normal:
        fg = colorScheme.primary;
        bg = colorScheme.surfaceContainerHighest;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: fg, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

const _autoLabel = '自动';

const _soraCapability = _ModelCapability(
  supportsImage: true,
  imageRequired: false,
  supportsMultiImage: false,
  maxImages: 1,
  aspectRatios: [
    SoraAspectRatios.landscape16x9,
    SoraAspectRatios.square,
    SoraAspectRatios.portrait9x16,
    SoraAspectRatios.landscape4x3,
    SoraAspectRatios.portrait3x4,
  ],
  resolutions: [
    _autoLabel,
    SoraResolutions.p720,
    SoraResolutions.p1080,
    SoraResolutions.k4,
  ],
  durations: [
    SoraDurations.fiveSeconds,
    SoraDurations.sixSeconds,
    SoraDurations.eightSeconds,
    SoraDurations.tenSeconds,
  ],
);

const _veoCapability = _ModelCapability(
  supportsImage: true,
  imageRequired: false,
  supportsMultiImage: true,
  maxImages: 6,
  aspectRatios: [
    VeoAspectRatios.landscape16x9,
    VeoAspectRatios.portrait9x16,
  ],
  resolutions: [_autoLabel, VeoResolutions.p720, VeoResolutions.p1080],
  durations: [
    VeoDurations.fourSeconds,
    VeoDurations.fiveSeconds,
    VeoDurations.sixSeconds,
    VeoDurations.eightSeconds,
  ],
);

const _jimengCapability = _ModelCapability(
  supportsImage: true,
  imageRequired: true,
  supportsMultiImage: false,
  maxImages: 1,
  aspectRatios: [
    JimengAspectRatios.landscape16x9,
    JimengAspectRatios.landscape4x3,
    JimengAspectRatios.square,
    JimengAspectRatios.portrait3x4,
    JimengAspectRatios.portrait9x16,
  ],
  resolutions: ['1080p', '720p'],
  durations: [JimengDurations.fiveSeconds, JimengDurations.tenSeconds],
);

const _klingCapability = _ModelCapability(
  supportsImage: true,
  imageRequired: true,
  supportsMultiImage: false,
  maxImages: 1,
  aspectRatios: ['16:9', '9:16'],
  resolutions: [_autoLabel],
  durations: [KlingDurations.fiveSeconds, KlingDurations.tenSeconds],
);

_ModelCapability _wanxiangCapability(String? modelId) {
  final modelKey = modelId?.toLowerCase().trim();
  final resolutions =
      modelKey != null &&
                WanXiangModelConstraints.resolutionsByModel.containsKey(
                  modelKey,
                )
            ? WanXiangModelConstraints.resolutionsByModel[modelKey]!
            : WanXiangModelConstraints.resolutionsByModel.values
                  .expand((values) => values)
                  .toSet()
                  .toList()
        ..sort();
  final durations =
      modelKey != null &&
                WanXiangModelConstraints.durationsByModel.containsKey(modelKey)
            ? WanXiangModelConstraints.durationsByModel[modelKey]!
            : WanXiangModelConstraints.durationsByModel.values
                  .expand((values) => values)
                  .toSet()
                  .toList()
        ..sort();

  return _ModelCapability(
    supportsImage: true,
    imageRequired: true,
    supportsMultiImage: false,
    maxImages: 1,
    aspectRatios: const [],
    resolutions: resolutions.isEmpty ? const [_autoLabel] : resolutions,
    durations: durations.isEmpty ? const [] : durations,
  );
}

class _ModelCapability {
  const _ModelCapability({
    required this.supportsImage,
    required this.imageRequired,
    required this.supportsMultiImage,
    required this.maxImages,
    required this.aspectRatios,
    required this.resolutions,
    required this.durations,
  });

  final bool supportsImage;
  final bool imageRequired;
  final bool supportsMultiImage;
  final int maxImages;
  final List<String> aspectRatios;
  final List<String> resolutions;
  final List<int> durations;
}

const _defaultCapability = _ModelCapability(
  supportsImage: true,
  imageRequired: false,
  supportsMultiImage: false,
  maxImages: 1,
  aspectRatios: ['16:9', '1:1', '9:16'],
  resolutions: [_autoLabel, '720p', '1080p'],
  durations: [5, 8, 10],
);

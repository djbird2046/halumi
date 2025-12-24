import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../localization/app_language.dart';
import '../models/ai_model_config.dart';
import '../persistence/hive_boxes.dart';

class SettingsRepository {
  SettingsRepository(this.box);

  final Box box;

  Future<void> ensureDefaults() async {
    if (!box.containsKey(HiveKeys.themeMode)) {
      await box.put(HiveKeys.themeMode, 'system');
    }
    if (!box.containsKey(HiveKeys.language)) {
      await box.put(HiveKeys.language, AppLanguage.system.storageValue);
    }
    if (!box.containsKey(HiveKeys.aiModel)) {
      await box.put(HiveKeys.aiModel, 'halumi-video-1');
    }
    if (!box.containsKey(HiveKeys.aiModels)) {
      await box.put(HiveKeys.aiModels, <Map<String, dynamic>>[]);
    }
    if (!box.containsKey(HiveKeys.outputDirectory)) {
      await box.put(
        HiveKeys.outputDirectory,
        await resolveDefaultOutputDirectory(),
      );
    } else {
      final current = box.get(HiveKeys.outputDirectory);
      final resolved = (current is String) ? current.trim() : '';
      final normalized =
          Platform.isMacOS ? _normalizePath(resolved) : resolved;
      if (resolved.isEmpty ||
          resolved == _fallbackOutputDirectory() ||
          _looksLikeContainerDefault(resolved)) {
        await box.put(
          HiveKeys.outputDirectory,
          await resolveDefaultOutputDirectory(),
        );
      } else if (Platform.isMacOS && normalized != resolved) {
        await box.put(HiveKeys.outputDirectory, normalized);
      }
    }
  }

  bool _looksLikeContainerDefault(String path) {
    final normalized = _normalizePath(path).toLowerCase();
    return normalized.contains('/library/containers/') &&
        normalized.endsWith('/halumi/outputs');
  }

  String _normalizePath(String path) =>
      path
          .replaceAll('\\', '/')
          .replaceAll(RegExp('/+'), '/')
          .replaceAll(RegExp(r'/+$'), '');

  String loadThemeMode() =>
      box.get(HiveKeys.themeMode, defaultValue: 'system') as String;

  Future<void> updateThemeMode(String value) =>
      box.put(HiveKeys.themeMode, value);

  AppLanguage loadLanguage() => appLanguageFromStorage(
    box.get(HiveKeys.language, defaultValue: AppLanguage.system.storageValue)
        as String,
  );

  Future<void> updateLanguage(AppLanguage language) =>
      box.put(HiveKeys.language, language.storageValue);

  String _fallbackOutputDirectory() {
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    final base = (home == null || home.isEmpty) ? Directory.current.path : home;
    if (Platform.isMacOS) {
      final inferredHome = _inferUserHomeFromPath(base) ?? _inferUserHomeFromEnv();
      if (inferredHome != null) {
        final downloads = [
          inferredHome,
          'Downloads',
        ].join(Platform.pathSeparator);
        if (Directory(downloads).existsSync()) {
          return [
            downloads,
            'Halumi',
            'outputs',
          ].join(Platform.pathSeparator);
        }
      }
    }
    if (Platform.isWindows) {
      final downloads = [base, 'Downloads'].join(Platform.pathSeparator);
      if (Directory(downloads).existsSync()) {
        return [
          downloads,
          'Halumi',
          'outputs',
        ].join(Platform.pathSeparator);
      }
    }
    return [base, 'Halumi', 'outputs'].join(Platform.pathSeparator);
  }

  String? _inferUserHomeFromEnv() {
    final user = Platform.environment['USER'] ?? Platform.environment['LOGNAME'];
    if (user == null || user.isEmpty) return null;
    final candidate = [
      'Users',
      user,
    ].join(Platform.pathSeparator);
    final resolved = '${Platform.pathSeparator}$candidate';
    return Directory(resolved).existsSync() ? resolved : null;
  }

  String? _inferUserHomeFromPath(String path) {
    final normalized = _normalizePath(path);
    final parts = normalized.split('/');
    final userIndex = parts.indexOf('Users');
    if (userIndex == -1 || userIndex + 1 >= parts.length) {
      return null;
    }
    final candidate = [
      'Users',
      parts[userIndex + 1],
    ].join(Platform.pathSeparator);
    final resolved = '${Platform.pathSeparator}$candidate';
    return Directory(resolved).existsSync() ? resolved : null;
  }

  Future<String> resolveDefaultOutputDirectory() async {
    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        final downloadsPath = downloadsDir.path;
        final normalized = _normalizePath(downloadsPath);
        if (Platform.isMacOS &&
            normalized.toLowerCase().contains('/library/containers/')) {
          final inferredHome =
              _inferUserHomeFromPath(normalized) ?? _inferUserHomeFromEnv();
          if (inferredHome != null) {
            final candidate = [
              inferredHome,
              'Downloads',
            ].join(Platform.pathSeparator);
            if (Directory(candidate).existsSync()) {
              return [
                candidate,
                'Halumi',
                'outputs',
              ].join(Platform.pathSeparator);
            }
          }
        }
        return [downloadsPath, 'Halumi', 'outputs']
            .join(Platform.pathSeparator);
      }
    } catch (_) {}
    return _fallbackOutputDirectory();
  }

  String loadOutputDirectory() {
    final value = box.get(
      HiveKeys.outputDirectory,
      defaultValue: _fallbackOutputDirectory(),
    );
    final resolved = (value is String) ? value.trim() : '';
    return resolved.isEmpty ? _fallbackOutputDirectory() : resolved;
  }

  Future<void> updateOutputDirectory(String value) {
    final trimmed = value.trim();
    return box.put(
      HiveKeys.outputDirectory,
      trimmed.isEmpty ? _fallbackOutputDirectory() : trimmed,
    );
  }

  String loadAiModel() =>
      box.get(HiveKeys.aiModel, defaultValue: 'halumi-video-1') as String;

  Future<void> updateAiModel(String value) => box.put(HiveKeys.aiModel, value);

  List<AiModelConfig> loadAiModels() {
    final raw = box.get(HiveKeys.aiModels, defaultValue: <dynamic>[]) as List;
    return raw
        .map((e) => AiModelConfig.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<AiModelConfig>> addAiModel(AiModelConfig config) async {
    final existing = loadAiModels();
    final updated = [...existing, config];
    await box.put(HiveKeys.aiModels, updated.map((e) => e.toMap()).toList());
    await box.put(HiveKeys.aiModel, config.id);
    return updated;
  }

  Future<List<AiModelConfig>> updateAiModelConfig(AiModelConfig config) async {
    final existing = loadAiModels();
    final index = existing.indexWhere((model) => model.id == config.id);
    final updated = [...existing];
    if (index == -1) {
      updated.add(config);
    } else {
      updated[index] = config;
    }
    await box.put(HiveKeys.aiModels, updated.map((e) => e.toMap()).toList());
    return updated;
  }

  ValueListenable<Box> listenable() => box.listenable(
    keys: [
      HiveKeys.themeMode,
      HiveKeys.language,
      HiveKeys.outputDirectory,
      HiveKeys.aiModel,
      HiveKeys.aiModels,
    ],
  );
}

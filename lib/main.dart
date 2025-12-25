import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'core/persistence/hive_boxes.dart';
import 'core/persistence/hive_initializer.dart';
import 'core/repositories/project_repository.dart';
import 'core/repositories/settings_repository.dart';
import 'ui/macos/halumi_macos_app.dart';
import 'ui/windows/halumi_windows_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForApp();
  await _configureWindow();
  await openAppBoxes();

  final projectRepository = ProjectRepository(Hive.box(HiveBoxes.projects));
  final settingsRepository = SettingsRepository(Hive.box(HiveBoxes.settings));
  await settingsRepository.ensureDefaults();

  if (!kIsWeb && Platform.isWindows) {
    runApp(
      HalumiWindowsApp(
        projectRepository: projectRepository,
        settingsRepository: settingsRepository,
      ),
    );
  } else {
    runApp(
      HalumiMacosApp(
        projectRepository: projectRepository,
        settingsRepository: settingsRepository,
      ),
    );
  }
}

final _macosWindowHandler = _MacosWindowHandler();

Future<void> _configureWindow() async {
  if (kIsWeb) return;
  if (!(Platform.isMacOS || Platform.isWindows)) return;

  await windowManager.ensureInitialized();
  if (Platform.isMacOS) {
    await windowManager.setPreventClose(true);
    windowManager.addListener(_macosWindowHandler);
  }
  final windowOptions = WindowOptions(
    size: const Size(1100, 720),
    minimumSize: const Size(900, 620),
    center: true,
    title: 'Halumi',
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

class _MacosWindowHandler with WindowListener {
  @override
  void onWindowClose() async {
    final isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await windowManager.minimize();
    }
  }
}

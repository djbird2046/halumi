import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../core/localization/app_language.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/repositories/project_repository.dart';
import '../../core/repositories/settings_repository.dart';
import '../shared/views/home_view.dart';
import '../theme/app_theme.dart';
import 'widgets/windows_window_controls.dart';

class HalumiWindowsApp extends StatelessWidget {
  const HalumiWindowsApp({
    super.key,
    required this.projectRepository,
    required this.settingsRepository,
  });

  final ProjectRepository projectRepository;
  final SettingsRepository settingsRepository;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: settingsRepository.listenable(),
      builder: (context, box, _) {
        final themeMode = themeModeFromString(
          settingsRepository.loadThemeMode(),
        );
        final language = settingsRepository.loadLanguage();
        return MaterialApp(
          title: 'Halumi',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: themeMode,
          locale: language.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: HomeView(
            projectRepository: projectRepository,
            settingsRepository: settingsRepository,
            enableDragToMove: true,
            reserveNativeButtonsSpace: false,
            topBarHeight: 32,
            topBarTrailing: const WindowsWindowControls(height: 32),
          ),
        );
      },
    );
  }
}

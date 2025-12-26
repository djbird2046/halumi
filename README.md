# Halumi

AI video generation desktop workspace built with Flutter.

[中文说明](README-zh_CN.md)

## Features
- Multi-provider AI model management (OpenAI Sora 2, Google Veo, Alibaba WanXiang, ByteDance JiMeng, Kwai Kling).
- Project-based workflow: create, rename, and delete works.
- Prompt + reference images (single/multi image depending on the model).
- Model-aware parameter controls: aspect ratio, resolution, duration.
- Generation progress, status, saved file path, and quick open of output folder.
- Local settings: language (English/中文), theme (light/dark/system), output directory.
- Local persistence for projects and settings via Hive.

## Platforms
- macOS
- Windows

## Setup
1. Install Flutter, then run `flutter pub get`.
2. Start the desktop app:
   - `flutter run -d macos`
   - `flutter run -d windows`

## macOS Packaging
1. Build the macOS release:
   - `flutter build macos --release`
2. Find the app bundle at:
   - `build/macos/Build/Products/Release/Halumi.app`
3. Create a DMG installer:
   - `hdiutil create -volname Halumi -srcfolder build/macos/Build/Products/Release/Halumi.app -ov -format UDZO build/macos/Halumi.dmg`

The DMG output goes to `build/macos/Halumi.dmg`.

## Windows Packaging (Inno Setup)
1. Build the Windows release:
   - `flutter build windows --release`
2. Compile the installer with Inno Setup (ISCC):
   - `iscc windows/installer/halumi.iss`

The installer output goes to `build/installer`.

## Usage
1. Open `Settings` -> `AI Model` to add a provider config.
2. Create a project from the sidebar.
3. Enter a prompt and select reference images if required by the model.
4. Choose aspect ratio, resolution, duration, then click `Generate`.

## Provider Notes
- Sora 2: API key; optional base URL; optional model ID.
- Veo: OAuth token, Project ID, Location/Region; optional Storage URI.
- WanXiang: API key; optional model ID.
- JiMeng/Kling: API key + Secret Key; requires at least one reference image.
- Some providers accept multiple images; the UI enforces limits based on model capability.

## Development
- `flutter analyze`
- `flutter test`

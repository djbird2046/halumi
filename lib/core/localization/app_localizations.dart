import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const delegate = _AppLocalizationsDelegate();
  static const supportedLocales = [Locale('en'), Locale('zh')];

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settingsTitle': 'Settings',
      'settingsTabGeneral': 'General',
      'settingsTabAiModel': 'AI Model',
      'settingsAppearanceHeader': 'Appearance',
      'settingsLanguageLabel': 'Language',
      'settingsLanguageDescription': 'Choose app language',
      'settingsLanguageSystem': 'Follow system',
      'settingsLanguageChinese': '简体中文',
      'settingsLanguageEnglish': 'English',
      'settingsThemeLabel': 'Theme',
      'settingsThemeDescription': 'Choose light or dark appearance',
      'settingsThemeSystem': 'Follow system',
      'settingsThemeLight': 'Light',
      'settingsThemeDark': 'Dark',
      'settingsOutputTitle': 'Output directory',
      'settingsOutputDescription':
          'Generated videos are saved under this folder (one subfolder per project).',
      'settingsOutputChange': 'Change',
      'settingsOutputReset': 'Reset to default',
      'settingsAddModel': 'Add',
      'settingsNoModels': 'No models yet. Click Add to start.',
      'settingsDialogAddModelTitle': 'Add model',
      'settingsDialogEditModelTitle': 'Edit model',
      'settingsDialogProviderLabel': 'Provider',
      'settingsDialogNameLabel': 'Name',
      'settingsDialogNameValidation': 'Please enter a name',
      'settingsDialogApiKeyLabel': 'API Key/Token',
      'settingsDialogApiKeyValidation': 'Please enter an API key',
      'settingsDialogModelIdLabel': 'Model ID (optional)',
      'settingsDialogBaseUrlLabel': 'Custom Base URL (optional)',
      'settingsDialogSecretKeyLabel': 'Secret Key',
      'settingsDialogProjectIdLabel': 'Project ID',
      'settingsDialogLocationLabel': 'Location/Region',
      'settingsDialogStorageUriLabel': 'Storage URI (optional)',
      'settingsDialogProviderRequired': 'Please select a provider',
      'settingsDialogModelRequired': 'Please select a model',
      'commonAdd': 'Add',
      'commonSave': 'Save',
      'commonCancel': 'Cancel',
      'commonDelete': 'Delete',
      'commonSettings': 'Settings',
      'commonOpenFolder': 'Open folder',
      'commonCopyPath': 'Copy path',
      'commonCopy': 'Copy',
      'commonCopied': 'Copied',
      'commonGenerate': 'Generate',
      'commonNewProject': 'New Work',
      'projectImagesTrimmed':
          'Kept the first {count} images; the rest were ignored.',
      'projectAddModelHint': 'Add a model in Settings first.',
      'projectEnterPrompt': 'Please enter a prompt.',
      'projectSelectImagesMulti': 'Select at least one reference image.',
      'projectSelectImageSingle': 'Select a reference image.',
      'projectGenerateReady':
          'Parameters ready; hook up inference to generate.',
      'projectOpenDirUnsupported':
          'Opening the folder is not supported on this platform yet.',
      'projectOpenDirFailed': 'Failed to open folder: {error}',
      'projectOpenLinkUnsupported':
          'Opening links is not supported on this platform yet.',
      'projectOpenLinkFailed': 'Failed to open link: {error}',
      'projectAiModel': 'AI Model',
      'projectAddModelCta': 'Add in Settings',
      'projectNoModelsHelp': 'No models yet. Add one in Settings on the left.',
      'projectSelectModelLabel': 'Select model',
      'projectSupportsMultiImages': 'Supports multiple images (<= {count})',
      'projectSupportsSingleImage': 'Supports single image',
      'projectNoImageNeeded': 'No image input needed',
      'projectAspectRatiosLabel': 'Aspect ratios: {value}',
      'projectResolutionsLabel': 'Resolutions: {value}',
      'projectDurationsLabel': 'Durations: {value}',
      'projectOptionAuto': 'Auto',
      'projectPromptTitle': 'Prompt',
      'projectPromptHint': 'Describe the scene, mood, camera, duration, etc.',
      'projectParamsTitle': 'Generation parameters',
      'projectAspectRatioLabel': 'Aspect ratio',
      'projectResolutionLabel': 'Resolution',
      'projectDurationLabel': 'Duration (s)',
      'projectOtherParamsLabel': 'Other params (e.g., fps/duration)',
      'projectOtherParamsHint': 'Leave empty for now; hook real params later.',
      'projectGenerateTitle': 'Generate video',
      'projectSelectModelFirst': 'Select a model first',
      'projectGenerateDescription': 'Use {model} to generate, output to {dir}',
      'projectReferenceImagesTitle': 'Reference images',
      'projectNoImagesRequired': 'Current model does not need images',
      'projectNoImagesDescription':
          "This model doesn't need image input. You can generate with just a prompt.",
      'projectPickMultiple': 'Pick multiple images',
      'projectPickSingle': 'Pick image',
      'projectMultiImageNote': 'Supports multiple images, sent in order.',
      'projectSingleImageNote': 'Only supports one reference image.',
      'projectNoImagesSelected': 'No images selected',
      'projectPickImagesNoResult':
          'No files were selected. If no picker appeared, check system permissions.',
      'projectPickImagesTimeout':
          'Opening the file picker timed out. Please try again.',
      'projectPickImagesFailed': 'Failed to open image picker: {error}',
      'projectMultiImageLimit': 'Up to {count} images',
      'projectMultiImageUnlimited': 'No limit',
      'projectSingleOnly': 'Single only',
      'projectStatusLabel': 'Status: {status}',
      'projectStatusQueued': 'Queued',
      'projectStatusProcessing': 'Processing',
      'projectStatusStreaming': 'Streaming',
      'projectStatusSucceeded': 'Succeeded',
      'projectStatusFailed': 'Failed',
      'projectDownloadedFile': 'Saved file: {name}',
      'projectGenerationSucceeded': 'Generation completed',
      'projectGenerationFailed': 'Generation failed: {error}',
      'homeDeleteProjectTitle': 'Delete work',
      'homeDeleteProjectMessage':
          'Are you sure you want to delete the work "{name}"? This cannot be undone.',
      'createProjectTitle': 'Create work',
      'createProjectNameLabel': 'Work name',
      'createProjectNameValidation': 'Please enter a name',
      'createProjectModelLabel': 'Select model',
      'createProjectModelEmpty': 'Add an AI model in Settings first.',
      'createProjectAddModelLink': 'Add model',
    },
    'zh': {
      'settingsTitle': '设置',
      'settingsTabGeneral': '通用',
      'settingsTabAiModel': 'AI 模型',
      'settingsAppearanceHeader': '外观',
      'settingsLanguageLabel': '语言',
      'settingsLanguageDescription': '选择界面语言',
      'settingsLanguageSystem': '跟随系统',
      'settingsLanguageChinese': '简体中文',
      'settingsLanguageEnglish': '英文',
      'settingsThemeLabel': '主题',
      'settingsThemeDescription': '选择明暗模式',
      'settingsThemeSystem': '跟随系统',
      'settingsThemeLight': '浅色',
      'settingsThemeDark': '深色',
      'settingsOutputTitle': '输出目录',
      'settingsOutputDescription': '生成的视频会保存到该目录（每个作品单独子文件夹）。',
      'settingsOutputChange': '更改',
      'settingsOutputReset': '恢复默认',
      'settingsAddModel': '添加',
      'settingsNoModels': '暂无模型，请点击 Add 添加。',
      'settingsDialogAddModelTitle': '添加模型',
      'settingsDialogEditModelTitle': '编辑模型',
      'settingsDialogProviderLabel': 'Provider',
      'settingsDialogNameLabel': '名称',
      'settingsDialogNameValidation': '请输入名称',
      'settingsDialogApiKeyLabel': 'API Key/Token',
      'settingsDialogApiKeyValidation': '请输入 API Key',
      'settingsDialogModelIdLabel': '模型 ID（可选）',
      'settingsDialogBaseUrlLabel': '自定义 Base URL（可选）',
      'settingsDialogSecretKeyLabel': 'Secret Key/密钥',
      'settingsDialogProjectIdLabel': 'Project ID',
      'settingsDialogLocationLabel': '区域（Location）',
      'settingsDialogStorageUriLabel': '存储 URI（可选）',
      'settingsDialogProviderRequired': '请选择 Provider',
      'settingsDialogModelRequired': '请选择模型',
      'commonAdd': '添加',
      'commonSave': '保存',
      'commonCancel': '取消',
      'commonDelete': '删除',
      'commonSettings': '设置',
      'commonOpenFolder': '打开文件夹',
      'commonCopyPath': '复制路径',
      'commonCopy': '复制',
      'commonCopied': '已复制',
      'commonGenerate': '生成',
      'commonNewProject': '新建作品',
      'projectImagesTrimmed': '已截取前 {count} 张图片，其余已忽略。',
      'projectAddModelHint': '请先在 Settings 中添加模型并完成选择。',
      'projectEnterPrompt': '请输入提示词。',
      'projectSelectImagesMulti': '请选择至少一张参考图。',
      'projectSelectImageSingle': '请选择参考图。',
      'projectGenerateReady': '参数已准备，接入推理后可调用生成。',
      'projectOpenDirUnsupported': '当前平台暂未适配自动打开目录。',
      'projectOpenDirFailed': '打开目录失败：{error}',
      'projectOpenLinkUnsupported': '当前平台暂未适配自动打开链接。',
      'projectOpenLinkFailed': '打开链接失败：{error}',
      'projectAiModel': 'AI 模型',
      'projectAddModelCta': '请在 Settings 中添加',
      'projectNoModelsHelp': '暂无模型，请先在左侧 Settings 中添加可用的模型配置。',
      'projectSelectModelLabel': '选择模型',
      'projectSupportsMultiImages': '支持多图 (<= {count})',
      'projectSupportsSingleImage': '支持单图',
      'projectNoImageNeeded': '不需要图像输入',
      'projectAspectRatiosLabel': '比例: {value}',
      'projectResolutionsLabel': '分辨率: {value}',
      'projectDurationsLabel': '时长: {value}',
      'projectOptionAuto': '自动',
      'projectPromptTitle': '提示词',
      'projectPromptHint': '描述你想要的画面、情绪、镜头、时长等信息。',
      'projectParamsTitle': '生成参数',
      'projectAspectRatioLabel': '画面比例',
      'projectResolutionLabel': '分辨率',
      'projectDurationLabel': '时长（秒）',
      'projectOtherParamsLabel': '其他参数 (如帧率/时长)',
      'projectOtherParamsHint': '可留空，后续接入真实参数',
      'projectGenerateTitle': '生成视频',
      'projectSelectModelFirst': '请先选择模型',
      'projectGenerateDescription': '将使用 {model} 生成，输出到 {dir}',
      'projectReferenceImagesTitle': '参考图片',
      'projectNoImagesRequired': '当前模型不需要图片',
      'projectNoImagesDescription': '此模型暂不需要图片输入，可直接使用提示词生成。',
      'projectPickMultiple': '选择多张图片',
      'projectPickSingle': '选择图片',
      'projectMultiImageNote': '支持多张图片，将按顺序传入模型。',
      'projectSingleImageNote': '仅支持单张参考图。',
      'projectNoImagesSelected': '尚未选择图片',
      'projectPickImagesNoResult': '未选择任何图片。如未弹出选择器，请检查系统权限。',
      'projectPickImagesTimeout': '打开文件选择器超时，请重试。',
      'projectPickImagesFailed': '选择图片失败：{error}',
      'projectMultiImageLimit': '最多 {count} 张',
      'projectMultiImageUnlimited': '不限',
      'projectSingleOnly': '仅单张',
      'projectStatusLabel': '状态：{status}',
      'projectStatusQueued': '排队中',
      'projectStatusProcessing': '处理中',
      'projectStatusStreaming': '生成中',
      'projectStatusSucceeded': '成功',
      'projectStatusFailed': '失败',
      'projectDownloadedFile': '已保存文件：{name}',
      'projectGenerationSucceeded': '生成完成',
      'projectGenerationFailed': '生成失败：{error}',
      'homeDeleteProjectTitle': '删除作品',
      'homeDeleteProjectMessage': '确认删除作品 "{name}" 吗？操作不可恢复。',
      'createProjectTitle': '新建作品',
      'createProjectNameLabel': '作品名称',
      'createProjectNameValidation': '请输入名称',
      'createProjectModelLabel': '选择大模型',
      'createProjectModelEmpty': '请先在设置中添加模型。',
      'createProjectAddModelLink': '添加模型',
    },
  };

  String get settingsTitle => _t('settingsTitle');
  String get settingsTabGeneral => _t('settingsTabGeneral');
  String get settingsTabAiModel => _t('settingsTabAiModel');
  String get settingsAppearanceHeader => _t('settingsAppearanceHeader');
  String get settingsLanguageLabel => _t('settingsLanguageLabel');
  String get settingsLanguageDescription => _t('settingsLanguageDescription');
  String get settingsLanguageSystem => _t('settingsLanguageSystem');
  String get settingsLanguageChinese => _t('settingsLanguageChinese');
  String get settingsLanguageEnglish => _t('settingsLanguageEnglish');
  String get settingsThemeLabel => _t('settingsThemeLabel');
  String get settingsThemeDescription => _t('settingsThemeDescription');
  String get settingsThemeSystem => _t('settingsThemeSystem');
  String get settingsThemeLight => _t('settingsThemeLight');
  String get settingsThemeDark => _t('settingsThemeDark');
  String get settingsOutputTitle => _t('settingsOutputTitle');
  String get settingsOutputDescription => _t('settingsOutputDescription');
  String get settingsOutputChange => _t('settingsOutputChange');
  String get settingsOutputReset => _t('settingsOutputReset');
  String get settingsAddModel => _t('settingsAddModel');
  String get settingsNoModels => _t('settingsNoModels');
  String get settingsDialogAddModelTitle => _t('settingsDialogAddModelTitle');
  String get settingsDialogEditModelTitle => _t('settingsDialogEditModelTitle');
  String get settingsDialogProviderLabel => _t('settingsDialogProviderLabel');
  String get settingsDialogNameLabel => _t('settingsDialogNameLabel');
  String get settingsDialogNameValidation => _t('settingsDialogNameValidation');
  String get settingsDialogApiKeyLabel => _t('settingsDialogApiKeyLabel');
  String get settingsDialogApiKeyValidation =>
      _t('settingsDialogApiKeyValidation');
  String get settingsDialogModelIdLabel => _t('settingsDialogModelIdLabel');
  String get settingsDialogBaseUrlLabel => _t('settingsDialogBaseUrlLabel');
  String get settingsDialogSecretKeyLabel => _t('settingsDialogSecretKeyLabel');
  String get settingsDialogProjectIdLabel => _t('settingsDialogProjectIdLabel');
  String get settingsDialogLocationLabel => _t('settingsDialogLocationLabel');
  String get settingsDialogStorageUriLabel =>
      _t('settingsDialogStorageUriLabel');
  String get settingsDialogProviderRequired =>
      _t('settingsDialogProviderRequired');
  String get settingsDialogModelRequired => _t('settingsDialogModelRequired');

  String get commonAdd => _t('commonAdd');
  String get commonSave => _t('commonSave');
  String get commonCancel => _t('commonCancel');
  String get commonDelete => _t('commonDelete');
  String get commonSettings => _t('commonSettings');
  String get commonOpenFolder => _t('commonOpenFolder');
  String get commonCopyPath => _t('commonCopyPath');
  String get commonCopy => _t('commonCopy');
  String get commonCopied => _t('commonCopied');
  String get commonGenerate => _t('commonGenerate');
  String get commonNewProject => _t('commonNewProject');

  String projectImagesTrimmed(int count) =>
      _format('projectImagesTrimmed', {'count': '$count'});
  String get projectAddModelHint => _t('projectAddModelHint');
  String get projectEnterPrompt => _t('projectEnterPrompt');
  String get projectSelectImagesMulti => _t('projectSelectImagesMulti');
  String get projectSelectImageSingle => _t('projectSelectImageSingle');
  String get projectGenerateReady => _t('projectGenerateReady');
  String get projectOpenDirUnsupported => _t('projectOpenDirUnsupported');
  String projectOpenDirFailed(String error) =>
      _format('projectOpenDirFailed', {'error': error});
  String get projectOpenLinkUnsupported => _t('projectOpenLinkUnsupported');
  String projectOpenLinkFailed(String error) =>
      _format('projectOpenLinkFailed', {'error': error});
  String get projectAiModel => _t('projectAiModel');
  String get projectAddModelCta => _t('projectAddModelCta');
  String get projectNoModelsHelp => _t('projectNoModelsHelp');
  String get projectSelectModelLabel => _t('projectSelectModelLabel');
  String projectSupportsMultiImages(String count) =>
      _format('projectSupportsMultiImages', {'count': count});
  String get projectSupportsSingleImage => _t('projectSupportsSingleImage');
  String get projectNoImageNeeded => _t('projectNoImageNeeded');
  String projectAspectRatiosLabel(String value) =>
      _format('projectAspectRatiosLabel', {'value': value});
  String projectResolutionsLabel(String value) =>
      _format('projectResolutionsLabel', {'value': value});
  String projectDurationsLabel(String value) =>
      _format('projectDurationsLabel', {'value': value});
  String get projectOptionAuto => _t('projectOptionAuto');
  String get projectPromptTitle => _t('projectPromptTitle');
  String get projectPromptHint => _t('projectPromptHint');
  String get projectParamsTitle => _t('projectParamsTitle');
  String get projectAspectRatioLabel => _t('projectAspectRatioLabel');
  String get projectResolutionLabel => _t('projectResolutionLabel');
  String get projectDurationLabel => _t('projectDurationLabel');
  String get projectOtherParamsLabel => _t('projectOtherParamsLabel');
  String get projectOtherParamsHint => _t('projectOtherParamsHint');
  String get projectParamsNote => _t('projectParamsNote');
  String get projectGenerateTitle => _t('projectGenerateTitle');
  String get projectSelectModelFirst => _t('projectSelectModelFirst');
  String projectGenerateDescription(String model, String dir) =>
      _format('projectGenerateDescription', {'model': model, 'dir': dir});
  String get projectReferenceImagesTitle => _t('projectReferenceImagesTitle');
  String get projectNoImagesRequired => _t('projectNoImagesRequired');
  String get projectNoImagesDescription => _t('projectNoImagesDescription');
  String get projectPickMultiple => _t('projectPickMultiple');
  String get projectPickSingle => _t('projectPickSingle');
  String get projectMultiImageNote => _t('projectMultiImageNote');
  String get projectSingleImageNote => _t('projectSingleImageNote');
  String get projectNoImagesSelected => _t('projectNoImagesSelected');
  String get projectPickImagesNoResult => _t('projectPickImagesNoResult');
  String get projectPickImagesTimeout => _t('projectPickImagesTimeout');
  String projectPickImagesFailed(String error) =>
      _format('projectPickImagesFailed', {'error': error});
  String projectMultiImageLimit(int count) =>
      _format('projectMultiImageLimit', {'count': '$count'});
  String get projectMultiImageUnlimited => _t('projectMultiImageUnlimited');
  String get projectSingleOnly => _t('projectSingleOnly');
  String projectStatusLabel(String status) =>
      _format('projectStatusLabel', {'status': status});
  String get projectStatusQueued => _t('projectStatusQueued');
  String get projectStatusProcessing => _t('projectStatusProcessing');
  String get projectStatusStreaming => _t('projectStatusStreaming');
  String get projectStatusSucceeded => _t('projectStatusSucceeded');
  String get projectStatusFailed => _t('projectStatusFailed');
  String projectDownloadedFile(String name) =>
      _format('projectDownloadedFile', {'name': name});
  String get projectGenerationSucceeded => _t('projectGenerationSucceeded');
  String projectGenerationFailed(String error) =>
      _format('projectGenerationFailed', {'error': error});

  String get homeDeleteProjectTitle => _t('homeDeleteProjectTitle');
  String homeDeleteProjectMessage(String name) =>
      _format('homeDeleteProjectMessage', {'name': name});
  String get createProjectTitle => _t('createProjectTitle');
  String get createProjectNameLabel => _t('createProjectNameLabel');
  String get createProjectNameValidation => _t('createProjectNameValidation');
  String get createProjectModelLabel => _t('createProjectModelLabel');
  String get createProjectModelEmpty => _t('createProjectModelEmpty');
  String get createProjectAddModelLink => _t('createProjectAddModelLink');

  String _t(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String _format(String key, Map<String, String> params) {
    var value = _t(key);
    params.forEach((k, v) {
      value = value.replaceAll('{$k}', v);
    });
    return value;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'zh'].contains(locale.languageCode.toLowerCase());

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

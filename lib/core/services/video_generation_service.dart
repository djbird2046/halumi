import 'package:ai_video_gen_dart/ai_video_gen_dart.dart';
import 'package:ai_video_gen_dart/src/model.dart' show GeneratorCapabilities;

import '../models/ai_model_config.dart';

/// 统一封装各 Provider 的生成流程。
class VideoGenerationService {
  VideoGenerationService({VideoGenerationClient? client})
      : client =
      client ??
          VideoGenerationClient(
            options: const ClientOptions(
              pollIntervalMs: 4000,
              maxPollTimeMs: 10 * 60 * 1000,
            ),
          );

  final VideoGenerationClient client;

  String? promptGuideUrlFor(AiModelConfig model) {
    try {
      return _buildPromptGuideGenerator(model)?.promptGuideUrl;
    } catch (_) {
      return null;
    }
  }

  GeneratorCapabilities? capabilitiesFor(AiModelConfig model) {
    try {
      return _buildPromptGuideGenerator(model)?.capabilities;
    } catch (_) {
      return null;
    }
  }

  Future<GenerationResult> generate({
    required AiModelConfig model,
    required String prompt,
    required List<String> imagePaths,
    required String outputDir,
    String? aspectRatio,
    String? resolution,
    int? durationSeconds,
    void Function(GenerationResult result)? onProgress,
  }) async {
    final generator = _buildGenerator(model, imagePaths);
    final request = _buildRequest(
      model: model,
      prompt: prompt,
      imagePaths: imagePaths,
      aspectRatio: aspectRatio,
      resolution: resolution,
      durationSeconds: durationSeconds,
    );

    return client.generate(
      generator,
      request,
      onProgress: onProgress,
      pollOptions: PollOptions(downloadDir: outputDir),
    );
  }

  VideoGenerator _buildGenerator(AiModelConfig model, List<String> imagePaths) {
    final provider = model.provider.trim().toLowerCase();
    switch (provider) {
      case 'sora2':
      case 'sora':
        return SoraGenerator(
          apiKey: model.apiKey,
          baseUrl: model.baseUrl,
          model: model.model,
        );
      case 'veo':
        if ((model.projectId ?? '').isEmpty || (model.location ?? '').isEmpty) {
          throw VideoGenException('Veo 需要 projectId 和 location');
        }
        return VeoGenerator(
          oauthToken: model.apiKey,
          projectId: model.projectId ?? '',
          location: model.location ?? '',
          model: model.model,
          baseUrl: model.baseUrl,
        );
      case 'jimeng':
        if ((model.secretKey ?? '').isEmpty) {
          throw VideoGenException('Jimeng 需要 Secret Key');
        }
        final firstImage = _requireFirstImage(imagePaths, 'Jimeng');
        final reqKey = model.model;
        switch (_jimengVariant(reqKey)) {
          case _JimengVariant.p1080:
            return JiMeng3P1080Generator(
              accessKey: model.apiKey,
              secretAccessKey: model.secretKey ?? '',
              options: JiMeng3RequestOptions(image: firstImage),
              baseUrl: model.baseUrl,
            );
          case _JimengVariant.p720:
            return JiMeng3P720Generator(
              accessKey: model.apiKey,
              secretAccessKey: model.secretKey ?? '',
              options: JiMeng3RequestOptions(image: firstImage),
              baseUrl: model.baseUrl,
            );
          case _JimengVariant.pro:
            return JiMeng3ProGenerator(
              accessKey: model.apiKey,
              secretAccessKey: model.secretKey ?? '',
              options: JiMengRequestOptions(image: firstImage, reqKey: reqKey),
              baseUrl: model.baseUrl,
            );
        }
      case 'kling':
      case 'keling':
        if ((model.secretKey ?? '').isEmpty) {
          throw VideoGenException('Kling 需要 Secret Key');
        }
        _requireFirstImage(imagePaths, 'Kling');
        return KlingGenerator(
          accessKey: model.apiKey,
          secretKey: model.secretKey,
          baseUrl: model.baseUrl,
        );
      case 'wanxiang':
        _requireFirstImage(imagePaths, 'WanXiang');
        return WanXiangGenerator(apiKey: model.apiKey, baseUrl: model.baseUrl);
      default:
        throw VideoGenException('未知的 Provider: $provider');
    }
  }

  VideoGenerator? _buildPromptGuideGenerator(AiModelConfig model) {
    final provider = model.provider.trim().toLowerCase();
    final apiKey = model.apiKey.isNotEmpty ? model.apiKey : 'prompt-guide';
    final secretKey =
    (model.secretKey != null && model.secretKey!.isNotEmpty)
        ? model.secretKey!
        : 'prompt-guide';
    const placeholderImage = 'prompt-guide-image';
    switch (provider) {
      case 'sora2':
      case 'sora':
        return SoraGenerator(
          apiKey: apiKey,
          baseUrl: model.baseUrl,
          model: model.model,
        );
      case 'veo':
        return VeoGenerator(
          oauthToken: apiKey,
          projectId: (model.projectId != null && model.projectId!.isNotEmpty)
              ? model.projectId!
              : 'prompt-guide-project',
          location: (model.location != null && model.location!.isNotEmpty)
              ? model.location!
              : 'us-central1',
          model: model.model,
          baseUrl: model.baseUrl,
        );
      case 'jimeng':
        final reqKey = model.model;
        switch (_jimengVariant(reqKey)) {
          case _JimengVariant.p1080:
            return JiMeng3P1080Generator(
              accessKey: apiKey,
              secretAccessKey: secretKey,
              options: JiMeng3RequestOptions(image: placeholderImage),
              baseUrl: model.baseUrl,
            );
          case _JimengVariant.p720:
            return JiMeng3P720Generator(
              accessKey: apiKey,
              secretAccessKey: secretKey,
              options: JiMeng3RequestOptions(image: placeholderImage),
              baseUrl: model.baseUrl,
            );
          case _JimengVariant.pro:
            return JiMeng3ProGenerator(
              accessKey: apiKey,
              secretAccessKey: secretKey,
              options: JiMengRequestOptions(
                image: placeholderImage,
                reqKey: reqKey,
              ),
              baseUrl: model.baseUrl,
            );
        }
      case 'kling':
      case 'keling':
        return KlingGenerator(
          accessKey: apiKey,
          secretKey: secretKey,
          baseUrl: model.baseUrl,
        );
      case 'wanxiang':
        return WanXiangGenerator(apiKey: apiKey, baseUrl: model.baseUrl);
      default:
        return null;
    }
  }

  UnifiedVideoRequest _buildRequest({
    required AiModelConfig model,
    required String prompt,
    required List<String> imagePaths,
    String? aspectRatio,
    String? resolution,
    int? durationSeconds,
  }) {
    final provider = model.provider.trim().toLowerCase();
    final metadata = <String, Object?>{};
    final firstImage = imagePaths.isNotEmpty ? imagePaths.first.trim() : null;

    switch (provider) {
      case 'sora2':
      case 'sora':
        if (firstImage != null && firstImage.isNotEmpty) {
          metadata['input_reference'] = firstImage;
        }
        break;
      case 'veo':
        if (firstImage != null && firstImage.isNotEmpty) {
          metadata['image'] = firstImage;
        }
        if (model.storageUri != null && model.storageUri!.isNotEmpty) {
          metadata['storage_uri'] = model.storageUri;
        }
        break;
      case 'jimeng':
      // JiMeng 选填 reqKey 使用 config.model。
        break;
      case 'kling':
      case 'keling':
        if (firstImage != null && firstImage.isNotEmpty) {
          metadata['image'] = firstImage;
        }
        if (durationSeconds != null) {
          metadata['duration'] = durationSeconds;
        }
        break;
      case 'wanxiang':
        if (firstImage != null && firstImage.isNotEmpty) {
          metadata['image'] = firstImage;
        }
        if (resolution != null && resolution.isNotEmpty) {
          metadata['resolution'] = resolution;
        }
        if (durationSeconds != null) {
          metadata['duration'] = durationSeconds;
        }
        if (model.model != null && model.model!.isNotEmpty) {
          metadata['model'] = model.model;
        }
        break;
      default:
        break;
    }

    metadata.removeWhere((_, value) => value == null);

    return UnifiedVideoRequest(
      apiKey: model.apiKey,
      prompt: prompt,
      model: _normalizeText(model.model),
      durationSeconds: durationSeconds,
      aspectRatio: _normalizeText(aspectRatio),
      resolution: _normalizeText(resolution),
      metadata: metadata.isEmpty ? null : metadata,
    );
  }

  String _requireFirstImage(List<String> images, String providerLabel) {
    if (images.isEmpty) {
      throw VideoGenException('$providerLabel 需要至少一张参考图');
    }
    return images.first;
  }
}

enum _JimengVariant { p720, p1080, pro }

_JimengVariant _jimengVariant(String? model) {
  final value = (model ?? '').trim();
  switch (value) {
    case 'jimeng_i2v_first_v30_1080':
      return _JimengVariant.p1080;
    case 'jimeng_i2v_first_v30':
      return _JimengVariant.p720;
    case 'jimeng_ti2v_v30_pro':
      return _JimengVariant.pro;
    default:
      final lower = value.toLowerCase();
      if (lower.contains('1080')) return _JimengVariant.p1080;
      if (lower.contains('720')) return _JimengVariant.p720;
      return _JimengVariant.pro;
  }
}

String? _normalizeText(String? value) {
  if (value == null) return null;
  final text = value.trim();
  return text.isEmpty ? null : text;
}

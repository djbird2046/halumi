class AiModelConfig {
  AiModelConfig({
    required this.id,
    required this.name,
    required this.provider,
    required this.apiKey,
    this.baseUrl,
    this.model,
    this.secretKey,
    this.projectId,
    this.location,
    this.storageUri,
  });

  final String id;
  final String name;
  final String provider;
  final String apiKey;
  final String? baseUrl;
  final String? model;
  final String? secretKey;
  final String? projectId;
  final String? location;
  final String? storageUri;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'provider': provider,
    'apiKey': apiKey,
    'baseUrl': baseUrl,
    'model': model,
    'secretKey': secretKey,
    'projectId': projectId,
    'location': location,
    'storageUri': storageUri,
  };

  factory AiModelConfig.fromMap(Map<String, dynamic> map) => AiModelConfig(
    id: map['id'] as String? ?? '',
    name: map['name'] as String? ?? '',
    provider: map['provider'] as String? ?? '',
    apiKey: map['apiKey'] as String? ?? '',
    baseUrl: map['baseUrl'] as String?,
    model: map['model'] as String?,
    secretKey: map['secretKey'] as String?,
    projectId: map['projectId'] as String?,
    location: map['location'] as String?,
    storageUri: map['storageUri'] as String?,
  );
}

class Project {
  Project({required this.id, required this.name, required this.createdAt});

  final String id;
  String name;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Project.fromMap(Map<String, dynamic> raw) => Project(
    id: raw['id'] as String? ?? '',
    name: raw['name'] as String? ?? 'Untitled',
    createdAt:
        DateTime.tryParse(raw['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

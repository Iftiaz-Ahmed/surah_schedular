class AdhanItem {
  final String name;
  final String path;
  final int type;

  AdhanItem({
    required this.name,
    required this.path,
    required this.type,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AdhanItem &&
        this.name == other.name &&
        this.path == other.path &&
        this.type == other.type;
  }

  @override
  int get hashCode => name.hashCode ^ path.hashCode ^ type.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'type': type,
    };
  }

  factory AdhanItem.fromJson(Map json) {
    return AdhanItem(
      name: json['name'],
      path: json['path'],
      type: json['type'],
    );
  }

  @override
  String toString() {
    return 'AdhanItem(name: $name, path: $path, type: $type)';
  }
}

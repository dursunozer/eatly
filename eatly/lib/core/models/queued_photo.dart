class QueuedPhoto {
  final String id;
  final String localPath;
  final DateTime takenAt;
  final bool isSynced;
  final String? remotePath;

  QueuedPhoto({
    required this.id,
    required this.localPath,
    required this.takenAt,
    required this.isSynced,
    this.remotePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'localPath': localPath,
        'takenAt': takenAt.toIso8601String(),
        'isSynced': isSynced,
        'remotePath': remotePath,
      };

  static QueuedPhoto fromJson(Map<String, dynamic> json) => QueuedPhoto(
        id: json['id'] as String,
        localPath: json['localPath'] as String,
        takenAt: DateTime.parse(json['takenAt'] as String),
        isSynced: json['isSynced'] as bool? ?? false,
        remotePath: json['remotePath'] as String?,
      );
}



class FileEntity {
  final String? key; // Firebase key for deletion
  final String name;
  final int size;
  final String url;
  final DateTime uploadTime;

  FileEntity({
    this.key,
    required this.name,
    required this.size,
    required this.url,
    required this.uploadTime,
  });
} 
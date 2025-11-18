class JournalEntry {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const JournalEntry({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id']?.toString() ?? '',
    userId: json['user_id']?.toString() ?? '',
    content: (json['journal'] ?? '') as String,
    createdAt: _parseDate(json['created_at']),
    updatedAt: _tryParseDate(json['updated_at']),
  );

  Map<String, dynamic> toJson(String userIdOverride) => {
    'id': id.isEmpty ? null : id,
    'user_id': userIdOverride,
    'journal': content,
  };

  JournalEntry copyWith({
    String? id,
    String? userId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => JournalEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.parse(value);
    return DateTime.now();
  }

  static DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.parse(value);
    return null;
  }
}

class Note {
  int? id;
  String title;
  String content;
  int priority; // 1: Thấp, 2: Trung bình, 3: Cao
  DateTime createdAt;
  DateTime modifiedAt;
  List<String>? tags;
  String? color;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
    required this.modifiedAt,
    this.tags,
    this.color,
  });

  /// Chuyển đối tượng Note thành Map (dùng cho SQLite hoặc gửi API)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'tags': tags != null ? tags!.join(',') : null,
      'color': color,
    };
  }

  /// Tạo đối tượng Note từ Map (đọc từ DB hoặc từ JSON API)
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] is int ? map['id'] : int.tryParse('${map['id']}'),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      priority: map['priority'] is int ? map['priority'] : int.tryParse('${map['priority']}') ?? 1,
      createdAt: DateTime.parse(map['createdAt']),
      modifiedAt: DateTime.parse(map['modifiedAt']),
      tags: _parseTags(map['tags']),
      color: map['color'],
    );
  }

  /// Hàm hỗ trợ parse tags từ dạng chuỗi hoặc list
  static List<String>? _parseTags(dynamic raw) {
    if (raw == null) return null;

    if (raw is List) {
      return List<String>.from(raw.map((e) => e.toString()));
    } else if (raw is String) {
      return raw.split(',').map((e) => e.trim()).toList();
    }

    return null;
  }

  /// Tạo bản sao với một số thuộc tính được thay đổi
  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? priority,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<String>? tags,
    String? color,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      tags: tags ?? this.tags,
      color: color ?? this.color,
    );
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, content: $content, priority: $priority, '
        'createdAt: $createdAt, modifiedAt: $modifiedAt, tags: $tags, color: $color)';
  }
}

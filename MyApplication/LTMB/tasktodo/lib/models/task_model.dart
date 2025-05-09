class TaskModel {
  String id;
  String title;
  String description;
  String status; // To do, In progress, Done, Cancelled
  int priority; // 1: Thấp, 2: Trung bình, 3: Cao
  DateTime? dueDate;
  DateTime createdAt;
  DateTime updatedAt;
  String? assignedTo;
  String createdBy;
  String? category;
  List<String>? attachments;
  bool completed;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.assignedTo,
    required this.createdBy,
    this.category,
    this.attachments,
    required this.completed,
  });

  factory TaskModel.fromMap(Map<String, dynamic> data) {
    return TaskModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'To do',
      priority: data['priority'] ?? 1,
      dueDate: data['dueDate'] != null
          ? DateTime.parse(data['dueDate'])
          : null,
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      assignedTo: data['assignedTo'],
      createdBy: data['createdBy'] ?? '',
      category: data['category'],
      attachments: List<String>.from(data['attachments'] ?? []),
      completed: data['completed'] ?? false,
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasktodo/models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createTask(TaskModel task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).set({
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'status': task.status,
        'priority': task.priority,
        'dueDate': task.dueDate?.toIso8601String(),
        'createdAt': task.createdAt.toIso8601String(),
        'updatedAt': task.updatedAt.toIso8601String(),
        'assignedTo': task.assignedTo,
        'createdBy': task.createdBy,
        'category': task.category,
        'attachments': task.attachments ?? [],
        'completed': task.completed,
      });
      print('Nhiệm vụ đã được tạo thành công: ${task.id}');
    } catch (e) {
      print('Lỗi khi tạo nhiệm vụ trong Firestore: $e');
      throw e;
    }
  }

  Future<List<TaskModel>> getTasksForUser(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tasks')
          .where('assignedTo', isEqualTo: userId)
          .get();
      return snapshot.docs.map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách nhiệm vụ: $e');
      throw e;
    }
  }
}
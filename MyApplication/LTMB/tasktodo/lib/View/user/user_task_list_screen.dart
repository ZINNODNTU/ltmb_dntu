import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasktodo/models/task_model.dart';
import 'task_detail_screen.dart'; // Import màn hình chi tiết nhiệm vụ dành cho User

class TaskListScreenUser extends StatelessWidget {
  final String userId;

  TaskListScreenUser({required this.userId, Key? key}) : super(key: key);

  Future<void> _deleteTask(String taskId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa nhiệm vụ thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa nhiệm vụ thất bại: $e')),
      );
    }
  }

  Future<void> _toggleCompleted(String taskId, bool newValue, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({'completed': newValue});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newValue ? 'Đã đánh dấu hoàn thành' : 'Đã bỏ đánh dấu hoàn thành')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật trạng thái thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách nhiệm vụ'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('assignedTo', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có nhiệm vụ nào.'));
          }

          List<TaskModel> tasks = snapshot.data!.docs
              .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>)
            ..id = doc.id) // Gán ID của document
              .toList();

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                child: ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: task.completed,
                        onChanged: (bool? value) {
                          if (value != null) {
                            _toggleCompleted(task.id, value, context);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Xóa nhiệm vụ',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xác nhận xóa'),
                              content: const Text('Bạn có chắc muốn xóa nhiệm vụ này không?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteTask(task.id, context);
                                  },
                                  child: const Text(
                                    'Xóa',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskDetailScreenUser(task: task),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

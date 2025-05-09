import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tasktodo/models/task_model.dart';
import 'edit_task_screen.dart';
import 'package:tasktodo/helpers/file_utils.dart';

class TaskDetailScreenAdmin extends StatefulWidget {
  final TaskModel task;

  TaskDetailScreenAdmin({required this.task});

  @override
  _TaskDetailScreenAdminState createState() => _TaskDetailScreenAdminState();
}

class _TaskDetailScreenAdminState extends State<TaskDetailScreenAdmin> {
  final DateFormat dateFormatter = DateFormat('dd-MM-yyyy HH:mm');
  late AttachmentHandler attachmentHandler;

  @override
  void initState() {
    super.initState();
    attachmentHandler = AttachmentHandler(context, widget.task.title);
  }

  // Fetch the names of the task creator and assignee from Firestore
  Future<Map<String, String>> _fetchUserNames() async {
    String creatorName = 'Không rõ người tạo';
    String assigneeName = 'Chưa được giao';

    try {
      if (widget.task.createdBy.isNotEmpty) {
        final creatorDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.task.createdBy)
            .get();
        if (creatorDoc.exists) {
          creatorName = creatorDoc.data()?['name'] ?? creatorName;
        }
      }

      if (widget.task.assignedTo != null && widget.task.assignedTo!.isNotEmpty) {
        final assigneeDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.task.assignedTo!)
            .get();
        if (assigneeDoc.exists) {
          assigneeName = assigneeDoc.data()?['name'] ?? assigneeName;
        }
      }
    } catch (e) {
      print('Error fetching user names: $e');
    }

    return {'creator': creatorName, 'assignee': assigneeName};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết công việc'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent.shade700,
        onPressed: () async {
          final updatedTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditTaskScreen( task: widget.task,
              currentUserId: widget.task.createdBy ?? '',)),
          );
          if (updatedTask != null && updatedTask is TaskModel) {
            setState(() {});
          }
        },
        child: Icon(Icons.edit, color: Colors.white),
        tooltip: 'Chỉnh sửa công việc',
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _fetchUserNames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (snapshot.hasError) {
            print('FutureBuilder error: ${snapshot.error}');
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('Không thể tải thông tin người dùng.'));
          }

          final userNames = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.teal.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chi tiết công việc',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    context,
                    title: 'Tổng quan',
                    children: [
                      _infoTile(context, 'Mô tả',
                          widget.task.description.isNotEmpty ? widget.task.description : 'Không có mô tả'),
                      Divider(height: 1, color: Colors.grey.shade300),
                      _infoTile(context, 'Danh mục', widget.task.category ?? 'Chưa phân loại'),
                      Divider(height: 1, color: Colors.grey.shade300),
                      _infoTile(context, 'Trạng thái', widget.task.status),
                      Divider(height: 1, color: Colors.grey.shade300),
                      _infoTile(context, 'Mức ưu tiên', _priorityText(widget.task.priority)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    context,
                    title: 'Chi tiết',
                    children: [
                      _infoTile(context, 'Ngày hết hạn',
                          widget.task.dueDate != null ? dateFormatter.format(widget.task.dueDate!) : 'Chưa đặt'),
                      Divider(height: 1, color: Colors.grey.shade300),
                      _infoTile(context, 'Hoàn thành', widget.task.completed ? 'Đã hoàn thành' : 'Chưa hoàn thành'),
                      Divider(height: 1, color: Colors.grey.shade300),
                      _infoTile(context, 'Người được giao', userNames['assignee']!),
                      Divider(height: 1, color: Colors.grey.shade300),
                      _infoTile(context, 'Người tạo', userNames['creator']!),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    context,
                    title: 'Dòng thời gian',
                    children: [
                      _infoTile(context, 'Ngày tạo', dateFormatter.format(widget.task.createdAt)),
                      Divider(height: 1, color: Colors.grey.shade300),
                      _infoTile(context, 'Ngày cập nhật', dateFormatter.format(widget.task.updatedAt)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (widget.task.attachments != null && widget.task.attachments!.isNotEmpty)
                    attachmentHandler.buildAttachmentsSection(widget.task.attachments!),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Build a section with a title and a card containing info tiles
  Widget _buildInfoSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.teal.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  // Build a single info row within a section
  Widget _infoTile(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to get priority text
  String _priorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Cao';
      default:
        return 'Không xác định';
    }
  }
}
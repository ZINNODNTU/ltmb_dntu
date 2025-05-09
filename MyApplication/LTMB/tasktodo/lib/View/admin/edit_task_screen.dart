import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tasktodo/models/task_model.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:tasktodo/helpers/file_utils.dart';

// Màn hình chỉnh sửa nhiệm vụ
class EditTaskScreen extends StatefulWidget {
  final TaskModel task; // nhiệm vụ cần chỉnh sửa
  final String currentUserId; // ID của người dùng hiện tại

  EditTaskScreen({required this.task, required this.currentUserId});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  // Các controller cho input
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  String? assignedTo; // Người được giao nhiệm vụ
  String status = 'Chưa làm'; // Trạng thái mặc định
  int priority = 1; // Mức độ ưu tiên mặc định
  DateTime? dueDate; // Ngày hết hạn
  bool completed = false; // Trạng thái hoàn thành
  List<String> attachments = []; // Danh sách tệp đính kèm dạng base64
  List<File> newFiles = []; // Danh sách tệp mới được chọn
  late AttachmentHandler attachmentHandler;

  bool get isOwner => widget.task.createdBy == widget.currentUserId; // kiểm tra có phải chủ sở hữu

  @override
  void initState() {
    super.initState();
    // Khởi tạo AttachmentHandler
    attachmentHandler = AttachmentHandler(context, widget.task.title);
    // Gán giá trị ban đầu từ task
    titleController.text = widget.task.title;
    descriptionController.text = widget.task.description;
    categoryController.text = widget.task.category ?? '';
    assignedTo = widget.task.assignedTo;
    status = widget.task.status;
    priority = widget.task.priority;
    dueDate = widget.task.dueDate;
    completed = widget.task.completed;
    attachments = List<String>.from(widget.task.attachments ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh Sửa Nhiệm Vụ'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trường nhập tiêu đề
            _buildTextField('Tiêu Đề', titleController, enabled: isOwner),
            SizedBox(height: 12),
            // Trường nhập mô tả
            _buildTextField('Mô Tả', descriptionController, maxLines: 3, enabled: isOwner),
            SizedBox(height: 12),
            // Dropdown chọn trạng thái
            _buildDropdownStatus(),
            SizedBox(height: 12),
            // Dropdown chọn độ ưu tiên (chỉ hiển thị cho chủ sở hữu)
            if (isOwner) _buildDropdownPriority(),
            if (isOwner) SizedBox(height: 12),
            // Chọn ngày hết hạn
            if (isOwner) _buildDueDatePicker(),
            if (isOwner) SizedBox(height: 12),
            // Trường nhập danh mục
            if (isOwner) _buildTextField('Danh Mục', categoryController, enabled: isOwner),
            SizedBox(height: 12),
            // Chuyển đổi hoàn thành
            if (isOwner) _buildCompletedSwitch(),
            if (isOwner) SizedBox(height: 12),
            _buildAssignedToDropdown(),
            if (isOwner) SizedBox(height: 12),
            // Hiển thị phần tệp đính kèm
            _buildAttachmentsSection(),
            SizedBox(height: 20),
            // Nút lưu thay đổi
            ElevatedButton.icon(
              onPressed: _updateTask,
              icon: Icon(Icons.save),
              label: Text('Lưu Thay Đổi'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tạo ô nhập liệu
  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, bool enabled = true}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  // Dropdown chọn trạng thái
  Widget _buildDropdownStatus() {
    List<String> statuses = ['To do', 'In progress', 'Done', 'Cancelled'];
    return DropdownButtonFormField<String>(
      value: status,
      decoration: InputDecoration(
        labelText: 'Trạng Thái',
        border: OutlineInputBorder(),
      ),
      items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (value) {
        setState(() {
          status = value!;
        });
      },
    );
  }

  // Dropdown chọn độ ưu tiên
  Widget _buildDropdownPriority() {
    return DropdownButtonFormField<int>(
      value: priority,
      decoration: InputDecoration(
        labelText: 'Độ Ưu Tiên',
        border: OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(value: 1, child: Text('Thấp')),
        DropdownMenuItem(value: 2, child: Text('Trung Bình')),
        DropdownMenuItem(value: 3, child: Text('Cao')),
      ],
      onChanged: (value) {
        setState(() {
          priority = value!;
        });
      },
    );
  }

  // Chọn ngày hết hạn
  Widget _buildDueDatePicker() {
    return InkWell(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: dueDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            dueDate = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Ngày Hết Hạn',
          border: OutlineInputBorder(),
        ),
        child: Text(
          dueDate != null ? DateFormat('yyyy-MM-dd').format(dueDate!) : 'Chọn ngày',
        ),
      ),
    );
  }

  // Switch trạng thái hoàn thành
  Widget _buildCompletedSwitch() {
    return SwitchListTile(
      title: Text('Hoàn Thành'),
      value: completed,
      onChanged: (value) {
        setState(() {
          completed = value;
        });
      },
    );
  }
  //hiển thị người được giao
  Widget _buildAssignedToDropdown() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('users').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: LinearProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Lỗi khi tải danh sách người dùng: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('Không tìm thấy người dùng');
        }

        List<DropdownMenuItem<String>> userItems = snapshot.data!.docs.map((doc) {
          return DropdownMenuItem(
            value: doc.id,
            child: Text(doc['name'] ?? 'Không có tên'),
          );
        }).toList();

        bool isAssignedToValid = assignedTo != null &&
            userItems.any((item) => item.value == assignedTo);

        if (!isAssignedToValid && assignedTo != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              assignedTo = null;
            });
          });
        }

        return DropdownButtonFormField<String>(
          value: isAssignedToValid ? assignedTo : null,
          decoration: InputDecoration(
            labelText: 'Giao Cho',
            border: OutlineInputBorder(),
          ),
          hint: Text('Chọn Người Dùng'),
          onChanged: (value) {
            setState(() {
              assignedTo = value;
            });
          },
          items: userItems,
        );
      },
    );
  }
  // Hiển thị danh sách tệp đính kèm
  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tệp Đính Kèm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal.shade900)),
        SizedBox(height: 8),
        // Nút thêm tệp
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: Icon(Icons.attach_file),
          label: Text('Thêm Tệp'),
          onPressed: _pickFiles,
        ),
        SizedBox(height: 8),
        // Hiển thị danh sách tệp cũ
        attachmentHandler.buildAttachmentsSection(attachments),
        // Hiển thị danh sách tệp mới chọn
        if (newFiles.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tệp Mới Được Chọn',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.teal.shade800),
              ),
              SizedBox(height: 8),
              ...newFiles.asMap().entries.map((entry) {
                int index = entry.key;
                File file = entry.value;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(file.path.split('/').last)),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => setState(() => newFiles.removeAt(index)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
      ],
    );
  }

  // Hàm chọn tệp
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      );
      if (result != null) {
        List<File> pickedFiles = result.paths.map((path) => File(path!)).toList();
        for (File file in pickedFiles) {
          if (file.lengthSync() > 700 * 1024) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tệp ${file.path.split('/').last} quá lớn (giới hạn 700KB)')),
            );
            return;
          }
        }
        setState(() => newFiles.addAll(pickedFiles));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi chọn tệp: $e')));
    }
  }

  // Hàm cập nhật nhiệm vụ
  void _updateTask() {
    Map<String, dynamic> updateData = {
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (isOwner) {
      List<String> allAttachments = List.from(attachments);
      for (File file in newFiles) {
        try {
          List<int> fileBytes = file.readAsBytesSync();
          String base64String = base64Encode(fileBytes);
          allAttachments.add(base64String);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi mã hóa tệp ${file.path.split('/').last}: $e')),
          );
          return;
        }
      }

      updateData.addAll({
        'title': titleController.text,
        'description': descriptionController.text,
        'priority': priority,
        'dueDate': dueDate?.toIso8601String(),
        'category': categoryController.text,
        'assignedTo': assignedTo,
        'completed': completed,
        'attachments': allAttachments,
      });
    }

    FirebaseFirestore.instance.collection('tasks').doc(widget.task.id).update(updateData).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nhiệm vụ đã được cập nhật thành công!')),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật nhiệm vụ: $error')),
      );
    });
  }
}
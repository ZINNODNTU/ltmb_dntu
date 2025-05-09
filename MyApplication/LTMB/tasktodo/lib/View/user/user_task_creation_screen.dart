import 'package:flutter/material.dart';
import 'package:tasktodo/Service/task_service.dart';
import 'package:tasktodo/models/task_model.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class TaskCreationScreenuser extends StatefulWidget {
  @override
  _TaskCreationScreenuserState createState() => _TaskCreationScreenuserState();
}

class _TaskCreationScreenuserState extends State<TaskCreationScreenuser> {
  // Controller cho các trường nhập liệu
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final TaskService _taskService = TaskService(); // Dịch vụ xử lý tác vụ

  DateTime? dueDate; // Ngày hết hạn
  int priority = 1; // Độ ưu tiên mặc định (1 = thấp)
  List<File> selectedFiles = []; // Danh sách tệp đã chọn
  bool isUploading = false; // Trạng thái đang upload

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo Nhiệm Vụ'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nhập tiêu đề
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Tiêu Đề',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Nhập mô tả
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Mô Tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),

              // Chọn ngày hết hạn
              ListTile(
                title: Text(
                  'Ngày Hết Hạn: ${dueDate != null ? dueDate!.toLocal().toString().split(' ')[0] : 'Chưa đặt'}',
                ),
                trailing: Icon(Icons.calendar_today, color: Colors.teal),
                onTap: _selectDueDate,
              ),
              SizedBox(height: 16),

              // Dropdown chọn độ ưu tiên
              DropdownButtonFormField<int>(
                value: priority,
                decoration: InputDecoration(
                  labelText: 'Độ Ưu Tiên',
                  border: OutlineInputBorder(),
                ),
                onChanged: (int? newValue) {
                  setState(() {
                    priority = newValue!;
                  });
                },
                items: <int>[1, 2, 3].map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value == 1 ? 'Thấp' : value == 2 ? 'Trung Bình' : 'Cao'),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),

              // Tiêu đề phần tệp đính kèm
              Text(
                'Tệp Đính Kèm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade900,
                ),
              ),
              SizedBox(height: 8),

              // Nút chọn tệp
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: Icon(Icons.attach_file),
                label: Text('Chọn Tệp'),
                onPressed: _pickFiles,
              ),
              SizedBox(height: 8),

              // Hiển thị danh sách tệp đã chọn
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: selectedFiles.isEmpty
                    ? Text(
                  'Chưa chọn tệp. Nhấn "Chọn Tệp" để thêm tệp đính kèm.',
                  style: TextStyle(color: Colors.grey.shade600),
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: selectedFiles.map((file) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text(file.path.split('/').last)),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                selectedFiles.remove(file);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),

              // Nút tạo nhiệm vụ
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isUploading ? null : _createTask,
                child: isUploading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Tạo Nhiệm Vụ', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hàm chọn ngày hết hạn
  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dueDate) {
      setState(() {
        dueDate = picked;
      });
    }
  }

  /// Hàm chọn file từ thiết bị
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      );
      if (result != null) {
        setState(() {
          selectedFiles.addAll(result.paths.map((path) => File(path!)).toList());
          print('Đã chọn các tệp: ${selectedFiles.map((f) => f.path).toList()}');
        });
      } else {
        print('Không có tệp nào được chọn');
      }
    } catch (e) {
      print('Lỗi khi chọn tệp: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn tệp: $e')),
      );
    }
  }

  /// Hàm xử lý tạo nhiệm vụ
  Future<void> _createTask() async {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tiêu đề')),
      );
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng đăng nhập để tạo nhiệm vụ')),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      String taskId = DateTime.now().millisecondsSinceEpoch.toString();
      List<String> attachmentBase64Strings = [];

      // Kiểm tra & chuyển file sang base64
      for (File file in selectedFiles) {
        if (!await file.exists()) {
          throw Exception('Tệp không tồn tại: ${file.path}');
        }

        int fileSize = file.lengthSync();
        if (fileSize > 700 * 1024) {
          throw Exception('Tệp ${file.path.split('/').last} quá lớn (giới hạn 700KB)');
        }

        List<int> fileBytes = await file.readAsBytes();
        String base64String = base64Encode(fileBytes);
        print('Tệp ${file.path.split('/').last} mã hóa base64 (${base64String.length} ký tự)');
        attachmentBase64Strings.add(base64String);
      }

      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Tạo đối tượng task
      TaskModel task = TaskModel(
        id: taskId,
        title: titleController.text,
        description: descriptionController.text,
        status: 'To do',
        priority: priority,
        dueDate: dueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: userId,
        assignedTo: userId,
        completed: false,
        attachments: attachmentBase64Strings,
      );

      // Gửi task lên service
      await _taskService.createTask(task);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tạo nhiệm vụ: $e')),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }
}

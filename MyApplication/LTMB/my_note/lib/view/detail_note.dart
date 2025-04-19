import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_note/model/Note.dart';

class DetailNote extends StatelessWidget {
  final Note note;

  const DetailNote({Key? key, required this.note}) : super(key: key);

  String formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  String getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Cao';
      default:
        return 'Không rõ';
    }
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi Tiết Ghi Chú'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề
                Row(
                  children: [
                    Icon(Icons.title, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note.title,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Nội dung
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note.content,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Mức độ ưu tiên
                Row(
                  children: [
                    Icon(Icons.priority_high, color: getPriorityColor(note.priority)),
                    SizedBox(width: 8),
                    Text(
                      'Mức độ ưu tiên: ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Chip(
                      label: Text(getPriorityText(note.priority)),
                      backgroundColor: getPriorityColor(note.priority).withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: getPriorityColor(note.priority),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Ngày tạo
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey[700]),
                    SizedBox(width: 8),
                    Text(
                      'Ngày tạo: ',
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                    Text(
                      formatDate(note.createdAt),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Ngày cập nhật
                Row(
                  children: [
                    Icon(Icons.update, color: Colors.grey[700]),
                    SizedBox(width: 8),
                    Text(
                      'Cập nhật: ',
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                    Text(
                      formatDate(note.modifiedAt),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                //màu sắc hiển thị bằng chuỗi
                Row(
                  children: [
                    Icon(Icons.color_lens, color: Colors.grey[700]),
                    SizedBox(width: 8),
                    Text(
                      'Màu sắc: ',
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                    Text(
                      note.color ?? 'Không có màu sắc',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Thẻ hiển thị chuỗi
                Row(
                  children: [
                    Icon(Icons.tag, color: Colors.grey[700]),
                    SizedBox(width: 8),
                    Text(
                      'Thẻ: ',
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 8.0,
                        children: note.tags?.map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor: Colors.blue.withOpacity(0.2),
                          );
                        }).toList() ??
                            [],
                      ),
                    ),
                  ],
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}

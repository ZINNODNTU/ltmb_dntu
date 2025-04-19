import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_note/model/Note.dart';
import 'package:my_note/view/detail_note.dart';
import 'package:share_plus/share_plus.dart';

class NoteListItem extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const NoteListItem({
    Key? key,
    required this.note,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
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

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: const Text('Bạn có chắc chắn muốn xoá ghi chú này?'),
        actions: [
          TextButton(
            child: const Text('Huỷ'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Xoá'),
            onPressed: () {
              onDelete();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
  //chuyển priority từ số sang chuỗi
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



  void _shareNote() {
    // chuyển priority từ số sang chuỗi
    String priorityText = getPriorityText(note.priority);
    final shareContent = '''
    📝 ${note.title}
    ${note.content}
    📅 Ngày tạo: ${formatDate(note.createdAt)}
    📅 Ngày sửa: ${formatDate(note.modifiedAt)}
   
    🔺 Ưu tiên: ${priorityText}
    Tags: ${note.tags?.join(', ') ?? 'Không có'}
    color: ${note.color ?? 'Không có'}
    
    ''';
    Share.share(shareContent);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailNote(note: note),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Priority indicator
              Container(
                width: 5,
                height: 60,
                decoration: BoxDecoration(
                  color: getPriorityColor(note.priority),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),

              // Note content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ngày tạo: ${formatDate(note.createdAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Edit, Delete, and Share buttons
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmationDialog(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.green),
                    onPressed: _shareNote,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
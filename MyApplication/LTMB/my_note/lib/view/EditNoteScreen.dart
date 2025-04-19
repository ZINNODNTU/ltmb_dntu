import 'package:flutter/material.dart';
import 'package:my_note/model/Note.dart'; // Import model Note
import 'package:my_note/view/note_form.dart'; // Import NoteForm
import 'package:my_note/API/NoteAPIService.dart';

// Màn hình chỉnh sửa thông tin ghi chú
class EditNoteScreen extends StatelessWidget {
  final Note note; // Đối tượng ghi chú cần chỉnh sửa

  const EditNoteScreen({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NoteForm(
        note: note, // Truyền thông tin ghi chú vào NoteForm
        onSave: (Note updatedNote) async {
          try {
            // Cập nhật thông tin ghi chú trong cơ sở dữ liệu
            await NoteAPIService.instance.updateNote(updatedNote);

            // Hiển thị thông báo cập nhật thành công
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật ghi chú thành công'),
                backgroundColor: Colors.green,
              ),
            );

            // Đóng màn hình và trả về `true` để báo rằng cập nhật thành công
            Navigator.pop(context, true);
          } catch (e) {
            // Hiển thị thông báo lỗi nếu có vấn đề xảy ra
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi khi cập nhật ghi chú: $e'),
                backgroundColor: Colors.red,
              ),
            );

            // Đóng màn hình và trả về `false` để báo lỗi
            Navigator.pop(context, false);
          }
        },
      ),
    );
  }
}
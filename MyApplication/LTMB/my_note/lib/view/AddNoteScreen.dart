import 'package:flutter/material.dart';
import 'package:my_note/model/Note.dart';
import 'package:my_note/view/note_form.dart';
import 'package:my_note/API/NoteAPIService.dart';

class AddNoteScreen extends StatelessWidget {
  const AddNoteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: NoteForm(
        onSave: (Note note) async {
          try {
            // Save the note to the database
            await NoteAPIService.instance.createNote(note);

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thêm ghi chú thành công'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate back to the previous screen
            Navigator.pop(context, true);
          } catch (e) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi khi thêm ghi chú: $e'),
                backgroundColor: Colors.red,
              ),
            );

            // Navigate back with a failure indication
            Navigator.pop(context, false);
          }
        },
      ),
    );
  }
}
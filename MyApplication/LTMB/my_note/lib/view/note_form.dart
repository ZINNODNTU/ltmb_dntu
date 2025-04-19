import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:my_note/model/Note.dart';

class NoteForm extends StatefulWidget {
  final Note? note;
  final Function(Note) onSave;

  const NoteForm({Key? key, this.note, required this.onSave}) : super(key: key);

  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  int _priority = 2;
  Color _pickedColor = Colors.blue; // Mặc định
  late DateTime _createdAt;
  late DateTime _modifiedAt;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _tagsController.text = widget.note!.tags?.join(', ') ?? '';
      _priority = widget.note!.priority;
      _pickedColor = _colorFromHex(widget.note!.color ?? "#2196F3");
      _createdAt = widget.note!.createdAt;
      _modifiedAt = widget.note!.modifiedAt;
    } else {
      _createdAt = DateTime.now();
      _modifiedAt = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newNote = Note(
        id: widget.note?.id,
        title: _titleController.text,
        content: _contentController.text,
        priority: _priority,
        createdAt: _createdAt,
        modifiedAt: DateTime.now(),
        tags: _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
        color: _colorToHex(_pickedColor),
      );

      widget.onSave(newNote);
    }
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = _pickedColor;
        return AlertDialog(
          title: const Text('Chọn màu'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) => tempColor = color,
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('HỦY'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _pickedColor = tempColor;
                });
                Navigator.pop(context);
              },
              child: const Text('CHỌN'),
            ),
          ],
        );
      },
    );
  }

  String _colorToHex(Color color) =>
      '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';

  Color _colorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse('0x$hexColor'));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa ghi chú' : 'Thêm ghi chú'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Tiêu đề
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 16),

              // Nội dung
              TextFormField(
                controller: _contentController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Vui lòng nhập nội dung' : null,
              ),
              const SizedBox(height: 16),

              // Mức độ ưu tiên
              DropdownButtonFormField<int>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Mức độ ưu tiên',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Thấp')),
                  DropdownMenuItem(value: 2, child: Text('Trung bình')),
                  DropdownMenuItem(value: 3, child: Text('Cao')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _priority = value);
                },
              ),
              const SizedBox(height: 16),

              // Tags
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (phân cách bằng dấu phẩy)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Chọn màu
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.color_lens),
                      label: const Text('Chọn màu'),
                      onPressed: _pickColor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pickedColor,
                        foregroundColor: useWhiteForeground(_pickedColor)
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nút lưu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(isEditing ? 'CẬP NHẬT' : 'THÊM MỚI'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

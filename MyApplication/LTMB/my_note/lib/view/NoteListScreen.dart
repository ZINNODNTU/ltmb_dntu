import 'package:flutter/material.dart';
import 'package:my_note/API/NoteAPIService.dart';
import 'package:my_note/model/Note.dart';
import 'package:my_note/view/AddNoteScreen.dart';
import 'package:my_note/view/EditNoteScreen.dart';
import 'package:my_note/view/NoteListItem.dart';
import 'package:provider/provider.dart';
import 'package:my_note/view/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../view/LoginScreen.dart';

class NoteListScreen extends StatefulWidget {
  final Future<void> Function()? onLogout;

  const NoteListScreen({Key? key, this.onLogout}) : super(key: key);

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  late Future<List<Note>> _notesFuture;
  int? _selectedPriority;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    setState(() {
      _notesFuture = NoteAPIService.instance.getAllNotes();
    });
  }

  Future<void> _deleteNote(int id) async {
    await NoteAPIService.instance.deleteNote(id);
    _loadNotes();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi Chú Của Bạn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotes,
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: () {
              themeProvider.toggleTheme(!isDarkMode);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Đăng xuất'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Tìm ghi chú...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<int>(
              value: _selectedPriority,
              decoration: InputDecoration(
                labelText: 'Chọn mức độ ưu tiên',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Tất cả')),
                DropdownMenuItem(value: 1, child: Text('Thấp')),
                DropdownMenuItem(value: 2, child: Text('Trung bình')),
                DropdownMenuItem(value: 3, child: Text('Cao')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Note>>(
              future: _notesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Chưa có ghi chú nào.'));
                } else {
                  final notes = snapshot.data!;
                  final filteredNotes = notes.where((note) {
                    final matchesPriority = _selectedPriority == null || note.priority == _selectedPriority;
                    final matchesSearchQuery = note.title.toLowerCase().contains(_searchQuery) ||
                        note.content.toLowerCase().contains(_searchQuery);
                    return matchesPriority && matchesSearchQuery;
                  }).toList();

                  filteredNotes.sort((a, b) => b.priority.compareTo(a.priority));

                  return ListView.builder(
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return NoteListItem(
                        note: note,
                        onDelete: () => _deleteNote(note.id!),
                        onEdit: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditNoteScreen(note: note),
                            ),
                          );
                          if (updated == true) {
                            _loadNotes();
                          }
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Thêm ghi chú',
        child: const Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNoteScreen(),
            ),
          );
          if (created == true) {
            _loadNotes();
          }
        },
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận đăng xuất'),
        content: Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (widget.onLogout != null) {
                widget.onLogout!(); // Gọi callback nếu có
              } else {
                _logout(); // fallback
              }
            },
            child: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
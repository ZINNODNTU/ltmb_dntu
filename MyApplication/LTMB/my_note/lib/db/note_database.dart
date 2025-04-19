import 'package:my_note/model/Note.dart'; // Đảm bảo đường dẫn đúng với mô hình Note
import "package:sqflite/sqflite.dart";
import 'package:path/path.dart';

class NoteDatabaseHelper {
  static final NoteDatabaseHelper instance = NoteDatabaseHelper._init();
  static Database? _database;

  NoteDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
        CREATE TABLE notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          priority INTEGER NOT NULL,
          createdAt TEXT NOT NULL,
          modifiedAt TEXT NOT NULL,
          tags TEXT,
          color TEXT
        )
      ''');

    // Tạo sẵn dữ liệu mẫu
    await _insertSampleData(db);
  }

  // Phương thức chèn dữ liệu mẫu
  Future _insertSampleData(Database db) async {
    // Danh sách dữ liệu mẫu
    final List<Map<String, dynamic>> sampleNotes = [
      {
        'title': 'Ghi chú 1',
        'content': 'Nội dung ghi chú 1',
        'priority': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'modifiedAt': DateTime.now().toIso8601String(),
        'tags': null,
        'color': '#FF5733',
      },
      {
        'title': 'Ghi chú 2',
        'content': 'Nội dung ghi chú 2',
        'priority': 2,
        'createdAt': DateTime.now().toIso8601String(),
        'modifiedAt': DateTime.now().toIso8601String(),
        'tags': null,
        'color': '#33FF57',
      },
      {
        'title': 'Ghi chú 3',
        'content': 'Nội dung ghi chú 3',
        'priority': 3,
        'createdAt': DateTime.now().toIso8601String(),
        'modifiedAt': DateTime.now().toIso8601String(),
        'tags': null,
        'color': '#3357FF',
      },
    ];

    // Chèn từng ghi chú vào cơ sở dữ liệu
    for (final noteData in sampleNotes) {
      await db.insert('notes', noteData);
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Create - Thêm ghi chú mới
  Future<int> createNote(Note note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  // Read - Đọc tất cả ghi chú
  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes');

    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Read - Đọc ghi chú theo id
  Future<Note?> getNoteById(int id) async {
    final db = await instance.database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  // Update - Cập nhật ghi chú
  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Delete - Xoá ghi chú
  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Delete - Xoá tất cả ghi chú
  Future<int> deleteAllNotes() async {
    final db = await instance.database;
    return await db.delete('notes');
  }

// Đếm số lượng ghi chú
  Future<int> countNotes() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM notes');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

// getNotesByPriority(int priority): Lấy ghi chú theo mức độ ưu tiên

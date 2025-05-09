import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tasktodo/models/task_model.dart';
import 'package:tasktodo/View/user/task_detail_screen.dart';
import 'package:tasktodo/View/admin/task_detail_screen.dart';

// Hàm tiện ích để chuẩn hóa ngày về đầu ngày (bỏ giờ, phút, giây)
DateTime _normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

// Widget hiển thị một ô ngày trong tiêu đề lịch
class _DayTile extends StatelessWidget {
  final DateTime date; // Ngày của ô
  final bool isSelected; // Trạng thái được chọn
  final bool isToday; // Là ngày hiện tại
  final int taskCount; // Số lượng công việc trong ngày
  final VoidCallback onTap; // Hành động khi nhấn

  const _DayTile({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.taskCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50, // Chiều rộng ô ngày
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.withOpacity(0.2) : Colors.grey[100], // Màu nền
          borderRadius: BorderRadius.circular(12), // Góc bo tròn
          border: isSelected ? Border.all(color: Colors.teal, width: 1.5) : null, // Viền khi được chọn
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hiển thị thứ trong tuần (VD: T2, T3)
            Text(
              DateFormat.E().format(date).toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.teal : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            // Hiển thị số ngày
            Text(
              DateFormat.d().format(date),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.teal : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            // Hiển thị "Now" cho ngày hiện tại hoặc số lượng công việc
            if (isToday)
              Text(
                "Now",
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (taskCount > 0)
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "$taskCount",
                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )
            else
              const SizedBox(height: 18), // Giữ khoảng cách nhất quán
          ],
        ),
      ),
    );
  }
}

// Widget hiển thị một thẻ công việc trong danh sách
class _TaskCard extends StatelessWidget {
  final TaskModel task; // Công việc
  final bool isAdmin; // Vai trò admin
  final VoidCallback onTap; // Hành động khi nhấn

  const _TaskCard({
    required this.task,
    required this.isAdmin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            task.description.isEmpty ? "Không có mô tả" : task.description,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Icon(
          task.completed ? Icons.check_circle : Icons.timer_outlined,
          color: task.completed ? Colors.green : Colors.orange,
          size: 24,
        ),
        onTap: onTap,
      ),
    );
  }
}

// Màn hình lịch công việc
class TaskCalendarScreen extends StatefulWidget {
  final bool isAdmin; // Vai trò admin

  const TaskCalendarScreen({super.key, required this.isAdmin});

  @override
  State<TaskCalendarScreen> createState() => _TaskCalendarScreenState();
}

class _TaskCalendarScreenState extends State<TaskCalendarScreen> {
  late Map<DateTime, List<TaskModel>> _tasks; // Danh sách công việc theo ngày
  DateTime _selectedDay = DateTime.now(); // Ngày được chọn
  DateTime _startOfWeek = _getStartOfWeek(DateTime.now()); // Ngày đầu tuần

  // Lấy ngày bắt đầu của tuần (Thứ Hai)
  static DateTime _getStartOfWeek(DateTime date) {
    int daysToSubtract = date.weekday == 7 ? 6 : date.weekday - 1;
    return _normalizeDate(date.subtract(Duration(days: daysToSubtract)));
  }

  @override
  void initState() {
    super.initState();
    _tasks = {};
    _fetchTasks(); // Tải công việc
    // Chọn ngày hiện tại nếu nằm trong tuần hiện tại
    _selectedDay = _normalizeDate(DateTime.now());
    final start = _startOfWeek;
    final end = start.add(const Duration(days: 6));
    if (!_selectedDay.isAfter(start.subtract(const Duration(days: 1))) ||
        !_selectedDay.isBefore(end.add(const Duration(days: 1)))) {
      _selectedDay = start;
    }
  }

  // Tải công việc từ Firestore
  Future<void> _fetchTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final taskMap = <DateTime, List<TaskModel>>{};
    final uniqueTasks = <String, TaskModel>{};

    try {
      // Lấy công việc do người dùng tạo
      final createdBySnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('createdBy', isEqualTo: user.uid)
          .get();

      // Lấy công việc được giao cho người dùng
      final assignedToSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('assignedTo', isEqualTo: user.uid)
          .get();

      // Kết hợp và loại bỏ trùng lặp
      final allDocs = [...createdBySnapshot.docs, ...assignedToSnapshot.docs];
      final processedDocIds = <String>{};
      for (var doc in allDocs) {
        if (!processedDocIds.contains(doc.id)) {
          final data = doc.data();
          final task = TaskModel.fromMap({...data, 'id': doc.id});
          uniqueTasks[task.id] = task;
          processedDocIds.add(doc.id);
        }
      }

      // Nhóm công việc theo ngày đến hạn
      for (var task in uniqueTasks.values) {
        final dueDate = task.dueDate;
        if (dueDate == null) continue;
        final dayKey = _normalizeDate(dueDate);
        taskMap.putIfAbsent(dayKey, () => []).add(task);
      }

      if (mounted) {
        setState(() {
          _tasks = taskMap;
        });
      }
    } catch (e) {
      print('Lỗi khi tải công việc: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải công việc. Vui lòng thử lại.')),
        );
      }
    }
  }

  // Lấy danh sách công việc cho một ngày
  List<TaskModel> _getTasksForDay(DateTime day) {
    final key = _normalizeDate(day);
    return _tasks[key] ?? [];
  }

  // Chuyển sang tuần trước
  void _previousWeek() {
    setState(() {
      _startOfWeek = _startOfWeek.subtract(const Duration(days: 7));
      _selectedDay = _startOfWeek;
    });
  }

  // Chuyển sang tuần sau
  void _nextWeek() {
    setState(() {
      _startOfWeek = _startOfWeek.add(const Duration(days: 7));
      _selectedDay = _startOfWeek;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tạo danh sách ngày trong tuần
    final daysOfWeekDates = List.generate(7, (index) => _startOfWeek.add(Duration(days: index)));

    // Tạo danh sách widget ô ngày
    final daysOfWeekWidgets = daysOfWeekDates.map((date) {
      final selectedDayKey = _normalizeDate(_selectedDay);
      final dateKey = _normalizeDate(date);
      final todayKey = _normalizeDate(DateTime.now());

      return _DayTile(
        date: date,
        isSelected: selectedDayKey == dateKey,
        isToday: todayKey == dateKey,
        taskCount: _getTasksForDay(date).length,
        onTap: () {
          setState(() {
            _selectedDay = date;
          });
        },
      );
    }).toList();

    final tasksForSelectedDay = _getTasksForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thời khóa biểu"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Tiêu đề lịch tuần (có thể cuộn ngang)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: daysOfWeekWidgets,
            ),
          ),
          const SizedBox(height: 12),
          // Hiển thị khoảng thời gian tuần
          Text(
            "${DateFormat('d/M').format(_startOfWeek)} - ${DateFormat('d/M').format(_startOfWeek.add(const Duration(days: 6)))}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          const Divider(height: 24),
          // Danh sách công việc cho ngày được chọn
          Expanded(
            child: tasksForSelectedDay.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_available_outlined, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    "Trống lịch vào ngày này",
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Không có công việc nào được lên lịch.",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: tasksForSelectedDay.length,
              itemBuilder: (context, index) {
                final task = tasksForSelectedDay[index];
                return _TaskCard(
                  task: task,
                  isAdmin: widget.isAdmin,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => widget.isAdmin
                            ? TaskDetailScreenAdmin(task: task)
                            : TaskDetailScreenUser(task: task),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Nút điều hướng tuần
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              onPressed: _previousWeek,
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              mini: true,
              heroTag: 'prevWeekBtn',
              child: const Icon(Icons.arrow_back),
            ),
            FloatingActionButton(
              onPressed: _nextWeek,
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              mini: true,
              heroTag: 'nextWeekBtn',
              child: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );
  }
}
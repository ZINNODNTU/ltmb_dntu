import 'package:app_02/userMS/db/UserDatabaseHelper.dart'; // Import lớp hỗ trợ cơ sở dữ liệu
import 'package:app_02/userMS/model/User.dart'; // Import model User
import 'package:app_02/userMS/view/UserForm.dart'; // Import biểu mẫu nhập dữ liệu người dùng
import 'package:flutter/material.dart'; // Import thư viện giao diện Flutter

// Màn hình thêm người dùng, sử dụng StatelessWidget
class AddUserScreen extends StatelessWidget {
  const AddUserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserForm(
      onSave: (User user) async {
        try {
          // Gọi hàm để lưu người dùng vào cơ sở dữ liệu
          await UserDatabaseHelper.instance.createUser(user);

          // Đóng màn hình và trả về `true` để báo rằng đã thêm người dùng thành công
          Navigator.pop(context, true);

          // Hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Thêm người dùng thành công'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          // Hiển thị thông báo lỗi nếu có vấn đề xảy ra
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi thêm người dùng: $e'),
              backgroundColor: Colors.red,
            ),
          );

          // Đóng màn hình và trả về `false` để báo lỗi
          Navigator.pop(context, false);
        }
      },
    );
  }
}
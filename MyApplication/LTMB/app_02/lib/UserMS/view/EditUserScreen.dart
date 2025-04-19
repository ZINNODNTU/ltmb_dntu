import 'package:app_02/userMS/db/UserDatabaseHelper.dart'; // Import lớp hỗ trợ cơ sở dữ liệu
import 'package:app_02/userMS/model/User.dart'; // Import model User
import 'package:app_02/userMS/view/UserForm.dart'; // Import biểu mẫu nhập dữ liệu người dùng
import 'package:flutter/material.dart'; // Import thư viện giao diện Flutter

// Màn hình chỉnh sửa thông tin người dùng
class EditUserScreen extends StatelessWidget {
  final User user; // Đối tượng người dùng cần chỉnh sửa

  const EditUserScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserForm(
      user: user, // Truyền thông tin người dùng vào UserForm
      onSave: (User updatedUser) async {
        try {
          // Cập nhật thông tin người dùng trong cơ sở dữ liệu
          await UserDatabaseHelper.instance.updateUser(updatedUser);

          // Đóng màn hình và trả về `true` để báo rằng cập nhật thành công
          Navigator.pop(context, true);

          // Hiển thị thông báo cập nhật thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cập nhật người dùng thành công'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          // Hiển thị thông báo lỗi nếu có vấn đề xảy ra
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi cập nhật người dùng: $e'),
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

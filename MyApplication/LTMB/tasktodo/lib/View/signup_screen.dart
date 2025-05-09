import 'package:flutter/material.dart';
import 'package:tasktodo/View/login_screen.dart';
import 'package:tasktodo/Service/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService(); // Khởi tạo service để xử lý đăng ký

  // Các controller để lấy dữ liệu từ ô nhập
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'User'; // Vai trò mặc định
  bool _isLoading = false; // Trạng thái đang tải khi xử lý đăng ký
  bool isPasswordHidden = true; // Trạng thái ẩn/hiện mật khẩu

  // Hàm xử lý đăng ký
  void _signup() async {
    setState(() => _isLoading = true); // Hiển thị vòng quay chờ

    // Gọi hàm đăng ký từ AuthService
    String? result = await _authService.signup(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
    );

    setState(() => _isLoading = false); // Tắt vòng quay chờ

    if (result == null) {
      // Thành công: Hiển thị thông báo và chuyển đến màn hình đăng nhập
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công! Hãy đăng nhập ngay.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      // Thất bại: Hiển thị lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thất bại: $result')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Khoảng cách padding xung quanh
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset("assets/6333204.jpg"), // Hình ảnh đầu trang

              const SizedBox(height: 16),
              // Nhập tên hiển thị
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên hiển thị',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),
              // Nhập email
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),
              // Nhập mật khẩu
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },
                    icon: Icon(
                      isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
                obscureText: isPasswordHidden,
              ),

              const SizedBox(height: 16),
              // Chọn vai trò (Admin/User)
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Vai trò',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  }
                },
                items: ['Admin', 'User'].map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              // Nút đăng ký hoặc vòng quay chờ
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signup,
                  child: const Text('Đăng ký'),
                ),
              ),

              const SizedBox(height: 10),
              // Chuyển sang màn hình đăng nhập nếu đã có tài khoản
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Đã có tài khoản? ",
                    style: TextStyle(fontSize: 18),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Đăng nhập ngay",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: -1,
                      ),
                    ),
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

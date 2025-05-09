import 'package:flutter/material.dart';
import 'package:tasktodo/view/home_screen.dart';
import 'package:tasktodo/view/signup_screen.dart';
import 'package:tasktodo/Service/auth_service.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _resetEmailController = TextEditingController(); // Bộ điều khiển cho email đặt lại mật khẩu
  bool _isLoading = false;
  bool isPasswordHidden = true;

  // Hàm xử lý đăng nhập
  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email và mật khẩu')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Hiển thị trạng thái đang tải
    });

    Map<String, dynamic>? result = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false; // Tắt trạng thái đang tải
    });

    if (result != null && result.containsKey('role')) {
      String role = result['role'] ?? 'User';
      String? avatar = result['avatar'];

      // Hiển thị thông báo đăng nhập thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng nhập thành công! Vai trò: $role'),
          backgroundColor: Colors.teal,
        ),
      );

      // Điều hướng dựa trên vai trò người dùng
      if (role == 'Admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserScreen()),
        );
      }
    } else {
      String errorMessage = result != null && result.containsKey('error')
          ? result['error']
          : 'Không tìm thấy dữ liệu người dùng.';
      // Hiển thị thông báo đăng nhập thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập thất bại: $errorMessage')),
      );
    }
  }

  // Hàm hiển thị hộp thoại đặt lại mật khẩu
  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đặt lại mật khẩu'),
        content: TextField(
          controller: _resetEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Nhập email của bạn',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          // Nút hủy
          TextButton(
            onPressed: () {
              _resetEmailController.clear();
              Navigator.pop(context);
            },
            child: const Text('Hủy'),
          ),
          // Nút gửi email đặt lại mật khẩu
          ElevatedButton(
            onPressed: () async {
              final email = _resetEmailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập email')),
                );
                return;
              }

              setState(() {
                _isLoading = true; // Hiển thị trạng thái đang tải
              });

              try {
                await _authService.sendPasswordResetEmail(email); // Corrected line
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email đặt lại mật khẩu đã được gửi!'),
                    backgroundColor: Colors.teal,
                  ),
                );
                _resetEmailController.clear();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: $e')),
                );
              } finally {
                setState(() {
                  _isLoading = false; // Tắt trạng thái đang tải
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Gửi'),
          ),        ],
      ),
    );
  }

  @override
  void dispose() {
    // Giải phóng các bộ điều khiển để tránh rò rỉ bộ nhớ
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Hiển thị hình ảnh logo
              Image.asset("assets/3094352.jpg", height: 180),
              const SizedBox(height: 30),
              // Trường nhập email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Trường nhập mật khẩu
              TextField(
                controller: _passwordController,
                obscureText: isPasswordHidden,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        // Chuyển đổi trạng thái ẩn/hiện mật khẩu
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Nút quên mật khẩu
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _showResetPasswordDialog,
                  child: const Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Nút đăng nhập
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                  : ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Đăng nhập', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              // Liên kết đến màn hình đăng ký
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Chưa có tài khoản? ", style: TextStyle(fontSize: 16)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: const Text(
                      "Đăng ký ngay",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
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
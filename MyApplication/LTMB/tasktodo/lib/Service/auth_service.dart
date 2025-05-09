import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Đối tượng xác thực Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Đối tượng Firestore để lưu thông tin người dùng

  /// Đăng ký tài khoản mới
  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    required String role,
    String? avatar, // URL hình đại diện (tùy chọn)
  }) async {
    try {
      // Tạo người dùng với email và mật khẩu
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Lưu thông tin người dùng vào Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': role,
        'avatar': avatar,
        'createdAt': FieldValue.serverTimestamp(), // Thời gian tạo tài khoản
        'lastActive': FieldValue.serverTimestamp(), // Lần hoạt động cuối
      });

      return null; // Trả về null nếu thành công
    } catch (e) {
      return e.toString(); // Trả về lỗi nếu có
    }
  }

  /// Đăng nhập tài khoản
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Đăng nhập với email và mật khẩu
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Lấy thông tin người dùng từ Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;

        // Cập nhật thời gian hoạt động cuối cùng
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'lastActive': FieldValue.serverTimestamp(),
        });

        // Trả về vai trò và avatar
        return {
          'role': data['role']?.toString(),
          'avatar': data['avatar']?.toString(),
        };
      }

      return null; // Không tìm thấy tài liệu người dùng
    } catch (e) {
      return {'error': e.toString()}; // Trả về lỗi dạng Map
    }
  }

  /// Gửi email đặt lại mật khẩu
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Đăng xuất người dùng
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

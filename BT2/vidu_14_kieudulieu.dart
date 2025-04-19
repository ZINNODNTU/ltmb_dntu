void main() {
  //int kiểu số nguyên
  int x = 5;

  //double kiểu số thực
  double y = 5.5;

  //num kiểu số nguyên hoặc số thực
  num t = 5;
  t = 5.5;

  // chuyển chuổi sang số nguyên
  int a = int.parse("5");

  // chuyển chuổi sang số thực
  double b = double.parse("5.5");

  //chuyển số nguyên sang chuỗi
  String c = 5.toString();

  //bool kiểu luận lý
  bool kiemtra = true;

  //dynamic kiểu động
  dynamic z = 5;
  z = "Hello";

  print(a == 5 ? "true" : "false");
  print(b == 5.5 ? "true" : "false");
  print(c == 5 ? "true" : "false");

  //số pi với 5 số chuyển sang chuỗi lấy 2 số sau dấu phẩy
  double pi = 3.14159;
  print(pi.toStringAsFixed(2));
}

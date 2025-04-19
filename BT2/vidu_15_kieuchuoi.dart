/*
Chuỗi trong dart là tập hợp các ký tự Unicode, được bao quanh bởi dấu nháy đơn hoặc dấu nháy kép. UTF-16 được sử dụng để mã hóa chuỗi trong Dart.


*/

void main() {
  var s1 = 'Hello Dart';
  var s2 = "Hello.Flutter";

  //chèn giá trị của 1 biểu thức, hiển vào trong chuỗi bằng cách sử dụng ${expression}
  double diemtoan = 9.5;
  double diemly = 8.5;
  var s3 =
      "Điểm toán: $diemtoan, điểm lý: $diemly tổng điểm: ${diemtoan + diemly}";
  print(s3);

  // tạo ra chuỗi ở nhiều dòng
  var s4 = '''
  Hello
  Dart
  ''';
  print(s4);

  var s5 = """
  Hello
  Flutter
  """;
  print(s5);

  //chèn ký tự đặt biệt vào chuỗi để xuống dòng
  var s6 = "Hello \nDart";
  print(s6);

  //chèn ký tự đặt biệt nhưng không xuống dòng
  var s7 = r"Hello \nDart";
  print(s7);

  var s8 = "Hello" + "Dart";
  print(s8);
  var s9 =
      "Hello"
      "Dart"
      "Flutter";
  print(s9);
}

import 'dart:io';

void main() {
  stdout.write("Nhập tên của bạn: ");
  String ten = stdin.readLineSync()!;
  print("Chào mừng bạn $ten đến với Dart!");
  stdout.write("Nhập tuổi của bạn: ");
  int tuoi = int.parse(stdin.readLineSync()!);
  print("Tuổi của bạn là: $tuoi");
}

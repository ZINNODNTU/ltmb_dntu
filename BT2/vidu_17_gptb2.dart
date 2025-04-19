/*
Giải phương trình bậc 2: ax^2 + bx + c = 0

*/
import 'dart:math' as Math;
import 'dart:io';

void main() {
  double a = 0, b = 0, c = 0;
  do {
    stdout.write("Nhập a: ");
    String? input = stdin.readLineSync();
    if (input != null) {
      a = double.tryParse(input) ?? 0;
    }
  } while (a == 0);

  stdout.write("Nhập b: ");
  String? inputB = stdin.readLineSync();
  if (inputB != null) {
    b = double.tryParse(inputB) ?? 0;
  }
  stdout.write("Nhập a: ");
  String? inputC = stdin.readLineSync();
  if (inputC != null) {
    c = double.tryParse(inputC) ?? 0;
  }
  // Tính delta
  double delta = b * b - 4 * a * c;

  //hiển thị phương trình rA
  print("Phương trình: ${a}x^2 + ${b}x + ${c} = 0");

  //giải phương trình
  if (delta < 0) {
    print("Phương trình vô nghiệm");
  } else if (delta == 0) {
    double x = -b / (2 * a);
    print("Phương trình có nghiệm kép x1 = x2 = ${x.toStringAsFixed(2)}");
  } else {
    double x1 = (-b + Math.sqrt(delta)) / (2 * a);
    double x2 = (-b - Math.sqrt(delta)) / (2 * a);
    print(
      "Phương trình có 2 nghiệm phân biệt: x1 = ${x1.toStringAsFixed(2)}, x2 = ${x2.toStringAsFixed(2)}",
    );
  }
}

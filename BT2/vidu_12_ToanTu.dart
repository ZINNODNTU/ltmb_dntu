void main() {
  var kiemtra = (100 % 2 == 0) ? "Số chẵn" : "Số lẻ";
  print(kiemtra);

  var x = 100;
  var y = x ?? 50;
  print(y);

  int? z;
  y = z ?? 30;
  print(y);
}

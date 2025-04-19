//cấu trúc dữ liệu list
import 'dart:math';

void main() {
  //định nghĩa một list
  //- là tập hợp các phần tử có cùng kiểu dữ liệu
  //- có thể chứa nhiều phần tử
  //- có thể chứa các phần tử trùng lặp

  List<String> list = ['A', 'B', 'C', 'D']; //Trực Tiếp
  var list2 = ['A', 'B', 'C', 'D']; //Tự nhận biết kiểu dữ liệu bằng var
  List<String> list3 = []; //Khởi tạo rỗng list rỗng
  var list4 = List<int>.filled(
    3,
    0,
  ); //Khởi tạo list với 3 phần tử 0 kích thức cố điịnh
  print(list4);

  //thêm phần tử vào list
  list.add('E'); //thêm 1 phần tử vào cuối list
  list.addAll(['A', 'C']); //thêm nhiều phần tử vào cuối list

  list.insert(0, 'Z'); //thêm phần tử vào vị trí index

  list.insertAll(1, ['1', '0']); //thêm nhiều phần tử vào vị trí index
  print(list);

  //xóa phần tử khỏi list
  list.remove('A'); //xóa phần tử đầu tiên có giá trị A

  list.removeAt(0); //xóa phần tử tại vị trí index

  list.removeLast(); //xóa phần tử cuối cùng

  list.removeWhere((element) => element == 'B'); //xóa phần tử theo điều kiện

  list.clear(); //xóa tất cả phần tử trong list
  print(list);

  //truy cập phần tử trong list
  print(list2[0]); //truy cập phần tử tại vị trí index
  print(list2.first); //truy cập phần tử đầu tiên
  print(list2.last); //truy cập phần tử cuối cùng
  print(list2.length); //lấy kích thước list

  //kiểm tra phần tử trong list
  print(list2.isEmpty); //kiểm tra list rỗng
  print(list2.isNotEmpty); //kiểm tra list không rỗng

  print(
    'List 3: ${list3.isNotEmpty ? "Không rông" : "rỗng"}',
  ); //kiểm tra list rỗng
  print(list4.contains(0)); //kiểm tra phần tử có tồn tại trong list
  print(list4.indexOf(0)); //lấy vị trí index của phần tử
  print(list4.lastIndexOf(0)); //lấy vị trí index cuối cùng của phần tử

  //sắp xếp list
  list4 = [2, 1, 3, 9, 0, 10];
  print(list4);
  list4.sort(); //sắp xếp tăng dần
  print(list4.reversed); //đảo ngược list
  list4.sort((a, b) => b.compareTo(a)); //sắp xếp giảm dần
  print(list4);

  //cắt và nối list
  var sublist = list4.sublist(1, 3); //cắt list từ index 1 đến index 3
  print(sublist);

  var str_joined = list4.join(', '); //nối list thành chuỗi
  print(str_joined);

  //duyệt phần tử trong list
  list4.forEach((e) {
    print(e);
  });
}

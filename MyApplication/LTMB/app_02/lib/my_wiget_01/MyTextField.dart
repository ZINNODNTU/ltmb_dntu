import "package:flutter/material.dart";

class MyTextField extends StatelessWidget {
  const MyTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App 02"),
        backgroundColor: Colors.lightBlue,
        elevation: 4,
        actions: [
          IconButton(
            onPressed: () {
              print("b1");
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              print("b2");
            },
            icon: Icon(Icons.abc),
          ),
          IconButton(
            onPressed: () {
              print("b3");
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Họ và tên",
                hintText: "Nhập vào họ và tên của bạn",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "Example@gmail.com",
                helperText: "Nhập vào email cá nhân",
                prefixIcon: Icon(Icons.email),
                suffixIcon: Icon(Icons.clear),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                filled: true,
                fillColor: Colors.greenAccent,
              ),
            ),
            SizedBox(height: 30),
            TextField(
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "Example@gmail.com",
                helperText: "Nhập vào email cá nhân",
                prefixIcon: Icon(Icons.email),
                suffixIcon: Icon(Icons.clear),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                filled: true,
                fillColor: Colors.greenAccent,
              ),
            ),
            SizedBox(height: 30),
            //tao sizebox
            TextField(
              decoration: InputDecoration(
                labelText: "Ngày sinh",
                hintText: "Nhập vào ngày sinh của bạn",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),

            SizedBox(height: 30),
            TextField(
              decoration: InputDecoration(
                labelText: "Mật khẩu",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
              obscureText: true,
              obscuringCharacter: '*',
            ),

            SizedBox(height: 30),
            TextField(
              // onChanged: (value){
              //   print("Đang nhập: $value");
              // },
              onSubmitted: (value){
                print("Đã hoàn thành nội dung: $value");
              },
              decoration: InputDecoration(
                labelText: "Câu hỏi bí mật",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("pressed");
        },
        child: const Icon(Icons.add_ic_call),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Tìm kiếm"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Cá nhân"),
        ],
      ),
    );
  }
}
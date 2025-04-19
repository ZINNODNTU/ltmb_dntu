import 'package:flutter/material.dart';

class Mybutton2 extends StatelessWidget {
  const Mybutton2({super.key});

  @override
  Widget build(BuildContext context) {
    // tra ve Scaffold - cung cap bo cuc desgin don goam
    return Scaffold(
      //tieu de cua ung dung
      appBar: AppBar(
        title: Text("App 02"),
        backgroundColor: Colors.blue,
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
              print("b1");
            },
            icon: Icon(Icons.abc),
          ),
          IconButton(
            onPressed: () {
              print("b1");
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),

      body: Center(
        child: Column(
          children: [
            SizedBox(height: 50,),

            ElevatedButton(
              onPressed: () {
                print("ElevatedButton");
              },
              child: Text("haha", style: TextStyle(fontSize: 24)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                elevation: 14,

              ),
            ),

            SizedBox(height: 50,),

            IconButton(onPressed: (){print("pressed");},
                icon: Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
            SizedBox(height: 50,),

            InkWell(
              onTap: (){
                print("inwell duoc nhan");
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,

                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue)
                ),
                child: Text("button tuy chinh"),
              ),
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
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Cài đặt"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Ca nha"),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class Mybutton_3 extends StatelessWidget {
  const Mybutton_3({super.key});

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
            onPressed: null,
            child: Text("haha", style: TextStyle(fontSize: 24),)),
        SizedBox(height: 50,),

        ElevatedButton(
            onPressed: () {
              print("pressed");
            },
            onLongPress: () {
              print("long pressed");
            },
            child: Text("haha", style: TextStyle(fontSize: 24),)),
        SizedBox(height: 50,),

        InkWell(
          onTap: () {
            print("inwell duoc nhan");
          },
          onDoubleTap: () {
            print("inwell duoc nhan 2 lan");
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
            SizedBox(height: 50,),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.favorite),
              label: Text("Yêu thích"),
            ),

          ],
    ),
    ),
    floatingActionButton: FloatingActionButton(onPressed: (){print("pressed");},
    child: const Icon(Icons.add_ic_call),
    ),
    bottomNavigationBar: BottomNavigationBar(
    items: [
    BottomNavigationBarItem(
    icon: Icon(Icons.home),
    label: "Trang chủ",
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.settings),
    label: "Cài đặt",
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.person),
    label: "Ca nha",
    ),
    ],
    ),


    );
  }

}
import 'package:flutter/material.dart';

class Mybutton extends StatelessWidget{
     const Mybutton({super.key});

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
               ElevatedButton(
                   onPressed: (){print("ElevatedButton");}, 
                   child: Text("haha", style: TextStyle(fontSize: 24),)),
               // TextButton là một button phẳng,
               // , không có đổ bóng,
               // thường dùng cho các hành động thứ yếu
               // hoặc trong các thành phần như Dialog, Card.
               TextButton(
                   onPressed: (){print("TextButton");},
                   child: Text("TextButton", style: TextStyle(fontSize: 24),)),

               SizedBox(height: 20),
               // OutlinedButton là button có viền bao quanh,
               // không có màu nền,
               // phù hợp cho các thay thế.
               OutlinedButton(
                   onPressed: (){print("OutlinedButton");},
                   child: Text("OutlinedButton", style: TextStyle(fontSize: 24),)),

               SizedBox(height: 20),
               // IconButton là button chỉ gồm icon,
               // không có văn bản,
               // thường dùng trong AppBar, ToolBar.
               IconButton(
                   onPressed: (){print("Iconbuuton");},
                   icon: Icon(Icons.favorite)),
               
               FloatingActionButton(
                   onPressed: (){print("Iconbuuton");},
                 child: Icon(Icons.add),
               )
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
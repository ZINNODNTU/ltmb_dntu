import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget{
     const MyAppBar({super.key});

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



            body: Center(child: Text("Noi dung chinh "),),
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
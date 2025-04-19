import 'package:flutter/material.dart';

class myContainer extends StatelessWidget{
     const myContainer({super.key});

  @override
  Widget build(BuildContext context) {
    // tra ve Scaffold - cung cap bo cuc desgin don goam
       return Scaffold(
            //tieu de cua ung dung
         appBar: AppBar(
        //   title: Text("App 02"),
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
           child: Container(
             width: 200,
             height: 200,
             decoration: BoxDecoration(
                 color: Colors.cyan,
                 borderRadius: BorderRadius.circular(20),
                 boxShadow: [
                   BoxShadow(
                       color: Colors.orange.withOpacity(0.5),
                       spreadRadius:5,
                       blurRadius: 7,
                       offset: const Offset(0, 3)

                   ),
                 ]
             ),
             child: Align(
               alignment: Alignment.center,
               child: Text(
                 "Nguyen Thanh Nhan",
                 style: TextStyle( // ✅ Đặt style vào đây
                   color: Colors.amber,
                   fontSize: 20, // ✅ Giảm size vì 100 quá lớn
                 ),
               ),
             ),
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
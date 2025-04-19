import 'package:flutter/material.dart';

class MyText extends StatelessWidget{
     const MyText({super.key});

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
               const SizedBox(height: 50,),
               const Text("Nguyen Thanh Nhan"),
               const SizedBox(height: 20,),

               const Text("Xin chao tat ca cac ban",
                 style: TextStyle(
                   fontSize: 30,
                   fontWeight: FontWeight.bold,
                   color: Colors.blue,
                   letterSpacing: 1.5,
                 ),),
               const Text("Căn cứ Quyết định số 41/QĐ-ĐHCNĐN ngày 17/3/2023 của Hội đồng Trường về việc ban hành quy định chức năng, nhiệm vụ các đơn vị của Trường Đại học Công nghệ Đồng Nai;",
                 maxLines: 2,
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   fontSize: 30,
                   fontWeight: FontWeight.bold,
                   color: Colors.black,
                   letterSpacing: 1.5,

                 ),),
             ]

           )
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
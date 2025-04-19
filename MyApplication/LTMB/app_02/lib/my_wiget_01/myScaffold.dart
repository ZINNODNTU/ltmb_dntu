import 'package:flutter/material.dart';

class MySacffold extends StatelessWidget{
     const MySacffold({super.key});

  @override
  Widget build(BuildContext context) {
    // tra ve Scaffold - cung cap bo cuc desgin don goam
       return Scaffold(
            //tieu de cua ung dung
          appBar: AppBar(
               title: Text("App 02"),
          ),

            backgroundColor: Colors.blue,
            
            body: Center(child: Text("Noi dung chinh "),),
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
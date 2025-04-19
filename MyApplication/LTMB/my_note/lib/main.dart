import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_note/view/theme_provider.dart';
import 'package:my_note/view/LoginScreen.dart';
import 'package:my_note/view/NoteListScreen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'My Note',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(), // <-- Đây nè
      themeMode: themeProvider.themeMode,
      home: const AuthCheckWidget(),
    );

  }
}

class AuthCheckWidget extends StatelessWidget {
  const AuthCheckWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return  LoginScreen();
        }

        final prefs = snapshot.data!;
        final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

        if (isLoggedIn) {
          return NoteListScreen(
            onLogout: () async {
              final BuildContext currentContext = context;

              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              Navigator.of(currentContext).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) =>  LoginScreen()),
                    (Route<dynamic> route) => false,
              );

              print("Đăng xuất thành công");
            },
          );
        } else {
          return  LoginScreen();
        }
      },
    );
  }
}

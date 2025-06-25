import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user_state.dart';
import 'pages/login_page.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserState>(
      create: (_) => UserState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TodoApp',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 38, 144, 177))),
        home: LoginPage(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/user_state.dart';
import 'todo_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '', password = '', infoText = '';
  final _formKey = GlobalKey<FormState>();

  Future<void> _signInOrUp(bool isSignUp) async {
    try {
      final auth = FirebaseAuth.instance;
      final result = isSignUp
          ? await auth.createUserWithEmailAndPassword(
              email: email, password: password)
          : await auth.signInWithEmailAndPassword(
              email: email, password: password);

      if (result.user != null) {
        Provider.of<UserState>(context, listen: false).setUser(result.user!);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const TodoPage()));
      }
    } catch (e) {
      setState(() {
        infoText = "エラー：${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ログイン / 登録')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'メールアドレス'),
                  onChanged: (value) => email = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'パスワード'),
                  obscureText: true,
                  onChanged: (value) => password = value,
                ),
                const SizedBox(height: 16),
                Text(infoText, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _signInOrUp(true),
                        child: const Text('ユーザー登録'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _signInOrUp(false),
                        child: const Text('ログイン'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

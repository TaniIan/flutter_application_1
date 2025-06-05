import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/user_state.dart';
import 'todo_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String infoText = '';
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'メールアドレス'),
                onChanged: (value) => setState(() => email = value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                onChanged: (value) => setState(() => password = value),
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: Text(infoText),
              ),
              ElevatedButton(
                child: Text('ユーザー登録'),
                onPressed: () async {
                  try {
                    final auth = FirebaseAuth.instance;
                    final result = await auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                    userState.setUser(result.user!);
                    await Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => TodoPage()),
                    );
                  } catch (e) {
                    setState(() {
                      infoText = "登録に失敗しました：${e.toString()}";
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                child: Text('ログイン'),
                onPressed: () async {
                  try {
                    final auth = FirebaseAuth.instance;
                    final result = await auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    userState.setUser(result.user!);
                    await Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => TodoPage()),
                    );
                  } catch (e) {
                    setState(() {
                      infoText = "ログインに失敗しました：${e.toString()}";
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

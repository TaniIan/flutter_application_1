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
  String email = '';
  String password = '';
  String infoText = '';
  final _formKey = GlobalKey<FormState>();

  Future<void> _signInOrUp(bool isSignUp) async {
    // フォームの入力検証
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // onChangedで値が更新されるため不要な場合もありますが、念のため

      try {
        final auth = FirebaseAuth.instance;
        UserCredential result;

        if (isSignUp) {
          result = await auth.createUserWithEmailAndPassword(
              email: email, password: password);
        } else {
          result = await auth.signInWithEmailAndPassword(
              email: email, password: password);
        }

        if (result.user != null) {
          if (mounted) {
            Provider.of<UserState>(context, listen: false)
                .setUser(result.user!);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const TodoPage()));
          }
        }
      } on FirebaseAuthException catch (e) {
        // FirebaseAuthException をより具体的にハンドリング
        String message;
        if (e.code == 'weak-password') {
          message = 'パスワードが弱すぎます。';
        } else if (e.code == 'email-already-in-use') {
          message = 'このメールアドレスは既に登録されています。';
        } else if (e.code == 'user-not-found') {
          message = 'ユーザーが見つかりません。';
        } else if (e.code == 'wrong-password') {
          message = 'パスワードが間違っています。';
        } else if (e.code == 'invalid-email') {
          message = 'メールアドレスの形式が正しくありません。';
        } else {
          message = 'エラーが発生しました: ${e.message}';
        }
        setState(() {
          infoText = message;
        });
      } catch (e) {
        // その他のエラー
        setState(() {
          infoText = "予期せぬエラー：${e.toString()}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Todo App',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor, // テーマカラーを使用
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // アプリのロゴやアイコン（例）
              Icon(
                Icons.check_circle_outline,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                'アカウントにログインまたは登録',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'メールアドレス',
                            hintText: 'your_email@example.com',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) => email = value.trim(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'メールアドレスを入力してください';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return '有効なメールアドレスを入力してください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'パスワード',
                            hintText: '最低6文字',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          obscureText: true,
                          onChanged: (value) => password = value.trim(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'パスワードを入力してください';
                            }
                            if (value.length < 6) {
                              return 'パスワードは最低6文字必要です';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        if (infoText.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              infoText,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _signInOrUp(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                child: const Text('ユーザー登録'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _signInOrUp(false),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor),
                                ),
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
            ],
          ),
        ),
      ),
    );
  }
}

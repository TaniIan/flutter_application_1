import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

const Color kAccentColor = Color(0xFFFE7C64);
const Color kBackgroundColor = Color(0xFF19283D);
const Color kTextColorPrimary = Color(0xFFECEFF1);
const Color kTextColorSecondary = Color(0xFFB0BEC5);
const Color kButtonColorPrimary = Color(0xFFECEFF1);
const Color kButtonTextColorPrimary = Color(0xFF455A64);
const Color kIconColor = Color(0xFF455A64);

//更新可能なデータ
class UserState extends ChangeNotifier {
  User? user;

  void setUser(User newUser) {
    user = newUser;
    notifyListeners();
  }

  void clearUser(){
    user = null;
    notifyListeners();
  }
}

Future<void> main() async {
  //初期化処理を追加
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDgysxbzYb20cVlS5Z-yPmDTW5DkULOtQc",
          authDomain: "mytodoapp-5b1c5.firebaseapp.com",
          projectId: "mytodoapp-5b1c5",
          storageBucket: "mytodoapp-5b1c5.firebasestorage.app",
          messagingSenderId: "713225149531",
          appId: "1:713225149531:web:efd1d311a8baa4c0b1b37e",
          measurementId: "G-P4MLCGCX3T"),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  ToDoApp({super.key});
  final UserState userState = UserState();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserState>(
      create: (context) => UserState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        //アプリ名
        title: 'ToDoApp',
        theme: ThemeData.dark().copyWith(
          //accentColor: kAccentColor,
          colorScheme: ThemeData.dark().colorScheme.copyWith(
                secondary: kAccentColor,
              ),
        ),
        //ログイン画面を表示
        home: LoginPage(),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _Header(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _SignInForm(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 64),
                child: _Footer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.55,
        size.height,
        size.width,
        size.height * 0.6,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class _HeaderBackground extends StatelessWidget {
  final double height;

  const _HeaderBackground({
    Key? key,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderCurveClipper(),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: FractionalOffset.topLeft,
            end: FractionalOffset.bottomRight,
            colors: [
              Color(0xFFFD9766),
              Color(0xFFFF7362),
            ],
            stops: [0, 1],
          ),
        ),
      ),
    );
  }
}

class _HeaderCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.4),
      12,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.2),
      12,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class _HeaderCircles extends StatelessWidget {
  final double height;

  const _HeaderCircles({
    Key? key,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HeaderCirclePainter(),
      child: Container(
        width: double.infinity,
        height: height,
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Welcome',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: kTextColorPrimary,
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: 4),
        Text(
          'Sign in to continue',
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: kTextColorPrimary),
        ),
      ],
    );
  }
}

class _HeadBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: kButtonTextColorPrimary,
        backgroundColor: Colors.transparent,
        shape: CircleBorder(
          side: BorderSide(color: kButtonColorPrimary),
        ),
      ),
      onPressed: () {},
      child: Icon(Icons.chevron_left, color: kIconColor),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double height = 320;
    return Container(
      height: height,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _HeaderBackground(height: height),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _HeaderCircles(height: height),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 128),
              child: _HeaderTitle(),
            ),
          ),
          Positioned(
            top: 16,
            left: 0,
            child: _HeadBackButton(),
          ),
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final bool obscureText;
  final ValueChanged<String> onChanged;

  const _CustomTextField({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.obscureText,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(color: kTextColorSecondary),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: kAccentColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: kTextColorSecondary,
          ),
        ),
      ),
      obscureText: obscureText,
      onChanged: onChanged,
      onTap: () {},
    );
  }
}

class _SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm>{
  String infoText = '';
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CustomTextField(
          labelText: 'Email',
          hintText: 'your email address goes here',
          obscureText: false,
          onChanged:(String value){
            setState((){
              email = value;
            });
          },
        ),
        SizedBox(height: 48),
        _CustomTextField(
          labelText: 'Password',
          hintText: 'your password goes here',
          obscureText: true,
          onChanged: (String value) {
            setState(() {
              password = value;
            });
          },
        ),
        Container(
          padding: EdgeInsets.all(8),
          child: Text(infoText),
        ),
        SizedBox(height: 4),
        Text(
          'Forgot Password?',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: kTextColorSecondary),
        ),
        SizedBox(height: 48),
        Container(
          width: double.infinity,
          //ログイン登録ボタン
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: kButtonTextColorPrimary,
              backgroundColor: kButtonColorPrimary,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              try{
                //メール/パスワードでログイン
                final FirebaseAuth auth = FirebaseAuth.instance;
                final result = await auth.signInWithEmailAndPassword(
                  email: email, 
                  password: password,
                  );
                  //ログインに成功した場合
                  //チャット画面に遷移＋ログイン画面を破棄
                await Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context){
                    return MainPage();
                  }),
                );
              } catch (e) {
                //ログインに失敗した場合
                setState(() {
                  infoText = "ログインに失敗しました：${e.toString()}";
                });
              }
            },
            child: Text(
              'Sign in',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(color: kButtonTextColorPrimary, fontSize: 18),
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'OR',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: kTextColorSecondary),
        ),
        SizedBox(height: 16),
        Text(
          'Connect with',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: kTextColorPrimary),
        ),
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {},
            ),
            Container(
              color: kTextColorSecondary,
              width: 1,
              height: 16,
            ),
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {},
            ),
          ],
        )
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Dont\'t have Account?',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: kTextColorSecondary),
        ),
        SizedBox(width: 4),
        Text(
          'Sign up',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: kTextColorPrimary),
        ),
      ],
    );
  }
}

//メイン画面用Widget
class MainPage extends StatelessWidget {
  MainPage();

  @override
  Widget build(BuildContext context) {
    //ユーザー情報を受け取る
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user!;

    return Scaffold(
      appBar: AppBar(
        title: Text('ToDoリスト'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              //ログアウト処理
              //内部で保持しているログイン情報等が初期化される
              await FirebaseAuth.instance.signOut();
              //ログイン画面に遷移＋メイン画面を破棄
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Text('ログイン情報：${user.email}'),
          ),
          Expanded(
            //StreamBuilder
            //非同期処理の結果を元にWidgetを作れる
            child: StreamBuilder<QuerySnapshot>(
              //投稿メッセージ一覧を取得（非同期処理）
              //投稿日時でソート
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                //データが取得できた場合
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  //取得した投稿メッセージ一覧を元にリスト表示
                  return ListView(
                    children: documents.map((document) {
                      return Card(
                        child: ListTile(
                          title: Text(document['text']),
                          subtitle: Text(document['email']),
                          //自分の投稿メッセージの場合は削除ボタンを表示
                          trailing: document['email'] == user.email
                              ? IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    //投稿メッセージのドキュメントを削除
                                    await FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(document.id)
                                        .delete();
                                  },
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                }
                //データが読込中の場合
                return Center(
                  child: Text('読込中...'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          //投稿画面に遷移
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddPostPage();
            }),
          );
        },
      ),
    );
  }
}

//投稿画面用Widget
class AddPostPage extends StatefulWidget {
  AddPostPage();

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  //入力した投稿メッセージ
  String messageText = '';

  @override
  Widget build(BuildContext context) {
    //ユーザー情報を受け取る
    final UserState userState = Provider.of<UserState>(context);
    final User user = userState.user!;

    return Scaffold(
      appBar: AppBar(
        title: Text('ToDo投稿'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //投稿メッセージ入力
              TextFormField(
                decoration: InputDecoration(labelText: '投稿メッセージ'),
                //複数行のテキスト入力
                keyboardType: TextInputType.multiline,
                //最大3行
                maxLines: 3,
                onChanged: (String value) {
                  setState(() {
                    messageText = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('投稿'),
                  onPressed: () async {
                    final date =
                        DateTime.now().toLocal().toIso8601String(); //現在の日時
                    final email = user.email; //AddPostPageのデータを参照
                    //投稿メッセージ用ドキュメント作成
                    await FirebaseFirestore.instance
                        .collection('posts') //コレクションID指定
                        .doc() //ドキュメントID自動生成
                        .set({
                      'text': messageText,
                      'email': email,
                      'date': date
                    });
                    //一つ前の画面に戻る
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

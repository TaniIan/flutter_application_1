import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb

Future<void> main() async {
  //Firebase初期化
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCYtU6kmUQez1pFq1TPfvjBjWZ6BZ0a8fU",
          authDomain: "myapp2-73853.firebaseapp.com",
          projectId: "myapp2-73853",
          storageBucket: "myapp2-73853.firebasestorage.app",
          messagingSenderId: "24973505380",
          appId: "1:24973505380:web:19363b9f438f8b4dd8c071",
          measurementId: "G-TX0LT5NKRW"),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // useMaterial3: true,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyFirestorePage(),
    );
  }
}

class MyFirestorePage extends StatefulWidget {
  @override
  _MyFirestorePageState createState() => _MyFirestorePageState();
}

class _MyFirestorePageState extends State<MyFirestorePage> {
  //作成したドキュメント一覧
  List<DocumentSnapshot> documentList = [];

  //指定したドキュメントの情報
  String orderDocumentInfo = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              child: Text('コレクション＋ドキュメント作成'),
              onPressed: () async {
                //ドキュメント作成
                await FirebaseFirestore.instance
                    .collection('users') //コレクションID
                    .doc('id_abc') //ドキュメントID
                    .set({'name': '鈴木', 'age': 40}); //データ
              },
            ),
            ElevatedButton(
              child: Text('サブコレクション＋ドキュメント作成'),
              onPressed: () async {
                //サブコレクション内にドキュメント作成
                await FirebaseFirestore.instance
                    .collection('users') //コレクションID
                    .doc('id_abc') //ドキュメントID << usersコレクション内のドキュメント
                    .collection('orders') //サブコレクションID
                    .doc('id_123') //ドキュメントID << サブコレクション内のドキュメント
                    .set({'price': 600, 'date': '9/13'});
              },
            ),
            ElevatedButton(
              child: Text('ドキュメント一覧取得'),
              onPressed: () async {
                //コレクション内のドキュメント一覧を取得
                final snapshot =
                    await FirebaseFirestore.instance.collection('users').get();
                //取得したドキュメント一覧をUIに反映
                setState(() {
                  documentList = snapshot.docs;
                });
              },
            ),
            //コレクション内のドキュメント一覧を表示
            Column(
              children: documentList.map((document) {
                return ListTile(
                  title: Text('${document['name']}さん'),
                  subtitle: Text('${document['age']}歳'),
                );
              }).toList(),
            ),
            ElevatedButton(
              child: Text('ドキュメントを指定して取得'),
              onPressed: () async {
                //コレクションIDとドキュメントIDを指定して取得
                final document = await FirebaseFirestore.instance
                    .collection('users')
                    .doc('id_abc')
                    .collection('orders')
                    .doc('id_123')
                    .get();
                //取得したドキュメントの情報をUIに反映
                setState(() {
                  orderDocumentInfo =
                      '${document['date']} ${document['price']}円';
                });
              },
            ),
            //ドキュメントの情報を表示
            ListTile(title: Text(orderDocumentInfo)),
            ElevatedButton(
              child: Text('ドキュメント更新'),
              onPressed: () async {
                //ドキュメント更新
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc('id_abc')
                    .update({'age': 41});
              },
            ),
            ElevatedButton(
              child: Text('ドキュメント削除'),
              onPressed: () async {
                //ドキュメント削除
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc('id_abc')
                    .collection('orders')
                    .doc('id_123')
                    .delete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

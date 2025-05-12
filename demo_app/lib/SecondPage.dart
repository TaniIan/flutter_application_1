import 'package:flutter/material.dart';
import 'package:flutter_application_1/ThirdPage.dart';

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("ページ(2)")),
        body: Center(
          child: TextButton(
            child: Text("ページ(3)へ"),
            // （1） 前の画面に戻る
            onPressed: () {
              Navigator.push(
                  // （1） 指定した画面に遷移する
                  context,
                  MaterialPageRoute(
                      // （2） 実際に表示するページ(ウィジェット)を指定する
                      builder: (context) => ThirdPage()));
            },
          ),
        ));
  }
}

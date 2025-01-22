import 'package:flutter/material.dart';

class OriginalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("オリジナルページ目"),
      ),
      body: Center(
        child: Text("ここはオリジナルページです"),
      ),
    );
  }
}

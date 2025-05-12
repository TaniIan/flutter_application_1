import 'package:flutter/material.dart';

// class OriginalPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("オリジナルページ目"),
//       ),
//       body: Center(
//         child: Text("ここはオリジナルページです"),
//       ),
//     );
//   }
// }
class OriginalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text("オリジナルページ目"),
        title: Row(children: const [
          Icon(Icons.create),
          Text("オリジナルページ"),
        ]),
      ),
      body: Column(children: [
        const Text("HelloWorld"),
        const Text("ハローワールド"),
        TextButton(
          onPressed: () => {print("ボタンが押されたよ")},
          child: const Text("テキストボタン"),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
          Icon(
            Icons.favorite,
            color: Colors.pink,
            size: 24.0,
          ),
          Icon(
            Icons.audiotrack,
            color: Colors.green,
            size: 30.0,
          ),
          Icon(
            Icons.beach_access,
            color: Colors.blue,
            size: 36.0,
          ),
        ]),
      ]),
      floatingActionButton: FloatingActionButton(
          onPressed: () => {print("押したね？")}, child: const Icon(Icons.timer)),
      drawer: const Drawer(child: Center(child: Text("Drawer"))),
      endDrawer: const Drawer(child: Center(child: Text("EndDrawer"))),
    );
  }
}

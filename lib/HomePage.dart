// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/FirstPage.dart';

// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("ホーム"),
//       ),
//       body: Center(
//         child: TextButton(
//           child: Text("1ページ目に遷移する"),
//           onPressed: () {
//             // （1） 指定した画面に遷移する
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     // （2） 実際に表示するページ(ウィジェット)を指定する
//                     builder: (context) => FirstPage()));
//           },
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_application_1/FirstPage.dart';
import 'package:flutter_application_1/OriginalPage.dart'; // OriginalPage をインポート

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ホーム"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              child: Text("1ページ目に遷移する"),
              onPressed: () {
                // （1） 指定した画面に遷移する
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // （2） 実際に表示するページ(ウィジェット)を指定する
                    builder: (context) => FirstPage(),
                  ),
                );
              },
            ),
            SizedBox(height: 20), // ボタン間のスペース
            TextButton(
              child: Text("オリジナルページに遷移する"),
              onPressed: () {
                // 新しい画面に遷移する
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OriginalPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

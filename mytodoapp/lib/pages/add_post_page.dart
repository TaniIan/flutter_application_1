import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/user_state.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  String message = '';
  String selectedCategory = 'プライベート'; // 初期値を設定
  final _formKey = GlobalKey<FormState>(); // フォームのキーを追加

  final List<String> categories = ['仕事', 'プライベート', '趣味', 'その他']; // カテゴリ一覧

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserState>(context).user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'やること追加',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor, // テーマカラーを使用
        iconTheme: const IconThemeData(color: Colors.white), // 戻るボタンのアイコン色を白に
      ),
      body: Center(
        // 中央寄せにするためCenterを追加
        child: SingleChildScrollView(
          // 画面サイズが小さい場合にスクロールできるようにSingleChildScrollViewを追加
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Columnのコンテンツを中央寄せ
            children: [
              // アプリのロゴやアイコン（LoginPageに合わせて追加）
              Icon(
                Icons.playlist_add_check, // ToDo追加に合うアイコンに変更
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                '新しいToDoを追加',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              ),
              const SizedBox(height: 30),
              Card(
                // LoginPageと同様にCardで囲む
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    // バリデーションのためにFormウィジェットを使用
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'やること内容',
                            hintText: '例：〇〇を完了させる',
                            prefixIcon:
                                const Icon(Icons.description), // アイコンを追加
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          maxLines: 3,
                          onChanged: (value) =>
                              message = value.trim(), // trim()で空白を除去
                          validator: (value) {
                            // 入力検証を追加
                            if (value == null || value.isEmpty) {
                              return 'やること内容を入力してください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20), // 間隔を広げる
                        // カテゴリ選択ドロップダウン
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'カテゴリ',
                            prefixIcon: const Icon(Icons.category), // アイコンを追加
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          value: selectedCategory,
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedCategory = value);
                            }
                          },
                          // ドロップダウンのテキストスタイルを統一
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 16,
                          ),
                          dropdownColor:
                              Theme.of(context).cardColor, // ドロップダウンリストの背景色
                        ),
                        const SizedBox(height: 30), // 間隔を広げる
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('ToDoを追加'), // ボタンテキストを明確に
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // フォームの検証
                                _formKey.currentState!.save();
                                final now = DateTime.now().toIso8601String();
                                await FirebaseFirestore.instance
                                    .collection('posts')
                                    .add({
                                  'text': message,
                                  'email': user.email,
                                  'date': now,
                                  'done': false,
                                  'category': selectedCategory,
                                });
                                Navigator.pop(context);
                              }
                            },
                          ),
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

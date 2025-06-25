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

  final List<String> categories = ['仕事', 'プライベート', '趣味', 'その他']; // カテゴリ一覧

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserState>(context).user!;

    return Scaffold(
      appBar: AppBar(title: const Text('やること追加')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'やること内容'),
              maxLines: 3,
              onChanged: (value) => message = value,
            ),
            const SizedBox(height: 16),
            // カテゴリ選択ドロップダウン
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'カテゴリ'),
              value: selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => selectedCategory = value);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text('追加'),
                onPressed: () async {
                  final now = DateTime.now().toIso8601String();
                  await FirebaseFirestore.instance.collection('posts').add({
                    'text': message,
                    'email': user.email,
                    'date': now,
                    'done': false,
                    'category': selectedCategory, // カテゴリをFirestoreに追加
                  });
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPostPage extends StatefulWidget {
  final DocumentSnapshot document;

  const EditPostPage({super.key, required this.document});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _textController;

  String? _selectedCategory;

  // 🔥 固定カテゴリリスト
  final List<String> _allCategories = [
    '仕事',
    '趣味',
    'プライベート',
    'その他',
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.document.data()! as Map<String, dynamic>;
    _textController = TextEditingController(text: data['text'] ?? '');
    _selectedCategory = data['category'] ?? _allCategories.first;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('投稿を編集')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: '内容'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _allCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'カテゴリー'),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.document.id)
                    .update({
                  'text': _textController.text,
                  'category': _selectedCategory,
                });
                if (mounted) Navigator.pop(context);
              },
              child: const Text('更新する'),
            ),
          ],
        ),
      ),
    );
  }
}

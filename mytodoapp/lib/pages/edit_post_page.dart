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

  @override
  void initState() {
    super.initState();
    final data = widget.document.data()! as Map<String, dynamic>;
    _textController = TextEditingController(text: data['text'] ?? '');
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.document.id)
                    .update({
                  'text': _textController.text,
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

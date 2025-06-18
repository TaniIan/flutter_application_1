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

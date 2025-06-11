import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_state.dart';

class AddPostPage extends StatefulWidget {
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  String messageText = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserState>(context).user!;

    return Scaffold(
      appBar: AppBar(title: Text('やること追加')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'やること内容'),
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              onChanged: (value) => setState(() => messageText = value),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              child: Text('追加'),
              onPressed: () async {
                final date = DateTime.now().toLocal().toIso8601String();
                await FirebaseFirestore.instance.collection('posts').add({
                  'text': messageText,
                  'email': user.email,
                  'date': date,
                  'isDone': false,
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

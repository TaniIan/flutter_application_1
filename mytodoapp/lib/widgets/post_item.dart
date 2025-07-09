import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pages/edit_post_page.dart';

class PostItem extends StatelessWidget {
  final DocumentSnapshot document;
  final User currentUser;

  const PostItem({
    super.key,
    required this.document,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final data = document.data()! as Map<String, dynamic>;
    final isOwner = data['email'] == currentUser.email;

    return Card(
      child: ListTile(
        title: Text(
          data['text'],
          style: TextStyle(
            decoration:
                (data['done'] ?? false) ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(data['email']),
        leading: Checkbox(
          value: data['done'] ?? false,
          onChanged: (val) {
            FirebaseFirestore.instance
                .collection('posts')
                .doc(document.id)
                .update({'done': val});
          },
        ),
        trailing: isOwner
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditPostPage(document: document),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('posts')
                          .doc(document.id)
                          .delete();
                    },
                  ),
                ],
              )
            : null,
      ),
    );
  }
}

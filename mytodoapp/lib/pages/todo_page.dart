import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_state.dart';
import '../widgets/post_item.dart';
import 'add_post_page.dart';
import 'login_page.dart';

enum Filter { all, completed, incomplete }

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  Filter _filter = Filter.all;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserState>(context).user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('やること一覧'),
        actions: [
          PopupMenuButton<Filter>(
            onSelected: (Filter selected) {
              setState(() => _filter = selected);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: Filter.all, child: Text('すべて')),
              const PopupMenuItem(value: Filter.completed, child: Text('完了のみ')),
              const PopupMenuItem(
                  value: Filter.incomplete, child: Text('未完了のみ')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Provider.of<UserState>(context, listen: false).clearUser();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('email', isEqualTo: user.email)
            .orderBy('date')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('データがありません'));
          }

          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final done = data['done'] as bool? ?? false;
            switch (_filter) {
              case Filter.completed:
                return done;
              case Filter.incomplete:
                return !done;
              case Filter.all:
              default:
                return true;
            }
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, i) => PostItem(
              document: docs[i],
              currentUser: user,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPostPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('追加'),
      ),
    );
  }
}

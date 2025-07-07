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
  String _selectedCategory = 'すべて';
  List<String> _allCategories = ['すべて']; // 初期状態

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserState>(context).user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('やること一覧'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              items: _allCategories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
              icon: const Icon(Icons.category, color: Colors.white),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
            ),
          ),
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

          // フィルター処理
          final allDocs = snapshot.data!.docs;

          _allCategories = ['すべて'];
          for (var doc in allDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final category = data['category'] as String? ?? '未分類';
            if (!_allCategories.contains(category)) {
              _allCategories.add(category);
            }
          }
          final filteredDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final done = data['done'] as bool? ?? false;
            final category = data['category'] as String? ?? '未分類';

            final matchesFilter = switch (_filter) {
              Filter.completed => done,
              Filter.incomplete => !done,
              Filter.all => true,
            };

            final matchesCategory =
                _selectedCategory == 'すべて' || _selectedCategory == category;
            return matchesFilter && matchesCategory;
          }).toList();

          // カテゴリ別にグループ化
          final Map<String, List<DocumentSnapshot>> categorized = {};
          for (var doc in filteredDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final category = data['category'] as String? ?? '未分類';
            categorized.putIfAbsent(category, () => []).add(doc);
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: categorized.entries.map((entry) {
              final category = entry.key;
              final items = entry.value;
              return ExpansionTile(
                title: Text(category),
                children: items.map((doc) {
                  return PostItem(document: doc, currentUser: user);
                }).toList(),
              );
            }).toList(),
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

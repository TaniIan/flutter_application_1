import 'package:flutter/cupertino.dart';
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
  List<String> _allCategories = ['すべて'];

  final Map<String, bool> _expanded = {};
  late User _currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentUser = Provider.of<UserState>(context).user!;
  }

  void _openLogOutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('ログアウト'),
          content: const Text('本当にログアウトしますか？'),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                'キャンセル',
                style: TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: const Text(
                'ログアウト',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context); // ダイアログを閉じる
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Provider.of<UserState>(context, listen: false).clearUser();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } catch (e) {
      debugPrint('ログアウトエラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsQuery = FirebaseFirestore.instance
        .collection('posts')
        .where('email', isEqualTo: _currentUser.email)
        .orderBy('date');

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
            itemBuilder: (context) => const [
              PopupMenuItem(value: Filter.all, child: Text('すべて')),
              PopupMenuItem(value: Filter.completed, child: Text('完了のみ')),
              PopupMenuItem(value: Filter.incomplete, child: Text('未完了のみ')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _openLogOutDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: postsQuery.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDocs = snapshot.data!.docs;

          if (allDocs.isEmpty) {
            return const Center(child: Text('データがありません'));
          }

          // ✅ 1. カテゴリは全件から生成
          final Set<String> categorySet = {'すべて'};
          for (var doc in allDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final category = data['category'] as String? ?? '未分類';
            categorySet.add(category);
          }
          _allCategories = categorySet.toList();

          // ✅ 2. ローカルで完了・未完了フィルタも行う
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

          if (filteredDocs.isEmpty) {
            return const Center(child: Text('条件に一致するデータがありません'));
          }

          // ✅ 3. カテゴリごとにグループ化
          final Map<String, List<DocumentSnapshot>> categorized = {};
          for (var doc in filteredDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final category = data['category'] as String? ?? '未分類';
            categorized.putIfAbsent(category, () => []).add(doc);
          }

          final categories = categorized.entries.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final entry = categories[index];
              final category = entry.key;
              final items = entry.value;

              return ExpansionTile(
                title: Text(category),
                initiallyExpanded: _expanded[category] ?? false,
                onExpansionChanged: (val) {
                  setState(() => _expanded[category] = val);
                },
                children: items.map((doc) {
                  return PostItem(document: doc, currentUser: _currentUser);
                }).toList(),
              );
            },
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

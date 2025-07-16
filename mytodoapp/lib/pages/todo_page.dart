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
        title: const Text(
          'やること一覧',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true, // ログインページに合わせてタイトルを中央寄せ
        backgroundColor: Theme.of(context).primaryColor, // テーマカラーを使用
        actions: [
          // カテゴリ選択ドロップダウン
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              items: _allCategories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(
                    category,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
              icon: const Icon(Icons.category, color: Colors.white),
              dropdownColor: Theme.of(context).cardColor, // カードの背景色に合わせる
              style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color), // テキストカラーも調整
            ),
          ),
          // フィルターオプション
          PopupMenuButton<Filter>(
            onSelected: (Filter selected) {
              setState(() => _filter = selected);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: Filter.all, child: Text('すべて')),
              PopupMenuItem(value: Filter.completed, child: Text('完了のみ')),
              PopupMenuItem(value: Filter.incomplete, child: Text('未完了のみ')),
            ],
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
          // ログアウトボタン
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in, // やることがない場合のアイコン
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'まだToDoがありません。\n右下のボタンから追加しましょう！',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          // ✅ 1. カテゴリは全件から生成
          final Set<String> categorySet = {'すべて'};
          for (var doc in allDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final category = data['category'] as String? ?? '未分類';
            categorySet.add(category);
          }
          // カテゴリリストの順序を安定させるためソート
          _allCategories = categorySet.toList()..sort();

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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined, // フィルター後の結果がない場合のアイコン
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '選択された条件に一致するToDoはありません。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          // ✅ 3. カテゴリごとにグループ化
          final Map<String, List<DocumentSnapshot>> categorized = {};
          for (var doc in filteredDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final category = data['category'] as String? ?? '未分類';
            categorized.putIfAbsent(category, () => []).add(doc);
          }

          // カテゴリ名をアルファベット順（または日本語の順序）にソートして表示
          final categories = categorized.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final entry = categories[index];
              final category = entry.key;
              final items = entry.value;

              return Card(
                // カードデザインを適用
                elevation: 4, // 影の深さ
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // 角を丸くする
                ),
                child: ExpansionTile(
                  title: Text(
                    category,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor, // カテゴリ名を強調
                    ),
                  ),
                  initiallyExpanded: _expanded[category] ?? false,
                  onExpansionChanged: (val) {
                    setState(() => _expanded[category] = val);
                  },
                  children: items.map((doc) {
                    return PostItem(document: doc, currentUser: _currentUser);
                  }).toList(),
                ),
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
        backgroundColor: Theme.of(context).primaryColor, // テーマカラーを使用
        foregroundColor: Colors.white, // 文字色を白に
        shape: RoundedRectangleBorder(
          // 角を丸くする
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

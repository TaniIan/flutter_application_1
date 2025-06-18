import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_state.dart';
import 'add_post_page.dart';
import 'login_page.dart';

enum FilterType { all, done, undone }

class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  FilterType _filterType = FilterType.all;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserState>(context).user!;
    return Scaffold(
      appBar: AppBar(
        title: Text('一覧'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFilterButton('すべて', FilterType.all),
              _buildFilterButton('未完了', FilterType.undone),
              _buildFilterButton('完了', FilterType.done),
            ],
          ),
        ),
      ),
      body: _buildTodoList(user),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddPostPage()),
          );
        },
      ),
    );
  }

  Widget _buildFilterButton(String label, FilterType type) {
    final isSelected = _filterType == type;
    return TextButton(
      onPressed: () {
        setState(() {
          _filterType = type;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black54,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTodoList(User user) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('email', isEqualTo: user.email)
          .orderBy('date', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('エラー: ${snapshot.error}'));
        }
        if (!snapshot.hasData) return Center(child: Text('読込中...'));

        final docs = snapshot.data!.docs;

        // フィルター適用
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final isDone = data['isDone'] ?? false;
          switch (_filterType) {
            case FilterType.done:
              return isDone;
            case FilterType.undone:
              return !isDone;
            case FilterType.all:
            default:
              return true;
          }
        }).toList();

        return ListView(
          children: filteredDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final isDone = data['isDone'] ?? false;

            // dateフィールドをDateTime型に変換
            DateTime? dateTime;
            final dateValue = data['date'];
            if (dateValue is Timestamp) {
              dateTime = dateValue.toDate();
            } else if (dateValue is String) {
              dateTime = DateTime.tryParse(dateValue);
            }

            return Card(
              child: ListTile(
                leading: Checkbox(
                  value: isDone,
                  onChanged: (value) {
                    FirebaseFirestore.instance
                        .collection('posts')
                        .doc(doc.id)
                        .update({'isDone': value});
                  },
                ),
                title: Text(
                  data['text'],
                  style: TextStyle(
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? Colors.grey : null,
                  ),
                ),
                subtitle: Text(
                  data['email'] +
                      (dateTime != null
                          ? ' (${dateTime.toLocal().toString().split(".")[0]})'
                          : ''),
                ),
                trailing: data['email'] == user.email
                    ? IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('posts')
                              .doc(doc.id)
                              .delete();
                        },
                      )
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

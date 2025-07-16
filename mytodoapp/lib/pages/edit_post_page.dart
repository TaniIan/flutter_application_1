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
  final _formKey = GlobalKey<FormState>(); // フォームのキーを追加

  // 固定カテゴリリスト
  final List<String> _allCategories = [
    '仕事',
    'プライベート',
    '趣味',
    'その他',
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.document.data()! as Map<String, dynamic>;
    _textController = TextEditingController(text: data['text'] ?? '');
    // 初期カテゴリが_allCategoriesに含まれていない場合、最初のカテゴリをデフォルトにする
    _selectedCategory = _allCategories.contains(data['category'])
        ? data['category']
        : _allCategories.first;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'やること編集', // タイトルを「やること編集」に変更
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor, // テーマカラーを使用
        iconTheme: const IconThemeData(color: Colors.white), // 戻るボタンのアイコン色を白に
      ),
      body: Center(
        // 中央寄せにするためCenterを追加
        child: SingleChildScrollView(
          // 画面サイズが小さい場合にスクロールできるようにSingleChildScrollViewを追加
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Columnのコンテンツを中央寄せ
            children: [
              // アプリのロゴやアイコン（LoginPageに合わせて追加）
              Icon(
                Icons.edit_note, // 編集に合うアイコンに変更
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                'ToDoの内容を編集',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              ),
              const SizedBox(height: 30),
              Card(
                // LoginPageと同様にCardで囲む
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    // バリデーションのためにFormウィジェットを使用
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _textController,
                          decoration: InputDecoration(
                            labelText: 'やること内容',
                            hintText: '例：〇〇を完了させる',
                            prefixIcon:
                                const Icon(Icons.description), // アイコンを追加
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          maxLines: 3,
                          validator: (value) {
                            // 入力検証を追加
                            if (value == null || value.trim().isEmpty) {
                              // trim()を適用
                              return 'やること内容を入力してください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20), // 間隔を広げる
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          items: _allCategories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'カテゴリ',
                            prefixIcon: const Icon(Icons.category), // アイコンを追加
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          // ドロップダウンのテキストスタイルを統一
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 16,
                          ),
                          dropdownColor:
                              Theme.of(context).cardColor, // ドロップダウンリストの背景色
                          validator: (value) {
                            // カテゴリ選択の検証
                            if (value == null || value.isEmpty) {
                              return 'カテゴリを選択してください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30), // 間隔を広げる
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // フォームの検証
                                await FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(widget.document.id)
                                    .update({
                                  'text': _textController.text
                                      .trim(), // 更新時もtrim()を適用
                                  'category': _selectedCategory,
                                });
                                if (mounted) Navigator.pop(context);
                              }
                            },
                            child: const Text('更新する'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../model/todo.dart'; // DEMO: ここが検知される

class TodoPage extends StatelessWidget {
  TodoPage({super.key});

  final List<Todo> todos = const [Todo(title: 'FlutterKaigi 2026 で登壇する')];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      body: ListView(
        children: [for (final todo in todos) ListTile(title: Text(todo.title))],
      ),
    );
  }
}

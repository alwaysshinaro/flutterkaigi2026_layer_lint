import 'package:flutter/material.dart';

import '../view_model/todo_view_model.dart';

class TodoPage extends StatelessWidget {
  TodoPage({super.key});

  final TodoViewModel viewModel = TodoViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      body: ListView(
        children: [
          for (final title in viewModel.titles) ListTile(title: Text(title)),
        ],
      ),
    );
  }
}

import 'package:example/model/todo.dart' as model;
import 'package:flutter/material.dart';

import '../model/todo.dart';

class ScreenshotPage extends StatelessWidget {
  const ScreenshotPage({super.key});

  @override
  Widget build(BuildContext context) {
    const relativeTodo = Todo(title: '相対 import');
    const packageTodo = model.Todo(title: 'package import');
    return ListView(
      children: [Text(relativeTodo.title), Text(packageTodo.title)],
    );
  }
}

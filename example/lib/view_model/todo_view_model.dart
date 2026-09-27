import '../model/todo.dart';

class TodoViewModel {
  final List<Todo> _todos = const [Todo(title: 'FlutterKaigi 2026 で登壇する')];

  List<String> get titles => [for (final todo in _todos) todo.title];
}

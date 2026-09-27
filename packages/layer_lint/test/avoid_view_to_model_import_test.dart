// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:layer_lint/src/avoid_view_to_model_import.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidViewToModelImportTest);
  });
}

@reflectiveTest
class AvoidViewToModelImportTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidViewToModelImport();
    super.setUp();
    newFile('$testPackageLibPath/model/todo.dart', r'''
class Todo {}
''');
    newFile('$testPackageLibPath/view_model/todo_view_model.dart', r'''
class TodoViewModel {}
''');
  }

  void test_view_imports_model_with_relative_uri() async {
    var path = newFile('$testPackageLibPath/view/todo_page.dart', r'''
import '../model/todo.dart';

Todo? todo;
''').path;
    await assertDiagnosticsInFile(path, [lint(7, 20)]);
  }

  void test_view_imports_model_with_package_uri() async {
    var path = newFile('$testPackageLibPath/view/todo_page.dart', r'''
import 'package:test/model/todo.dart';

Todo? todo;
''').path;
    await assertDiagnosticsInFile(path, [lint(7, 30)]);
  }

  void test_view_imports_view_model() async {
    var path = newFile('$testPackageLibPath/view/todo_page.dart', r'''
import '../view_model/todo_view_model.dart';

TodoViewModel? viewModel;
''').path;
    await assertNoDiagnosticsInFile(path);
  }

  void test_view_model_imports_model() async {
    var path = newFile(
      '$testPackageLibPath/view_model/todo_view_model.dart',
      r'''
import '../model/todo.dart';

class TodoViewModel {
  Todo? todo;
}
''',
    ).path;
    await assertNoDiagnosticsInFile(path);
  }
}

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'src/avoid_view_to_model_import.dart';

final plugin = LayerLintPlugin();

class LayerLintPlugin extends Plugin {
  @override
  String get name => 'layer_lint';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(AvoidViewToModelImport());
  }
}

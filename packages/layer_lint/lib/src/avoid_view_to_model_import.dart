import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import 'layer.dart';

class AvoidViewToModelImport extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_view_to_model_import',
    'View から Model への直接依存は禁止されています。',
    correctionMessage: 'ViewModel を経由してください。',
  );

  AvoidViewToModelImport()
    : super(
        name: 'avoid_view_to_model_import',
        description: 'View 層から Model 層を直接 import することを禁止します。',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    var visitor = _Visitor(this, context);
    registry.addImportDirective(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;
  _Visitor(this.rule, this.context);

  @override
  void visitImportDirective(ImportDirective node) {
    var importingLibrary = context.libraryElement?.uri;
    var importedLibrary = node.libraryImport?.importedLibrary?.uri;
    if (isForbiddenDependency(from: importingLibrary, to: importedLibrary)) {
      rule.reportAtNode(node.uri);
    }
  }
}

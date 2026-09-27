class AvoidViewToModelImport extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_view_to_model_import',
    'View から Model への直接依存は禁止されています。',
    correctionMessage: 'ViewModel を経由してください。',
  );
  // ここで省略したのは、コンストラクタ（name / description）と diagnosticCode getter です。
  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    var visitor = _Visitor(this, context);
    registry.addImportDirective(this, visitor);
  }
}

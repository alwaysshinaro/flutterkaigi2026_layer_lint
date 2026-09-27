  @override
  void visitImportDirective(ImportDirective node) {
    var importingLibrary = context.libraryElement?.uri;
    var importedLibrary =
        node.libraryImport?.importedLibrary?.uri;
    if (isForbiddenDependency(
      from: importingLibrary,
      to: importedLibrary,
    )) {
      rule.reportAtNode(node.uri);
    }
  }

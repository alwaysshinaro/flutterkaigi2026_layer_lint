enum Layer { view, viewModel, model }

/// `lib/` 直下のディレクトリ名と層の対応表。
const layerDirectories = <String, Layer>{
  'view': Layer.view,
  'view_model': Layer.viewModel,
  'model': Layer.model,
};

/// 禁止する依存（キーの層 → 値の層）。
const forbiddenDependencies = <Layer, Set<Layer>>{
  Layer.view: {Layer.model},
};

/// [from] のライブラリが [to] のライブラリに依存することが禁止されているか。
bool isForbiddenDependency({required Uri? from, required Uri? to}) {
  if (from == null || to == null) return false;
  if (packageNameOf(from) != packageNameOf(to)) return false;

  var fromLayer = layerOf(from);
  var toLayer = layerOf(to);
  return forbiddenDependencies[fromLayer]?.contains(toLayer) ?? false;
}

/// `package:<name>/<directory>/...` 形式の URI から層を判定する。
Layer? layerOf(Uri libraryUri) {
  var segments = libraryUri.pathSegments;
  if (packageNameOf(libraryUri) == null || segments.length < 3) return null;
  return layerDirectories[segments[1]];
}

String? packageNameOf(Uri libraryUri) {
  if (!libraryUri.isScheme('package')) return null;
  return libraryUri.pathSegments.first;
}

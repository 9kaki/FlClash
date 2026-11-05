import 'dart:io';

import 'package:path/path.dart' as p;

const sourceRoots = ['lib'];

List<FileSystemEntity> sourceEntities() => [
  for (final root in sourceRoots) ...Directory(root).listSync(recursive: true),
];

/// A repository-relative path with forward slashes, so a lint reads the same
/// on Windows as it does on CI.
String relativeSourcePath(String path) => p.split(p.relative(path)).join('/');

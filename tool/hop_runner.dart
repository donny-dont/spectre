library hop_runner;

import 'package:bot/hop.dart';
import 'package:bot/hop_tasks.dart';

void main() {
  _assertKnownPath();

  //
  // Analyzer
  //
  addTask('analyze_lib', createDartAnalyzerTask(['lib/spectre.dart',
                                                 'lib/spectre_post.dart',
                                                 'lib/disposable.dart',
                                                 'lib/spectre_asset_pack.dart',
                                                 ]));
  addTask('analyze_test', createDartAnalyzerTask(['test/test_runner.dart']));

  addTask('docs', getCompileDocsFunc('gh-pages', 'packages/', _getLibs));

  runHopCore();
}

void _assertKnownPath() {
  // since there is no way to determine the path of 'this' file
  // assume that Directory.current() is the root of the project.
  // So check for existance of /bin/hop_runner.dart
  final thisFile = new File('tool/hop_runner.dart');
  assert(thisFile.existsSync());
}

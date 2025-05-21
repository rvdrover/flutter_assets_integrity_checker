import 'dart:async';
import 'dart:convert';
import 'dart:developer' as console;
import 'dart:io';

import 'package:build/build.dart';
import 'package:crypto/crypto.dart';
import 'package:yaml/yaml.dart';

Builder masterAssetHashBuilder(BuilderOptions options) => _NoOutputHashBuilder();

class _NoOutputHashBuilder implements Builder {
  @override
  final buildExtensions = const {
    r'$package$': ['.placeholder'], // won't be used
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final config = _loadConfig();
    final assetDirs = config['asset_paths'].cast<String>();
    final validExtensions = config['allowed_extensions'].cast<String>();

    final allFiles = <File>[];

    for (final dirPath in assetDirs) {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        allFiles.addAll(dir.listSync(recursive: true).whereType<File>().where((f) => validExtensions.any((ext) => f.path.endsWith(ext))));
      }
    }

    allFiles.sort((a, b) => a.path.compareTo(b.path));

    final buffer = StringBuffer();
    for (final file in allFiles) {
      final bytes = await file.readAsBytes();
      final hash = sha256.convert(bytes).toString();
      final relative = file.path.replaceAll('\\', '/');
      buffer.write('$relative:$hash;');
    }

    final masterHash = sha256.convert(utf8.encode(buffer.toString())).toString();
    console.log('🔒 [flutter_assets_integrity_checker] Master asset hash: $masterHash');
  }

  Map<String, dynamic> _loadConfig() {
    final file = File('asset_integrity.yaml');
    if (!file.existsSync()) {
      throw Exception('Missing asset_integrity.yaml in project root!');
    }
    final content = file.readAsStringSync();
    final yaml = loadYaml(content);
    return Map<String, dynamic>.from(yaml);
  }
}

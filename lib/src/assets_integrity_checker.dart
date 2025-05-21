import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

// import 'hash_utils.dart';

/// A utility to verify that bundled assets have not been tampered with.
class AssetIntegrityChecker {
  /// Paths to asset directories that need to be verified.
  final List<String> assetPaths;

  /// Allowed extensions to be included in hashing.
  final List<String> allowedExtensions;

  /// The generated master hash from dev time.
  final String masterAssetHash;

  const AssetIntegrityChecker({required this.assetPaths, required this.allowedExtensions, required this.masterAssetHash});

  /// Computes a master hash of all target assets in release.
  Future<String> _computeMasterHash() async {
    final assetManifestJson = await rootBundle.loadString('AssetManifest.json');
    final assetManifest = Map<String, dynamic>.from(json.decode(assetManifestJson));

    final assetFiles =
        assetManifest.keys
            .where((path) => assetPaths.any((dir) => path.startsWith(dir)))
            .where((path) => allowedExtensions.any((ext) => path.endsWith(ext)))
            .toList()
          ..sort();

    final buffer = StringBuffer();

    for (final path in assetFiles) {
      try {
        final byteData = await rootBundle.load(path);
        final bytes = byteData.buffer.asUint8List();
        final hash = sha256.convert(bytes).toString();
        buffer.write('$path:$hash;');
      } catch (_) {
        return 'INVALID';
      }
    }

    return sha256.convert(utf8.encode(buffer.toString())).toString();
  }

  /// Compares runtime hash with the dev-time generated [masterAssetHash].
  Future<bool> verify() async {
    final runtimeHash = await _computeMasterHash();

    if (runtimeHash == 'INVALID') {
      log("🚫 Missing or unreadable asset detected.");
      return false;
    }

    if (runtimeHash != masterAssetHash) {
      log("❗ Asset tampering detected!");
      log("   Expected: $masterAssetHash");
      log("   Found:    $runtimeHash");
      return false;
    }

    log("✅ Master asset hash verified.");
    return true;
  }
}

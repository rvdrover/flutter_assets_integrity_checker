import 'package:flutter/material.dart';
import 'package:flutter_assets_integrity_checker/flutter_assets_integrity_checker.dart';

const masterAssetHash = 'your-generated-master-hash-here';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final checker = AssetIntegrityChecker(
    assetPaths: ['assets/images/', 'assets/icons/'],
    allowedExtensions: ['.png', '.svg', '.json'],
    masterAssetHash: masterAssetHash,
  );

  final result = await checker.verify();

  if (!result) {
    // Tampering detected: show error or log out
    runApp(TamperedApp());
  } else {
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class TamperedApp extends StatelessWidget {
  const TamperedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

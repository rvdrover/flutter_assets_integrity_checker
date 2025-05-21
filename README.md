# 🔐 flutter\_assets\_integrity\_checker

A lightweight Flutter package to verify **asset integrity at runtime** using SHA-256 hash validation — ensuring no assets have been tampered with after your app is released.

Ideal for applications that depend on trusted assets such as configuration files, level data, JSON files, and images.

---

## ✨ Features

* ✅ Verifies asset integrity using Flutter's `AssetManifest.json`
* ✅ Secure SHA-256 hash-based comparison
* ✅ Detects missing, changed, or corrupted assets
* ✅ Runtime-only — no persistent output or files
* ✅ Optional hash generation via `build_runner`
* ✅ Platform-agnostic and release-safe

---

## 🛠 Installation

Add the package to your project:

```yaml
dependencies:
  flutter_assets_integrity_checker: ^1.0.3
```

---

## 📁 Setup Instructions

### 1. Configure assets

Create a file at the root of your app named `asset_integrity.yaml`:

```yaml
asset_paths:
  - assets/images/
  - assets/icons/
  - locales/

allowed_extensions:
  - .png
  - .svg
  - .webp
  - .json
```

This YAML file tells the tool which asset folders and file types to include in the master hash.

### 2. Generate the master asset hash (during development)

Run the following command:

```bash
dart run build_runner build
```

This prints a master SHA-256 hash to the console and generates a Dart file (by default at lib/generated/master_asset_hash.dart) containing the master hash as a constant. **Copy that hash** — it represents your asset state at dev time and can be imported in your app for runtime verification.

> 💡 Only use this hash in production builds. Regenerate it when assets change.

---

## ✅ Runtime Verification Example

```dart
import 'package:flutter_assets_integrity_checker/flutter_assets_integrity_checker.dart';

const masterAssetHash = 'your-generated-master-hash-here';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final checker = AssetIntegrityChecker(
    assetPaths: [
      'assets/images/',
      'assets/icons/',
    ],
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
```

---

## ⚙️ What Happens Under the Hood

* Uses `rootBundle.loadString('AssetManifest.json')` to get a map of all assets
* Filters them based on your config
* Hashes each file with `sha256`
* Sorts and joins them to generate a master string
* Hashes the final string again — the result is compared with your master


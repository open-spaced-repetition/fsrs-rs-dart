# FSRS Rust Dart binding

A Rust implementation of the Free Spaced Repetition Scheduler (FSRS) algorithm with Flutter/Dart bindings using flutter_rust_bridge.

## Usage

```dart
import 'package:fsrs/fsrs.dart';

Future<void> main() async {
  // Initialize the Rust bridge
  await RustLib.init();
  ...
}
```

## Examples

see [examples](./examples)

## Features

- Core FSRS algorithm implemented in Rust
- Flutter bindings for cross-platform use
- Memory state management
- Review scheduling
- Item state tracking

---

## Online development

go to <https://idx.google.com/import>

---

## Prerequisites

- Rust (stable channel)
- Flutter SDK (v3.27.3 or later)
- flutter\_rust\_bridge\_codegen (`cargo install flutter_rust_bridge_codegen`)

## Setup

```bash
git clone <repository-url>
cd fsrs-rs-dart
flutter_rust_bridge_codegen generate
flutter pub get
cd rust
cargo build -r
cd ..
flutter analyze
```

## License

MIT

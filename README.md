# FSRS Rust Dart binding

A Rust implementation of the Free Spaced Repetition Scheduler (FSRS) algorithm with Flutter/Dart bindings using flutter_rust_bridge.

## Examples

see [example](./lib/example.dart)

## Features

- Core FSRS algorithm implemented in Rust
- Flutter bindings for cross-platform use
- Memory state management
- Review scheduling
- Item state tracking

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
flutter analyze
```

## License

MIT

# FSRS Rust Dart binding(WIP)

A Rust implementation of the Free Spaced Repetition Scheduler (FSRS) algorithm with Flutter/Dart bindings using flutter_rust_bridge.

## Features

- Core FSRS algorithm implemented in Rust
- Flutter bindings for cross-platform use
- Memory state management
- Review scheduling
- Item state tracking

## Prerequisites

- Rust (stable channel)
- Flutter SDK (v3.27.3 or later)
- flutter_rust_bridge_codegen (`cargo install flutter_rust_bridge_codegen`)

## Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd fsrs-rs-dart
cargo build
flutter pub get
flutter_rust_bridge_codegen generate
```

## License

MIT

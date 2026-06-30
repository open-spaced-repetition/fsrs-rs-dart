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

## Scheduling with learning steps

Use `FsrsScheduler` when you want Py-FSRS-style learning and relearning
steps. The lower-level `Fsrs.nextStates()` API returns FSRS memory states and
review intervals only; `FsrsScheduler` applies fixed learning-step intervals
around those memory-state updates.

```dart
import 'package:fsrs/fsrs.dart';

Future<void> main() async {
  await RustLib.init();

  final scheduler = FsrsScheduler(
    parameters: defaultParameters(),
    learningSteps: const [
      Duration(minutes: 1),
      Duration(minutes: 10),
    ],
    relearningSteps: const [
      Duration(minutes: 10),
    ],
  );

  final card = FsrsCard();
  final result = scheduler.reviewCard(card, FsrsRating.good);

  print(result.card.state);
  print(result.card.step);
  print(result.card.due);
}
```

## Features

- Core FSRS algorithm implemented in Rust
- Flutter bindings for cross-platform use
- Memory state management
- Review scheduling
- Item state tracking
- Py-FSRS-style learning and relearning step scheduling

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

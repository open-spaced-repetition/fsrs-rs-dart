import '../lib/fsrs.dart';

Future<void> main() async {
  // Initialize the Rust bridge
  await RustLib.init();

  // Create a new FSRS instance with default parameters
  final fsrs = new Fsrs(
    parameters: List<double>.from([
      0.4,
      0.6,
      2.4,
      5.8,
      4.93,
      0.94,
      0.86,
      0.01,
      1.49,
      0.14,
      0.94,
      2.18,
      0.05,
      0.34,
      1.26,
      0.29,
      2.61,
      0.05,
      0.4
    ]),
  );

  // Example: Calculate next states for a new item
  // Initial review with no prior memory state
  final nextStates = fsrs.nextStates(
    currentMemoryState: null, // No prior state for new items
    desiredRetention: 0.9, // 90% retention target
    daysElapsed: 0, // First review
  );

  // Print the results
  print('Next states calculated:');
  print('Again state: ${(nextStates.again).interval} days');
  print('Hard  state: ${(nextStates.hard).interval} days');
  print('Good  state: ${(nextStates.good).interval} days');
  print('Easy  state: ${(nextStates.easy).interval} days');
}

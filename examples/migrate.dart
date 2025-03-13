import '../lib/fsrs.dart';

void migrateWithFullHistory() {
  // Create a new FSRS instance with default parameters
  final fsrs = new Fsrs(parameters: defaultParameters);

  // Simulate a full review history for a card
  final reviews = [
    new FsrsReview(rating: 3, deltaT: 0),
    new FsrsReview(rating: 3, deltaT: 1),
    new FsrsReview(rating: 4, deltaT: 3),
    new FsrsReview(rating: 3, deltaT: 7),
  ];
  
  final item = new FsrsItem(reviews: reviews);
  final memoryState = fsrs.memoryState(item: item, startingState: null);
  
  print('Migrated memory state: $memoryState');
}

void migrateWithPartialHistory() {
  final fsrs = new Fsrs(parameters: defaultParameters);

  // Set the true retention of the original algorithm
  const sm2Retention = 0.9;
  const easeFactor = 2.0;
  const interval = 5.0;

  // Calculate the earliest memory state
  final initialState = fsrs.memoryStateFromSm2(
    easeFactor: easeFactor,
    interval: interval,
    sm2Retention: sm2Retention,
  );

  // Simulate partial review history
  final reviews = [
    new FsrsReview(rating: 3, deltaT: 5),
    new FsrsReview(rating: 4, deltaT: 10),
    new FsrsReview(rating: 3, deltaT: 20),
  ];
  final item = new FsrsItem(reviews: reviews);

  // Calculate current memory state with initial state
  final memoryState = fsrs.memoryState(item: item, startingState: initialState);
  print('Migrated memory state: $memoryState');
}

void migrateWithLatestState() {
  final fsrs = new Fsrs(parameters: defaultParameters);

  // Set the true retention of the original algorithm
  const sm2Retention = 0.9;
  const easeFactor = 2.5;
  const interval = 10.0;

  // Calculate the memory state
  final memoryState = fsrs.memoryStateFromSm2(
    easeFactor: easeFactor,
    interval: interval,
    sm2Retention: sm2Retention,
  );
  print('Migrated memory state: $memoryState');
}

Future<void> main() async {
  // Initialize the Rust bridge
  await RustLib.init();

  print('Migrating with full history:');
  migrateWithFullHistory();
  
  print('\nMigrating with partial history:');
  migrateWithPartialHistory();
  
  print('\nMigrating with latest state only:');
  migrateWithLatestState();
}
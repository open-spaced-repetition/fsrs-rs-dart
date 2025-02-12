import 'src/rust/frb_generated.dart';
import 'src/rust/api/fsrs_api.dart';

class Card {
  DateTime due;
  MemoryState? memoryState;
  int scheduledDays;
  DateTime? lastReview;

  Card()
      : due = DateTime.now().toUtc(),
        memoryState = null,
        scheduledDays = 0,
        lastReview = null;
}

Future<void> scheduleNewCard() async {
  // Create a new card
  final card = Card();

  // Set desired retention
  const desiredRetention = 0.9;

  // Create a new FSRS model
  final fsrs = new Fsrs(parameters: defaultParameters);

  // Get next states for a new card
  final nextStates = fsrs.nextStates(
    currentMemoryState: card.memoryState, 
    desiredRetention: desiredRetention,
    daysElapsed: 0
  );

  // Display the intervals for each rating
  print('Again interval: ${nextStates.again.interval.toStringAsFixed(1)} days');
  print('Hard interval: ${nextStates.hard.interval.toStringAsFixed(1)} days');
  print('Good interval: ${nextStates.good.interval.toStringAsFixed(1)} days');
  print('Easy interval: ${nextStates.easy.interval.toStringAsFixed(1)} days');

  // Assume the card was reviewed and the rating was 'good'
  final nextState = nextStates.good;
  final interval = (nextState.interval.round()).clamp(1, double.infinity).toInt();

  // Update the card with the new memory state and interval
  card.memoryState = nextState.memory;
  card.scheduledDays = interval;
  card.lastReview = DateTime.now().toUtc();
  card.due = card.lastReview!.add(Duration(days: interval));

  print('Next review due: ${card.due}');
  print('Memory state: ${card.memoryState}');
}

Future<void> scheduleExistingCard() async {
  // Create an existing card with memory state and last review date
  final card = new Card();
  card.due = DateTime.now().toUtc();
  card.lastReview = DateTime.now().toUtc().subtract(const Duration(days: 7));
  card.memoryState = new MemoryState(stability: 7.0, difficulty: 5.0);
  card.scheduledDays = 7;

  // Set desired retention
  const desiredRetention = 0.9;

  // Create a new FSRS model
  final fsrs = new Fsrs(parameters: defaultParameters);

  // Calculate the elapsed time since the last review
  final elapsedDays = DateTime.now().toUtc().difference(card.lastReview!).inDays;

  // Get next states for an existing card
  final nextStates =
      fsrs.nextStates(
        currentMemoryState: card.memoryState,
        desiredRetention: desiredRetention,
        daysElapsed: elapsedDays
  );

  // Display the intervals for each rating
  print('Again interval: ${nextStates.again.interval.toStringAsFixed(1)} days');
  print('Hard interval: ${nextStates.hard.interval.toStringAsFixed(1)} days');
  print('Good interval: ${nextStates.good.interval.toStringAsFixed(1)} days');
  print('Easy interval: ${nextStates.easy.interval.toStringAsFixed(1)} days');

  // Assume the card was reviewed and the rating was 'again'
  final nextState = nextStates.again;
  final interval = nextState.interval.round().clamp(1, double.infinity).toInt();

  // Update the card with the new memory state and interval
  card.memoryState = nextState.memory;
  card.scheduledDays = interval;
  card.lastReview = DateTime.now().toUtc();
  card.due = card.lastReview!.add(Duration(days: interval));

  print('Next review due: ${card.due}');
  print('Memory state: ${card.memoryState}');
}

Future<void> main() async {
  await RustLib.init();
  print('Scheduling a new card:');
  await scheduleNewCard();

  print('\nScheduling an existing card:');
  await scheduleExistingCard();
}
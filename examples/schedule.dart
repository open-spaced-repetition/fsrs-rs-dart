import '../lib/fsrs.dart';

Future<void> scheduleNewCard() async {
  final scheduler = FsrsScheduler(parameters: defaultParameters());
  final now = DateTime.utc(2026, 1, 1, 12);
  final card = FsrsCard(due: now);

  final preview = scheduler.preview(card, reviewDate: now);
  print('New card preview:');
  for (final rating in FsrsRating.values) {
    final result = preview[rating]!;
    print(
      '${rating.name}: ${result.card.state.name}, '
      'step=${result.card.step}, due=${result.card.due}',
    );
  }

  final reviewed = scheduler.reviewCard(
    card,
    FsrsRating.good,
    reviewDate: now,
  );

  print('After Good:');
  print('state=${reviewed.card.state.name}');
  print('step=${reviewed.card.step}');
  print('due=${reviewed.card.due}');
  print('memoryState=${reviewed.card.memoryState}');
}

Future<void> scheduleReviewCard() async {
  final scheduler = FsrsScheduler(parameters: defaultParameters());
  final now = DateTime.utc(2026, 1, 10, 12);
  final card = FsrsCard(
    state: FsrsCardState.review,
    memoryState: MemoryState(stability: 7.0, difficulty: 5.0),
    due: now,
    lastReview: now.subtract(const Duration(days: 7)),
  );

  final reviewed = scheduler.reviewCard(
    card,
    FsrsRating.again,
    reviewDate: now,
  );

  print('After Again on a review card:');
  print('state=${reviewed.card.state.name}');
  print('step=${reviewed.card.step}');
  print('due=${reviewed.card.due}');
  print('memoryState=${reviewed.card.memoryState}');
}

Future<void> main() async {
  await RustLib.init();

  await scheduleNewCard();
  print('');
  await scheduleReviewCard();
}

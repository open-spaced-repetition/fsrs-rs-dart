import '../lib/fsrs.dart';

Future<void> main() async {
  // Initialize Rust bridge
  await RustLib.init();

  // Create review histories for cards
  final reviewHistoriesOfCards = createReviewHistoriesForCards();

  // Convert review histories to FSRSItems
  final fsrsItems = reviewHistoriesOfCards.expand((history) => convertToFsrsItem(history)).toList();
  print('Number of FSRS items: ${fsrsItems.length}');

  // Create FSRS instance with default parameters
  final fsrs = new Fsrs(parameters: defaultParameters);
  print('Default parameters: ${defaultParameters}');

  // Optimize parameters
  final optimizedParameters = fsrs.computeParameters(trainSet: fsrsItems);
  print('Optimized parameters: $optimizedParameters');
}

List<List<(DateTime, int)>> createReviewHistoriesForCards() {
  final baseHistories = [
    [
      (DateTime(2023, 1, 1), 3),
      (DateTime(2023, 1, 2), 4),
      (DateTime(2023, 1, 5), 3),
      (DateTime(2023, 1, 15), 4),
      (DateTime(2023, 2, 1), 3),
      (DateTime(2023, 2, 20), 4),
    ],
    [
      (DateTime(2023, 1, 1), 2),
      (DateTime(2023, 1, 2), 3),
      (DateTime(2023, 1, 4), 4),
      (DateTime(2023, 1, 12), 3),
      (DateTime(2023, 1, 28), 4),
      (DateTime(2023, 2, 15), 3),
      (DateTime(2023, 3, 5), 4),
    ],
    // Add more review histories similar to Python example...
  ];

  // Repeat histories to create 100 cards worth of data
  return List.generate(100, (i) => baseHistories[i % baseHistories.length]);
}

List<FsrsItem> convertToFsrsItem(List<(DateTime, int)> history) {
  final reviews = <FsrsReview>[];
  var lastDate = history[0].$1;
  final items = <FsrsItem>[];

  for (final (date, rating) in history) {
    final deltaT = date.difference(lastDate).inDays;
    final review = new FsrsReview(
      rating: rating,
      deltaT: deltaT,
    );
    reviews.add(review);
    final item = new FsrsItem(reviews: List.from(reviews));
    items.add(item);
    lastDate = date;
  }

  return items.where((item) => item.longTermReviewCnt > BigInt.zero).toList();
}
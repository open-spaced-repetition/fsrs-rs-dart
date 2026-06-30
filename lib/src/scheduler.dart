import 'rust/api/fsrs_api.dart';

/// The rating selected by a reviewer.
enum FsrsRating {
  again(1),
  hard(2),
  good(3),
  easy(4);

  const FsrsRating(this.value);

  final int value;
}

/// The scheduling state of a card.
enum FsrsCardState {
  learning(1),
  review(2),
  relearning(3);

  const FsrsCardState(this.value);

  final int value;
}

/// Minimal card state needed by [FsrsScheduler].
class FsrsCard {
  FsrsCard({
    this.cardId,
    this.state = FsrsCardState.learning,
    int? step,
    this.memoryState,
    DateTime? due,
    DateTime? lastReview,
  })  : step = state == FsrsCardState.review ? null : step ?? 0,
        due = (due ?? DateTime.now().toUtc()).toUtc(),
        lastReview = lastReview?.toUtc();

  final int? cardId;
  final FsrsCardState state;
  final int? step;
  final MemoryState? memoryState;
  final DateTime due;
  final DateTime? lastReview;

  double? get stability => memoryState?.stability;

  double? get difficulty => memoryState?.difficulty;

  FsrsCard copyWith({
    int? cardId,
    FsrsCardState? state,
    int? step,
    MemoryState? memoryState,
    DateTime? due,
    DateTime? lastReview,
  }) {
    return FsrsCard(
      cardId: cardId ?? this.cardId,
      state: state ?? this.state,
      step: step ?? this.step,
      memoryState: memoryState ?? this.memoryState,
      due: due ?? this.due,
      lastReview: lastReview ?? this.lastReview,
    );
  }
}

/// Result of reviewing a card with one rating.
class FsrsSchedulingResult {
  const FsrsSchedulingResult({
    required this.card,
    required this.rating,
    required this.reviewedAt,
    required this.interval,
    required this.itemState,
  });

  final FsrsCard card;
  final FsrsRating rating;
  final DateTime reviewedAt;
  final Duration interval;
  final ItemState itemState;

  int get scheduledDays => interval.inDays;
}

/// Schedules cards with FSRS memory updates plus learning/relearning steps.
///
/// The Rust FSRS binding calculates the next memory state for each rating. This
/// class applies the same fixed-step scheduling policy used by Py-FSRS around
/// those memory states.
class FsrsScheduler {
  FsrsScheduler({
    Fsrs? fsrs,
    List<double>? parameters,
    this.desiredRetention = 0.9,
    List<Duration> learningSteps = const [
      Duration(minutes: 1),
      Duration(minutes: 10),
    ],
    List<Duration> relearningSteps = const [
      Duration(minutes: 10),
    ],
    this.maximumInterval = 36500,
  })  : fsrs = fsrs ?? Fsrs(parameters: parameters ?? defaultParameters()),
        learningSteps = List.unmodifiable(learningSteps),
        relearningSteps = List.unmodifiable(relearningSteps) {
    if (desiredRetention <= 0 || desiredRetention >= 1) {
      throw ArgumentError.value(
        desiredRetention,
        'desiredRetention',
        'must be between 0 and 1',
      );
    }
    if (maximumInterval < 1) {
      throw ArgumentError.value(
        maximumInterval,
        'maximumInterval',
        'must be at least 1',
      );
    }
  }

  final Fsrs fsrs;
  final double desiredRetention;
  final List<Duration> learningSteps;
  final List<Duration> relearningSteps;
  final int maximumInterval;

  /// Returns the scheduling result for each rating without mutating [card].
  Map<FsrsRating, FsrsSchedulingResult> preview(
    FsrsCard card, {
    DateTime? reviewDate,
  }) {
    _validateCard(card);

    final reviewedAt = (reviewDate ?? DateTime.now().toUtc()).toUtc();
    final daysElapsed = _daysElapsed(card, reviewedAt);
    final nextStates = fsrs.nextStates(
      currentMemoryState: card.memoryState,
      desiredRetention: desiredRetention,
      daysElapsed: daysElapsed,
    );

    return {
      for (final rating in FsrsRating.values)
        rating: _scheduleRating(
          card: card,
          rating: rating,
          reviewedAt: reviewedAt,
          itemState: _itemState(nextStates, rating),
        ),
    };
  }

  /// Reviews [card] with [rating] and returns the updated card state.
  FsrsSchedulingResult reviewCard(
    FsrsCard card,
    FsrsRating rating, {
    DateTime? reviewDate,
  }) {
    return preview(card, reviewDate: reviewDate)[rating]!;
  }

  FsrsSchedulingResult _scheduleRating({
    required FsrsCard card,
    required FsrsRating rating,
    required DateTime reviewedAt,
    required ItemState itemState,
  }) {
    return switch (card.state) {
      FsrsCardState.learning => _scheduleStepCard(
          card: card,
          rating: rating,
          reviewedAt: reviewedAt,
          itemState: itemState,
          steps: learningSteps,
          stepState: FsrsCardState.learning,
        ),
      FsrsCardState.review => _scheduleReviewCard(
          card: card,
          rating: rating,
          reviewedAt: reviewedAt,
          itemState: itemState,
        ),
      FsrsCardState.relearning => _scheduleStepCard(
          card: card,
          rating: rating,
          reviewedAt: reviewedAt,
          itemState: itemState,
          steps: relearningSteps,
          stepState: FsrsCardState.relearning,
        ),
    };
  }

  FsrsSchedulingResult _scheduleReviewCard({
    required FsrsCard card,
    required FsrsRating rating,
    required DateTime reviewedAt,
    required ItemState itemState,
  }) {
    if (rating == FsrsRating.again && relearningSteps.isNotEmpty) {
      return _result(
        card: card,
        rating: rating,
        reviewedAt: reviewedAt,
        itemState: itemState,
        state: FsrsCardState.relearning,
        step: 0,
        interval: relearningSteps.first,
      );
    }

    return _graduate(
      card: card,
      rating: rating,
      reviewedAt: reviewedAt,
      itemState: itemState,
    );
  }

  FsrsSchedulingResult _scheduleStepCard({
    required FsrsCard card,
    required FsrsRating rating,
    required DateTime reviewedAt,
    required ItemState itemState,
    required List<Duration> steps,
    required FsrsCardState stepState,
  }) {
    final step = card.step ?? 0;

    if (steps.isEmpty ||
        (step >= steps.length && rating != FsrsRating.again)) {
      return _graduate(
        card: card,
        rating: rating,
        reviewedAt: reviewedAt,
        itemState: itemState,
      );
    }

    switch (rating) {
      case FsrsRating.again:
        return _result(
          card: card,
          rating: rating,
          reviewedAt: reviewedAt,
          itemState: itemState,
          state: stepState,
          step: 0,
          interval: steps.first,
        );
      case FsrsRating.hard:
        final interval = step == 0
            ? (steps.length == 1
                ? _multiplyDuration(steps.first, 1.5)
                : _averageDuration(steps[0], steps[1]))
            : steps[step];
        return _result(
          card: card,
          rating: rating,
          reviewedAt: reviewedAt,
          itemState: itemState,
          state: stepState,
          step: step,
          interval: interval,
        );
      case FsrsRating.good:
        if (step + 1 == steps.length) {
          return _graduate(
            card: card,
            rating: rating,
            reviewedAt: reviewedAt,
            itemState: itemState,
          );
        }
        return _result(
          card: card,
          rating: rating,
          reviewedAt: reviewedAt,
          itemState: itemState,
          state: stepState,
          step: step + 1,
          interval: steps[step + 1],
        );
      case FsrsRating.easy:
        return _graduate(
          card: card,
          rating: rating,
          reviewedAt: reviewedAt,
          itemState: itemState,
        );
    }
  }

  FsrsSchedulingResult _graduate({
    required FsrsCard card,
    required FsrsRating rating,
    required DateTime reviewedAt,
    required ItemState itemState,
  }) {
    return _result(
      card: card,
      rating: rating,
      reviewedAt: reviewedAt,
      itemState: itemState,
      state: FsrsCardState.review,
      step: null,
      interval: Duration(days: _reviewIntervalDays(itemState)),
    );
  }

  FsrsSchedulingResult _result({
    required FsrsCard card,
    required FsrsRating rating,
    required DateTime reviewedAt,
    required ItemState itemState,
    required FsrsCardState state,
    required int? step,
    required Duration interval,
  }) {
    return FsrsSchedulingResult(
      card: FsrsCard(
        cardId: card.cardId,
        state: state,
        step: step,
        memoryState: itemState.memory,
        due: reviewedAt.add(interval),
        lastReview: reviewedAt,
      ),
      rating: rating,
      reviewedAt: reviewedAt,
      interval: interval,
      itemState: itemState,
    );
  }

  int _daysElapsed(FsrsCard card, DateTime reviewedAt) {
    final lastReview = card.lastReview;
    if (lastReview == null) {
      return 0;
    }
    final days = reviewedAt.difference(lastReview).inDays;
    return days < 0 ? 0 : days;
  }

  int _reviewIntervalDays(ItemState itemState) {
    final rounded = itemState.interval.round();
    return rounded.clamp(1, maximumInterval).toInt();
  }

  ItemState _itemState(NextStates nextStates, FsrsRating rating) {
    return switch (rating) {
      FsrsRating.again => nextStates.again,
      FsrsRating.hard => nextStates.hard,
      FsrsRating.good => nextStates.good,
      FsrsRating.easy => nextStates.easy,
    };
  }

  void _validateCard(FsrsCard card) {
    if (card.state != FsrsCardState.learning && card.memoryState == null) {
      throw ArgumentError.value(
        card,
        'card',
        '${card.state.name} cards must have a memoryState',
      );
    }
  }
}

Duration _averageDuration(Duration first, Duration second) {
  return Duration(
    microseconds: ((first.inMicroseconds + second.inMicroseconds) / 2).round(),
  );
}

Duration _multiplyDuration(Duration duration, double factor) {
  return Duration(
    microseconds: (duration.inMicroseconds * factor).round(),
  );
}

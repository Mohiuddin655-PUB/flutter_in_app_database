part of 'query.dart';

enum Selections {
  endAt,
  endAtDocument,
  endBefore,
  endBeforeDocument,
  startAfter,
  startAfterDocument,
  startAt,
  startAtDocument,
  none;

  bool get isNone => this == none;

  bool get isEndAt => this == endAt;

  bool get isEndAtDocument => this == endAtDocument;

  bool get isEndBefore => this == endBefore;

  bool get isEndBeforeDocument => this == endBeforeDocument;

  bool get isStartAfter => this == startAfter;

  bool get isStartAfterDocument => this == startAfterDocument;

  bool get isStartAt => this == startAt;

  bool get isStartAtDocument => this == startAtDocument;
}

class Selection {
  final Object? value;
  final Selections type;

  Iterable<Object?>? get values {
    return value is Iterable<Object?> ? value as Iterable<Object?> : null;
  }

  const Selection._(
    this.value, {
    this.type = Selections.none,
  });

  const Selection.empty() : this._(null);

  const Selection.from(Object? snapshot, Selections type)
      : this._(snapshot, type: type);

  const Selection.endAt(Iterable<Object?>? values)
      : this._(values, type: Selections.endAt);

  const Selection.endAtDocument(Object? snapshot)
      : this._(snapshot, type: Selections.endAtDocument);

  const Selection.endBefore(Iterable<Object?>? values)
      : this._(values, type: Selections.endBefore);

  const Selection.endBeforeDocument(Object? snapshot)
      : this._(snapshot, type: Selections.endBeforeDocument);

  const Selection.startAfter(Iterable<Object?>? values)
      : this._(values, type: Selections.startAfter);

  const Selection.startAfterDocument(Object? snapshot)
      : this._(snapshot, type: Selections.startAfterDocument);

  const Selection.startAt(Iterable<Object?>? values)
      : this._(values, type: Selections.startAt);

  const Selection.startAtDocument(Object? snapshot)
      : this._(snapshot, type: Selections.startAtDocument);
}

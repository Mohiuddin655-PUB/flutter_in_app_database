enum DataSelectionTypes {
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

class DataSelection {
  final Object? value;
  final DataSelectionTypes type;

  Iterable<Object?>? get values {
    return value is Iterable<Object?> ? value as Iterable<Object?> : null;
  }

  const DataSelection._(
    this.value, {
    this.type = DataSelectionTypes.none,
  });

  const DataSelection.empty() : this._(null);

  const DataSelection.endAt(Iterable<Object?>? values)
      : this._(values, type: DataSelectionTypes.endAt);

  const DataSelection.endAtDocument(Object? snapshot)
      : this._(snapshot, type: DataSelectionTypes.endAtDocument);

  const DataSelection.endBefore(Iterable<Object?>? values)
      : this._(values, type: DataSelectionTypes.endBefore);

  const DataSelection.endBeforeDocument(Object? snapshot)
      : this._(snapshot, type: DataSelectionTypes.endBeforeDocument);

  const DataSelection.startAfter(Iterable<Object?>? values)
      : this._(values, type: DataSelectionTypes.startAfter);

  const DataSelection.startAfterDocument(Object? snapshot)
      : this._(snapshot, type: DataSelectionTypes.startAfterDocument);

  const DataSelection.startAt(Iterable<Object?>? values)
      : this._(values, type: DataSelectionTypes.startAt);

  const DataSelection.startAtDocument(Object? snapshot)
      : this._(snapshot, type: DataSelectionTypes.startAtDocument);
}

import 'package:in_app_query/in_app_query.dart';

class InAppSelection extends Selection {
  InAppSelection.empty() : super.empty();

  const InAppSelection.from(Object super.snapshot, super.type) : super.from();

  const InAppSelection.endAt(super.values) : super.endAt();

  const InAppSelection.endAtDocument(super.snapshot) : super.endAtDocument();

  const InAppSelection.endBefore(super.values) : super.endBefore();

  const InAppSelection.endBeforeDocument(super.snapshot)
      : super.endBeforeDocument();

  const InAppSelection.startAfter(super.values) : super.startAfter();

  const InAppSelection.startAfterDocument(super.snapshot)
      : super.startAfterDocument();

  const InAppSelection.startAt(super.values) : super.startAt();

  const InAppSelection.startAtDocument(super.snapshot)
      : super.startAtDocument();
}

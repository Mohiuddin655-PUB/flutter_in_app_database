part of 'base.dart';

class InAppCollectionReference extends InAppQueryReference {
  const InAppCollectionReference(
    super.reference,
    super.instance,
  );

  InAppDocumentReference document(String field) {
    return InAppDocumentReference("$reference/$field", instance);
  }

  Future<InAppDocumentSnapshot> add(InAppDocument data) {
    return document(id).set(data);
  }

  Future<InAppQuerySnapshot> set(List<InAppDocument> data) {
    instance.collections[reference] = data;
    return get();
  }

  Future<InAppQuerySnapshot> delete() {
    instance.collections.remove(reference);
    return get();
  }
}

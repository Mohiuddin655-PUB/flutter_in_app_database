typedef InAppValue = Object?;
typedef InAppDocument = Map<String, InAppValue>;

class InAppSetOptions {
  final bool merge;

  const InAppSetOptions({
    this.merge = false,
  });
}

import 'package:in_app_query/in_app_query.dart';

class InAppFilter extends Filter {
  InAppFilter(
    super.field, {
    super.isEqualTo,
    super.isNotEqualTo,
    super.isLessThan,
    super.isLessThanOrEqualTo,
    super.isGreaterThan,
    super.isGreaterThanOrEqualTo,
    super.arrayContains,
    super.arrayNotContains,
    super.arrayContainsAny,
    super.arrayNotContainsAny,
    super.whereIn,
    super.whereNotIn,
    super.isNull,
  });

  const InAppFilter.and(super.filters) : super.and();

  const InAppFilter.or(super.filters) : super.or();
}

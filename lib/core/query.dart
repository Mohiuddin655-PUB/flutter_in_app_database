import 'package:in_app_query/in_app_query.dart';

import 'field_path.dart';

class InAppQuery extends Query {
  const InAppQuery(
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

  const InAppQuery.filter(Filter filter) : this(filter);

  const InAppQuery.path(InAppFieldPath path) : this(path);
}

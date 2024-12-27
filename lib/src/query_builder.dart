class AirtableQueryCrud {
  final List<String> _clauses = [];

  /// Adds a basic condition.
  AirtableQueryCrud where(Map<String, String> conditions) {
    _clauses.addAll(_buildClause(conditions));
    return this;
  }

  /// Adds a condition with `AND` logic.
  AirtableQueryCrud and(Map<String, String> conditions) {
    _clauses.addAll(_buildClause(conditions));
    return this;
  }

  /// Adds a condition with `OR` logic.
  AirtableQueryCrud or(Map<String, String> conditions) {
    if (_clauses.isEmpty) {
      throw Exception('No conditions exist to add OR logic.');
    }
    final lastClause = _clauses.removeLast();
    final orClause = "OR($lastClause, ${_buildClause(conditions).join(', ')})";
    _clauses.add(orClause);
    return this;
  }

  /// Builds the filter formula by combining all added clauses.
  String build() {
    if (_clauses.isEmpty) {
      throw Exception('No conditions have been added to the query.');
    }
    return _clauses.length == 1
        ? _clauses.first
        : "AND(${_clauses.join(', ')})";
  }

  /// Helper method to build conditions.
  List<String> _buildClause(Map<String, String> conditions) {
    return conditions.entries
        .map((entry) => "{${entry.key}} = '${_escapeValue(entry.value)}'")
        .toList();
  }

  /// Escapes single quotes in string values to avoid syntax errors.
  String _escapeValue(String value) {
    return value.replaceAll("'", "\\'");
  }

  /// Resets the query builder.
  void reset() {
    _clauses.clear();
  }
}

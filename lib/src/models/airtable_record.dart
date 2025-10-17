/// A class representing a record from an Airtable base.
///
/// Each `AirtableRecord` consists of a unique `id` and a `fields` map
/// containing the data for each field in the record.
///
/// As of v1.3.0, this class encourages immutability through the [copyWith]
/// method, though direct field mutation is still supported for backward
/// compatibility (will be removed in v2.0.0).
class AirtableRecord {
  /// The unique identifier of the record in Airtable.
  final String id;

  /// Private backing field for the record's data.
  final Map<String, dynamic> _fields;

  /// An immutable view of the record's fields.
  ///
  /// To update fields, use [copyWith] or [updateField] methods instead
  /// of mutating this map directly.
  Map<String, dynamic> get fields => Map.unmodifiable(_fields);

  /// Creates an instance of [AirtableRecord] with the given [id] and [fields].
  AirtableRecord({
    required this.id,
    required Map<String, dynamic> fields,
  }) : _fields = Map<String, dynamic>.from(fields);

  /// Creates an [AirtableRecord] instance from a JSON map.
  ///
  /// - [json]: A map representing the JSON object returned from the Airtable API.
  ///
  /// Returns an instance of [AirtableRecord].
  factory AirtableRecord.fromJson(Map<String, dynamic> json) {
    return AirtableRecord(
      id: json['id'] as String,
      fields: Map<String, dynamic>.from(json['fields'] ?? {}),
    );
  }

  /// Creates a copy of this record with some fields replaced.
  ///
  /// This is the recommended way to update record data. It creates a new
  /// [AirtableRecord] instance with the specified changes.
  ///
  /// Example:
  /// ```dart
  /// final updated = record.copyWith(
  ///   fields: {...record.fields, 'name': 'New Name'},
  /// );
  /// ```
  AirtableRecord copyWith({
    String? id,
    Map<String, dynamic>? fields,
  }) {
    return AirtableRecord(
      id: id ?? this.id,
      fields: fields ?? _fields,
    );
  }

  /// Creates a copy of this record with a single field updated.
  ///
  /// This is a convenience method for updating a single field without
  /// manually creating a new fields map.
  ///
  /// Example:
  /// ```dart
  /// final updated = record.updateField('status', 'completed');
  /// ```
  AirtableRecord updateField(String key, dynamic value) {
    return copyWith(
      fields: {..._fields, key: value},
    );
  }

  /// Creates a copy of this record with a field removed.
  ///
  /// Example:
  /// ```dart
  /// final updated = record.removeField('tempData');
  /// ```
  AirtableRecord removeField(String key) {
    final newFields = Map<String, dynamic>.from(_fields);
    newFields.remove(key);
    return copyWith(fields: newFields);
  }

  /// Gets a field value with type casting.
  ///
  /// Returns `null` if the field doesn't exist or can't be cast to [T].
  ///
  /// Example:
  /// ```dart
  /// final name = record.getField<String>('name');
  /// final age = record.getField<int>('age');
  /// ```
  T? getField<T>(String fieldName) {
    final value = _fields[fieldName];
    if (value is T) {
      return value;
    }
    return null;
  }

  /// Checks if a field exists in this record.
  bool hasField(String fieldName) {
    return _fields.containsKey(fieldName);
  }

  /// DEPRECATED: Direct field mutation setter.
  ///
  /// Use [copyWith] or [updateField] instead for immutable updates.
  /// This setter will be removed in version 2.0.0.
  @Deprecated(
      'Direct mutation of fields is deprecated. Use copyWith() or updateField() instead. '
      'This setter will be removed in version 2.0.0. '
      'Deprecated since version 1.3.0.')
  set fields(Map<String, dynamic> newFields) {
    _fields.clear();
    _fields.addAll(newFields);
  }

  /// Converts the [AirtableRecord] instance to a JSON map.
  ///
  /// Returns a map that can be serialized to JSON, containing the `id` and `fields`.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fields': Map<String, dynamic>.from(_fields),
    };
  }

  @override
  String toString() {
    return 'AirtableRecord(id: $id, fields: $_fields)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AirtableRecord &&
        other.id == id &&
        _mapsEqual(other._fields, _fields);
  }

  @override
  int get hashCode => Object.hash(id, _fields);

  /// Helper method to compare two maps for equality.
  bool _mapsEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }
    return true;
  }
}

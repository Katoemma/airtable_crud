/// A class representing a record from an Airtable base.
///
/// Each `AirtableRecord` consists of a unique `id` and a `fields` map
/// containing the data for each field in the record.
class AirtableRecord {
  /// The unique identifier of the record in Airtable.
  String id;

  /// A map of field names to their corresponding values.
  Map<String, dynamic> fields;

  /// Creates an instance of [AirtableRecord] with the given [id] and [fields].
  AirtableRecord({required this.id, required this.fields});

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

  /// Converts the [AirtableRecord] instance to a JSON map.
  ///
  /// Returns a map that can be serialized to JSON, containing the `id` and `fields`.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fields': fields,
    };
  }
}

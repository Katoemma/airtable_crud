class AirtableRecord {
  String id;
  Map<dynamic, dynamic> fields;

  AirtableRecord({required this.id, required this.fields});

  factory AirtableRecord.fromJson(Map<dynamic, dynamic> json) {
    return AirtableRecord(
      id: json['id'],
      fields: (json['fields'] as Map<dynamic, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fields': fields,
    };
  }
}

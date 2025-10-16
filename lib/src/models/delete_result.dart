/// Result of a delete operation on an Airtable record.
///
/// This class provides information about a successfully deleted record,
/// including the record ID, deletion status, and timestamp.
class DeleteResult {
  /// The ID of the deleted record.
  final String id;

  /// Whether the record was successfully deleted.
  ///
  /// This will be `true` for successful deletions.
  final bool deleted;

  /// The timestamp when the record was deleted.
  ///
  /// This is set by the client when the delete operation completes successfully.
  final DateTime deletedAt;

  /// Creates a [DeleteResult].
  ///
  /// - [id]: The ID of the deleted record
  /// - [deleted]: Whether the deletion was successful (typically true)
  /// - [deletedAt]: When the record was deleted
  const DeleteResult({
    required this.id,
    required this.deleted,
    required this.deletedAt,
  });

  /// Creates a [DeleteResult] from a JSON response.
  ///
  /// The Airtable API returns a simple object with an 'id' and 'deleted' field
  /// when a record is successfully deleted.
  factory DeleteResult.fromJson(Map<String, dynamic> json) {
    return DeleteResult(
      id: json['id'] as String,
      deleted: json['deleted'] as bool? ?? true,
      deletedAt: DateTime.now(),
    );
  }

  /// Converts this [DeleteResult] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deleted': deleted,
      'deletedAt': deletedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'DeleteResult(id: $id, deleted: $deleted, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteResult &&
        other.id == id &&
        other.deleted == deleted &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode => Object.hash(id, deleted, deletedAt);
}

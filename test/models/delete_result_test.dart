import 'package:airtable_crud/src/models/delete_result.dart';
import 'package:test/test.dart';

void main() {
  group('DeleteResult', () {
    const testId = 'rec123abc';
    final testDeletedAt = DateTime(2024, 1, 15, 10, 30);

    test('creates DeleteResult with all parameters', () {
      final result = DeleteResult(
        id: testId,
        deleted: true,
        deletedAt: testDeletedAt,
      );

      expect(result.id, equals(testId));
      expect(result.deleted, equals(true));
      expect(result.deletedAt, equals(testDeletedAt));
    });

    test('fromJson creates DeleteResult from API response', () {
      final json = {
        'id': testId,
        'deleted': true,
      };

      final result = DeleteResult.fromJson(json);

      expect(result.id, equals(testId));
      expect(result.deleted, equals(true));
      expect(result.deletedAt, isA<DateTime>());
    });

    test('fromJson handles missing deleted field', () {
      final json = {
        'id': testId,
      };

      final result = DeleteResult.fromJson(json);

      expect(result.id, equals(testId));
      expect(result.deleted, equals(true)); // Defaults to true
    });

    test('toJson converts DeleteResult to JSON', () {
      final result = DeleteResult(
        id: testId,
        deleted: true,
        deletedAt: testDeletedAt,
      );

      final json = result.toJson();

      expect(json['id'], equals(testId));
      expect(json['deleted'], equals(true));
      expect(json['deletedAt'], equals(testDeletedAt.toIso8601String()));
    });

    test('toString returns readable representation', () {
      final result = DeleteResult(
        id: testId,
        deleted: true,
        deletedAt: testDeletedAt,
      );

      final str = result.toString();
      expect(str, contains(testId));
      expect(str, contains('true'));
      expect(str, contains('DeleteResult'));
    });

    test('equality works correctly', () {
      final result1 = DeleteResult(
        id: testId,
        deleted: true,
        deletedAt: testDeletedAt,
      );

      final result2 = DeleteResult(
        id: testId,
        deleted: true,
        deletedAt: testDeletedAt,
      );

      expect(result1, equals(result2));
      expect(result1.hashCode, equals(result2.hashCode));
    });

    test('inequality works correctly', () {
      final result1 = DeleteResult(
        id: testId,
        deleted: true,
        deletedAt: testDeletedAt,
      );

      final result2 = DeleteResult(
        id: 'different_id',
        deleted: true,
        deletedAt: testDeletedAt,
      );

      expect(result1, isNot(equals(result2)));
    });
  });
}

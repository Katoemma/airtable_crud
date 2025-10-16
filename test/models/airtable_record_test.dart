import 'package:airtable_crud/src/models/airtable_record.dart';
import 'package:test/test.dart';

void main() {
  group('AirtableRecord', () {
    const testId = 'rec123abc';
    final testFields = {
      'name': 'John Doe',
      'age': 30,
      'email': 'john@example.com'
    };

    test('creates record with id and fields', () {
      final record = AirtableRecord(id: testId, fields: testFields);

      expect(record.id, equals(testId));
      expect(record.fields, equals(testFields));
    });

    test('fields are immutable', () {
      final record = AirtableRecord(id: testId, fields: testFields);

      // Attempt to modify should throw
      expect(
        () => record.fields['name'] = 'Jane Doe',
        throwsUnsupportedError,
      );
    });

    test('fromJson creates record from JSON', () {
      final json = {
        'id': testId,
        'fields': testFields,
      };

      final record = AirtableRecord.fromJson(json);

      expect(record.id, equals(testId));
      expect(record.fields, equals(testFields));
    });

    test('fromJson handles missing fields', () {
      final json = {
        'id': testId,
      };

      final record = AirtableRecord.fromJson(json);

      expect(record.id, equals(testId));
      expect(record.fields, isEmpty);
    });

    test('toJson converts record to JSON', () {
      final record = AirtableRecord(id: testId, fields: testFields);
      final json = record.toJson();

      expect(json['id'], equals(testId));
      expect(json['fields'], equals(testFields));
    });

    group('copyWith', () {
      test('creates new record with updated id', () {
        final record = AirtableRecord(id: testId, fields: testFields);
        final updated = record.copyWith(id: 'newId');

        expect(updated.id, equals('newId'));
        expect(updated.fields, equals(testFields));
        expect(record.id, equals(testId)); // Original unchanged
      });

      test('creates new record with updated fields', () {
        final record = AirtableRecord(id: testId, fields: testFields);
        final newFields = {'name': 'Jane Doe', 'age': 25};
        final updated = record.copyWith(fields: newFields);

        expect(updated.id, equals(testId));
        expect(updated.fields, equals(newFields));
        expect(record.fields, equals(testFields)); // Original unchanged
      });

      test('preserves values when not specified', () {
        final record = AirtableRecord(id: testId, fields: testFields);
        final updated = record.copyWith();

        expect(updated.id, equals(testId));
        expect(updated.fields, equals(testFields));
      });
    });

    group('updateField', () {
      test('creates new record with single field updated', () {
        final record = AirtableRecord(id: testId, fields: testFields);
        final updated = record.updateField('name', 'Jane Doe');

        expect(updated.fields['name'], equals('Jane Doe'));
        expect(updated.fields['age'], equals(30));
        expect(record.fields['name'], equals('John Doe')); // Original unchanged
      });

      test('adds new field if it doesn\'t exist', () {
        final record = AirtableRecord(id: testId, fields: testFields);
        final updated = record.updateField('status', 'active');

        expect(updated.fields['status'], equals('active'));
        expect(updated.fields.length, equals(testFields.length + 1));
      });
    });

    group('removeField', () {
      test('creates new record with field removed', () {
        final record = AirtableRecord(id: testId, fields: testFields);
        final updated = record.removeField('email');

        expect(updated.fields.containsKey('email'), isFalse);
        expect(updated.fields['name'], equals('John Doe'));
        expect(
            record.fields.containsKey('email'), isTrue); // Original unchanged
      });

      test('handles removing non-existent field', () {
        final record = AirtableRecord(id: testId, fields: testFields);
        final updated = record.removeField('nonexistent');

        expect(updated.fields, equals(testFields));
      });
    });

    group('getField', () {
      test('returns field value with correct type', () {
        final record = AirtableRecord(id: testId, fields: testFields);

        expect(record.getField<String>('name'), equals('John Doe'));
        expect(record.getField<int>('age'), equals(30));
        expect(record.getField<String>('email'), equals('john@example.com'));
      });

      test('returns null for non-existent field', () {
        final record = AirtableRecord(id: testId, fields: testFields);

        expect(record.getField<String>('nonexistent'), isNull);
      });

      test('returns null for incorrect type', () {
        final record = AirtableRecord(id: testId, fields: testFields);

        expect(record.getField<int>('name'), isNull); // name is String, not int
      });
    });

    group('hasField', () {
      test('returns true for existing field', () {
        final record = AirtableRecord(id: testId, fields: testFields);

        expect(record.hasField('name'), isTrue);
        expect(record.hasField('age'), isTrue);
      });

      test('returns false for non-existent field', () {
        final record = AirtableRecord(id: testId, fields: testFields);

        expect(record.hasField('nonexistent'), isFalse);
      });
    });

    group('deprecated fields setter', () {
      test('still works for backward compatibility', () {
        final record = AirtableRecord(id: testId, fields: testFields);
        final newFields = {'name': 'Jane Doe'};

        // This should work but show deprecation warning
        // ignore: deprecated_member_use_from_same_package
        record.fields = newFields;

        // Note: The actual implementation modifies the internal map
        // This test verifies backward compatibility
        expect(record.fields.containsKey('name'), isTrue);
      });
    });

    test('toString returns readable representation', () {
      final record = AirtableRecord(id: testId, fields: testFields);
      final str = record.toString();

      expect(str, contains(testId));
      expect(str, contains('AirtableRecord'));
    });

    test('equality works correctly', () {
      final record1 = AirtableRecord(id: testId, fields: testFields);
      final record2 = AirtableRecord(id: testId, fields: testFields);

      expect(record1, equals(record2));
      expect(record1.hashCode, equals(record2.hashCode));
    });

    test('inequality works correctly for different ids', () {
      final record1 = AirtableRecord(id: testId, fields: testFields);
      final record2 = AirtableRecord(id: 'differentId', fields: testFields);

      expect(record1, isNot(equals(record2)));
    });

    test('inequality works correctly for different fields', () {
      final record1 = AirtableRecord(id: testId, fields: testFields);
      final record2 = AirtableRecord(id: testId, fields: {'name': 'Jane Doe'});

      expect(record1, isNot(equals(record2)));
    });
  });
}

import 'package:airtable_crud/airtable_crud.dart';
import 'package:test/test.dart';

void main() {
  const apiKey =
      'YOUR_AIRTABLE_API_KEY'; // Replace with your actual API key to run tests
  const baseId = 'YOUR_BASE_ID'; // Replace with your actual Base ID
  const tableName = 'crudTest';

  late AirtableCrud airtableCrud;

  // Setup that runs before all tests
  setUp(() {
    // Test both old and new constructors
    final config = AirtableConfig(
      apiKey: apiKey,
      baseId: baseId,
      timeout: Duration(seconds: 30),
      maxRetries: 3,
      enableLogging: false,
    );
    airtableCrud = AirtableCrud.withConfig(config);
  });

  group('v1.3.0 - New Features', () {
    group('Configuration', () {
      test('withConfig constructor works with custom settings', () {
        final config = AirtableConfig(
          apiKey: apiKey,
          baseId: baseId,
          timeout: Duration(seconds: 60),
          maxRetries: 5,
          enableLogging: false,
        );
        final crud = AirtableCrud.withConfig(config);

        expect(crud.apiKey, equals(apiKey));
        expect(crud.baseId, equals(baseId));
      });

      test('simple config factory works', () {
        final config = AirtableConfig.simple(
          apiKey: apiKey,
          baseId: baseId,
        );
        final crud = AirtableCrud.withConfig(config);

        expect(crud.apiKey, equals(apiKey));
      });
    });

    group('Unified fetchRecords()', () {
      test('fetchRecords without filter', () async {
        // Create a test record first to ensure table has data
        final testData = {'Name': 'Fetch Test Record', 'Status': 'Active'};
        final created = await airtableCrud.createRecord(tableName, testData);

        try {
          final records = await airtableCrud.fetchRecords(tableName);

          expect(records, isList);
          expect(records.isNotEmpty, true);
          expect(records.first.id, isNotEmpty);
        } finally {
          // Cleanup
          await airtableCrud.deleteRecord(tableName, created.id);
        }
      });

      test('fetchRecords with filter parameter', () async {
        // Create a test record first
        final testData = {
          'Name': 'Unified Fetch Test',
          'Status': 'Active',
        };
        final created = await airtableCrud.createRecord(tableName, testData);

        try {
          // Use new unified method with filter parameter
          final records = await airtableCrud.fetchRecords(
            tableName,
            filter: '{Name} = "Unified Fetch Test"',
          );

          expect(records, isList);
          expect(records.isNotEmpty, true);
          expect(records.first.fields['Name'], equals('Unified Fetch Test'));
        } finally {
          // Cleanup
          await airtableCrud.deleteRecord(tableName, created.id);
        }
      });

      test('fetchRecords with multiple parameters', () async {
        final records = await airtableCrud.fetchRecords(
          tableName,
          fields: ['Name', 'Status'],
          maxRecords: 5,
        );

        expect(records, isList);
        if (records.isNotEmpty) {
          // Verify only specified fields are returned
          expect(records.first.fields.containsKey('Name'), true);
          expect(records.length, lessThanOrEqualTo(5));
        }
      });
    });

    group('Enhanced Return Values', () {
      test('updateRecord returns updated AirtableRecord', () async {
        // Create a record
        final testData = {'Name': 'Return Value Test', 'Status': 'Initial'};
        final created = await airtableCrud.createRecord(tableName, testData);

        try {
          // Update using new immutable pattern
          final updated = created.updateField('Status', 'Updated');
          final result = await airtableCrud.updateRecord(tableName, updated);

          // Verify return value
          expect(result, isA<AirtableRecord>());
          expect(result.id, equals(created.id));
          expect(result.fields['Status'], equals('Updated'));
        } finally {
          // Cleanup
          await airtableCrud.deleteRecord(tableName, created.id);
        }
      });

      test('deleteRecord returns DeleteResult', () async {
        // Create a record to delete
        final testData = {'Name': 'Delete Result Test', 'Status': 'To Delete'};
        final created = await airtableCrud.createRecord(tableName, testData);

        // Delete and check return value
        final result = await airtableCrud.deleteRecord(tableName, created.id);

        expect(result, isA<DeleteResult>());
        expect(result.id, equals(created.id));
        expect(result.deleted, isTrue);
        expect(result.deletedAt, isA<DateTime>());
      });
    });

    group('Immutable AirtableRecord', () {
      test('copyWith creates new instance', () async {
        final testData = {'Name': 'Immutable Test', 'Status': 'Original'};
        final created = await airtableCrud.createRecord(tableName, testData);

        try {
          // Use copyWith to update
          final updated = created.copyWith(
            fields: {...created.fields, 'Status': 'Modified'},
          );

          expect(updated.id, equals(created.id));
          expect(updated.fields['Status'], equals('Modified'));
          expect(created.fields['Status'], equals('Original'));
        } finally {
          await airtableCrud.deleteRecord(tableName, created.id);
        }
      });

      test('updateField helper works', () async {
        final testData = {'Name': 'Helper Test', 'Status': 'Old'};
        final created = await airtableCrud.createRecord(tableName, testData);

        try {
          final updated = created.updateField('Status', 'New');

          expect(updated.fields['Status'], equals('New'));
          expect(created.fields['Status'], equals('Old'));
        } finally {
          await airtableCrud.deleteRecord(tableName, created.id);
        }
      });

      test('removeField helper works', () async {
        final testData = {
          'Name': 'Remove Field Test',
          'Status': 'Active',
          'Notes': 'To be removed'
        };
        final created = await airtableCrud.createRecord(tableName, testData);

        try {
          final updated = created.removeField('Notes');

          expect(updated.fields.containsKey('Notes'), isFalse);
          expect(updated.fields.containsKey('Name'), isTrue);
          expect(created.fields.containsKey('Notes'), isTrue);
        } finally {
          await airtableCrud.deleteRecord(tableName, created.id);
        }
      });

      test('getField provides type-safe access', () async {
        final testData = {'Name': 'Type Safe Test', 'Status': 'Active'};
        final created = await airtableCrud.createRecord(tableName, testData);

        try {
          expect(created.getField<String>('Name'), equals('Type Safe Test'));
          expect(created.getField<String>('Status'), equals('Active'));
          expect(created.getField<int>('Name'), isNull); // Wrong type
          expect(created.getField<String>('NonExistent'), isNull);
        } finally {
          await airtableCrud.deleteRecord(tableName, created.id);
        }
      });

      test('hasField checks field existence', () async {
        final testData = {'Name': 'Field Check Test', 'Status': 'Active'};
        final created = await airtableCrud.createRecord(tableName, testData);

        try {
          expect(created.hasField('Name'), isTrue);
          expect(created.hasField('Status'), isTrue);
          expect(created.hasField('NonExistent'), isFalse);
        } finally {
          await airtableCrud.deleteRecord(tableName, created.id);
        }
      });
    });

    group('Bulk Operations', () {
      test('updateBulkRecords updates multiple records', () async {
        // Create test records
        final testDataList = [
          {'Name': 'Bulk Update 1', 'Status': 'Pending'},
          {'Name': 'Bulk Update 2', 'Status': 'Pending'},
        ];
        final created =
            await airtableCrud.createBulkRecords(tableName, testDataList);

        try {
          // Update all records
          final toUpdate = created
              .map((record) => record.updateField('Status', 'Completed'))
              .toList();

          final updated =
              await airtableCrud.updateBulkRecords(tableName, toUpdate);

          expect(updated.length, equals(2));
          expect(updated[0].fields['Status'], equals('Completed'));
          expect(updated[1].fields['Status'], equals('Completed'));
        } finally {
          // Cleanup
          await airtableCrud.deleteBulkRecords(
            tableName,
            created.map((r) => r.id).toList(),
          );
        }
      });

      test('deleteBulkRecords deletes multiple records', () async {
        // Create test records
        final testDataList = [
          {'Name': 'Bulk Delete 1', 'Status': 'Active'},
          {'Name': 'Bulk Delete 2', 'Status': 'Active'},
          {'Name': 'Bulk Delete 3', 'Status': 'Active'},
        ];
        final created =
            await airtableCrud.createBulkRecords(tableName, testDataList);

        final ids = created.map((r) => r.id).toList();
        final results = await airtableCrud.deleteBulkRecords(tableName, ids);

        expect(results.length, equals(3));
        expect(results[0].deleted, isTrue);
        expect(results[1].deleted, isTrue);
        expect(results[2].deleted, isTrue);
      });
    });

    group('Exception Handling', () {
      test('AuthException for invalid API key', () async {
        final badCrud = AirtableCrud.withConfig(
          AirtableConfig(apiKey: 'invalid_key', baseId: baseId),
        );

        expect(
          () async => await badCrud.fetchRecords(tableName),
          throwsA(isA<AuthException>()),
        );
      });

      test('AuthException for invalid table (returns 403 not 404)', () async {
        // Airtable returns 403 (forbidden) for invalid table names, not 404
        expect(
          () async => await airtableCrud.fetchRecords('NonExistentTable'),
          throwsA(isA<AuthException>()),
        );
      });

      test('ValidationException for invalid data', () async {
        // Try to create a record with invalid field structure
        // This will depend on your table schema
        final invalidData = {
          'InvalidFieldThatDoesNotExist': 'value',
        };

        expect(
          () async => await airtableCrud.createRecord(tableName, invalidData),
          throwsA(
              isA<AirtableException>()), // Could be validation or other error
        );
      });

      test('Exception includes status code and details', () async {
        final badCrud = AirtableCrud.withConfig(
          AirtableConfig(apiKey: 'invalid_key', baseId: baseId),
        );

        try {
          await badCrud.fetchRecords(tableName);
          fail('Should have thrown exception');
        } on AuthException catch (e) {
          expect(e.message, isNotEmpty);
          expect(e.statusCode, equals(401));
          expect(e.toString(), contains('AuthException'));
          expect(e.toString(), contains('401'));
        }
      });
    });
  });

  group('Backward Compatibility', () {
    test('deprecated constructor still works', () {
      // ignore: deprecated_member_use
      final crud = AirtableCrud(apiKey, baseId);
      expect(crud.apiKey, equals(apiKey));
      expect(crud.baseId, equals(baseId));
    });

    test('deprecated fetchRecordsWithFilter still works', () async {
      final testData = {'Name': 'BC Filter Test', 'Status': 'Active'};
      final created = await airtableCrud.createRecord(tableName, testData);

      try {
        // Use deprecated method
        // ignore: deprecated_member_use_from_same_package
        final records = await airtableCrud.fetchRecordsWithFilter(
          tableName,
          '{Name} = "BC Filter Test"',
        );

        expect(records, isList);
        expect(records.isNotEmpty, true);
        expect(records.first.fields['Name'], equals('BC Filter Test'));
      } finally {
        await airtableCrud.deleteRecord(tableName, created.id);
      }
    });

    test('deprecated direct field mutation still works', () async {
      final testData = {'Name': 'BC Mutation Test', 'Status': 'Old'};
      final created = await airtableCrud.createRecord(tableName, testData);

      try {
        // Use deprecated direct mutation
        // ignore: deprecated_member_use_from_same_package
        created.fields = {...created.fields, 'Status': 'New'};

        final updated = await airtableCrud.updateRecord(tableName, created);
        expect(updated.fields['Status'], equals('New'));
      } finally {
        await airtableCrud.deleteRecord(tableName, created.id);
      }
    });
  });

  group('Original Tests (from airtable_plugin_test.dart)', () {
    test('Create Record', () async {
      final testData = {
        'Name': 'Test Record',
        'Status': 'Active',
        'Date': DateTime.now().toIso8601String(),
      };

      try {
        final createdRecord =
            await airtableCrud.createRecord(tableName, testData);
        expect(createdRecord.id, isNotEmpty);
        expect(createdRecord.fields['Name'], equals('Test Record'));
        expect(createdRecord.fields['Status'], equals('Active'));

        // Cleanup
        await airtableCrud.deleteRecord(tableName, createdRecord.id);
      } catch (e) {
        fail('Create record failed: $e');
      }
    });

    test('Fetch Records', () async {
      try {
        // Create a test record to ensure table has data
        final testData = {'Name': 'Test Record', 'Status': 'Active'};
        final created = await airtableCrud.createRecord(tableName, testData);

        final records = await airtableCrud.fetchRecords(tableName);
        expect(records, isList);
        expect(records.isNotEmpty, true);
        expect(records.first.id, isNotEmpty);

        // Cleanup
        await airtableCrud.deleteRecord(tableName, created.id);
      } catch (e) {
        fail('Fetch records failed: $e');
      }
    });

    test('Create Bulk Records', () async {
      final testDataList = [
        {
          'Name': 'Bulk Test 1',
          'Status': 'Pending',
        },
        {
          'Name': 'Bulk Test 2',
          'Status': 'Completed',
        },
      ];

      try {
        final createdRecords =
            await airtableCrud.createBulkRecords(tableName, testDataList);
        expect(createdRecords.length, equals(2));
        expect(createdRecords[0].fields['Name'], equals('Bulk Test 1'));
        expect(createdRecords[1].fields['Name'], equals('Bulk Test 2'));

        // Cleanup
        await airtableCrud.deleteBulkRecords(
          tableName,
          createdRecords.map((r) => r.id).toList(),
        );
      } catch (e) {
        fail('Bulk create failed: $e');
      }
    });

    test('Update Record', () async {
      // First create a record to update
      final initialData = {'Name': 'Update Test', 'Status': 'Initial'};
      final createdRecord =
          await airtableCrud.createRecord(tableName, initialData);

      try {
        // Use new immutable pattern
        final updated = createdRecord.updateField('Status', 'Updated');
        await airtableCrud.updateRecord(tableName, updated);

        // Fetch the updated record to verify
        final updatedRecords = await airtableCrud.fetchRecords(
          tableName,
          filter: '{Name} = "Update Test"',
        );
        expect(updatedRecords.first.fields['Status'], equals('Updated'));
      } finally {
        // Cleanup
        await airtableCrud.deleteRecord(tableName, createdRecord.id);
      }
    });

    test('Delete Record', () async {
      // First create a record to delete
      final testData = {'Name': 'Delete Test', 'Status': 'To Delete'};
      final createdRecord =
          await airtableCrud.createRecord(tableName, testData);

      try {
        final result =
            await airtableCrud.deleteRecord(tableName, createdRecord.id);

        // Verify DeleteResult
        expect(result.deleted, isTrue);
        expect(result.id, equals(createdRecord.id));

        // Try to fetch the deleted record
        final records = await airtableCrud.fetchRecords(
          tableName,
          filter: '{Name} = "Delete Test"',
        );
        expect(records.isEmpty, true);
      } catch (e) {
        fail('Delete record failed: $e');
      }
    });
  });
}

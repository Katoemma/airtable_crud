import 'package:airtable_crud/airtable_plugin.dart';
import 'package:test/test.dart';

void main() {
  const apiKey =
      'YOUR_AIRTABLE_API_KEY'; // Replace with your actual API key to run tests
  const baseId = 'YOUR_BASE_ID'; // Replace with your actual Base ID
  const tableName = 'crudTest';

  late AirtableCrud airtableCrud;

  // Setup that runs before all tests
  setUp(() {
    airtableCrud = AirtableCrud(apiKey, baseId);
  });

  group('AirtableCrud Tests', () {
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
      } catch (e) {
        fail('Create record failed: $e');
      }
    });

    test('Fetch Records', () async {
      try {
        final records = await airtableCrud.fetchRecords(tableName);
        expect(records, isList);
        expect(records.isNotEmpty, true);
        expect(records.first.id, isNotEmpty);
      } catch (e) {
        fail('Fetch records failed: $e');
      }
    });

    test('Fetch Records with Filter', () async {
      try {
        final records = await airtableCrud.fetchRecordsWithFilter(
          tableName,
          '{Name} = "Test Record"',
        );
        expect(records, isList);
        expect(records.isNotEmpty, true);
        expect(records.first.fields['Name'], equals('Test Record'));
      } catch (e) {
        fail('Fetch records with filter failed: $e');
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
        createdRecord.fields['Status'] = 'Updated';
        await airtableCrud.updateRecord(tableName, createdRecord);

        // Fetch the updated record to verify
        final updatedRecords = await airtableCrud.fetchRecordsWithFilter(
          tableName,
          '{Name} = "Update Test"',
        );
        expect(updatedRecords.first.fields['Status'], equals('Updated'));
      } catch (e) {
        fail('Update record failed: $e');
      }
    });

    test('Delete Record', () async {
      // First create a record to delete
      final testData = {'Name': 'Delete Test', 'Status': 'To Delete'};
      final createdRecord =
          await airtableCrud.createRecord(tableName, testData);

      try {
        await airtableCrud.deleteRecord(tableName, createdRecord.id);

        // Try to fetch the deleted record
        final records = await airtableCrud.fetchRecordsWithFilter(
          tableName,
          '{Name} = "Delete Test"',
        );
        expect(records.isEmpty, true);
      } catch (e) {
        fail('Delete record failed: $e');
      }
    });

    test('Error Handling - Invalid API Key', () async {
      final badAirtableCrud = AirtableCrud('invalid_key', baseId);

      expect(
        () async => await badAirtableCrud.fetchRecords(tableName),
        throwsA(isA<AirtableException>()),
      );
    });
  });
}

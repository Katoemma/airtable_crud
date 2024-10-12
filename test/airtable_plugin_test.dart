import 'package:airtable_plugin/airtable_plugin.dart';
import 'package:test/test.dart';
import 'package:airtable_plugin/src/models/airtable_record.dart';

void main() {
  const apiKey = 'Your apikey'; // Replace with your Airtable API key
  const baseId = 'your base id'; // Replace with your Airtable Base ID
  const tableName = 'users'; // Replace with your Airtable table name

  late AirtableCrud airtableService;

  setUp(() {
    airtableService = AirtableCrud(apiKey, baseId);
  });

  group('AirtableRecord', () {
    test('fromJson should create an instance from JSON', () {
      final json = {
        'id': 'recQy8wyFvbkhW2pB',
        'fields': {
          'id': 1,
          'firstname': 'John',
          'lastname': 'Smith',
          'password': 'p@ssw3rd',
          'username': 'jsmith',
        },
      };

      final record = AirtableRecord.fromJson(json);

      expect(record.id, 'recQy8wyFvbkhW2pB');
      expect(record.fields['id'], 1);
      expect(record.fields['firstname'], 'John');
      expect(record.fields['lastname'], 'Smith');
      expect(record.fields['password'], 'p@ssw3rd');
      expect(record.fields['username'], 'jsmith');
    });

    test('toJson should return a JSON map', () {
      final record = AirtableRecord(
        id: 'recQy8wyFvbkhW2pB',
        fields: {
          'id': 1,
          'firstname': 'John',
          'lastname': 'Smith',
          'password': 'p@ssw3rd',
          'username': 'jsmith',
        },
      );

      final json = record.toJson();

      expect(json['id'], 'recQy8wyFvbkhW2pB');
      expect(json['fields']['id'], 1);
      expect(json['fields']['firstname'], 'John');
      expect(json['fields']['lastname'], 'Smith');
      expect(json['fields']['password'], 'p@ssw3rd');
      expect(json['fields']['username'], 'jsmith');
    });

    test('fromJson should handle empty fields', () {
      final json = {
        'id': 'recQy8wyFvbkhW2pB',
        'fields': {},
      };

      final record = AirtableRecord.fromJson(json);

      expect(record.id, 'recQy8wyFvbkhW2pB');
      expect(record.fields.isEmpty, isTrue);
    });
  });

  group('AirtableService', () {
    test('fetchRecords should fetch records successfully', () async {
      final records = await airtableService.fetchRecords(tableName);
      records.forEach((record) {
        print(record.fields);
      });

      // Adjust the expected behavior according to your Airtable data.
      expect(records.isNotEmpty, isTrue);
      expect(records.first.fields['firstname'], isNotEmpty);
    });

    test('fetchRecords should throw an exception when fetching fails',
        () async {
      // Use an invalid table name to trigger an error
      expect(
        () async => await airtableService.fetchRecords('INVALID_TABLE_NAME'),
        throwsException,
      );
    });

    test('AirtableService createRecord should create a new record successfully',
        () async {
      final record = {
        'firstname': 'Test',
        'lastname': 'User',
        'password': 'testpassword',
        'username': 'testuser'
      };

      final createdRecord =
          await airtableService.createRecord(tableName, record);

      // Expect that a valid ID was assigned to the created record
      expect(createdRecord.id.isNotEmpty, isTrue);
      expect(createdRecord.fields['firstname'], 'Test');
    });

    test(
        'AirtableService updateRecord should update an existing record successfully',
        () async {
      final record = AirtableRecord(
        id: 'recs2coL10mDFyuhQ', // Replace with an existing Airtable record ID
        fields: {
          'firstname': 'Updateddated',
          'lastname': 'User',
        },
      );

      await airtableService.updateRecord(tableName, record);

      // Verify by fetching the record and checking the updated fields
      final updatedRecords = await airtableService.fetchRecords(tableName);
      final updatedRecord =
          updatedRecords.firstWhere((r) => r.id == 'recs2coL10mDFyuhQ');

      expect(updatedRecord.fields['firstname'], 'Updated');
    });

    test('fetchRecordsWithFilter should fetch records with filter successfully',
        () async {
      // Replace this filter formula based on your Airtable table structure
      String filterByFormula = "AND({lastname} = 'User')";

      final filteredRecords = await airtableService.fetchRecordsWithFilter(
          tableName, filterByFormula);

      // Adjust the expected behavior according to your Airtable data
      expect(filteredRecords.isNotEmpty, isTrue);
      filteredRecords.forEach((record) {
        print(record.fields);
        expect(record.fields['lastname'], 'User');
      });
    });

    test('deleteRecord should delete a record successfully', () async {
      // Fetch records to delete one
      final records = await airtableService.fetchRecords(tableName);
      final recordToDelete = records.first;

      await airtableService.deleteRecord(tableName, recordToDelete.id);

      // Verify the record was deleted
      final remainingRecords = await airtableService.fetchRecords(tableName);
      final recordExists =
          remainingRecords.any((r) => r.id == recordToDelete.id);

      expect(recordExists, isFalse);
    });
  });
}

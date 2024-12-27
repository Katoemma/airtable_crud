import 'package:airtable_crud/airtable_plugin.dart';
import 'package:test/test.dart';

void main() {
  const apiKey =
      'patqvri6S9L4ep6ST.45263e0976debe3ad555b606809906fe584eda05f66921cda8524658206d8ca0';
  const baseId = 'appFkCaX7WZiYANVy';
  const tableName = 'crudTest';

  late AirtableCrud airtableCrud;
  late AirtableQueryCrud queryBuilder;

  setUp(() {
    airtableCrud = AirtableCrud(apiKey, baseId);
    queryBuilder = AirtableQueryCrud();
  });

  group('AirtableQueryCrud with Airtable API', () {
    test('fetchRecordsWithQueryBuilder should return filtered records',
        () async {
      // Build a query to filter records with a specific firstname and lastname
      queryBuilder.where({'firstname': 'Test'}).and({'lastname': 'User'});

      // Print the generated formula
      final formula = queryBuilder.build();
      print('Generated Formula: $formula');

      // Fetch records using the query
      try {
        final records = await airtableCrud.fetchRecordsWithQueryBuilder(
          tableName,
          queryBuilder,
        );

        // Print fetched records
        for (final record in records) {
          print('Fetched Record: ${record.fields}');
        }

        // Validate the results
        expect(records.isNotEmpty, isTrue);
        for (final record in records) {
          expect(record.fields['firstname'], 'Test');
        }
      } catch (e) {
        print('Error fetching records: $e');
        rethrow;
      }
    });

    test('fetchRecordsWithQueryBuilder with OR condition', () async {
      // Build a query with an OR condition
      queryBuilder.where({'firstname': 'Bulk'}).or({'lastname': 'User1'});

      // Print the generated formula
      final formula = queryBuilder.build();
      print('Generated Formula: $formula');

      // Fetch records using the query
      try {
        final records = await airtableCrud.fetchRecordsWithQueryBuilder(
          tableName,
          queryBuilder,
        );

        // Print fetched records
        for (final record in records) {
          print('Fetched Record: ${record.fields}');
        }

        // Validate the results
        expect(records.isNotEmpty, isTrue);
        for (final record in records) {
          expect(
            record.fields['firstname'] == 'Bulk' ||
                record.fields['lastname'] == 'User1',
            isTrue,
          );
        }
      } catch (e) {
        print('Error fetching records: $e');
        rethrow;
      }
    });

    test('fetchRecordsWithQueryBuilder with complex conditions', () async {
      // Build a complex query
      queryBuilder.where({'firstname': 'Bulk'}).and({'lastname': 'User2'}).or(
          {'username': 'testuser'});

      // Print the generated formula
      final formula = queryBuilder.build();
      print('Generated Formula: $formula');

      // Fetch records using the query
      try {
        final records = await airtableCrud.fetchRecordsWithQueryBuilder(
          tableName,
          queryBuilder,
        );

        // Print fetched records
        for (final record in records) {
          print('Fetched Record: ${record.fields}');
        }

        // Validate the results
        expect(records.isNotEmpty, isTrue);
        for (final record in records) {
          final isBulkUser2 = record.fields['firstname'] == 'Bulk' &&
              record.fields['lastname'] == 'User2';
          final isTestUser = record.fields['username'] == 'testuser';

          expect(isBulkUser2 || isTestUser, isTrue);
        }
      } catch (e) {
        print('Error fetching records: $e');
        rethrow;
      }
    });

    test('and() should combine conditions with AND', () {
      queryBuilder.where({'firstname': 'Test'}).and({'lastname': 'User'});

      final formula = queryBuilder.build();
      expect(formula, "AND({firstname} = 'Test', {lastname} = 'User')");
    });

    test('or() should combine conditions with OR', () {
      queryBuilder.where({'firstname': 'Bulk'}).or({'lastname': 'User1'});

      final formula = queryBuilder.build();
      expect(formula, "OR({firstname} = 'Bulk', {lastname} = 'User1')");
    });

    test('and() and or() should nest conditions correctly', () {
      queryBuilder.where({'firstname': 'Bulk'}).and({'lastname': 'User2'}).or(
          {'username': 'testuser'});

      final formula = queryBuilder.build();
      expect(formula,
          "OR(AND({firstname} = 'Bulk', {lastname} = 'User2'), {username} = 'testuser')");
    });

    test('fetch all records without filters', () async {
      // Build a broad query without specific filters
      queryBuilder.where({'firstname': 'Bulk'});

      // Print the generated formula
      final formula = queryBuilder.build();
      print('Generated Formula: $formula');

      // Fetch records using the query
      try {
        final records = await airtableCrud.fetchRecordsWithQueryBuilder(
          tableName,
          queryBuilder,
        );

        // Print fetched records
        for (final record in records) {
          print('Fetched Record: ${record.fields}');
        }

        // Validate the results
        expect(records.isNotEmpty, isTrue);
      } catch (e) {
        print('Error fetching records: $e');
        rethrow;
      }
    });
  });
}

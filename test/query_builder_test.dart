import 'package:test/test.dart';
import 'package:airtable_crud/src/query_builder.dart';

void main() {
  group('AirtableQueryCrud', () {
    late AirtableQueryCrud queryBuilder;

    setUp(() {
      queryBuilder = AirtableQueryCrud();
    });

    test('build() should throw an exception if no conditions are added', () {
      expect(() => queryBuilder.build(), throwsException);
    });

    test('where() should add a single condition', () {
      queryBuilder.where({'firstname': 'Test'});

      final formula = queryBuilder.build();
      expect(formula, "{firstname} = 'Test'");
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

    test('reset() should clear all conditions', () {
      queryBuilder.where({'firstname': 'Test'});
      queryBuilder.reset();

      expect(() => queryBuilder.build(), throwsException);
    });

    test('should escape single quotes in values', () {
      queryBuilder.where({'username': "test'user"});

      final formula = queryBuilder.build();
      expect(formula, "{username} = 'test\\'user'");
    });

    test('complex query should match simulated response', () {
      queryBuilder.where({'firstname': 'Test'}).or({'lastname': 'User1'}).and(
          {'username': 'testuser'});

      final formula = queryBuilder.build();

      // Simulating the response from the Airtable API
      final response = {
        "records": [
          {
            "id": "recX1tiIX4rT4bJzZ",
            "createdTime": "2024-12-27T13:04:51.000Z",
            "fields": {
              "lastname": "User",
              "firstname": "Test",
              "password": "testpassword",
              "username": "testuser"
            }
          },
          {
            "id": "recQVnGrQEHQBV34p",
            "createdTime": "2024-12-27T13:05:00.000Z",
            "fields": {
              "lastname": "User1",
              "firstname": "Bulk",
              "password": "password1",
              "username": "bulkuser1"
            }
          },
          {
            "id": "rec2iZdSXqwYgPErf",
            "createdTime": "2024-12-27T13:05:00.000Z",
            "fields": {
              "lastname": "User2",
              "firstname": "Bulk",
              "password": "password2",
              "username": "bulkuser2"
            }
          }
        ],
        "offset": "itrNo2WEAGmkAdYxS/rec2iZdSXqwYgPErf"
      };

      final matchingRecords =
          (response['records'] as List<dynamic>?)?.where((record) {
        final fields = record['fields'] as Map<String, dynamic>;
        return (fields['firstname'] == 'Test' ||
                fields['lastname'] == 'User1') &&
            fields['username'] == 'testuser';
      }).toList();

      expect(matchingRecords!.length, 1);
      expect(matchingRecords.first['fields']['firstname'], 'Test');
    });
  });
}

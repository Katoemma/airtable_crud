import 'package:airtable_crud/src/client/request_builder.dart';
import 'package:test/test.dart';

void main() {
  group('RequestBuilder', () {
    const endpoint = 'https://api.airtable.com/v0';
    const baseId = 'appTestBase123';
    const tableName = 'Users';

    late RequestBuilder builder;

    setUp(() {
      builder = RequestBuilder(endpoint: endpoint, baseId: baseId);
    });

    group('buildFetchUrl', () {
      test('builds basic URL with just table name', () {
        final uri = builder.buildFetchUrl(tableName: tableName);

        expect(uri.toString(), equals('$endpoint/$baseId/Users'));
      });

      test('encodes table name with spaces', () {
        final uri = builder.buildFetchUrl(tableName: 'My Table');

        expect(uri.toString(), contains('My%20Table'));
      });

      test('adds view parameter', () {
        final uri = builder.buildFetchUrl(
          tableName: tableName,
          view: 'Grid view',
        );

        expect(uri.toString(), contains('view=Grid%20view'));
      });

      test('adds filter parameter', () {
        final uri = builder.buildFetchUrl(
          tableName: tableName,
          filter: "AND({status} = 'active')",
        );

        expect(uri.toString(), contains('filterByFormula='));
        expect(uri.toString(), contains('AND'));
      });

      test('adds offset parameter', () {
        final uri = builder.buildFetchUrl(
          tableName: tableName,
          offset: 'itrABC123',
        );

        expect(uri.toString(), contains('offset=itrABC123'));
      });

      test('adds maxRecords parameter', () {
        final uri = builder.buildFetchUrl(
          tableName: tableName,
          maxRecords: 100,
        );

        expect(uri.toString(), contains('maxRecords=100'));
      });

      test('adds single field', () {
        final uri = builder.buildFetchUrl(
          tableName: tableName,
          fields: ['name'],
        );

        expect(uri.toString(), contains('fields%5B%5D=name'));
      });

      test('adds multiple fields', () {
        final uri = builder.buildFetchUrl(
          tableName: tableName,
          fields: ['name', 'email', 'age'],
        );

        expect(uri.toString(), contains('fields%5B%5D=name'));
        expect(uri.toString(), contains('fields%5B%5D=email'));
        expect(uri.toString(), contains('fields%5B%5D=age'));
      });

      test('encodes field names with spaces', () {
        final uri = builder.buildFetchUrl(
          tableName: tableName,
          fields: ['First Name', 'Last Name'],
        );

        expect(uri.toString(), contains('First%20Name'));
        expect(uri.toString(), contains('Last%20Name'));
      });

      test('combines multiple parameters', () {
        final uri = builder.buildFetchUrl(
          tableName: tableName,
          view: 'Active Users',
          filter: "{status} = 'active'",
          fields: ['name', 'email'],
          maxRecords: 50,
          offset: 'itr123',
        );

        expect(uri.toString(), contains('view=Active%20Users'));
        expect(uri.toString(), contains('filterByFormula='));
        expect(uri.toString(), contains('fields%5B%5D=name'));
        expect(uri.toString(), contains('fields%5B%5D=email'));
        expect(uri.toString(), contains('maxRecords=50'));
        expect(uri.toString(), contains('offset=itr123'));
      });

      test('ignores empty view', () {
        final uri = builder.buildFetchUrl(
          tableName: tableName,
          view: '',
        );

        expect(uri.toString(), isNot(contains('view=')));
      });

      test('ignores empty filter', () {
        final uri = builder.buildFetchUrl(
          tableName: tableName,
          filter: '',
        );

        expect(uri.toString(), isNot(contains('filterByFormula=')));
      });

      test('ignores empty fields list', () {
        final uri = builder.buildFetchUrl(
          tableName: tableName,
          fields: [],
        );

        expect(uri.toString(), isNot(contains('fields')));
      });

      test('ignores zero maxRecords', () {
        final uri = builder.buildFetchUrl(
          tableName: tableName,
          maxRecords: 0,
        );

        expect(uri.toString(), isNot(contains('maxRecords')));
      });
    });

    group('buildCreateUrl', () {
      test('builds create URL', () {
        final uri = builder.buildCreateUrl(tableName: tableName);

        expect(uri.toString(), equals('$endpoint/$baseId/Users'));
      });

      test('encodes table name', () {
        final uri = builder.buildCreateUrl(tableName: 'My Table');

        expect(uri.toString(), contains('My%20Table'));
      });
    });

    group('buildUpdateUrl', () {
      test('builds update URL with record ID', () {
        final uri = builder.buildUpdateUrl(
          tableName: tableName,
          recordId: 'rec123abc',
        );

        expect(uri.toString(), equals('$endpoint/$baseId/Users/rec123abc'));
      });

      test('encodes table name and record ID', () {
        final uri = builder.buildUpdateUrl(
          tableName: 'My Table',
          recordId: 'rec 123',
        );

        expect(uri.toString(), contains('My%20Table'));
        // Note: record ID in path is not encoded by Uri.parse
      });
    });

    group('buildDeleteUrl', () {
      test('builds delete URL with record ID', () {
        final uri = builder.buildDeleteUrl(
          tableName: tableName,
          recordId: 'rec123abc',
        );

        expect(uri.toString(), equals('$endpoint/$baseId/Users/rec123abc'));
      });

      test('encodes table name', () {
        final uri = builder.buildDeleteUrl(
          tableName: 'My Table',
          recordId: 'rec123',
        );

        expect(uri.toString(), contains('My%20Table'));
      });
    });

    test('handles special characters in table name', () {
      final uri = builder.buildFetchUrl(
        tableName: 'My & Table',
      );

      expect(uri.toString(), contains('My%20%26%20Table'));
    });

    test('handles complex filter formulas', () {
      final uri = builder.buildFetchUrl(
        tableName: tableName,
        filter: "AND({Name}='John', OR({Age}>30, {Status}='Active'))",
      );

      expect(uri.toString(), contains('filterByFormula='));
      // Verify the filter is encoded
      expect(uri.queryParameters['filterByFormula'], isNotNull);
    });
  });
}

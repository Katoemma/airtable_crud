# Airtable CRUD Flutter Package

[![Pub Version](https://img.shields.io/pub/v/airtable_crud.svg)](https://pub.dev/packages/airtable_crud)

The Airtable CRUD Flutter Package is a robust solution for integrating Airtable's API with your Flutter applications. It enables developers to perform essential CRUD operations and filter records seamlessly.

## ✨ What's New in v1.3.0

- 🎯 **Unified API**: Single `fetchRecords()` method for all fetch operations
- 🛡️ **Better Error Handling**: Specific exception types (Auth, Network, RateLimit, etc.)
- ⚙️ **Advanced Configuration**: Configurable timeouts, retries, and logging
- 🔄 **Immutable Updates**: New `copyWith()` and `updateField()` methods
- 📦 **New Bulk Operations**: Bulk update and delete support
- 🏗️ **Improved Architecture**: Better organized, more testable code
- 📝 **Enhanced Return Values**: Operations now return more useful information
- ✅ **100% Backward Compatible**: All existing code still works!

[See full changelog](CHANGELOG.md) | [Migration guide](MIGRATION.md)

## Features

- **Fetch Records**: Retrieve all records with optional filtering, field selection, and pagination
- **Create Records**: Add single or multiple records efficiently in batches
- **Update Records**: Modify existing records with immutable patterns or bulk operations
- **Delete Records**: Remove single or multiple records with detailed results
- **Advanced Error Handling**: Catch specific error types for better error recovery
- **Retry Logic**: Automatic retry with exponential backoff
- **Configuration**: Customize timeouts, retries, logging, and more
- **Type Safety**: Immutable models and type-safe field access 

## Getting Started

### Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  airtable_crud: latest
```

Then run `flutter pub get` to install the package.

### Usage

1. **Import the package**:

   ```dart
   // Recommended (v1.3.0+)
   import 'package:airtable_crud/airtable_crud.dart';
   
   // ⚠️ Deprecated (still works but will be removed in v2.0.0)
   // import 'package:airtable_crud/airtable_plugin.dart';
   ```

2. **Initialize the Airtable CRUD**:

   ```dart
   // Simple initialization
   final airtableCrud = AirtableCrud('YOUR_API_KEY', 'YOUR_BASE_ID');
   
   // Advanced initialization (recommended in v1.3.0+)
   final config = AirtableConfig(
     apiKey: 'YOUR_API_KEY',
     baseId: 'YOUR_BASE_ID',
     timeout: Duration(seconds: 60),
     maxRetries: 5,
     enableLogging: true, // Helpful for debugging
   );
   final airtableCrud = AirtableCrud.withConfig(config);
   ```

3. **Fetch Records**:

   ```dart
   // Fetch all records with optional pagination and view selection
   final records = await airtableCrud.fetchRecords('your_table_name', view: 'your_view_name',fields:['field_1','field_2','field 3']);
   ```

   **Explanation**:

   - **Purpose**: Retrieves all records from a specified table in your Airtable base.
   - **Parameters**:
     - `your_table_name`: The name of the table you want to fetch records from.
     - `view` (optional): The view within the table to fetch records from. Defaults to `'Grid view'`.
     - `fields`(optional): The fields within the table to be included in the response.
   - **Usage**: Use this method when you need to retrieve all records, possibly with a specific view that may have filters or sorting applied and if you want to fetch only specific fields.
   - **Example**:

     ```dart
     final records = await airtableCrud.fetchRecords('Contacts', view: 'All Contacts',field:['firstName','lastName', 'Phone', 'Email']);
     ```

4. **Fetch Records with Filter**:

   ```dart
   // Fetch records with a filter
   final filteredRecords = await airtableCrud.fetchRecordsWithFilter(
     'your_table_name',
     "AND({lastname} = 'User')",
     view: 'your_view_name',
   );
   ```

   **Explanation**:

   - **Purpose**: Retrieves records from a table that match specific criteria using Airtable's `filterByFormula`.
   - **Parameters**:
     - `your_table_name`: The name of the table to query.
     - `filterByFormula`: An Airtable formula string that defines the filter criteria.
     - `view` (optional): The view to fetch records from. Defaults to `'Grid view'`.
     - `fields`(optional): The fields within the table to be included in the response.
   - **Usage**: Use this method to fetch records that meet certain conditions without retrieving the entire dataset.
   - **Example**:

     ```dart
     final filteredRecords = await airtableCrud.fetchRecordsWithFilter(
       'Contacts',
       "AND({lastname} = 'Smith', {status} = 'Active')",
       view: 'Active Contacts',
       fields:['firstName','Email','Contact']
     );
     ```

   - **Note**: The `filterByFormula` uses Airtable's formula syntax. You can combine conditions using `AND`, `OR`, and other functions.

5. **Create a Record**:

   ```dart
   final newRecord = {'firstname': 'John', 'lastname': 'Doe'};
   final createdRecord = await airtableCrud.createRecord('your_table_name', newRecord);
   ```

   **Explanation**:

   - **Purpose**: Adds a new record to the specified table in your Airtable base.
   - **Parameters**:
     - `your_table_name`: The name of the table where the new record will be added.
     - `newRecord`: A `Map<String, dynamic>` containing field names and their corresponding values.
   - **Usage**: Use this method to insert new data into your Airtable base.
   - **Example**:

     ```dart
     final newRecord = {
       'firstname': 'Jane',
       'lastname': 'Doe',
       'email': 'jane.doe@example.com',
     };
     final createdRecord = await airtableCrud.createRecord('Contacts', newRecord);
     ```

   - **Note**: Ensure that the field names in your map match the field names defined in your Airtable table.

6. **Bulk Create Records**:

   ```dart
   // Prepare a list of records to be created
   List<Map<String, dynamic>> dataList = [
     {'firstname': 'Alice', 'lastname': 'Smith'},
     {'firstname': 'Bob', 'lastname': 'Johnson'},
     // Add more records as needed
   ];

   // Create multiple records in bulk
   final createdRecords = await airtableCrud.createBulkRecords('your_table_name', dataList);
   ```

   **Explanation**:

   - **Purpose**: Adds multiple new records to the specified table efficiently by batching the requests.
   - **Parameters**:
     - `your_table_name`: The name of the table where the new records will be added.
     - `dataList`: A `List<Map<String, dynamic>>` containing multiple records to create.
   - **Usage**: Use this method to insert multiple records at once, which is more efficient than creating them individually.
   - **Example**:

     ```dart
     final dataList = [
       {
         'firstname': 'Charlie',
         'lastname': 'Brown',
         'email': 'charlie.brown@example.com',
       },
       {
         'firstname': 'Diana',
         'lastname': 'Prince',
         'email': 'diana.prince@example.com',
       },
       // Add more records as needed
     ];
     final createdRecords = await airtableCrud.createBulkRecords('Contacts', dataList);
     ```

   - **Note**:
     - The method automatically handles batching, respecting Airtable's limit of 10 records per request.
     - Ensure that the field names in your maps match the field names defined in your Airtable table.

7. **Update a Record**:

   ```dart
   createdRecord.fields['lastname'] = 'Smith'; // Update the lastname field
   await airtableCrud.updateRecord('your_table_name', createdRecord);
   ```

   **Explanation**:

   - **Purpose**: Updates an existing record in the specified table.
   - **Parameters**:
     - `your_table_name`: The name of the table containing the record to update.
     - `createdRecord`: An instance of `AirtableRecord` with updated field values.
   - **Usage**: Use this method when you need to modify data of an existing record.
   - **Example**:

     ```dart
     // Assume you have retrieved a record and stored it in 'recordToUpdate'
     recordToUpdate.fields['email'] = 'new.email@example.com';
     await airtableCrud.updateRecord('Contacts', recordToUpdate);
     ```

   - **Note**: You must include the record's ID in the `AirtableRecord` instance to identify which record to update.

8. **Delete a Record**:

   ```dart
   await airtableCrud.deleteRecord('your_table_name', createdRecord.id);
   ```

   **Explanation**:

   - **Purpose**: Deletes a record from the specified table in your Airtable base.
   - **Parameters**:
     - `your_table_name`: The name of the table containing the record to delete.
     - `createdRecord.id`: The unique ID of the record to delete.
   - **Usage**: Use this method to remove records that are no longer needed.
   - **Example**:

     ```dart
     await airtableCrud.deleteRecord('Contacts', 'rec1234567890ABC');
     ```

   - **Warning**: Deleting a record is irreversible. Ensure that you have the correct record ID before performing this operation.

## Error Handling

### v1.3.0+ Recommended Approach

The package provides specific exception types for different error scenarios, allowing for more granular error handling:

```dart
try {
  final records = await airtableCrud.fetchRecords('Users');
} on AuthException catch (e) {
  // Handle authentication/authorization errors (401/403)
  print('Auth error: ${e.message}');
  print('Check your API key or permissions');
} on RateLimitException catch (e) {
  // Handle rate limiting (429)
  print('Rate limited. Retry after: ${e.retryAfter}');
  await Future.delayed(e.retryAfter ?? Duration(seconds: 5));
  // Retry the operation
} on ValidationException catch (e) {
  // Handle validation errors (422)
  print('Invalid data: ${e.message}');
  print('Details: ${e.details}');
} on NotFoundException catch (e) {
  // Handle not found errors (404)
  print('Resource not found: ${e.message}');
} on NetworkException catch (e) {
  // Handle network/connection errors
  print('Network error: ${e.message}');
  // Maybe show offline message to user
} on AirtableException catch (e) {
  // Catch-all for any other Airtable errors
  print('Airtable error: ${e.message}');
  print('Status code: ${e.statusCode}');
}
```

### Legacy Approach (Still Works)

```dart
try {
  final records = await airtableCrud.fetchRecords('your_table_name');
} on AirtableException catch (e) {
  print('Error: ${e.message}');
  print('Details: ${e.details}');
}
```

**Benefits of Specific Exception Types:**
- Better error recovery strategies
- More informative user messages
- Easier debugging
- Conditional retry logic based on error type

---

## ⚠️ Deprecation Notices

Some features are deprecated in v1.3.0 and will be removed in v2.0.0:

| Deprecated | Use Instead | Removed In |
|------------|-------------|------------|
| `import 'package:airtable_crud/airtable_plugin.dart'` | `import 'package:airtable_crud/airtable_crud.dart'` | 2.0.0 |
| `fetchRecordsWithFilter(table, formula)` | `fetchRecords(table, filter: formula)` | 2.0.0 |
| `record.fields['key'] = value` | `record.copyWith(fields: {...})` or `record.updateField('key', value)` | 2.0.0 |
| `AirtableCrud(apiKey, baseId)` | `AirtableCrud.withConfig(config)` for advanced features | Basic constructor remains, but limited |

**All deprecated features still work in v1.3.0** - they just show warnings. You have 6-12 months to migrate before v2.0.0.

See [MIGRATION.md](MIGRATION.md) for detailed upgrade instructions.

---

## About the Author

<p align="left">
  <img src="https://i.imgur.com/HKJPtDU.jpg" alt="Profile Photo" style="object-fit:cover;border-radius:50%">
</p>

**Kato Emmanuel**

I'm the creator of the Airtable CRUD Flutter Plugin. Visit my [portfolio](https://katoemma.netlify.app/) to learn more about my work and other projects.


## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! If you have suggestions or improvements, please submit a pull request or open an issue.

## Acknowledgments

- This plugin leverages the Airtable API for data management.
- Thank you for using the Airtable CRUD Flutter Plugin! If you find this package useful, please consider giving it a star on [pub.dev](https://pub.dev/packages/airtable_crud).

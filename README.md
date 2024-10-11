# Airtable CRUD Flutter Plugin

[![Pub Version](https://img.shields.io/pub/v/airtable_plugin.svg)](https://pub.dev/packages/airtable_plugin)

The Airtable CRUD Flutter Plugin is a robust solution for integrating Airtable's API with your Flutter applications. It enables developers to perform essential CRUD operations and filter records seamlessly.

## Features

- **Fetch Records**: Retrieve all records from a specified table.
- **Fetch Records with Filter**: Use Airtable's `filterByFormula` to retrieve specific records based on criteria.
- **Create Records**: Easily add new records to your Airtable table.
- **Update Records**: Modify existing records effortlessly.
- **Delete Records**: Remove records from your Airtable table.
- **Pagination Support**: Fetch records with pagination options.
- **View Selection**: Option to select views when fetching records, with a default set to `Grid View`.

## Getting Started

### Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  airtable_plugin: ^1.0.0  # Replace with the latest version from pub.dev
```

### Usage

1. **Import the plugin**:

   ```dart
   import 'package:airtable_plugin/airtable_service.dart';
   import 'models/airtable_record.dart';
   ```

2. **Initialize the Airtable Service**:

   ```dart
   final airtableService = AirtableService('YOUR_AIRTABLE_API_KEY', 'YOUR_BASE_ID');
   ```

3. **Fetch Records**:

   ```dart
   // Fetch all records with optional pagination and view selection
   final records = await airtableService.fetchRecords('your_table_name', paginate: false, view: 'your_view_name');
   ```

4. **Fetch Records with Filter**:

   ```dart
   // Fetch records with a filter
   final filteredRecords = await airtableService.fetchRecordsWithFilter('your_table_name', "AND({lastname} = 'User')", paginate: false, view: 'your_view_name');
   ```

5. **Create a Record**:

   ```dart
   final newRecord = AirtableRecord(fields: {'firstname': 'John', 'lastname': 'Doe'});
   final createdRecord = await airtableService.createRecord('your_table_name', newRecord);
   ```

6. **Update a Record**:

   ```dart
   createdRecord.fields['lastname'] = 'Smith'; // Update the lastname field
   await airtableService.updateRecord('your_table_name', createdRecord);
   ```

7. **Delete a Record**:

   ```dart
   await airtableService.deleteRecord('your_table_name', createdRecord.id);
   ```

## Error Handling

The plugin throws `AirtableException` for error cases, providing details about the error message. Handle exceptions gracefully in your application.

```dart
try {
  final records = await airtableService.fetchRecords('your_table_name');
} on AirtableException catch (e) {
  print('Error: ${e.message}');
  print('Details: ${e.details}');
}
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! If you have suggestions or improvements, please submit a pull request or open an issue.

## Acknowledgments

- This plugin leverages the Airtable API for data management.
- Thank you for using the Airtable CRUD Flutter Plugin! If you find this package useful, please consider giving it a star on [pub.dev](https://pub.dev/packages/airtable_plugin).

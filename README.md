# Airtable CRUD Flutter Plugin

[![Pub Version](https://img.shields.io/pub/v/airtable_crud.svg)](https://pub.dev/packages/airtable_crud)

The Airtable CRUD Flutter Plugin is a robust solution for integrating Airtable's API with your Flutter applications. It enables developers to perform essential CRUD operations and filter records seamlessly.

## Features

- **Fetch Records**: Retrieve all records from a specified table.
- **Fetch Records with Filter**: Use Airtable's `filterByFormula` to retrieve specific records based on criteria.
- **Create Records**: Easily add new records to your Airtable table.
- **Bulk Create Records**: Create multiple records efficiently in batches.
- **Update Records**: Modify existing records effortlessly.
- **Delete Records**: Remove records from your Airtable table.
- **Pagination Support**: Fetch records with pagination options.
- **View Selection**: Option to select views when fetching records, with a default set to `Grid View`.

## Getting Started

### Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  airtable_crud: ^1.0.0  # Replace with the latest version from pub.dev
```

Then run `flutter pub get` to install the package.

### Usage

1. **Import the plugin**:

   ```dart
   import 'package:airtable_plugin/airtable_crud.dart';
   import 'package:airtable_plugin/models/airtable_record.dart';
   ```

2. **Initialize the Airtable CRUD**:

   ```dart
   final airtableCrud = AirtableCrud('YOUR_AIRTABLE_API_KEY', 'YOUR_BASE_ID');
   ```

3. **Fetch Records**:

   ```dart
   // Fetch all records with optional pagination and view selection
   final records = await airtableCrud.fetchRecords('your_table_name', view: 'your_view_name');
   ```

   **Explanation**:

   - **Purpose**: Retrieves all records from a specified table in your Airtable base.
   - **Parameters**:
     - `your_table_name`: The name of the table you want to fetch records from.
     - `view` (optional): The view within the table to fetch records from. Defaults to `'Grid view'`.
   - **Usage**: Use this method when you need to retrieve all records, possibly with a specific view that may have filters or sorting applied.
   - **Example**:

     ```dart
     final records = await airtableCrud.fetchRecords('Contacts', view: 'All Contacts');
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
   - **Usage**: Use this method to fetch records that meet certain conditions without retrieving the entire dataset.
   - **Example**:

     ```dart
     final filteredRecords = await airtableCrud.fetchRecordsWithFilter(
       'Contacts',
       "AND({lastname} = 'Smith', {status} = 'Active')",
       view: 'Active Contacts',
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

The plugin throws `AirtableException` for error cases, providing details about the error message. Handle exceptions gracefully in your application.

```dart
try {
  final records = await airtableCrud.fetchRecords('your_table_name');
} on AirtableException catch (e) {
  print('Error: ${e.message}');
  print('Details: ${e.details}');
}
```

**Explanation**:

- **Purpose**: To catch and handle errors that may occur during Airtable operations.
- **Usage**: Wrap your Airtable CRUD operations in a `try-catch` block to handle exceptions.
- **Example**:

  ```dart
  try {
    final newRecord = {'firstname': 'John'};
    final createdRecord = await airtableCrud.createRecord('Contacts', newRecord);
  } on AirtableException catch (e) {
    print('Failed to create record: ${e.message}');
    print('Error details: ${e.details}');
  }
  ```

- **Note**: The `AirtableException` provides a `message` and `details` to help you understand what went wrong.

## About the Author

<p align="left">
  <img src="https://katoemma.netlify.app/_nuxt/avatar.Q3ihwsGR.jpg" alt="kato emmanuel" width="50" height="50" style="border-radius: 50%;">
</p>

**Kato Emmanuel**

I'm the creator of the Airtable CRUD Flutter Plugin. Visit my [portfolio](https://katoemma.netlify.app/) to learn more about my work and other projects.

## Buy Me a Coffee ☕

If you find this plugin helpful and want to support further development, you can buy me a coffee! Your support is greatly appreciated. ☕💛

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/N4N314M0S8)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! If you have suggestions or improvements, please submit a pull request or open an issue.

## Acknowledgments

- This plugin leverages the Airtable API for data management.
- Thank you for using the Airtable CRUD Flutter Plugin! If you find this package useful, please consider giving it a star on [pub.dev](https://pub.dev/packages/airtable_crud).

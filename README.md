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

#### 1. **Import the package**

```dart
// ✅ New import (v1.3.0+)
import 'package:airtable_crud/airtable_crud.dart';

// ⚠️ Old import (deprecated, will be removed in v2.0.0)
// import 'package:airtable_crud/airtable_plugin.dart';
```

---

#### 2. **Initialize Airtable CRUD**

```dart
// ✅ Recommended: Advanced configuration
final config = AirtableConfig(
  apiKey: 'YOUR_API_KEY',
  baseId: 'YOUR_BASE_ID',
  timeout: Duration(seconds: 60),    // Custom timeout
  maxRetries: 5,                     // Retry failed requests
  enableLogging: true,               // Debug logging
  defaultView: 'Main View',          // Default view for fetches
);
final crud = AirtableCrud.withConfig(config);

// Simple initialization (still works)
final crud = AirtableCrud('YOUR_API_KEY', 'YOUR_BASE_ID');
```

---

#### 3. **Fetch Records** (Unified Method)

```dart
// ✅ Fetch all records
final allRecords = await crud.fetchRecords('Users');

// ✅ Fetch with filter
final activeUsers = await crud.fetchRecords(
  'Users',
  filter: "{Status} = 'Active'",
);

// ✅ Fetch specific fields only
final names = await crud.fetchRecords(
  'Users',
  fields: ['Name', 'Email'],
);

// ✅ Combine multiple options
final results = await crud.fetchRecords(
  'Users',
  filter: "AND({Status} = 'Active', {Age} > 18)",
  fields: ['Name', 'Email', 'Phone'],
  view: 'Active Users',
  maxRecords: 100,
);

// ⚠️ Old way (deprecated but still works)
// final filtered = await crud.fetchRecordsWithFilter('Users', "{Status} = 'Active'");
```

---

#### 4. **Create Records**

```dart
// Create a single record
final newUser = {
  'Name': 'John Doe',
  'Email': 'john@example.com',
  'Status': 'Active',
};
final created = await crud.createRecord('Users', newUser);
print('Created record with ID: ${created.id}');

// Access created record fields
print('Name: ${created.fields['Name']}');
```

---

#### 5. **Bulk Create Records**

```dart
// Create multiple records efficiently
final users = [
  {'Name': 'Alice Smith', 'Email': 'alice@example.com'},
  {'Name': 'Bob Johnson', 'Email': 'bob@example.com'},
  {'Name': 'Carol White', 'Email': 'carol@example.com'},
];

final createdRecords = await crud.createBulkRecords('Users', users);
print('Created ${createdRecords.length} records');

// Automatically handles batching (10 records per request)
```

---

#### 6. **Update Records** (Immutable Pattern ✨ New in v1.3.0)

```dart
// ✅ Recommended: Immutable update with copyWith
final user = await crud.fetchRecords('Users', filter: "{Email} = 'john@example.com'");
final record = user.first;

// Create updated version without mutating original
final updated = record.copyWith(
  fields: {...record.fields, 'Status': 'Inactive'},
);
final result = await crud.updateRecord('Users', updated);
print('Updated: ${result.fields['Status']}'); // Returns the updated record!

// ✅ Convenience helper for single field
final updated2 = record.updateField('Status', 'Active');
await crud.updateRecord('Users', updated2);

// ⚠️ Old way (deprecated but still works)
// record.fields['Status'] = 'Inactive';
// await crud.updateRecord('Users', record);
```

---

#### 7. **Bulk Update Records** (✨ New in v1.3.0)

```dart
// Update multiple records at once
final records = await crud.fetchRecords('Users', filter: "{Status} = 'Pending'");

final updatedRecords = records
    .map((r) => r.updateField('Status', 'Processed'))
    .toList();

final results = await crud.updateBulkRecords('Users', updatedRecords);
print('Updated ${results.length} records');
```

---

#### 8. **Delete Records** (Enhanced Return Value ✨ New in v1.3.0)

```dart
// Delete a single record - now returns metadata!
final result = await crud.deleteRecord('Users', 'rec123abc');
print('Deleted: ${result.id}');
print('Deleted at: ${result.deletedAt}');
print('Success: ${result.deleted}');
```

---

#### 9. **Bulk Delete Records** (✨ New in v1.3.0)

```dart
// Delete multiple records
final recordsToDelete = ['rec123', 'rec456', 'rec789'];
final results = await crud.deleteBulkRecords('Users', recordsToDelete);

for (final result in results) {
  print('Deleted ${result.id} at ${result.deletedAt}');
}
```

---

#### 10. **Type-Safe Field Access** (✨ New in v1.3.0)

```dart
final record = await crud.fetchRecords('Users').then((r) => r.first);

// Type-safe field access
final name = record.getField<String>('Name');        // Returns String?
final age = record.getField<int>('Age');             // Returns int?
final active = record.getField<bool>('IsActive');    // Returns bool?

// Check if field exists
if (record.hasField('Email')) {
  print('Email: ${record.fields['Email']}');
}

// Remove a field (returns new record)
final withoutEmail = record.removeField('Email');
```

---

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

**Kato Emmanuel**

I'm the creator of the Airtable CRUD Flutter Plugin. Visit my [portfolio](https://katoemma.netlify.app/) to learn more about my work and other projects.


## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! If you have suggestions or improvements, please submit a pull request or open an issue.

## Acknowledgments

- This plugin leverages the Airtable API for data management.
- Thank you for using the Airtable CRUD Flutter Plugin! If you find this package useful, please consider giving it a star on [pub.dev](https://pub.dev/packages/airtable_crud).

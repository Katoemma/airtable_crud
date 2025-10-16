/// Support for seamless integration with Airtable's API.
///
/// This library provides functionality for CRUD operations and
/// record filtering on Airtable tables.
///
/// ## Getting Started
///
/// Import this library in your Dart code:
///
/// ```dart
/// import 'package:airtable_crud/airtable_crud.dart';
/// ```
///
/// Then create an [AirtableCrud] instance:
///
/// ```dart
/// // Simple usage
/// final crud = AirtableCrud('YOUR_API_KEY', 'YOUR_BASE_ID');
///
/// // With configuration (recommended in v1.3.0+)
/// final config = AirtableConfig(
///   apiKey: 'YOUR_API_KEY',
///   baseId: 'YOUR_BASE_ID',
///   timeout: Duration(seconds: 60),
///   maxRetries: 5,
/// );
/// final crud = AirtableCrud.withConfig(config);
/// ```
///
/// ## Features
///
/// - **Fetch Records**: Retrieve records with optional filtering and field selection
/// - **Create Records**: Add new records individually or in bulk
/// - **Update Records**: Modify existing records with immutable patterns
/// - **Delete Records**: Remove records individually or in bulk
/// - **Error Handling**: Specific exception types for different error scenarios
/// - **Retry Logic**: Automatic retry with exponential backoff
/// - **Type Safety**: Immutable models and type-safe field access
///
/// See [AirtableCrud] for the main API documentation.
library airtable_crud;

// Core functionality
export 'src/airtable_crud_base.dart';

// Models
export 'src/models/airtable_record.dart';
export 'src/models/delete_result.dart';

// Configuration
export 'src/config/airtable_config.dart';

// Exceptions
export 'src/errors/airtable_exception.dart';
export 'src/errors/network_exception.dart';
export 'src/errors/auth_exception.dart';
export 'src/errors/rate_limit_exception.dart';
export 'src/errors/validation_exception.dart';
export 'src/errors/not_found_exception.dart';

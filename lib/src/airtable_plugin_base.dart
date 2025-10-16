/// DEPRECATED: This file has been renamed to airtable_crud_base.dart.
///
/// This file is maintained for backward compatibility and will be
/// removed in version 2.0.0.
///
/// ## Migration
///
/// If you were importing this file directly (which is rare), update your import:
///
/// From:
/// ```dart
/// import 'package:airtable_crud/src/airtable_plugin_base.dart';
/// ```
///
/// To:
/// ```dart
/// import 'package:airtable_crud/src/airtable_crud_base.dart';
/// // Or better yet, use the main entry point:
/// import 'package:airtable_crud/airtable_crud.dart';
/// ```
@Deprecated(
    'This file has been renamed. Import from "package:airtable_crud/airtable_crud.dart" instead. '
    'This file will be removed in version 2.0.0. '
    'Deprecated since version 1.3.0.')
library;

// Re-export everything from the new file
export 'airtable_crud_base.dart';

# Migration Guide

This guide helps you migrate from v1.2.x to v1.3.0 and prepare for v2.0.0.

---

## From 1.2.x to 1.3.0

### ⚡ Quick Start (TL;DR)

**Minimum change required:**
```dart
// Just update this one line:
import 'package:airtable_crud/airtable_crud.dart'; // Changed from airtable_plugin.dart
```

**Everything else still works!** The changes below are **optional improvements**.

---

### 📋 Detailed Migration (Recommended)

#### 1. Update Import Statement

**Before:**
```dart
import 'package:airtable_crud/airtable_plugin.dart';
```

**After:**
```dart
import 'package:airtable_crud/airtable_crud.dart';
```

**Why:** Consistent naming - the package is called `airtable_crud`, so the main file should be too.

---

#### 2. Unified Fetch Method (Optional)

**Before:**
```dart
// Separate methods for filtered vs non-filtered
final all = await crud.fetchRecords('Users');
final filtered = await crud.fetchRecordsWithFilter(
  'Users',
  "AND({status} = 'active')"
);
```

**After:**
```dart
// One method for both
final all = await crud.fetchRecords('Users');
final filtered = await crud.fetchRecords(
  'Users',
  filter: "AND({status} = 'active')",
);

// With multiple options
final results = await crud.fetchRecords(
  'Users',
  filter: "AND({status} = 'active')",
  view: 'Active Users',
  fields: ['name', 'email'],
  maxRecords: 100,
);
```

**Why:** Cleaner API, fewer methods to remember, more flexible.

---

#### 3. Immutable Record Updates (Optional)

**Before:**
```dart
record.fields['name'] = 'New Name'; // Direct mutation
await crud.updateRecord('Users', record);
```

**After:**
```dart
// Immutable pattern (recommended)
final updated = record.updateField('name', 'New Name');
await crud.updateRecord('Users', updated);

// Or using copyWith
final updated = record.copyWith(
  fields: {...record.fields, 'name': 'New Name'},
);
await crud.updateRecord('Users', updated);
```

**Why:** Safer code, prevents accidental mutations, easier to reason about.

**Note:** Direct mutation still works in v1.3.0 but shows a deprecation warning.

---

#### 4. Enhanced Error Handling (Optional)

**Before:**
```dart
try {
  await crud.fetchRecords('Users');
} on AirtableException catch (e) {
  print('Error: ${e.message}');
}
```

**After:**
```dart
try {
  await crud.fetchRecords('Users');
} on AuthException catch (e) {
  // Handle auth errors specifically
  print('Authentication failed: ${e.message}');
  print('Check your API key');
} on RateLimitException catch (e) {
  // Handle rate limiting
  print('Rate limited. Retry after: ${e.retryAfter}');
  await Future.delayed(e.retryAfter ?? Duration(seconds: 5));
} on NetworkException catch (e) {
  // Handle network issues
  print('Network error: ${e.message}');
} on ValidationException catch (e) {
  // Handle validation errors
  print('Invalid data: ${e.message}');
} on AirtableException catch (e) {
  // Catch-all for other Airtable errors
  print('Airtable error: ${e.message}');
}
```

**Why:** More specific error handling, better user experience, easier debugging.

---

#### 5. Configuration (Optional, for Advanced Use)

**Before:**
```dart
final crud = AirtableCrud(apiKey, baseId);
```

**After (with configuration):**
```dart
final config = AirtableConfig(
  apiKey: apiKey,
  baseId: baseId,
  timeout: Duration(seconds: 60),
  maxRetries: 5,
  retryDelay: Duration(seconds: 2),
  enableLogging: true, // Helpful for debugging
  defaultView: 'Main View',
);
final crud = AirtableCrud.withConfig(config);
```

**Why:** More control over timeouts, retries, and other options.

**Note:** The basic constructor still works in v1.3.0 but shows a deprecation warning.

---

#### 6. Return Values (Optional)

**Before:**
```dart
await crud.updateRecord('Users', record); // Returns void
await crud.deleteRecord('Users', id);     // Returns void
```

**After:**
```dart
// updateRecord now returns the updated record
final updated = await crud.updateRecord('Users', record);
print('Updated: ${updated.fields}');

// deleteRecord returns metadata
final result = await crud.deleteRecord('Users', id);
print('Deleted at: ${result.deletedAt}');
```

**Why:** More information about operations, better for logging and debugging.

---

### ✅ Migration Checklist

- [ ] Update import from `airtable_plugin.dart` to `airtable_crud.dart`
- [ ] (Optional) Replace `fetchRecordsWithFilter()` with `fetchRecords(filter: ...)`
- [ ] (Optional) Use `copyWith()` instead of direct field mutation
- [ ] (Optional) Update error handling to use specific exception types
- [ ] (Optional) Use `AirtableConfig` for advanced configuration
- [ ] (Optional) Handle return values from `updateRecord()` and `deleteRecord()`

---

### 🎯 Benefits of Upgrading

- ✅ **Cleaner API**: Fewer methods, more intuitive
- ✅ **Better Errors**: Know exactly what went wrong
- ✅ **Type Safety**: Immutable models prevent bugs
- ✅ **More Control**: Configuration options for timeouts, retries
- ✅ **Future Proof**: Ready for 2.0.0 when it arrives

---

### 📅 Timeline

- **v1.3.0** (Now): All deprecated items still work with warnings
- **v1.4.0-1.9.x** (3-6 months): Refinements based on feedback
- **v2.0.0** (6-12 months): Deprecated items removed

You have plenty of time to migrate! 🚀

---

## From 1.3.x to 2.0.0 (Future)

**When v2.0.0 is released, the following breaking changes will occur:**

### Breaking Changes

1. **`airtable_plugin.dart` removed**
   - Solution: Use `airtable_crud.dart` instead

2. **`fetchRecordsWithFilter()` removed**
   - Solution: Use `fetchRecords(filter: ...)` instead

3. **Direct field mutation removed**
   - Solution: Use `copyWith()` or `updateField()` instead

4. **Basic constructor becomes `const`**
   - Solution: Use `AirtableCrud.withConfig()` for custom options

### Migration Tool

We plan to provide an automated migration tool for v2.0.0 that will:
- Update imports automatically
- Convert deprecated method calls
- Update field mutations to immutable patterns

Stay tuned for more details!

---

## Need Help?

- 📖 Check the [README](README.md) for examples
- 🐛 [Report issues](https://github.com/Katoemma/airtable_crud/issues) on GitHub
- 💡 See [CHANGELOG](CHANGELOG.md) for all changes

Happy migrating! 🎉


# Changelog

## 1.3.0 - Modern API Design & Architecture Improvements

### ⚠️ Deprecations (All still work!)
- `airtable_plugin.dart` import → Use `airtable_crud.dart` instead
- `fetchRecordsWithFilter()` method → Use `fetchRecords(filter: ...)` instead
- Direct `AirtableRecord.fields` mutation → Use `.copyWith()` or `.updateField()` instead
- Basic `AirtableCrud()` constructor → Use `AirtableCrud.withConfig()` for advanced features

### ✨ New Features

**Core Improvements:**
- Unified `fetchRecords()` method with optional filter parameter
- Exception hierarchy for better error handling:
  - `NetworkException` - Connection and timeout errors
  - `AuthException` - Authentication and authorization errors (401/403)
  - `RateLimitException` - Rate limit errors with retry guidance (429)
  - `ValidationException` - Data validation errors (422)
  - `NotFoundException` - Resource not found errors (404)
- `AirtableConfig` class for centralized configuration
- `AirtableCrud.withConfig()` constructor for advanced setup
- Configurable timeouts, retry logic, and logging

**Enhanced Models:**
- `AirtableRecord.copyWith()` method for immutable updates
- `AirtableRecord.updateField()` convenience method
- `AirtableRecord.removeField()` method
- `AirtableRecord.getField<T>()` type-safe field accessor
- `AirtableRecord.hasField()` field existence check
- `DeleteResult` model with deletion metadata

**Improved Return Values:**
- `updateRecord()` now returns the updated `AirtableRecord`
- `deleteRecord()` now returns `DeleteResult` with metadata
- Better operation feedback and logging capabilities

**New Bulk Operations:**
- `updateBulkRecords()` - Update multiple records efficiently
- `deleteBulkRecords()` - Delete multiple records in batch

**HTTP Client Improvements:**
- Automatic retry with exponential backoff
- Configurable timeout handling
- Better error parsing and reporting
- Optional request/response logging

### 🏗️ Architecture Improvements
- Separated concerns: client, config, models properly organized
- `AirtableClient` class for HTTP operations abstraction
- `RequestBuilder` class for URL construction
- `AirtableConstants` class for centralized constants
- Better code organization and maintainability
- Improved testability with dependency injection support

### 📝 Documentation
- Added `MIGRATION.md` with detailed upgrade guide
- Updated `README.md` with new patterns and examples
- Added `PLAN.md` documenting the modernization strategy
- Added `STRUCTURE.md` with architecture overview
- Comprehensive inline documentation
- More code examples throughout

### 🔧 Technical Details
- No new external dependencies added
- Still using `http: ^1.3.0`
- SDK requirement: `^3.5.3`
- 100% backward compatible - no breaking changes
- All deprecated features still work with warnings

### 🚀 Migration
See [MIGRATION.md](MIGRATION.md) for a detailed upgrade guide. 
**TL;DR:** Just change your import to `airtable_crud.dart` and you're good!

### 🔮 Future (v2.0.0)
Deprecated items will be removed in v2.0.0 (estimated 6-12 months).
Plenty of time to migrate!

---

## 1.2.5
### Documentation Updates
- Updated README to reflect the removal of the query builder.
- Updated examples

## 1.2.4
## Eliminating Query Builder
- Removed the query builder functionality

## 1.2.3
### 🔥 Enhancements
- Added `fields` parameter support to `fetchRecordsWithFilter`, allowing users to retrieve only specific fields along with filters.
- Improved query string encoding to correctly format `fields[]` parameters.
- Ensured proper pagination handling while using filters.

## 1.0.0
- Initial version.

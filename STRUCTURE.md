# Package Structure Overview - v1.3.0

This document provides a visual overview of the package structure after v1.3.0 modernization.

---

## 📦 File Structure

```
airtable_crud/
├── lib/
│   ├── airtable_crud.dart              ⭐ NEW: Primary entry point
│   ├── airtable_plugin.dart            ⚠️  DEPRECATED: Re-exports airtable_crud.dart
│   │
│   └── src/
│       ├── airtable_crud_base.dart     ⭐ NEW: Renamed from plugin_base
│       ├── airtable_plugin_base.dart   ⚠️  DEPRECATED: Re-exports crud_base
│       │
│       ├── config/
│       │   └── airtable_config.dart    ⭐ NEW: Configuration management
│       │
│       ├── client/
│       │   ├── airtable_client.dart    ⭐ NEW: HTTP client abstraction
│       │   └── request_builder.dart    ⭐ NEW: URL/query builder
│       │
│       ├── models/
│       │   ├── airtable_record.dart    ✨ ENHANCED: Added copyWith, immutability
│       │   └── delete_result.dart      ⭐ NEW: Delete operation result
│       │
│       ├── errors/
│       │   ├── airtable_exception.dart ✨ ENHANCED: Base exception class
│       │   ├── network_exception.dart  ⭐ NEW: Network errors
│       │   ├── auth_exception.dart     ⭐ NEW: Auth errors (401/403)
│       │   ├── rate_limit_exception.dart ⭐ NEW: Rate limit (429)
│       │   ├── validation_exception.dart ⭐ NEW: Validation (422)
│       │   └── not_found_exception.dart ⭐ NEW: Not found (404)
│       │
│       └── constants/
│           └── airtable_constants.dart ⭐ NEW: Constants & defaults
│
├── test/
│   ├── airtable_crud_test.dart         ✨ ENHANCED: Main tests
│   ├── config/
│   │   └── airtable_config_test.dart   ⭐ NEW
│   ├── client/
│   │   └── airtable_client_test.dart   ⭐ NEW
│   ├── models/
│   │   └── airtable_record_test.dart   ✨ ENHANCED
│   └── errors/
│       └── exception_hierarchy_test.dart ⭐ NEW
│
├── example/
│   └── airtable_crud_example.dart      ✨ ENHANCED: Updated examples
│
├── PLAN.md                              ⭐ NEW: Full implementation plan
├── QUICK_START.md                       ⭐ NEW: Quick reference guide
├── STRUCTURE.md                         ⭐ NEW: This file
├── MIGRATION.md                         ⭐ NEW: Migration guide
├── CHANGELOG.md                         ✨ UPDATED
├── README.md                            ✨ UPDATED
└── pubspec.yaml                         ✨ UPDATED: Version 1.3.0

Legend:
⭐ NEW        - New file
✨ ENHANCED   - Existing file with improvements
⚠️  DEPRECATED - Deprecated but still works
```

---

## 🏗️ Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                     USER CODE                           │
│  import 'package:airtable_crud/airtable_crud.dart';    │
└─────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   PUBLIC API LAYER                       │
│  ┌──────────────────────────────────────────────────┐  │
│  │          AirtableCrud (Main Class)                │  │
│  │  • fetchRecords()                                 │  │
│  │  • createRecord()                                 │  │
│  │  • updateRecord()                                 │  │
│  │  • deleteRecord()                                 │  │
│  │  • createBulkRecords()                            │  │
│  │  • updateBulkRecords()  ⭐ NEW                    │  │
│  │  • deleteBulkRecords()  ⭐ NEW                    │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────┐
│                  CONFIGURATION LAYER                     │
│  ┌────────────────────────────────────────────────┐    │
│  │  AirtableConfig                                 │    │
│  │  • API key                                      │    │
│  │  • Base ID                                      │    │
│  │  • Timeout                                      │    │
│  │  • Retries                                      │    │
│  │  • Default view                                 │    │
│  └────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                          │
│  ┌────────────────────┐  ┌────────────────────────┐    │
│  │  AirtableClient    │  │   RequestBuilder       │    │
│  │  • HTTP requests   │  │   • Build URLs         │    │
│  │  • Retry logic     │  │   • Query params       │    │
│  │  • Error handling  │  │   • Encoding           │    │
│  │  • Timeout mgmt    │  │   • Pagination         │    │
│  └────────────────────┘  └────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   HTTP TRANSPORT                         │
│              (package:http)                              │
└─────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   AIRTABLE API                           │
│         https://api.airtable.com/v0                      │
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow

### Fetch Records Example

```
User Code
   │
   ├─ crud.fetchRecords('Users', filter: "...")
   │
   ▼
AirtableCrud.fetchRecords()
   │
   ├─ Validates parameters
   │
   ▼
RequestBuilder.buildFetchUrl()
   │
   ├─ Builds URL with query params
   ├─ Encodes filter formula
   ├─ Adds fields, view, pagination
   │
   ▼
AirtableClient.get()
   │
   ├─ Adds auth headers
   ├─ Sets timeout
   ├─ Makes HTTP request
   │
   ▼
HTTP Response
   │
   ├─ Success? Parse records
   │     └─> List<AirtableRecord>
   │
   └─ Error? Create specific exception
         ├─ 401/403 → AuthException
         ├─ 404 → NotFoundException
         ├─ 422 → ValidationException
         ├─ 429 → RateLimitException
         └─ Other → NetworkException
```

### Error Flow

```
Airtable API Error
   │
   ▼
AirtableClient catches
   │
   ├─ Parses status code
   ├─ Parses error message
   │
   ▼
Creates specific exception
   │
   ├─ statusCode: 401 → new AuthException()
   ├─ statusCode: 404 → new NotFoundException()
   ├─ statusCode: 422 → new ValidationException()
   ├─ statusCode: 429 → new RateLimitException()
   └─ Other → new NetworkException()
   │
   ▼
Throws to user code
   │
   ▼
User catches specific type
   │
   try {
     await crud.fetchRecords(...)
   } on AuthException catch (e) {
     // Handle auth error
   } on RateLimitException catch (e) {
     // Handle rate limiting
   }
```

---

## 🔌 Dependency Graph

```
airtable_crud.dart (entry point)
   │
   ├─► airtable_crud_base.dart (main class)
   │      │
   │      ├─► config/airtable_config.dart
   │      ├─► client/airtable_client.dart
   │      │      └─► client/request_builder.dart
   │      ├─► models/airtable_record.dart
   │      ├─► models/delete_result.dart
   │      ├─► errors/airtable_exception.dart
   │      │      ├─► errors/network_exception.dart
   │      │      ├─► errors/auth_exception.dart
   │      │      ├─► errors/rate_limit_exception.dart
   │      │      ├─► errors/validation_exception.dart
   │      │      └─► errors/not_found_exception.dart
   │      └─► constants/airtable_constants.dart
   │
   └─► (All exports available to user)
```

---

## 🎯 Import Patterns

### For Users (Recommended)

```dart
// Single import gets everything
import 'package:airtable_crud/airtable_crud.dart';

// Now you have access to:
// - AirtableCrud
// - AirtableConfig
// - AirtableRecord
// - DeleteResult
// - All exceptions
```

### For Users (Deprecated but works)

```dart
// Old import still works but shows warning
import 'package:airtable_crud/airtable_plugin.dart';

// Gets same everything, just different entry point
```

### Internal Imports (within package)

```dart
// In airtable_crud_base.dart
import 'config/airtable_config.dart';
import 'client/airtable_client.dart';
import 'models/airtable_record.dart';
// etc...
```

---

## 🔀 Migration Path

### v1.2.5 (Old)
```
lib/
├── airtable_plugin.dart
└── src/
    ├── airtable_plugin_base.dart
    ├── models/
    │   └── airtable_record.dart
    └── errors/
        └── airtable_exception.dart
```

### v1.3.0 (New, with compatibility)
```
lib/
├── airtable_crud.dart           ⭐ NEW
├── airtable_plugin.dart         ⚠️ Re-exports
└── src/
    ├── airtable_crud_base.dart  ⭐ NEW
    ├── airtable_plugin_base.dart ⚠️ Re-exports
    ├── config/                   ⭐ NEW
    ├── client/                   ⭐ NEW
    ├── models/                   ✨ ENHANCED
    ├── errors/                   ✨ ENHANCED
    └── constants/                ⭐ NEW
```

### v2.0.0 (Future, clean)
```
lib/
├── airtable_crud.dart           ✅ Only entry point
└── src/
    ├── airtable_crud_base.dart  ✅ Only base
    ├── config/                   ✅
    ├── client/                   ✅
    ├── models/                   ✅
    ├── errors/                   ✅
    └── constants/                ✅

(All deprecated files removed)
```

---

## 📊 Class Relationships

```
┌─────────────────────────────────────────────────────┐
│                  AirtableCrud                       │
│  - apiKey: String                                   │
│  - baseId: String                                   │
│  - _config: AirtableConfig                         │
│  - _client: AirtableClient                         │
│                                                     │
│  + fetchRecords()                                   │
│  + createRecord()                                   │
│  + updateRecord()                                   │
│  + deleteRecord()                                   │
│  + createBulkRecords()                              │
│  + updateBulkRecords()                              │
│  + deleteBulkRecords()                              │
└─────────────────────────────────────────────────────┘
           │                    │
           │ uses               │ uses
           ▼                    ▼
┌──────────────────┐  ┌──────────────────────┐
│ AirtableConfig   │  │  AirtableClient      │
│  - apiKey        │  │   - config           │
│  - baseId        │  │   - httpClient       │
│  - endpoint      │  │   + get()            │
│  - timeout       │  │   + post()           │
│  - maxRetries    │  │   + patch()          │
└──────────────────┘  │   + delete()         │
                      └──────────────────────┘
                               │ uses
                               ▼
                      ┌──────────────────────┐
                      │  RequestBuilder      │
                      │   + buildFetchUrl()  │
                      │   + encodeQuery()    │
                      │   + buildFilter()    │
                      └──────────────────────┘
```

```
┌──────────────────────────────────────┐
│      AirtableException               │
│      (abstract base)                 │
│  - message: String                   │
│  - details: String?                  │
│  - statusCode: int?                  │
└──────────────────────────────────────┘
                 △
                 │ extends
    ┌────────────┼────────────┬──────────────┬───────────────┐
    │            │            │              │               │
┌───────────┐ ┌────────┐ ┌─────────┐ ┌──────────────┐ ┌──────────┐
│  Network  │ │  Auth  │ │RateLimit│ │ Validation   │ │NotFound  │
│ Exception │ │Exception│ │Exception│ │ Exception    │ │Exception │
└───────────┘ └────────┘ └─────────┘ └──────────────┘ └──────────┘
```

```
┌──────────────────────────────────────┐
│      AirtableRecord                  │
│  - id: String                        │
│  - _fields: Map<String, dynamic>     │
│                                      │
│  + fields (getter)                   │
│  + copyWith()                        │
│  + updateField()                     │
│  + getField<T>()                     │
│  + fromJson()                        │
│  + toJson()                          │
└──────────────────────────────────────┘
```

```
┌──────────────────────────────────────┐
│      DeleteResult                    │
│  - id: String                        │
│  - deleted: bool                     │
│  - deletedAt: DateTime               │
└──────────────────────────────────────┘
```

---

## 🎨 Design Patterns Used

### 1. **Builder Pattern**
- `RequestBuilder` - Build URLs and queries

### 2. **Factory Pattern**
- `AirtableRecord.fromJson()` - Create from JSON
- `AirtableConfig.simple()` - Simple config creation

### 3. **Strategy Pattern**
- Different exception types for different errors
- Configurable retry strategies

### 4. **Facade Pattern**
- `AirtableCrud` - Simple interface over complex operations
- Hides HTTP client, request building complexity

### 5. **Immutable Object Pattern**
- `AirtableRecord.copyWith()` - Immutable updates
- Immutable configuration objects

---

## 📈 Complexity Comparison

### Before (v1.2.5)
```
Complexity: Low
Files: 4
Classes: 3
- Simple structure
- Direct HTTP calls
- Single exception type
```

### After (v1.3.0)
```
Complexity: Medium
Files: ~20
Classes: ~15
- Layered architecture
- Separation of concerns
- Rich exception hierarchy
- Better testability
+ More maintainable
+ More extensible
```

### Future (v2.0.0)
```
Complexity: Medium
Files: ~15 (removed deprecated)
Classes: ~15
- Clean architecture
- No legacy code
- Modern patterns
```

---

## 🧪 Testing Structure

```
test/
├── airtable_crud_test.dart (integration-style)
│   Tests: Full workflows, all methods
│
├── config/
│   └── airtable_config_test.dart
│       Tests: Configuration validation, defaults
│
├── client/
│   └── airtable_client_test.dart
│       Tests: HTTP operations, retries, errors
│
├── models/
│   ├── airtable_record_test.dart
│   │   Tests: copyWith, field access, immutability
│   └── fetch_options_test.dart
│       Tests: Option building, defaults
│
└── errors/
    └── exception_hierarchy_test.dart
        Tests: Each exception type, error parsing
```

---

## 💡 Key Takeaways

1. **Separation of Concerns**: Each class has a single responsibility
2. **Testability**: Each layer can be tested independently
3. **Extensibility**: Easy to add new features without breaking existing
4. **Backward Compatibility**: Old code still works via re-exports
5. **Progressive Enhancement**: Users can adopt new features gradually

---

**Questions?** See [PLAN.md](PLAN.md) for detailed implementation guide.


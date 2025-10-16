# Quick Start - v1.3.0 Implementation

> **TL;DR**: Step-by-step guide to implement the modernization plan.  
> For full details, see [PLAN.md](PLAN.md)

---

## 📋 Implementation Order (3 Weeks)

### Week 1: Foundation & Core

#### Day 1-2: Create New Models & Config
```bash
# Create directories
mkdir -p lib/src/{config,client,constants}
mkdir -p lib/src/errors

# Create files in this order:
1. lib/src/constants/airtable_constants.dart
2. lib/src/config/airtable_config.dart
3. lib/src/models/fetch_options.dart
4. lib/src/models/delete_result.dart
```

#### Day 3-4: Exception Hierarchy
```bash
# Create exception files:
1. lib/src/errors/airtable_exception.dart (enhance existing)
2. lib/src/errors/network_exception.dart
3. lib/src/errors/auth_exception.dart
4. lib/src/errors/rate_limit_exception.dart
5. lib/src/errors/validation_exception.dart
6. lib/src/errors/not_found_exception.dart
```

#### Day 5-7: HTTP Client Abstraction
```bash
# Create client files:
1. lib/src/client/request_builder.dart
2. lib/src/client/airtable_client.dart
```

---

### Week 2: Main Library & Compatibility

#### Day 8-10: Update Core Library
```bash
# Main work files:
1. Enhance lib/src/models/airtable_record.dart (add copyWith)
2. Create lib/src/airtable_crud_base.dart (rename from plugin_base)
3. Update AirtableCrud class with new methods
```

**Key changes in AirtableCrud**:
- Add `withConfig()` constructor
- Add unified `fetchRecords()` method
- Update `updateRecord()` to return AirtableRecord
- Update `deleteRecord()` to return DeleteResult
- Add `updateBulkRecords()` and `deleteBulkRecords()`
- Add `@Deprecated` annotations to old methods

#### Day 11-12: Backward Compatibility Layer
```bash
# Ensure old code still works:
1. Create lib/airtable_crud.dart (new entry point)
2. Update lib/airtable_plugin.dart (deprecate, re-export)
3. Update lib/src/airtable_plugin_base.dart (deprecate, re-export)
```

#### Day 13-14: Manual Testing
- Test all deprecated methods still work
- Test new methods work
- Test example app
- Verify deprecation warnings show in IDE

---

### Week 3: Documentation, Testing & Release

#### Day 15-16: Documentation
```bash
# Update docs:
1. README.md (update all examples)
2. CHANGELOG.md (document all changes)
3. MIGRATION.md (migration guide)
4. example/airtable_crud_example.dart (use new patterns)
```

#### Day 17-19: Testing
```bash
# Create test files:
1. test/config/airtable_config_test.dart
2. test/client/airtable_client_test.dart
3. test/models/airtable_record_test.dart (enhance)
4. test/models/fetch_options_test.dart
5. test/errors/exception_hierarchy_test.dart
6. test/airtable_crud_test.dart (enhance)

# Run all tests
flutter test
```

#### Day 20-21: Final Review & Release
- [ ] All tests passing
- [ ] No linter errors
- [ ] Documentation complete
- [ ] Example app working
- [ ] Update pubspec.yaml to 1.3.0
- [ ] Create git tag: `v1.3.0`
- [ ] Publish to pub.dev
- [ ] Create GitHub release

---

## 🎯 Critical Rules

### ✅ DO
- ✅ Add `@Deprecated` to all old methods/files
- ✅ Keep old code working (backward compatibility)
- ✅ Test both old and new code paths
- ✅ Document everything
- ✅ Use clear deprecation messages

### ❌ DON'T
- ❌ Break existing user code
- ❌ Remove old methods (save for v2.0.0)
- ❌ Change method signatures of existing methods
- ❌ Rush testing
- ❌ Forget to update documentation

---

## 📝 Code Templates

### Deprecation Annotation Template
```dart
@Deprecated(
  'Use <NEW_METHOD> instead. '
  'This will be removed in version 2.0.0. '
  'Deprecated since version 1.3.0.'
)
```

### New Constructor Pattern
```dart
// NEW: Recommended
AirtableCrud.withConfig(AirtableConfig config);

// OLD: Keep but deprecate
@Deprecated('Use AirtableCrud.withConfig() for more options. Deprecated since 1.3.0.')
AirtableCrud(this.apiKey, this.baseId);
```

### Exception Hierarchy Template
```dart
class SpecificException extends AirtableException {
  SpecificException({
    required String message,
    String? details,
    int? statusCode,
  }) : super(message: message, details: details, statusCode: statusCode);
}
```

---

## 🧪 Testing Checklist

### Unit Tests
- [ ] Test all new classes work correctly
- [ ] Test copyWith methods
- [ ] Test exception hierarchy
- [ ] Test configuration validation

### Backward Compatibility Tests
- [ ] Old import still works: `import 'package:airtable_crud/airtable_plugin.dart';`
- [ ] `fetchRecordsWithFilter()` still works
- [ ] Direct field mutation still works
- [ ] Basic constructor still works
- [ ] All old examples still run

### Integration Tests
- [ ] Example app runs without errors
- [ ] Deprecation warnings show in IDE
- [ ] New patterns work correctly
- [ ] Error handling works

---

## 📦 Release Checklist

### Pre-Release
- [ ] All code complete
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Example app tested
- [ ] No linter warnings
- [ ] Version bumped to 1.3.0

### Release
- [ ] Git tag created: `git tag v1.3.0`
- [ ] Pushed to GitHub
- [ ] Published to pub.dev
- [ ] Release notes written
- [ ] GitHub release created

### Post-Release
- [ ] Monitor for issues
- [ ] Respond to user feedback
- [ ] Update any issues found
- [ ] Plan for v1.4.0

---

## 🔥 Emergency Rollback Plan

If critical issues found after release:

1. **Don't panic** - Old version still available
2. **Create hotfix branch**: `git checkout -b hotfix/1.3.1`
3. **Fix the issue** quickly
4. **Test thoroughly**
5. **Release 1.3.1** immediately
6. **Communicate** with users about the fix

Users on 1.2.5 are unaffected, only 1.3.0 users need to upgrade.

---

## 🎓 Learning Resources

As you implement, refer to:
- [PLAN.md](PLAN.md) - Full detailed plan
- [Dart API Design](https://dart.dev/guides/language/effective-dart/design)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Current codebase - Keep consistent style

---

## 💡 Pro Tips

1. **Commit often** - Small, focused commits
2. **Test as you go** - Don't wait until the end
3. **Read your deprecation messages** - They should be helpful
4. **Keep it simple** - Don't over-engineer
5. **Ask for help** - When stuck, step back and review

---

## 📊 Progress Tracking

Use this to track your progress:

### Foundation (Week 1)
- [ ] Constants created
- [ ] Config created
- [ ] Models created
- [ ] Exceptions created
- [ ] Client created

### Core (Week 2)
- [ ] AirtableRecord enhanced
- [ ] AirtableCrud enhanced
- [ ] New methods added
- [ ] Deprecations added
- [ ] Backward compatibility verified

### Finalization (Week 3)
- [ ] Documentation complete
- [ ] Tests written
- [ ] Tests passing
- [ ] Example updated
- [ ] Ready to release

---

**Need help?** Check [PLAN.md](PLAN.md) for detailed guidance on each component.

Good luck! 🚀


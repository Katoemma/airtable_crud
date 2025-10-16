# Publishing Guide

This document explains how to publish new versions of `airtable_crud` to pub.dev using GitHub Actions.

## 🔧 Setup (One-time configuration)

### 1. Configure Automated Publishing on pub.dev

1. Go to https://pub.dev/packages/airtable_crud/admin
2. Find the **Automated publishing** section
3. Click **Enable publishing from GitHub Actions**
4. Enter the following:
   - **Repository**: `Katoemma/airtable_crud`
   - **Tag pattern**: `v{{version}}`
5. Click **Save**

### 2. (Optional) Add Environment Protection

For extra security, require a deployment environment:

1. On pub.dev admin page, click **Require GitHub Actions environment**
2. Enter environment name: `pub.dev`
3. On GitHub, go to: https://github.com/Katoemma/airtable_crud/settings/environments
4. Create a new environment named `pub.dev`
5. Configure **Required reviewers** (optional but recommended)

If you add environment protection, update `.github/workflows/publish.yml`:

```yaml
jobs:
  publish:
    permissions:
      id-token: write
    uses: dart-lang/setup-dart/.github/workflows/publish.yml@v1
    with:
      environment: pub.dev  # Add this line
```

---

## 📦 Publishing a New Version

### Prerequisites

- [ ] All changes committed and pushed to GitHub
- [ ] Version number updated in `pubspec.yaml`
- [ ] `CHANGELOG.md` updated with release notes
- [ ] All tests passing (`dart test`)
- [ ] No API keys or secrets in code

### Steps

#### Option 1: Using Git CLI

```bash
# 1. Make sure pubspec.yaml version matches the tag
cat pubspec.yaml | grep version
# Should show: version: 1.3.0

# 2. Create and push the tag
git tag v1.3.0
git push origin v1.3.0

# 3. Monitor the workflow
# Visit: https://github.com/Katoemma/airtable_crud/actions
```

#### Option 2: Using GitHub Releases (Recommended)

1. Go to: https://github.com/Katoemma/airtable_crud/releases/new
2. Click **Choose a tag** and type: `v1.3.0` (or your version)
3. Select **Create new tag on publish**
4. Set **Release title**: `v1.3.0 - Your Release Name`
5. Add **Release notes** from `CHANGELOG.md`
6. Click **Publish release**

This automatically creates the tag and triggers the publishing workflow!

---

## 📋 Pre-Publishing Checklist

Before creating a tag, ensure:

- [ ] `pubspec.yaml` version number is correct (e.g., `1.3.0`)
- [ ] `CHANGELOG.md` has entry for this version
- [ ] All tests pass: `dart test`
- [ ] README is up to date
- [ ] No TODO comments in production code
- [ ] No debug print statements
- [ ] No API keys or secrets in code or git history
- [ ] All files formatted: `dart format .`
- [ ] No linter warnings: `dart analyze`
- [ ] Example code tested

---

## 🔍 Verifying Publication

After pushing the tag:

1. **Check GitHub Actions**: https://github.com/Katoemma/airtable_crud/actions
   - Workflow should trigger within seconds
   - Green checkmark = success ✅
   - Red X = failure ❌ (check logs)

2. **Check pub.dev**: https://pub.dev/packages/airtable_crud
   - New version should appear within 1-2 minutes
   - Verify version number is correct

3. **Check Audit Log**: https://pub.dev/packages/airtable_crud/admin
   - Should show publication event
   - Should link to GitHub Actions run

---

## ❌ Troubleshooting

### Workflow didn't trigger
- **Check tag pattern**: Must be `v1.3.0` format (with lowercase `v`)
- **Check workflow file**: Pattern in `.github/workflows/publish.yml` must match
- **Check GitHub**: Tag must be on the correct branch

### Workflow failed
Common issues:

1. **Version mismatch**: `pubspec.yaml` version doesn't match tag
   ```
   Tag: v1.3.0
   pubspec.yaml: version: 1.3.0  ✅ Match!
   ```

2. **API keys detected**: GitHub blocks pushes with secrets
   - Remove secrets from code
   - If in git history, see "Fixing Git History" below

3. **Tests failing**: Fix tests before publishing

4. **Authentication failed**: Re-configure automated publishing on pub.dev

### Fixing Git History (API Keys Detected)

If GitHub rejects your push due to API keys in git history:

```bash
# Option 1: Rewrite the last N commits (if keys are recent)
git rebase -i HEAD~4  # Adjust number as needed
# In editor, change 'pick' to 'edit' for commits with keys
# Remove keys, then:
git add .
git commit --amend
git rebase --continue

# Option 2: Use BFG Repo-Cleaner (for old keys)
# See: https://rtyley.github.io/bfg-repo-cleaner/

# After fixing, force push (CAUTION!)
git push origin v1.3.0 --force
```

---

## 🔒 Security Best Practices

1. **Never commit API keys** to the repository
2. **Use tag protection rules** on GitHub
3. **Require environment approval** for publishing
4. **Review changes** before tagging
5. **Use signed commits** (optional but recommended)

---

## 📚 Additional Resources

- [Pub.dev Publishing Guide](https://dart.dev/tools/pub/publishing)
- [GitHub Actions for Dart](https://github.com/dart-lang/setup-dart)
- [Versioning Best Practices](https://dart.dev/tools/pub/versioning)
- [Semantic Versioning](https://semver.org/)

---

## 🆘 Need Help?

- Check [GitHub Actions logs](https://github.com/Katoemma/airtable_crud/actions)
- Review [pub.dev audit log](https://pub.dev/packages/airtable_crud/admin)
- Search [pub.dev help](https://pub.dev/help)
- Open an issue if problems persist


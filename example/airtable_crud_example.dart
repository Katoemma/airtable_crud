// ignore_for_file: avoid_print

import 'package:airtable_crud/airtable_crud.dart';
import 'package:flutter/material.dart';

/// Airtable CRUD v1.3.0 Flutter Example
///
/// This example demonstrates all the new features in v1.3.0:
/// - AirtableConfig for advanced configuration
/// - Unified fetchRecords() method
/// - Immutable record updates
/// - Enhanced error handling with specific exception types
/// - DeleteResult with metadata
/// - Type-safe field access
void main() {
  runApp(AirtableExampleApp());
}

class AirtableExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airtable CRUD Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AirtableHomePage(),
    );
  }
}

class AirtableHomePage extends StatefulWidget {
  @override
  _AirtableHomePageState createState() => _AirtableHomePageState();
}

class _AirtableHomePageState extends State<AirtableHomePage> {
  final String apiKey =
      'YOUR_AIRTABLE_API_KEY'; // Replace with your Airtable API key
  final String baseId = 'YOUR_BASE_ID'; // Replace with your Airtable Base ID
  final String tableName =
      'YOUR_TABLE_NAME'; // Replace with your Airtable table name

  late AirtableCrud airtableCrud;
  List<AirtableRecord> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // ✅ v1.3.0: Initialize with configuration
    final config = AirtableConfig(
      apiKey: apiKey,
      baseId: baseId,
      timeout: Duration(seconds: 60),
      maxRetries: 3,
      enableLogging: true,
    );
    airtableCrud = AirtableCrud.withConfig(config);
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    setState(() {
      isLoading = true;
    });

    try {
      // ✅ v1.3.0: Unified fetchRecords with optional filters
      List<AirtableRecord> fetchedRecords = await airtableCrud.fetchRecords(
        tableName,
        fields: ['firstname', 'lastname', 'email'],
        maxRecords: 100,
      );
      setState(() {
        records = fetchedRecords;
        isLoading = false;
      });
    } on AuthException catch (e) {
      print('Auth error: ${e.message}');
      _showErrorDialog('Authentication Error', e.message);
    } on NetworkException catch (e) {
      print('Network error: ${e.message}');
      _showErrorDialog('Network Error', 'Check your connection');
    } on AirtableException catch (e) {
      print('Error fetching records: ${e.message}');
      _showErrorDialog('Error', e.message);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> createRecord() async {
    final newRecord = {
      'firstname': 'New',
      'lastname': 'User',
      'email': 'new.user@example.com',
    };

    try {
      await airtableCrud.createRecord(tableName, newRecord);
      await fetchRecords();
    } catch (e) {
      print('Error creating record: $e');
    }
  }

  Future<void> createBulkRecords() async {
    final dataList = [
      {
        'firstname': 'Bulk',
        'lastname': 'User1',
        'email': 'bulk.user1@example.com',
      },
      {
        'firstname': 'Bulk',
        'lastname': 'User2',
        'email': 'bulk.user2@example.com',
      },
      // Add more records as needed
    ];

    try {
      await airtableCrud.createBulkRecords(tableName, dataList);
      await fetchRecords();
    } catch (e) {
      print('Error bulk creating records: $e');
    }
  }

  Future<void> updateRecord(AirtableRecord record) async {
    try {
      // ✅ v1.3.0: Immutable update pattern
      final updated = record.updateField('lastname', 'Updated');
      final result = await airtableCrud.updateRecord(tableName, updated);
      print('Updated record: ${result.id}');
      await fetchRecords();
    } on ValidationException catch (e) {
      print('Validation error: ${e.message}');
      _showErrorDialog('Invalid Data', e.message);
    } on AirtableException catch (e) {
      print('Error updating record: ${e.message}');
      _showErrorDialog('Update Error', e.message);
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      // ✅ v1.3.0: Delete returns DeleteResult with metadata
      final result = await airtableCrud.deleteRecord(tableName, id);
      print('Deleted ${result.id} at ${result.deletedAt}');
      await fetchRecords();
    } on NotFoundException catch (e) {
      print('Record not found: ${e.message}');
      _showErrorDialog('Not Found', 'Record already deleted');
    } on AirtableException catch (e) {
      print('Error deleting record: ${e.message}');
      _showErrorDialog('Delete Error', e.message);
    }
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget buildRecordList() {
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        AirtableRecord record = records[index];
        return ListTile(
          title: Text(record.fields['firstname'] ?? 'No Name'),
          subtitle: Text(record.fields['email'] ?? ''),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => updateRecord(record),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => deleteRecord(record.id),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildLoading() {
    return Center(child: CircularProgressIndicator());
  }

  Widget buildContent() {
    if (isLoading) {
      return buildLoading();
    } else {
      return buildRecordList();
    }
  }

  void showActionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Action'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    createRecord();
                  },
                  child: Text('Create Single Record'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    createBulkRecords();
                  },
                  child: Text('Bulk Create Records'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Airtable CRUD Example'),
      ),
      body: buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showActionsDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}

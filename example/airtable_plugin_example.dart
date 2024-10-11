import 'package:flutter/material.dart';
import 'package:airtable_plugin/airtable_plugin.dart';
import 'package:airtable_plugin/src/models/airtable_record.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AirtableExample(),
    );
  }
}

class AirtableExample extends StatefulWidget {
  @override
  _AirtableExampleState createState() => _AirtableExampleState();
}

class _AirtableExampleState extends State<AirtableExample> {
  final String apiKey = 'YOUR_API_KEY';
  final String baseId = 'YOUR_BASE_ID';
  final String tableName = 'users';

  late AirtableService airtableService;
  List<AirtableRecord> records = [];

  @override
  void initState() {
    super.initState();
    airtableService = AirtableService(apiKey, baseId);
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    try {
      final fetchedRecords = await airtableService.fetchRecords(tableName);
      setState(() {
        records = fetchedRecords;
      });
    } catch (e) {
      print('Error fetching records: $e');
    }
  }

  Future<void> createRecord() async {
    final newRecord = AirtableRecord(
      id: '', // Leave the ID empty for creation
      fields: {
        'firstname': 'John',
        'lastname': 'Doe',
        'username': 'johndoe',
        'password': '1234abcd',
      },
    );

    try {
      await airtableService.createRecord(tableName, newRecord);
      fetchRecords(); // Refresh records after creating a new one
    } catch (e) {
      print('Error creating record: $e');
    }
  }

  Future<void> updateRecord(String recordId) async {
    final updatedRecord = AirtableRecord(
      id: recordId,
      fields: {
        'firstname': 'Updated Name',
      },
    );

    try {
      await airtableService.updateRecord(tableName, updatedRecord);
      fetchRecords(); // Refresh after updating
    } catch (e) {
      print('Error updating record: $e');
    }
  }

  Future<void> deleteRecord(String recordId) async {
    try {
      await airtableService.deleteRecord(tableName, recordId);
      fetchRecords(); // Refresh after deleting
    } catch (e) {
      print('Error deleting record: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Airtable Example')),
      body: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return ListTile(
            title: Text(record.fields['firstname'] ?? 'No Name'),
            subtitle: Text(record.fields['lastname'] ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => updateRecord(record.id),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteRecord(record.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: createRecord,
      ),
    );
  }
}

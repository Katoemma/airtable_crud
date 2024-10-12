import 'package:flutter/material.dart';
import 'package:airtable_plugin/airtable_plugin.dart';

void main() {
  runApp(const AirtableApp());
}

class AirtableApp extends StatelessWidget {
  const AirtableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airtable CRUD Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RecordListScreen(),
    );
  }
}

class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  final AirtableCrud airtableCrud =
      AirtableCrud('YOUR_AIRTABLE_API_KEY', 'YOUR_BASE_ID');
  List<AirtableRecord> records = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    try {
      final fetchedRecords = await airtableCrud.fetchRecords('your_table_name');
      setState(() {
        records = fetchedRecords;
        isLoading = false;
        errorMessage = ''; // Clear any previous errors
      });
    } on AirtableException catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching records: ${e.message} - ${e.details}';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  Future<void> _createRecord() async {
    try {
      final newRecord =
          AirtableRecord(fields: {'firstname': 'John', 'lastname': 'Doe'});
      await airtableCrud.createRecord('your_table_name', newRecord.fields);
      _fetchRecords(); // Refresh records after creation
    } on AirtableException catch (e) {
      setState(() {
        errorMessage = 'Error creating record: ${e.message} - ${e.details}';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  Future<void> _updateRecord(AirtableRecord record) async {
    try {
      record.fields['lastname'] = 'Updated Doe';
      await airtableCrud.updateRecord('your_table_name', record);
      _fetchRecords(); // Refresh records after update
    } on AirtableException catch (e) {
      setState(() {
        errorMessage = 'Error updating record: ${e.message} - ${e.details}';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  Future<void> _deleteRecord(String id) async {
    try {
      await airtableCrud.deleteRecord('your_table_name', id);
      _fetchRecords(); // Refresh records after deletion
    } on AirtableException catch (e) {
      setState(() {
        errorMessage = 'Error deleting record: ${e.message} - ${e.details}';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Airtable Records'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child:
                      Text(errorMessage, style: TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return ListTile(
                      title: Text(record.fields['firstname'] ?? 'Unknown'),
                      subtitle: Text(record.fields['lastname'] ?? 'Unknown'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _updateRecord(record),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteRecord(record.id!),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createRecord,
        child: Icon(Icons.add),
      ),
    );
  }
}

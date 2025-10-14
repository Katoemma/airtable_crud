import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/material.dart';

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
    airtableCrud = AirtableCrud(apiKey, baseId);
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<AirtableRecord> fetchedRecords =
          await airtableCrud.fetchRecords(tableName);
      setState(() {
        records = fetchedRecords;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching records: $e');
      setState(() {
        isLoading = false;
      });
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

  Future<void> bulkCreateRecords() async {
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
    // Modify the record's fields
    record.fields['lastname'] = 'Updated';

    try {
      await airtableCrud.updateRecord(tableName, record);
      await fetchRecords();
    } catch (e) {
      print('Error updating record: $e');
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      await airtableCrud.deleteRecord(tableName, id);
      await fetchRecords();
    } catch (e) {
      print('Error deleting record: $e');
    }
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
                    bulkCreateRecords();
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

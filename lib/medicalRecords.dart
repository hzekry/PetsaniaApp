import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petapp/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class records {
  final String description;
  final String next_visit;
  final String record_date;
  final String results;
  final String type;
  records({
    required this.description,
    required this.next_visit,
    required this.record_date,
    required this.results,
    required this.type,
  });
}

class medicalRecords extends StatefulWidget {
  final String petId;
  const medicalRecords({Key? key, required this.petId}) : super(key: key);

  @override
  State<medicalRecords> createState() => _medicalRecordsState();
}

class _medicalRecordsState extends State<medicalRecords> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _recordsStream;
  List<records> _records = [];
  @override
  void initState() {
    super.initState();
    _recordsStream = FirebaseFirestore.instance
        .collection('medicalRecord')
        .where('pet_id', isEqualTo: widget.petId)
        .snapshots();
  }
  Future<void> _addMedicalRecord(BuildContext context) async {
    TextEditingController _descriptionController = TextEditingController();
    TextEditingController _nextVisitController = TextEditingController();
    TextEditingController _recordDateController = TextEditingController();
    TextEditingController _resultsController = TextEditingController();
    TextEditingController _typeController = TextEditingController();


    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add new Medical Record'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _recordDateController,
                      decoration: InputDecoration(labelText: 'Record Date'),
                    ),
                    TextFormField(
                      controller: _typeController,
                      decoration: InputDecoration(labelText: 'Type'),
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                    TextFormField(
                      controller: _resultsController,
                      decoration: InputDecoration(labelText: 'Results'),
                    ),

                    TextFormField(
                      controller: _nextVisitController,
                      decoration: InputDecoration(labelText: 'Next Visit'),
                    ),




                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _descriptionController.text = '';
                      _nextVisitController.text = '';
                      _recordDateController.text = '';
                      _resultsController.text = '';
                      _typeController.text = '';
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xff3E54AC)),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Color(0xff3E54AC))),
                  onPressed: () async {


                    // Create a new document in the "medicalRecord" collection
                    await FirebaseFirestore.instance.collection('medicalRecord').add({
                      'pet_id': widget.petId,
                      'description': _descriptionController.text,
                      'next_visit': _nextVisitController.text,
                      'record_date': _recordDateController.text,
                      'results': _resultsController.text,
                      'type': _typeController.text,
                    });

                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        title: 'Medical History',
      ),
      body: SafeArea(
        child: Column(
          children: [
            IconButton(
              onPressed: () {
                _addMedicalRecord(context);
              },
              icon: Icon(Icons.add),
            ),
            Expanded(
              child: Container(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _recordsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading Records'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('No medical history available.'),
                    );
                  }

                  _records = snapshot.data!.docs.map((doc) {
                    return records(
                      description: doc['description'],
                      next_visit: doc['next_visit'],
                      record_date: doc['record_date'],
                      results: doc['results'],
                      type: doc['type'],
                    );
                  }).toList();
                  _records.sort((a, b) => b.record_date.compareTo(a.record_date));
                  return ListView.builder(
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      records Record = _records[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xffE0E0E0),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Date: ',
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    )),
                                SizedBox(
                                  width: 60,
                                ),
                                Text(Record.record_date,
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    )),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text('Type: ',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                                SizedBox(
                                  width: 65,
                                ),
                                Text(Record.type,
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                    )),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text('Description: ',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                                SizedBox(
                                  width: 15,
                                ),
                                Flexible(
                                  child: Text(Record.description,
                                      style: GoogleFonts.roboto(
                                        fontSize: 16,
                                      )),
                                )
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text('Results: ',
                                    style: GoogleFonts.roboto(
                                        fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(
                                  width: 45,
                                ),
                                Flexible(
                                  child: Text(Record.results,
                                      style: GoogleFonts.roboto(
                                        fontSize: 16,
                                      )),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Record.next_visit.isNotEmpty
                                ? SizedBox(height: 8)
                                : SizedBox.shrink(),
                            Record.next_visit.isNotEmpty
                                ? Row(
                                    children: [
                                      Text(
                                        'Next Visit: ',
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        Record.next_visit,
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                        ),
                                      )
                                    ],
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      );
                    },
                  );
                },
              )),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavBar(
        currentIndex: 1,
      ),
    );
  }
}

class medicalRecordForm extends StatefulWidget {
  const medicalRecordForm({Key? key}) : super(key: key);

  @override
  State<medicalRecordForm> createState() => _medicalRecordFormState();
}

class _medicalRecordFormState extends State<medicalRecordForm> {
  late TextEditingController _descriptionController;
  late TextEditingController _nextVisitController;
  late TextEditingController _recordDateController;
  late TextEditingController _resultsController;
  late TextEditingController _typeController;

  Future<void> _saveMedicalRecord() async {
    try {
      // Get the current user's ID
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid;

      // Create a new document in the "medicalRecord" collection
      await FirebaseFirestore.instance.collection('medicalRecord').add({
        'customer_id': userId,
        'description': _descriptionController.text,
        'next_visit': _nextVisitController.text,
        'record_date': _recordDateController.text,
        'results': _resultsController.text,
        'type': _typeController.text,
      });

      // Clear the form fields
      _descriptionController.clear();
      _nextVisitController.clear();
      _recordDateController.clear();
      _resultsController.clear();
      _typeController.clear();

      // Show a success message or navigate to a new screen
      // TODO: Add your desired logic here

    } catch (error) {
      // Show an error message
      print('Error saving medical record: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _nextVisitController = TextEditingController();
    _recordDateController = TextEditingController();
    _resultsController = TextEditingController();
    _typeController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _nextVisitController.dispose();
    _recordDateController.dispose();
    _resultsController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Medical Record'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _nextVisitController,
                decoration: InputDecoration(labelText: 'Next Visit'),
              ),
              TextFormField(
                controller: _recordDateController,
                decoration: InputDecoration(labelText: 'Record Date'),
              ),
              TextFormField(
                controller: _resultsController,
                decoration: InputDecoration(labelText: 'Results'),
              ),
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(labelText: 'Type'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {

                      _saveMedicalRecord();
                    },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../navbar.dart';
import 'CategoryScreen.dart';

class TopBusinessesScreen extends StatefulWidget {
  const TopBusinessesScreen({Key? key}) : super(key: key);

  @override
  _TopBusinessesScreenState createState() => _TopBusinessesScreenState();
}

class _TopBusinessesScreenState extends State<TopBusinessesScreen> {
  String selectedCategory = '';
  String selectedState = '';
  List<String> states = [
    'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 'HI', 'ID',
    'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS',
    'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK',
    'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV',
    'WI', 'WY',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        title: 'Top Businesses',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = '';
                      selectedState = '';
                    }
                    );
                  },
                  child: Text('All'),
                  style: ButtonStyle(

                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          )),
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xff3E54AC))),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ButtonStyle(

                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          )),
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xff3E54AC))),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Select Category'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(

                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      )),
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(Color(0xff3E54AC))),
                              onPressed: () {
                                setState(() {
                                  selectedCategory = 'Pet Sitting';
                                });
                                Navigator.pop(context);
                              },
                              child: Text('Pet Sitting'),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(

                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      )),
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(Color(0xff3E54AC))),
                              onPressed: () {
                                setState(() {
                                  selectedCategory = 'Pet Groomers';
                                });
                                Navigator.pop(context);
                              },
                              child: Text('Pet Groomers'),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(

                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      )),
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(Color(0xff3E54AC))),
                              onPressed: () {
                                setState(() {
                                  selectedCategory = 'Veterinarians';
                                });
                                Navigator.pop(context);
                              },
                              child: Text('Veterinarians'),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(

                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      )),
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(Color(0xff3E54AC))),
                              onPressed: () {
                                setState(() {
                                  selectedCategory = 'Pet Training';
                                });
                                Navigator.pop(context);
                              },
                              child: Text('Pet Training'),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(

                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      )),
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(Color(0xff3E54AC))),
                              onPressed: () {
                                setState(() {
                                  selectedCategory = 'Pet Stores';
                                });
                                Navigator.pop(context);
                              },
                              child: Text('Pet Stores'),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(

                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      )),
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(Color(0xff3E54AC))),
                              onPressed: () {
                                setState(() {
                                  selectedCategory = 'Pet Adoption';
                                });
                                Navigator.pop(context);
                              },
                              child: Text('Other'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Text('Category'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xff3E54AC)),
                  ),
                  onPressed: () {
                    showStateDialog();
                  },
                  child: Text('State'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getBusinessesStream(selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No businesses found.'));
                } else {
                  final businesses = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: businesses.length,
                    itemBuilder: (context, index) {
                      final business = businesses[index];
                      final rank = index + 1;

                      // Access the state and stars fields from the business document
                      final state = business['state'];
                      final stars = business['stars'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BusinessDetailScreen(
                                businessID: business['business_id'],
                                businessName: business['name'],
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: Text(
                            '$rank',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(business['name']),
                              Text('State: $state'), // Display the state
                            ],
                          ),
                          subtitle: Text('Stars: $stars'), // Display the stars
                          trailing: Text(
                              'Score: ${business['total_sentiment_score'].toStringAsFixed(2)}'),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> getBusinessesStream(String category) {
    Query query = FirebaseFirestore.instance
        .collection('businesses')
        .orderBy('total_sentiment_score', descending: true)
        .limit(10);

    if (category.isNotEmpty) {
      query = query.where('categories', arrayContains: category);
    }

    if (selectedState.isNotEmpty && selectedState != 'All') {
      query = query.where('state', isEqualTo: selectedState);
    }

    return query.snapshots();
  }

  void showStateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select State'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: states.map((state) {
              return ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Color(0xff3E54AC)),
                ),
                onPressed: () {
                  setState(() {
                    selectedState = state;
                  });
                  Navigator.pop(context);
                },
                child: Text(state),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

}

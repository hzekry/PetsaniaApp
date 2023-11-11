import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'categories/CategoryScreen.dart';

class BusinessSearch extends StatefulWidget {
  @override
  _BusinessSearchState createState() => _BusinessSearchState();
}

class _BusinessSearchState extends State<BusinessSearch> {
  TextEditingController _searchController = TextEditingController();
  late Stream<QuerySnapshot> _stream;
  String name = "";
  late DocumentSnapshot<Map<String, dynamic>> _lastBusinessDocument;
  final int _businessLimit = 10;
  ScrollController _scrollController = ScrollController();

  // @override
  // void initState() {
  //   super.initState();
  //   _stream = FirebaseFirestore.instance
  //       .collection('businesses')
  //       .limit(_businessLimit)
  //       .snapshots();
  //   // FirebaseFirestore.instance
  //   //     .collection('businesses')
  //   //     .limit(_businessLimit)
  //   //     .get()
  //   //     .then((querySnapshot) {
  //   //   if (querySnapshot.size > 0) {
  //   //     _lastBusinessDocument = querySnapshot.docs[querySnapshot.size - 1];
  //   //   }
  //   // });
  //   _scrollController.addListener(() {
  //     if (_scrollController.position.pixels ==
  //         _scrollController.position.maxScrollExtent) {
  //       setState(() {
  //         _stream = FirebaseFirestore.instance
  //             .collection('businesses')
  //             .startAfterDocument(_lastBusinessDocument)
  //             .limit(_businessLimit)
  //             .snapshots();
  //       });
  //     }
  //   });
  // }
  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance.collection('businesses').snapshots();
    _searchController.addListener(() {
      setState(() {
        if (_searchController.text.isEmpty) {
          _stream =
              FirebaseFirestore.instance.collection('businesses').snapshots();
        } else {
          String searchTerm = _searchController.text.toLowerCase();
          _stream = FirebaseFirestore.instance
              .collection('businesses')
              .orderBy('name', descending: false)
              .startAt([searchTerm]).endAt([searchTerm + '\uf8ff']).snapshots();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Color(0xff252969),
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color(0xFFEFEFEF),
        title: Card(
          child: TextField(
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: 'Search...'),
            onChanged: (value) {
              setState(() {
                name = value;
              });
            },
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _stream,
          builder: (context, snapshots) {
            return (!snapshots.hasData)
                ? Center(child: CircularProgressIndicator())
                : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      controller: _scrollController,
                      itemCount: snapshots.data!.docs.length,
                      itemBuilder: (context, index) {
                        var data = snapshots.data!.docs[index].data()
                        as Map<String, dynamic>;

                        if (index == snapshots.data!.docs.length - 1) {
                          _lastBusinessDocument = snapshots
                              .data!.docs[index]
                          as DocumentSnapshot<Map<String, dynamic>>;
                        }
                        if (name.isEmpty ||
                            data['name']
                                .toLowerCase()
                                .contains(name.toLowerCase())) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BusinessDetailScreen(
                                        businessID:
                                        snapshots.data!.docs[index].id,
                                        businessName: snapshots
                                            .data!.docs[index]
                                            .get('name'),
                                      ),
                                ),
                              );
                            },
                            child: ListTile(
                              title: Text(
                                data['name'],
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.oswald(
                                    fontSize: 16,
                                    color: Color(0xff252969),
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Row(
                                children: [
                                  Text(
                                    '${data['city']}, ',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.oswald(
                                        fontSize: 16,
                                        color: Color(0xff252969),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    data['state'],
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.oswald(
                                        fontSize: 16,
                                        color: Color(0xff252969),
                                        fontWeight: FontWeight.bold),
                                  ),

                                ],
                              ),
                              // leading: CircleAvatar(),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }),
                ),

              ],
            );
          }),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import '../navbar.dart';
import '../reservation.dart';
import 'leaveReview.dart';

class CategoryScreen extends StatefulWidget {
  final String category;
  // final String petType;
  final String userState;
  const CategoryScreen({Key? key, required this.category,
    // required this.petType,
    required this.userState
  }) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _businesses;
  late DocumentSnapshot<Map<String, dynamic>> _lastBusinessDocument;
  final int _businessLimit = 10;

  var categories = [
    'Pet Stores',
    'Pet Training',
    'Veterinarians',
    'Pet Sitting',
    'Pet Groomers',
    'Pet Adoption'
  ];
  final Map<String, Color> _categoryColors = {
    'Pet Stores': Color(0x9992ADED),
    'Pet Training': Color(0x9998BDBD),
    'Veterinarians': Color(0x99FFC727),
    'Pet Sitting': Color(0x99F19999),
    'Pet Groomers': Color(0x99C888D4),
    'Pet Adoption': Color(0x99C6FF00),
  };
  List<String> states = [
    'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 'HI', 'ID',
    'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS',
    'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK',
    'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV',
    'WI', 'WY',
  ];
  late String selectedState;
  List<String> userPets = [];
  var  selectedPetType;

  @override
  void initState() {
    super.initState();
     selectedState = widget.userState;
    _businesses = FirebaseFirestore.instance
        .collection('businesses')
        .where('categories', arrayContainsAny: widget.category.split(','))
        //.where('type',isEqualTo:  widget.petType.split(','))
         .where('state', isEqualTo: selectedState)
        // .orderBy('name')
        // .limit(_businessLimit)
        .snapshots();

        setState(() {
          _businesses = FirebaseFirestore.instance
              .collection('businesses')
              .where('categories', arrayContainsAny: widget.category.split(','))
              //.where('type', arrayContains: widget.petType.split(','))
               .where('state', isEqualTo: widget.userState)
              // .orderBy('name')
              .snapshots();
          getUserPets();
        });

  }

  void getUserPets() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      var petsQuery = FirebaseFirestore.instance
          .collection('pet')
          .where('customer_id', isEqualTo: currentUser.uid);

      var petsSnapshot = await petsQuery.get();
      var pets = petsSnapshot.docs;

      setState(() {
        userPets = pets.map((pet) => pet.get('species') as String).toList();
      });
    }
  }
  List<String> getCategories(List<dynamic> businessCategories) {
    final List<String> allCategories = [];
    for (var category in businessCategories) {
      allCategories.add(category.toString());
    }
    final List<String> remainingCategories = List.from(categories)
      ..removeWhere((category) => allCategories.contains(category));
    if (remainingCategories.isEmpty) {
      return allCategories;
    } else {
      allCategories.addAll(remainingCategories);
      return allCategories;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFEF),
      appBar: appBar(
        title: widget.category =='Pet Adoption' ? 'Other': widget.category,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: DropdownButton<String>(
              value: selectedState,
              items: states.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),

              onChanged: (String? newValue) {
                setState(() {
                  selectedState = newValue!;
                  _businesses = FirebaseFirestore.instance
                      .collection('businesses')
                      .where('categories',
                      arrayContainsAny: widget.category.split(','))
                      .where('state', isEqualTo: selectedState)
                      .snapshots();
                });
              },
              hint: Text('Select a state'),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          //   child: DropdownButton<String>(
          //     value: selectedPetType,
          //     items: userPets.map((String value) {
          //       return DropdownMenuItem<String>(
          //         value: value,
          //         child: Text(value),
          //       );
          //     }).toList(),
          //     onChanged: (String? newValue) {
          //       setState(() {
          //         selectedPetType = newValue!;
          //       });
          //     },
          //     hint: Text('Your Pet Types'),
          //   ),
          // ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _businesses,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    final businesses = snapshot.data!.docs;
                    if (businesses.isEmpty) {
                      return Center(child: Text('No businesses found.'));
                    }
                    _lastBusinessDocument = businesses[businesses.length - 1];
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final businessCategories =
                                  snapshot.data!.docs[index].get('categories');
                              final categories = getCategories(businessCategories);
                              final category = categories[0];
                              final cardColor =
                                  _categoryColors[category] ?? Color(0xFFEFEFEF);
                              if (index == snapshot.data!.docs.length - 1) {
                                _lastBusinessDocument = snapshot.data!.docs[index];
                              }
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BusinessDetailScreen(
                                        businessID: snapshot.data!.docs[index].id,
                                        businessName:
                                            snapshot.data!.docs[index].get('name'),
                                      ),
                                    ),
                                  );
                                },
                                child: Align(
                                  child: Container(
                                    width: 360,
                                    child: Card(
                                      color: cardColor,
                                      margin: EdgeInsets.only(bottom: 20.0),
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [

                                                Flexible(
                                                  child: Text(
                                                    '${snapshot.data!.docs[index].get('name')}',
                                                    style: GoogleFonts.oswald(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '${snapshot.data!.docs[index].get('city')}, ${snapshot.data!.docs[index].get('state')}',
                                                  style: GoogleFonts.oswald(
                                                      fontSize: 14,
                                                      color: Colors.white70),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '${snapshot.data!.docs[index].get('stars')}',
                                                  style: GoogleFonts.oswald(
                                                      fontSize: 11,
                                                      color: Colors.white),
                                                ),
                                                Row(
                                                  children: List.generate(
                                                    snapshot.data!.docs[index]
                                                        .get('stars')
                                                        .toInt(),
                                                    (i) => Icon(
                                                      Icons.star,
                                                      color: Colors.yellow,
                                                      size: 12,
                                                    ),
                                                  ).toList(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     setState(() {
                        //       _businesses = FirebaseFirestore.instance
                        //           .collection('businesses')
                        //           .where('categories',
                        //               arrayContainsAny: widget.category.split(','))
                        //           .orderBy('name')
                        //           .startAfterDocument(_lastBusinessDocument)
                        //           .limit(_businessLimit)
                        //           .snapshots();
                        //     });
                        //   },
                        //   child: Text('Load More'),
                        // ),
                      ],
                    );
                  }
                }),
          ),
        ],
      ),
      bottomNavigationBar: bottomNavBar(
        currentIndex: 0,
      ),
    );
  }
}


class BusinessDetailScreen extends StatefulWidget {
  final String businessID;
  final String businessName;
  final int reviewLimit = 2;

  const BusinessDetailScreen(
      {Key? key, required this.businessID, required this.businessName})
      : super(key: key);

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  bool showFullReview = false;
  bool showFullReviewl = false;
  String _formatTimestamp(Timestamp timestamp) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final dateTime = timestamp.toDate();
    return dateFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        title: widget.businessName,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('businesses')
            .doc(widget.businessID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final business = snapshot.data!.data();
          final images = business!['images'] as List<dynamic>?;
          final stars = business!['stars'];
          final commonWordsSentiment =
          business!['common_words_sentiment'] as Map<String, dynamic>?;

          List<Widget> attributeWidgets = [];
          if (business['attributes'] != null) {
            Map<String, dynamic> attributes = business['attributes'];
            for (String key in attributes.keys) {
              if (attributes[key] == "True") {
                attributeWidgets.add(Text(key));
              }
            }
          }
          List<Widget> commonWordWidgets = [];
          if (commonWordsSentiment != null) {
            commonWordsSentiment.forEach((word, data) {
              final count = data['count'];
              final sentiment = data['sentiment'];

              Widget? icon;
              if (sentiment == 'positive') {
                icon = Icon(
                  Icons.sentiment_satisfied,
                  color: Colors.green,
                );
              } else if (sentiment == 'negative') {
                icon = Icon(
                  Icons.sentiment_dissatisfied,
                  color: Colors.red,
                );
              }

              final wordWidget = Row(
                children: [
                  Text('$word ($count)'),
                  SizedBox(width: 5),
                  icon ?? SizedBox(),
                ],
              );

              commonWordWidgets.add(wordWidget);
            });
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (images != null && images.isNotEmpty)
                    CarouselSlider(
                      items: images.map((imageUrl) {
                        return Container(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        );
                      }).toList(),
                      options: CarouselOptions(
                        height: 200,
                        aspectRatio: 16 / 9,
                        viewportFraction: 0.8,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration:
                        Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      width: 400,
                      color: Colors.grey,
                      child: Center(
                        child: Text(
                          'No Image Available',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  Text(
                    business['name'] ?? '',
                    style: GoogleFonts.oswald(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${business['address']}, ',
                          style: GoogleFonts.oswald(fontSize: 15)),
                      Text('${business['city']}, ',
                          style: GoogleFonts.oswald(fontSize: 15)),
                      Text(business['state'] ?? '',
                          style: GoogleFonts.oswald(fontSize: 15)),
                    ],
                  ),
                  if (business['is_open'] == 1)
                    Text(
                      'Open Now',
                      style: GoogleFonts.oswald(
                          fontSize: 16, color: Colors.green),
                    )
                  else
                    Text(
                      'Closed',
                      style: GoogleFonts.oswald(
                          fontSize: 16, color: Colors.red),
                    ),
                  Text(
                    'Hours: ',
                    style: GoogleFonts.oswald(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    business['hours'] != null
                        ? business['hours']
                        .entries
                        .map((e) => '${e.key}: ${e.value}')
                        .join('\n')
                        : '',
                    style: GoogleFonts.oswald(fontSize: 16),
                  ),

                  SizedBox(
                    height: 8,
                  ),


                  if (attributeWidgets.isNotEmpty)
                    DefaultTextStyle(
                      style: GoogleFonts.oswald(fontSize: 16, color: Colors.indigo),
                      child: Column(
                        children: attributeWidgets,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservationScreen(
                            businessID: widget.businessID,
                          ),
                        ),
                      );
                    },
                    child: Text('Make a Reservation'),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.all(15)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xff3E54AC)),
                    ),
                  ), SizedBox(height: 10
                    ,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Divider(
                      thickness: 10,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: leaveReview(businessID: widget.businessID),
                  ),Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Divider(
                      thickness: 10,),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${business['stars']}',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 5),
                          for (int i = 0; i < business['stars']; i++)
                            Icon(
                              Icons.star,
                              color: Colors.yellow,
                            ),
                        ],
                      ),
                      Text('(${business['review_count']})'),
                    ],
                  ),


                  Padding(
                    padding: EdgeInsets.fromLTRB(100, 20, 100, 20),
                    child: Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: commonWordWidgets,
                      ),
                    ),
                  ),
                  Padding(
          padding: const EdgeInsets.all(8.0),
          child: Divider(
          thickness: 10,),
          ),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('review')
                        .where('businessID', isEqualTo: widget.businessID)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final reviews = snapshot.data!.docs;
                      if (reviews.isEmpty) {
                        return Text('');
                      } else {
                        return Column(
                          children: [
                            for (final reviewDoc in reviews)
                              ListTile(
                                title: Text('${reviewDoc.data()['stars']} stars'),
                                subtitle: Column(
                                  children: [
                                    Text('Date: ${_formatTimestamp(reviewDoc.data()['timestamp'])}'),
                                    Text(
                                      showFullReview
                                          ? reviewDoc.data()['text']
                                          : '${reviewDoc.data()['text'].substring(0, reviewDoc.data()['text'].length >= 250 ? 250 : reviewDoc.data()['text'].length)}',
                                    ),


                                    if (reviewDoc.data()['text'].length > 250)
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            showFullReview = !showFullReview;
                                          });
                                        },
                                        child: Text(
                                          showFullReview ? 'Show less' : 'Show more',
                                          style: TextStyle(color: Color(0xff252969)),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Divider(
                                thickness: 10,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('reviews')
                        .where('business_id',
                        isEqualTo: widget.businessID)
                    // .orderBy('date', descending: true)
                    // .limit(reviewLimit)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final reviews = snapshot.data!.docs;
                      if (reviews.isEmpty) {
                        return Text('No reviews available');
                      } else {
                        final review = reviews.first.data();
                        final stars = review['stars'];
                        final reviewText = review['text'];
                        final date = review['date'];

                        final reviewl = reviews.last.data();
                        final starsl = reviewl['stars'];
                        final reviewTextl = reviewl['text'];
                        final datel = reviewl['date'];

                        return Column(
                          children: [
                            ListTile(
                              title: Text('$stars stars'),
                              subtitle: Column(
                                children: [
                                  Text('Date: $date'),
                                  Text(
                                    showFullReview
                                        ? reviewText
                                        : '${reviewText.length <= 250 ? reviewText : reviewText.substring(0, 250)}...',
                                  ),

                                  if (reviewText.length > 250)
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          showFullReview = !showFullReview;
                                        });
                                      },
                                      child: Text(
                                        showFullReview
                                            ? 'Show less'
                                            : 'Show more',
                                        style: TextStyle(
                                            color: Color(0xff252969)),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Divider(
                                thickness: 10,),
                            ),
                            ListTile(
                              title: Text('$starsl stars'),
                              subtitle: Column(
                                children: [
                                  Text('Date: $datel'),
                                  Text(
                                    showFullReviewl
                                        ? reviewTextl
                                        : '${reviewTextl.length <= 250 ? reviewTextl : reviewTextl.substring(0, 250)}...',
                                  ),

                                  if (reviewTextl.length > 250)
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          showFullReviewl = !showFullReviewl;
                                        });
                                      },
                                      child: Text(
                                        showFullReviewl
                                            ? 'Show less'
                                            : 'Show more',
                                        style: TextStyle(
                                          color: Color(0xff252969),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: bottomNavBar(
        currentIndex: 0,
      ),
    );
  }
}
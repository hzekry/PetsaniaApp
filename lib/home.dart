import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'categories/CategoryScreen.dart';
import 'categories/top10.dart';
import 'navbar.dart';

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  int _currentIndex = 0;

  Future<void> navigateToCategoryScreen(String category) async {
    final user = FirebaseAuth.instance.currentUser;
    final petsSnapshot = await FirebaseFirestore.instance
        .collection('pet')
        .where('customer_id', isEqualTo: user!.uid)
        .get();
    final customerSnapshot = await FirebaseFirestore.instance
        .collection('Customer')
        .doc(user.uid)
        .get();


    final userState = customerSnapshot.get('state');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryScreen(category: category
          , userState: userState,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFEF),
      appBar: appBar(
        title: 'PETSANIA',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Spacer(),
                Text('Top 10',style: GoogleFonts.oswald(
                    color: Color(0xff252969), fontSize: 15),),
                IconButton(onPressed:(){Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TopBusinessesScreen()),);},
                  icon: Icon(Icons.stacked_line_chart, color: Color(0xff252969)),),
              ],
            ),


            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: MediaQuery.of(context).size.width * 0.35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0x80F44444),
                          ),
                          child: IconButton(
                              onPressed: () {
                                navigateToCategoryScreen('Pet Sitting');
                              },
                              icon: Image.asset(
                                "assets/daycare.png",
                                width: 150,
                                height: 150,
                              )),
                        ),
                      ),
                      Text(
                        "DayCare",
                        style: GoogleFonts.oswald(
                            color: Color(0xff252969), fontSize: 15),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: MediaQuery.of(context).size.width * 0.35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0x80C888D4)),
                          child: IconButton(
                              onPressed: () {
                                navigateToCategoryScreen('Pet Groomers');
                              },
                              icon: Image.asset(
                                "assets/grooming.png",
                                width: 100,
                                height: 100,
                              )),
                        ),
                      ),
                      Text(
                        "Grooming",
                        style: GoogleFonts.oswald(
                            color: Color(0xff252969), fontSize: 15),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: MediaQuery.of(context).size.width * 0.35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0x80FFC727)),
                          child: IconButton(
                              onPressed: () {
                                navigateToCategoryScreen('Veterinarians');
                              },
                              icon: Image.asset(
                                "assets/Veterinary.png",
                                width: 140,
                                height: 140,
                              )),
                        ),
                      ),
                      Text(
                        "Veterinary",
                        style: GoogleFonts.oswald(
                            color: Color(0xff252969), fontSize: 15),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: MediaQuery.of(context).size.width * 0.35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0x8098BDBD)),
                          child: IconButton(
                              onPressed: () {
                                navigateToCategoryScreen('Pet Training');
                              },
                              icon: Image.asset(
                                "assets/training.png",
                                width: 140,
                                height: 140,
                              )),
                        ),
                      ),
                      Text(
                        "Training",
                        style: GoogleFonts.oswald(
                            color: Color(0xff252969), fontSize: 15),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: MediaQuery.of(context).size.width * 0.35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0x8092ADED)),
                          child: IconButton(
                              onPressed: () {
                                navigateToCategoryScreen('Pet Stores');
                              },
                              icon: Image.asset(
                                "assets/petshop.png",
                                width: 160,
                                height: 160,
                              )),
                        ),
                      ),
                      Text(
                        "Petshop",
                        style: GoogleFonts.oswald(
                            color: Color(0xff252969), fontSize: 15),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: MediaQuery.of(context).size.width * 0.35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0x80C6FF00)),
                          child: IconButton(
                              onPressed: () {
                                navigateToCategoryScreen('Pet Adoption');
                              },
                              icon: Image.asset(
                                "assets/other.png",
                                width: 130,
                                height: 130,
                              )),
                        ),
                      ),
                      Text(
                        "Other",
                        style: GoogleFonts.oswald(
                            color: Color(0xff252969), fontSize: 15),
                      ),

                    ],

                  ),

                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavBar(
        currentIndex: _currentIndex,
      ),
    );
  }
}

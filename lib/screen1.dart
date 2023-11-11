import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login.dart';

class FirstScreen extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFEF),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              alignment: Alignment.bottomLeft,
              image: ResizeImage(
                AssetImage("assets/paws.png"),
                width: 171,
                height: 172,
              ),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Text(
                "PETSANIA",
                style: GoogleFonts.yesevaOne(
                  color: Color(0xff252969),
                  fontSize: 15,
                ),
              ),
              Image.asset(
                "assets/logo.png",
                width: 94,
                height: 96,
              ),
              Image.asset(
                "assets/familyout.png",
                width: 450,
                height: 350,
              ),
              Text(
                "ALL YOUR PET'S NEEDS",
                textAlign: TextAlign.center,
                style: GoogleFonts.oswald(fontSize: 20),
              ),
              SizedBox(
                height: 50,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const login()),
                  );
                },
                child: Text(
                  "Get Started",
                  style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.all(15)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    )),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xff3E54AC))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

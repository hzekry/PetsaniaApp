import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petapp/profile.dart';
import 'package:petapp/search.dart';

import 'home.dart';
import 'myPets.dart';

class appBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic title;
  const appBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Navigator.canPop(context)
          ? IconButton(
              color: Color(0xff252969),
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => BusinessSearch()));
            // showModalBottomSheet(
            //   context: context,
            //   isScrollControlled: true,
            //   builder: (context) => Container(
            //     height: 500,
            //     child: SingleChildScrollView(
            //       child: SizedBox(
            //           height: MediaQuery.of(context).size.height * 0.7,
            //           child: BusinessSearch()),
            //     ),
            //   ),
            // );
          },
          icon: Icon(Icons.search),
          color: Color(0xff252969),
        )
      ],
      backgroundColor: Color(0xFFEFEFEF),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/logo.png",
            width: 28,
            height: 29,
          ),
          Expanded(
            child: Text(
              title,
              style:
                  GoogleFonts.yesevaOne(color: Color(0xff252969), fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class bottomNavBar extends StatelessWidget {
  final int currentIndex;
  const bottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedLabelStyle: GoogleFonts.roboto(fontSize: 10),
      unselectedLabelStyle: GoogleFonts.roboto(fontSize: 10),
      selectedItemColor: Color(0xff3E54AC),
      backgroundColor: Color(0xffD9D9D9),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.pets), label: "My Pets"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => home()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PetsScreen()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => profile()),
            );
            break;
        }
      },
    );
  }
}

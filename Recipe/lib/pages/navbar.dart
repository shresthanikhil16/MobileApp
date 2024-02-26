import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF99bbff), // Set the color to 0xFFc6b7fe
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            child: IconButton(
              icon: Icon(Icons.local_dining),
              color: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/recipelist');
              },
            ),
          ),
          Container(
            child: IconButton(
              icon: Icon(Icons.add),
              color: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/createRecipe');
              },
            ),
          ),
          Container(
            child: IconButton(
              icon: Icon(Icons.person),
              color: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ),
        ],
      ),
    );
  }
}
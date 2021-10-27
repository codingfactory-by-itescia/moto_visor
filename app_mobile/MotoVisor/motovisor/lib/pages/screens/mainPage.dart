// ignore_for_file: file_names, camel_case_types

import 'package:flutter/material.dart';

import 'package:moto_visor/pages/screens/homepage.dart';

class mainPage extends StatelessWidget {
  const mainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 500,
              width: 500,
              child: Image.asset('assets/images/logo.png'),
            ),
            const SizedBox(height: 15),
            // ignore: prefer_const_constructors
            Text(
              'This is a slogan',
              style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Colors.lightBlue),
            ),
            const SizedBox(
              height: 20,
            ),
            ButtonTheme(
                minWidth: MediaQuery.of(context).size.width / 3,
                height: 55.0,
                // ignore: deprecated_member_use
                child: RaisedButton(
                  elevation: 0,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const homepage();
                    }));
                  },
                  color: Colors.lightBlue,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: const Text(
                    "Let's go !",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ignore: file_names
// ignore_for_file: camel_case_types, file_names, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:moto_visor/pages/bluetooth/bluetoothPage.dart';
import 'package:moto_visor/pages/home/location.dart';

class homepage extends StatelessWidget {
  const homepage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Home Page',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.all(5.0),
            child: IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const BluetoothPage();
                  }));
                },
                icon: const Icon(
                  Icons.bluetooth,
                  color: Colors.lightBlue,
                  size: 20,
                )),
          ),
        ],
      ),
      body: const LocationApp(),
    );
  }
}

// ignore: file_names
// ignore_for_file: camel_case_types, file_names, duplicate_ignore

import 'package:battery/battery.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:moto_visor/pages/bluetooth/bluetoothPage.dart';
import 'package:moto_visor/pages/navigation/navigationPage.dart';

class homepage extends StatefulWidget {
  const homepage({Key? key}) : super(key: key);

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  var _speedMsg = 'Vitesse';
  var _batteryMsg = 'Batterie';
  int _batteryPercent = 0;

  /// Get current speed with Location package
  void getCurrentSpeedLocation() async {
    Location location = Location();

    location.enableBackgroundMode(
        enable: true); // To receive location when application is in background

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.onLocationChanged.listen((LocationData currentLocation) {
      var _speed = (currentLocation.speed! * 3.6); // m/s => km/h
      var _speedString = _speed.toStringAsFixed(0);
      setState(() {
        _speedMsg = "$_speedString km/h";
      });
    });
  }

  void getBatteryLevel() async {
    var _battery = Battery();

    _batteryPercent = await _battery.batteryLevel;
    _batteryMsg = "$_batteryPercent%";

    _battery.onBatteryStateChanged.listen((BatteryState state) {
      setState(() {
        _batteryMsg = "$_batteryPercent%";
      });
    });
  }

  Color getColorByBatteryLevel() {
    Color _baterryColor;
    if (_batteryPercent <= 10) {
      _baterryColor = Colors.red[800]!;
    } else if (_batteryPercent > 10 && _batteryPercent < 20) {
      _baterryColor = Colors.orange[300]!;
    } else if (_batteryPercent >= 20 && _batteryPercent < 50) {
      _baterryColor = Colors.green[300]!;
    } else if (_batteryPercent >= 50 && _batteryPercent <= 99) {
      _baterryColor = Colors.green[600]!;
    } else {
      _baterryColor = Colors.green[900]!;
    }
    return _baterryColor;
  }

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
          'Accueil',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.all(5.0),
            child: IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const NavigationPage();
                  }));
                },
                icon: const Icon(
                  Icons.location_on,
                  color: Colors.lightBlue,
                  size: 20,
                )),
            ),
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
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  height: 180,
                  width: MediaQuery.of(context).size.width * 0.44,
                  child: GestureDetector(
                    onTap: () => getCurrentSpeedLocation(),
                    child: Card(
                      color: Colors.grey[50],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.speed_rounded,
                            size: 100,
                            color: Colors.blue[500],
                          ),
                          Text(_speedMsg)
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 180,
                  width: MediaQuery.of(context).size.width * 0.44,
                  child: GestureDetector(
                    onTap: () => getBatteryLevel(),
                    child: Card(
                      color: Colors.grey[50],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // ignore: prefer_const_literals_to_create_immutables
                        children: [
                          const Icon(Icons.battery_alert_rounded,
                              size: 100, color: Colors.green),
                          Text(_batteryMsg)
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  height: 180,
                  width: MediaQuery.of(context).size.width * 0.44,
                  child: GestureDetector(
                    onTap: () => {},
                    child: Card(
                      color: Colors.grey[50],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_video_rounded,
                            size: 100,
                            color: Colors.blue[500],
                          ),
                          const Text("Musique")
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 180,
                  width: MediaQuery.of(context).size.width * 0.44,
                  child: GestureDetector(
                    onTap: () => {},
                    child: Card(
                      color: Colors.grey[50],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.dark_mode,
                            size: 100,
                            color: Colors.blue[500],
                          ),
                          const Text("Mode sombre")
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

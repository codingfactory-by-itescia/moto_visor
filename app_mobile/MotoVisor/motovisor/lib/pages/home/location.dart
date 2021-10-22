import 'package:battery/battery.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationApp extends StatefulWidget {
  const LocationApp({Key? key}) : super(key: key);

  @override
  _LocationAppState createState() => _LocationAppState();
}

class _LocationAppState extends State<LocationApp> {
  var _speedMsg = '';
  var _batteryMsg = '';
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
    getCurrentSpeedLocation();
    getBatteryLevel();

    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(),
            Expanded(
              child: GridView.count(
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                primary: false,
                crossAxisCount: 2,
                children: [
                  GestureDetector(
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
                          Text("Vitesse $_speedMsg")
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => getBatteryLevel(),
                    child: Card(
                      color: Colors.grey[50],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.battery_alert_rounded,
                              size: 100, color: getColorByBatteryLevel()),
                          Text(_batteryMsg)
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => print("musique"),
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
                  GestureDetector(
                    onTap: () => print("mode sombre"),
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
                ],
              ),
            ),
          ],
        ));
  }
}

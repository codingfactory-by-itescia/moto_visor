// ignore_for_file: file_names, unused_import, import_of_legacy_library_into_null_safe
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:location/location.dart';
import 'package:moto_visor/pages/widget/widgets.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({Key? key}) : super(key: key);

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {

  String _platformVersion = 'Unknown';
  String _instruction = "";

  final _destination = WayPoint(
    name: "My destination",
    latitude: 48.97736288804228,
    longitude: 1.911989432551735
  );
  final _formKey = GlobalKey<FormState>();

  late MapBoxNavigation _directions;
  late MapBoxOptions _options;
  late MapBoxNavigationViewController _controller;

  bool _isMultipleStop = false;
  bool _routeBuilt = false;
  bool _isNavigating = false;
  
  double _distanceRemaining = 0.0;
  double _durationRemaining = 0.0;
  
 


  /// Get current location
  void getCurrentLocation() async {
    
    Location location = Location();

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

    LocationData _locationData;
    _locationData = await location.getLocation();

    setState(() {
      _latitude = _locationData.latitude!;
      _longitude = _locationData.longitude!;
    });
  }
  
  

  @override
  void initState() {
    super.initState();
    initialize();
  }

  late double _latitude, _longitude;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initialize() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    
    getCurrentLocation();
    

    _directions = MapBoxNavigation(onRouteEvent: _onEmbeddedRouteEvent);
    _options = MapBoxOptions(
      // initialLatitude: _latitude,
      // initialLongitude: _longitude,
      zoom: 10.0,
      tilt: 0.0,
      bearing: 0.0,
      enableRefresh: false,
      alternatives: true,
      voiceInstructionsEnabled: true,
      bannerInstructionsEnabled: true,
      allowsUTurnAtWayPoints: true,
      mode: MapBoxNavigationMode.drivingWithTraffic,
      units: VoiceUnits.imperial,
      simulateRoute: false,
      animateBuildRoute: true,
      longPressDestinationEnabled: true,
      language: "fr"
    );

    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await _directions.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    setState(() {
      _platformVersion = platformVersion;
    });
  }



  @override
  Widget build(BuildContext context) {

   

    return MaterialApp(
      home: Scaffold(
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
            'Navigation Page',
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        body: Center(
          child: Column(children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    inputText(
                      label: "Latitude",
                      obsecureText: false,
                      hintext: "48.97736288804228",
                      context: context
                    ),
                    const SizedBox(height: 20),
                    inputText(
                      label: "Longitude",
                      obsecureText: false,
                      hintext: "1.911989432551735",
                      context: context
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          // ignore: deprecated_member_use
                          child: RaisedButton(
                            textColor: Colors.white,
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text("Rechercher"),
                                SizedBox(width: 7),
                                Icon(Icons.search)
                              ],
                            ),
                            onPressed: () async {
                              var wayPoints = <WayPoint>[];
                              wayPoints.add(WayPoint(name: "my pos", latitude: _latitude, longitude: _longitude));
                              wayPoints.add(_destination);

                              await _directions.startNavigation(
                                wayPoints: wayPoints,
                                options: MapBoxOptions(
                                  mode:
                                    MapBoxNavigationMode.drivingWithTraffic,
                                    simulateRoute: false,
                                    language: "fr",
                                    units: VoiceUnits.metric
                                )
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey,
                child: MapBoxNavigationView(
                    options: _options,
                    onRouteEvent: _onEmbeddedRouteEvent,
                    onCreated:
                        (MapBoxNavigationViewController controller) async {
                      _controller = controller;
                      controller.initialize();
                    }),
              ),
            )
          ]),
        ),
      ),
    );
  }

  Future<void> _onEmbeddedRouteEvent(e) async {
    _distanceRemaining = await _directions.distanceRemaining;
    _durationRemaining = await _directions.durationRemaining;

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        if (progressEvent.currentStepInstruction != null)
          _instruction = progressEvent.currentStepInstruction!;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        setState(() {
          _routeBuilt = true;
        });
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {
          _routeBuilt = false;
        });
        break;
      case MapBoxEvent.navigation_running:
        setState(() {
          _isNavigating = true;
        });
        break;
      case MapBoxEvent.on_arrival:
        if (!_isMultipleStop) {
          await Future.delayed(const Duration(seconds: 3));
          await _controller.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        setState(() {
          _routeBuilt = false;
          _isNavigating = false;
        });
        break;
      default:
        break;
    }
    setState(() {});
  }
}
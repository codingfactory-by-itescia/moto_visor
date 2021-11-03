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

  final _formKey = GlobalKey<FormState>();
  late MapBoxNavigation _directions;
  late MapBoxNavigationViewController _controller;
  late double _positionLatitude, _positionLongitude;
  late String _destinationLatitude, _destinationLongitude;

  bool _isMultipleStop = false;
  bool _routeBuilt = false;
  bool _isNavigating = false;
  
  double _distanceRemaining = 0.0;
  double _durationRemaining = 0.0;

  String _instruction = "";
  
 
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
      _positionLatitude = _locationData.latitude!;
      _positionLongitude = _locationData.longitude!;
    });
  }
  
  
  @override
  void initState() {
    super.initState();
    initialize();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initialize() async {
    if (!mounted) return;
    getCurrentLocation();
    _directions = MapBoxNavigation(onRouteEvent: _onEmbeddedRouteEvent);
  }

   
  Widget buildLatitudeField() => TextFormField(
    decoration: const InputDecoration(
      labelText: "Latitude",
      hintText: "48.97736288804228",
      border: OutlineInputBorder(),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return "Veuillez entrer une latitude valide !";
      } 
      return null;
    },
    onSaved: (latitude) {
      _destinationLatitude = latitude!;
    },
    keyboardType: TextInputType.number,
  );

  Widget buildLongitudeField() => TextFormField(
    decoration: const InputDecoration(
      labelText: "Longitude",
      hintText: "1.911989432551735",
      border: OutlineInputBorder(),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return "Veuillez entrer une longitude valide !";
      }
     
      return null;
    },
    onSaved: (longitude) {
      _destinationLongitude = longitude!;
    },
    keyboardType: TextInputType.number,
  );


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
            'Navigation',
            style: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 20),
              buildLatitudeField(),
              const SizedBox(height: 20),
              buildLongitudeField(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    
                    var wayPoints = <WayPoint>[];
                    wayPoints.add(WayPoint(name: "Position", latitude: _positionLatitude, longitude: _positionLongitude));
                    wayPoints.add(WayPoint(name: "Destination", latitude: double.parse(_destinationLatitude), longitude:  double.parse(_destinationLongitude)));

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

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );
                  }
                },
                child: const Text('Rechercher'),
              ),
            ],
          ),
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
        if (progressEvent.currentStepInstruction != null) {
          _instruction = progressEvent.currentStepInstruction!;
        }
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
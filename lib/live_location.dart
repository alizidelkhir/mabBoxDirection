import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class LiveLocationPage extends StatefulWidget {
  static const String route = '/live_location';

  @override
  _LiveLocationPageState createState() => _LiveLocationPageState();
}

class _LiveLocationPageState extends State<LiveLocationPage> with TickerProviderStateMixin {
  LocationData _currentLocation;
  MapController _mapController;
  bool _liveUpdate = false;
  bool _permission = false;
  String _serviceError = '';
  var interActiveFlags = InteractiveFlag.all;
  final Location _locationService = Location();
  LatLng currentLatLng;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    initLocationService();
    if (_currentLocation != null) {
      currentLatLng = LatLng(_currentLocation.latitude, _currentLocation.longitude);
    } else {
      currentLatLng = LatLng(0, 0);
    }
  }

  void initLocationService() async {
    await _locationService.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 100,
    );

    LocationData location;
    bool serviceEnabled;
    bool serviceRequestResult;

    try {
      serviceEnabled = await _locationService.serviceEnabled();

      if (serviceEnabled) {
        var permission = await _locationService.requestPermission();
        _permission = permission == PermissionStatus.granted;

        if (_permission) {
          location = await _locationService.getLocation();
          _currentLocation = location;
          _locationService.onLocationChanged.listen((LocationData result) async {
            if (mounted) {

              setState(() {if (_currentLocation != null) {
                currentLatLng = LatLng(_currentLocation.latitude, _currentLocation.longitude);
              } else {
                currentLatLng = LatLng(0, 0);
              }
                _currentLocation = result;
                _animatedMapMove(currentLatLng, 14);
                // If Live Update is enabled, move map center
                if (_liveUpdate) {
                  _mapController.move(LatLng(_currentLocation.latitude, _currentLocation.longitude), _mapController.zoom);
                }
              });
            }
          });
        }
      } else {
        serviceRequestResult = await _locationService.requestService();
        if (serviceRequestResult) {
          initLocationService();
          return;
        }
      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        _serviceError = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        _serviceError = e.message;
      }
      location = null;
    }
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = Tween<double>(begin: _mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(begin: _mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: _mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)), _zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      if (_currentLocation != null) {
        currentLatLng = LatLng(_currentLocation.latitude, _currentLocation.longitude);
      } else {
        currentLatLng = LatLng(0, 0);
      }
    });

    var markers = <Marker>[
      Marker(
        width: 80.0,
        height: 80.0,
        point: currentLatLng,
        builder: (ctx) => Container(
          child: Icon(
            Icons.person_pin_circle,
            size: 45,
            color: Colors.red,
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      // drawer: buildDrawer(context, LiveLocationPage.route),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: _serviceError.isEmpty
                  ? Text('This is a map that is showing '
                      '(${currentLatLng.latitude}, ${currentLatLng.longitude}).')
                  : Text('Error occured while acquiring location. Error Message : '
                      '$_serviceError'),
            ),
            Flexible(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: LatLng(currentLatLng.latitude, currentLatLng.longitude),
                  zoom: 5.0,
                  interactiveFlags: interActiveFlags,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                        "https://api.mapbox.com/styles/v1/zidelkhirali/cksjfvz2kdqil17pewkaik9eb/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiemlkZWxraGlyYWxpIiwiYSI6ImNrc2xvcmR4ZDBrMnkydnBmbWpndGpuM2QifQ.AKvvShGlGwdDELOYbOpfgw",
                    additionalOptions: {
                      'accessToken': 'pk.eyJ1IjoiemlkZWxraGlyYWxpIiwiYSI6ImNrc2pmczhiOTJkY2oyb3FrcTh0cGkzeWoifQ.Myrxiv98xlSU09eF8M4V7g',
                      'id': 'mapbox.satellite',
                    },
                    tileProvider: NonCachingNetworkTileProvider(),
                  ),
                  MarkerLayerOptions(markers: markers)
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(builder: (BuildContext context) {
        return FloatingActionButton(
          onPressed: () {
            setState(() {
              _liveUpdate = !_liveUpdate;

              if (_liveUpdate) {
                interActiveFlags = InteractiveFlag.rotate | InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom;

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('In live update mode only zoom and rotation are enable'),
                ));
              } else {
                interActiveFlags = InteractiveFlag.all;
              }
            });
          },
          child: _liveUpdate ? Icon(Icons.location_on) : Icon(Icons.location_off),
        );
      }),
    );
  }
}

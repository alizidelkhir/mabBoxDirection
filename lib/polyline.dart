import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/mapbox_api.dart';

class PolylinePage extends StatefulWidget {
  static const String route = 'polyline';

  @override
  _PolylinePageState createState() => _PolylinePageState();
}

class _PolylinePageState extends State<PolylinePage> {
  Future<void> testDirection() async {
     print('i am testing detrectr');
    final mapbox = MapboxApi(
      accessToken: 'pk.eyJ1IjoiemlkZWxraGlyYWxpIiwiYSI6ImNrc2xvcmR4ZDBrMnkydnBmbWpndGpuM2QifQ.AKvvShGlGwdDELOYbOpfgw',
    );

    final response = await mapbox.directions.request(
      profile: NavigationProfile.DRIVING_TRAFFIC,
      overview: NavigationOverview.FULL,
      geometries: NavigationGeometries.GEOJSON,
      steps: true,
      coordinates: <List<double>>[
        <double>[
          32.786060, // latitude
          2.246225, // longitude
        ],
        <double>[
          32.785939, // latitude
          2.194292, // longitude
        ],
      ],
    );

    if (response.error != null) {
      if (response.error is NavigationNoRouteError) {
        // handle NoRoute response
        print('handle NoRoute response');

      } else if (response.error is NavigationNoSegmentError) {
        // handle NoSegment response
        print('handle NoSegment response');

      }

      return;
    }

    if (response.routes.isNotEmpty) {
      final route = response.routes[0];
      final eta = Duration(
        seconds: route.duration.toInt(),
      );
      print('duration >> '+eta.toString());
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    testDirection();
  }

  @override
  Widget build(BuildContext context) {
    var points = <LatLng>[
      LatLng(51.5, -0.09),
      LatLng(53.3498, -6.2603),
      LatLng(48.8566, 2.3522),
    ];

    var pointsGradient = <LatLng>[
      LatLng(55.5, -0.09),
      LatLng(54.3498, -6.2603),
      LatLng(52.8566, 2.3522),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Polylines')),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text('Polylines'),
            ),
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(51.5, -0.09),
                  zoom: 5.0,
                ),
                layers: [
                  TileLayerOptions(
                      urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c']),
                  PolylineLayerOptions(
                    polylines: [
                      Polyline(
                          points: points,
                          strokeWidth: 4.0,
                          color: Colors.purple),
                    ],
                  ),
                  PolylineLayerOptions(
                    polylines: [
                      Polyline(
                        points: pointsGradient,
                        strokeWidth: 4.0,
                        gradientColors: [
                          Color(0xffE40203),
                          Color(0xffFEED00),
                          Color(0xff007E2D),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
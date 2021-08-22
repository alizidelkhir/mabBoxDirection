import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class AnimatedMapControllerPage extends StatefulWidget {
  static const String route = 'map_controller_animated';

  @override
  AnimatedMapControllerPageState createState() {
    return AnimatedMapControllerPageState();
  }
}

class AnimatedMapControllerPageState extends State<AnimatedMapControllerPage>
    with TickerProviderStateMixin {
  static LatLng london = LatLng(33.80444563664255, 2.8713747279087243);
  static LatLng paris =LatLng(33.80444563664255, 2.8713747279087243) ;
  static LatLng dublin =  LatLng(33.7974559654647, 2.8496595634244666);

      MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
    CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation));
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
    var markers = <Marker>[
      Marker(
        width: 80.0,
        height: 80.0,
        point: london,
        builder: (ctx) => Container(
          key: Key('blue'),
          child:Icon(
            Icons.person_pin_circle,
            size: 45,
            color: Colors.red,
          ),
        ),
      ),
      Marker(
        width: 80.0,
        height: 80.0,
        point: dublin,
        builder: (ctx) => Container(
          child: Icon(
            Icons.person_pin_circle,
            size: 45,
            color: Colors.blue,
          ),
        ),
      ),
      Marker(
        width: 80.0,
        height: 80.0,
        point: paris,
        builder: (ctx) => Container(
          key: Key('purple'),
          child: Icon(
            Icons.person_pin_circle,
            size: 45,
            color: Colors.blueGrey,
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Animated MapController')),
      //drawer: buildDrawer(context, AnimatedMapControllerPage.route),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      _animatedMapMove(london, 14.0);
                    },
                    child: Text('London'),
                  ),
                  MaterialButton(
                    onPressed: () {
                      _animatedMapMove(paris, 5.0);
                    },
                    child: Text('Paris'),
                  ),
                  MaterialButton(
                    onPressed: () {
                      _animatedMapMove(dublin, 5.0);
                    },
                    child: Text('Dublin'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      var bounds = LatLngBounds();
                      bounds.extend(dublin);
                      bounds.extend(paris);
                      bounds.extend(london);
                      mapController.fitBounds(
                        bounds,
                        options: FitBoundsOptions(
                          padding: EdgeInsets.only(left: 15.0, right: 15.0),
                        ),
                      );
                    },
                    child: Text('Fit Bounds'),
                  ),
                ],
              ),
            ),
            Flexible(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                    center: LatLng(33.80792318714, 2.86251239024267),
                    zoom: 5.0,
                    maxZoom: 15.0,
                    minZoom: 10.0),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                    "https://api.mapbox.com/styles/v1/zidelkhirali/cksjfvz2kdqil17pewkaik9eb/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiemlkZWxraGlyYWxpIiwiYSI6ImNrc2xvcmR4ZDBrMnkydnBmbWpndGpuM2QifQ.AKvvShGlGwdDELOYbOpfgw",
                    additionalOptions: {
                      'accessToken': 'pk.eyJ1IjoiemlkZWxraGlyYWxpIiwiYSI6ImNrc2pmczhiOTJkY2oyb3FrcTh0cGkzeWoifQ.Myrxiv98xlSU09eF8M4V7g',
                      'id': 'mapbox.satellite',
                    },
                    // For example purposes. It is recommended to use
                    // TileProvider with a caching and retry strategy, like
                    // NetworkTileProvider or CachedNetworkTileProvider
                    tileProvider: NonCachingNetworkTileProvider(),
                  ),
                  MarkerLayerOptions(markers: markers)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
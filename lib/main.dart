import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:provider/provider.dart';

import 'ProjactNavigation/full_map.dart';
import 'ProjactNavigation/providers/mapProvider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DotEnv.dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        accentColor: Colors.pink[300],
      ),
      home: FullMap(),
    );
  }
}
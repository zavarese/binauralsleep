import 'package:flutter/material.dart';
import 'package:binauralsleep/shared_prefs.dart';
import 'package:binauralsleep/splash.dart';

Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await sharedPrefs.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Binaural Beats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Splash(),
    );
  }
}

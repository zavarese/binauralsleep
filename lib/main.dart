import 'package:flutter/material.dart';
import 'package:binauralsleep/util/shared_prefs.dart';
import 'package:binauralsleep/pages/splash.dart';

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
      title: 'Binaural Beats MP3',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Raleway'
      ),
      home: Splash(),
    );
  }
}

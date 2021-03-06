import 'package:flutter/material.dart';
import 'package:binauralsleep/pages/config_list.dart';
import 'package:flutter/services.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    super.initState();
    //SystemChrome.setEnabledSystemUIOverlays([]);
    Future.delayed(Duration(seconds: 4)).then((_){
      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ConfigPage(0,"Alpha",3,16,432,true)));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ListConfigPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,]);

    return Container(
        color: Colors.black,
        child: Center(
          child: Container(
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration (
              color: Colors.black,
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.asset("assets/binaural_logo.png"),
          ),
        )
    );
  }
}


import 'dart:async';
import 'package:binauralsleep/util/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'config_list.dart';
import 'package:binauralsleep/util/util.dart';

class Config extends State  {

  //Binaural parameters
  int id;
  String name;
  double isoBeatMin;
  double isoBeatMax;
  double frequency;
  String waveMin;
  String waveMax;
  String path;
  bool decreasing;
  double minutes;
  double seconds = sharedPrefs.seconds;
  double volumeMusic = sharedPrefs.volumeMusic;
  double volumeWaves = sharedPrefs.volumeWaves;
  bool loop = true;


  Config(this.id,this.name,this.isoBeatMin,this.isoBeatMax,this.waveMin,this.waveMax,this.path,this.frequency,this.decreasing, this.minutes);

  static const platform = const MethodChannel('com.zavarese.binauralsleep/binaural');
  String _responseFromNativeCode = '';
  String action = "";
  int _start;
  Timer _timer;
  var f = new NumberFormat("00.0", "en_US");

  //File browser
  String loading = "0.0Hz";
  //String _loadedFile = "none";
  //FilePickerResult result;
  //File file;

  //Execution status
  String isPlaying = "false";
  String currFreq = "0";
  final formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  void initState(){
    //getConfig();
    super.initState();
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Play configuration
  Future<void> _play() async {
    String response = "";

    try {
      response = await platform.invokeMethod('play', <String, dynamic>{
          'frequency': frequency.toString(),
          'isoBeatMax': isoBeatMax.toInt().toString(),
          'isoBeatMin': isoBeatMin.toInt().toString(),
          'minutes': minutes.toString(),
          'seconds': seconds.toString(),
          'volumeWave': (volumeWaves/10).toString(),
          'path': path,
          'volumeMusic': (volumeMusic/10).toString(),
          'decreasing': decreasing.toString(),
          'loop': loop.toString(),
      });

    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
    _startTimer();
    isPlaying = "true";
    setState(() {
      path = response;
    });
  }

  Future<String> _stop() async {
    String response = "";
    //result = null;

    try {
      final String value = await platform.invokeMethod('stop');
      response = value;
      isPlaying = "false";
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
    setState(() {
      currFreq = "0";
      _responseFromNativeCode = response;
    });

    return response;
  }

  //Get Current Frequency is playing
  Future<void> _track() async {
    String response = "";
    String value = "";
    try {

      value = await platform.invokeMethod('track');
      response = value;
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
    setState(() {currFreq = response;});
  }

  //Is playing ?
  Future<void> _playing() async {
    String response = "";
    String value = "";
    try {
      value = await platform.invokeMethod('playing');
      response = value;
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }

    setState(() {
      isPlaying = response;
      if(isPlaying=="false"){
          _timer.cancel();
          path="";
      }

      if(isPlaying=="error"){
        _timer.cancel();
        path="";
        currFreq = "0";
        isPlaying="false";
        funShowDialog(context,"Error:","Please, choose another file.");
      }
    });
  }

  //Start monitoring frequency and playing
  void _startTimer() {
    _start = ((minutes.toInt()+6)*60)+30;

    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(() {
        if (_start < 1) {
          timer.cancel();
        } else {
          _track();
          _playing();
          _start = _start - 1;
        }
      },
      ),
    );
  }

  //Insert config in DB
  Future<void> saveInsertButton() async {
    String response = "";

    debugPrint("insert ID : "+id.toString());

    try {
      final String value = await platform.invokeMethod('insert', <String, dynamic>{
        'name': name,
        'frequency': frequency.toInt().toString(),
        'isoBeatMax': isoBeatMax.toString(),
        'isoBeatMin': isoBeatMin.toString(),
        'decreasing': decreasing.toString(),
        'path': path,
        'minutes': minutes.toString(),
      });

      response = value;

    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }

    setState(() {id = int.parse(response);});
  }

  //Update config in DB
  Future<void> saveUpdateButton() async {
    String response = "";

    debugPrint("update ID : "+id.toString());

    try {
      final String value = await platform.invokeMethod('update', <String, dynamic>{
        'id': id,
        'name': name,
        'frequency': frequency.toInt().toString(),
        'isoBeatMax': isoBeatMax.toString(),
        'isoBeatMin': isoBeatMin.toString(),
        'decreasing': decreasing.toString(),
        'path': path,
        'minutes': minutes.toString(),
      });
      response = value;
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }

    setState(() {_responseFromNativeCode = response;});
  }

  //Delete config in DB
  Future<void> deleteButton() async{
    String response = "";

    try {
      final String value = await platform.invokeMethod('delete', <String, dynamic>{
        'id': id,});
      response = value;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ListConfigPage()));
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
  }

  //To get mp3 or wav files
  Future<void> musicButton() async {
    String response = "";

    setState(() {loading = "loading...";});

    try {
      path = await platform.invokeMethod('file_explorer');

      //while(path == ""){
        //path = await platform.invokeMethod('get_music');
      //}
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }

    debugPrint("flutter path: "+path);

    if(path=="error"){
      path = "";
    }

    debugPrint("flutter path: "+path);

    setState(() {loading = "0.0Hz";});
  }

  void backButton(){
    setState(() {
      if (isPlaying=="true") {
        _timer.cancel();
        _stop();
      }
    });
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ListConfigPage()));
  }

  //Play float button
  void playButton() {
    if(loading == "0.0Hz") {
      setState(() {
        if (isPlaying=="true") {
          _timer.cancel();
          _stop();
        } else {
          _play();
        }
      });
    }
  }

  //Loop music config
  void loopButton(){
    setState(() {
      if (loop == true) {
        loop = false;
      } else {
        loop = true;
      }
    });
  }

  //Decrease (down) or increase (up) beat frequency
  void upDownButton(){
    setState(() {
      if (decreasing == true) {
        decreasing = false;
      } else {
        decreasing = true;
      }
    });
  }

  //Set iso beat min and iso beat max frequency
  void setRangeFreqValues(values){
    setState(() {
      if (values.start + 1 > values.end) {
        values = RangeValues(isoBeatMin, isoBeatMin + 1);
      }else {
        isoBeatMin = values.start;
        isoBeatMax = values.end;
      }
    });
  }

  void setName(text){
    setState(() {
      name = text;
    });
  }

  //Carrier frequency
  void setFrequency(double value){
    setState(() {
      frequency = value;
    });
  }

  void setMinutes(double value) {
    setState(() {
      minutes = value;
    });
  }

  void setSeconds(double value) {
    setState(() {
      seconds = value;
      sharedPrefs.seconds = seconds;
    });
  }

  void setVolumeMusic(double value) {
    setState(() {
      volumeMusic = value;
      sharedPrefs.volumeMusic = volumeMusic;
    });
  }

  void setVolumeWaves(double value) {
    setState(() {
      volumeWaves = value;
      sharedPrefs.volumeWaves = volumeWaves;
    });
  }

  void setEmptyMusic(){
    if(isPlaying=="false") {
      setState(() {
        path = "";
      });
    }
  }
}
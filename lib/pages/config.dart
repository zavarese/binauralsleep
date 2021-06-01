import 'dart:async';
import 'dart:io';
import 'package:binauralsleep/util/shared_prefs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'config_list.dart';

class Config extends State  {

  //Binaural parameters
  int id;
  String name;
  double isoBeatMin;
  double isoBeatMax;
  double frequency;
  bool decreasing;
  double minutes = sharedPrefs.minutes;
  double volumeMusic = sharedPrefs.volumeMusic;
  double volumeWaves = sharedPrefs.volumeWaves;
  bool loop = true;

  Config(this.id,this.name,this.isoBeatMin,this.isoBeatMax,this.frequency,this.decreasing);

  static const platform = const MethodChannel('com.zavarese.binauralsleep/binaural');
  String _responseFromNativeCode = '';
  String action = "";
  int _start;
  Timer _timer;
  var f = new NumberFormat("###.#", "en_US");

  //File browser
  String loading = "0Hz";
  String _loadedFile = "none";
  FilePickerResult result;
  File file;

  //Frequency slider bar default values
  double freqMin = 130;
  double freqMax = 460;
  int division = 329;

  //Execution status
  bool isPlaying = false;
  String currFreq = "";
  final formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  void initState(){
    //getFrequencies();

    //getConfig();

    super.initState();
  }

  Future<void> addConfig() async {
    String response = "";

    debugPrint("insert ID : "+id.toString());

    try {
      final String value = await platform.invokeMethod('insert', <String, dynamic>{
        'name': name,
        'frequency': frequency.toInt().toString(),
        'isoBeatMax': isoBeatMax.toString(),
        'isoBeatMin': isoBeatMin.toString(),
        'decreasing': decreasing.toString(),
      });

      response = value;

    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }

    setState(() {id = int.parse(response);});
  }

  Future<void> updateConfig() async {
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
      });
      response = value;
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }

    setState(() {_responseFromNativeCode = response;});
  }

  Future<void> deleteConfig() async{
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

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //To get mp3 or wav files
  Future<void> fileBrowser() async {
    setState(() {loading = "loading...";});

    result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav'],
    );

    //result = await FilePicker.platform.getDirectoryPath();

    if(result != null) {
      file = File(result.files.single.path);
    }

    setState(() {loading = "0Hz";});
  }

  //Play configuration
  Future<void> _play(double volume) async {
    String response = "";

    if(result != null) {
      _loadedFile = file.path;
    }else{
      _loadedFile = "none";
    }

    //debugPrint("_loadedFile: "+_loadedFile);

    try {
      final String value = await platform.invokeMethod('play', <String, dynamic>{
        'frequency': frequency.toString(),
        'isoBeatMax': isoBeatMax.toString(),
        'isoBeatMin': isoBeatMin.toString(),
        'minutes': minutes.toString(),
        'volumeWave': (volume/10).toString(),
        'url': _loadedFile,
        'volumeNoise': (volumeMusic/10).toString(),
        'decreasing': decreasing.toString(),
        'loop': loop.toString(),
      });
      response = value;
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
    setState(() {_responseFromNativeCode = response;});
  }

  Future<String> _stop() async {
    String response = "";
    result = null;

    try {
      final String value = await platform.invokeMethod('stop');
      response = value;
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
    setState(() {
      currFreq = "";
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
      if(response=="true") {
        isPlaying = true;
      }else{
        _timer.cancel();
        isPlaying = false;
        result=null;
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

  void backList(){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ListConfigPage()));
  }

  void setName(text){
    setState(() {
      name = text;
    });
  }

  //Play float button
  void playButton() {
    if(loading == "0Hz") {
      setState(() {
        if (isPlaying) {
          _timer.cancel();
          _stop();
          isPlaying = false;
        } else {
          _play(volumeWaves);
          _startTimer();
          isPlaying = true;
        }
      });
    }
  }

  void setFrequency(double value){
    setState(() {
      frequency = value;
    });
  }

  void setMinutes(double value) {
    setState(() {
      minutes = value;
      sharedPrefs.minutes = minutes;
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
    if(loading == "0Hz" && isPlaying==false) {
      setState(() {
        result = null;
      });
    }
  }

  void setDecreasing(){
    setState(() {
      if (decreasing == true) {
        decreasing = false;
      } else {
        decreasing = true;
      }
    });
  }

  void setLoop(){
    setState(() {
      if (loop == true) {
        loop = false;
      } else {
        loop = true;
      }
    });
  }

}
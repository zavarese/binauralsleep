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
  String waveMin;
  String waveMax;
  String path;
  bool decreasing;
  double minutes = sharedPrefs.minutes;
  double volumeMusic = sharedPrefs.volumeMusic;
  double volumeWaves = sharedPrefs.volumeWaves;
  bool loop = true;

  Config(this.id,this.name,this.isoBeatMin,this.isoBeatMax,this.waveMin,this.waveMax,this.path,this.frequency,this.decreasing);

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

  //Execution status
  bool isPlaying = false;
  String currFreq = "0";
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

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Play configuration
  Future<void> _play(double volume) async {
    String response = "";

    if(result != null) {
      _loadedFile = file.path;
      path = _loadedFile;
    }else{
      if(path == null) {
        _loadedFile = "none";
      }else{
        _loadedFile = path;
      }
    }

    //debugPrint("_loadedFile: "+_loadedFile);

    try {
      final String value = await platform.invokeMethod('play', <String, dynamic>{
        'frequency': frequency.toString(),
        'isoBeatMax': isoBeatMax.toString(),
        'isoBeatMin': isoBeatMin.toString(),
        'minutes': minutes.toString(),
        'volumeWave': (volume/10).toString(),
        'path': _loadedFile,
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
    //result = null;

    try {
      final String value = await platform.invokeMethod('stop');
      response = value;
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
        'path': (path==null?"":path),
      });

      response = value;

    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }

    setState(() {id = int.parse(response);});
  }

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
        'path': (path==null?"":path),
      });
      response = value;
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }

    setState(() {_responseFromNativeCode = response;});
  }

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

  void backButton(){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ListConfigPage()));
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

  void loopButton(){
    setState(() {
      if (loop == true) {
        loop = false;
      } else {
        loop = true;
      }
    });
  }

  void upDownButton(){
    setState(() {
      if (decreasing == true) {
        decreasing = false;
      } else {
        decreasing = true;
      }
    });
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

  void setName(text){
    setState(() {
      name = text;
    });
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
        path = null;
      });
    }
  }

}
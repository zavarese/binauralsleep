import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:binauralsleep/util/shared_prefs.dart';
import 'package:binauralsleep/util/style.dart';
import 'package:binauralsleep/util/components.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import 'config_list.dart';

class ConfigPage extends StatefulWidget {
  int id;
  String name;
  double isoBeatMin;
  double isoBeatMax;
  double frequency;
  bool decreasing;
  ConfigPage(this.id,this.name,this.isoBeatMin,this.isoBeatMax,this.frequency,this.decreasing);
  @override
  ConfigPageState createState() => new ConfigPageState(this.id,this.name,this.isoBeatMin,this.isoBeatMax,this.frequency,this.decreasing);
}

class ConfigPageState extends State<ConfigPage> with WidgetsBindingObserver  {
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

  ConfigPageState(this.id,this.name,this.isoBeatMin,this.isoBeatMax,this.frequency,this.decreasing);

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
  final _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return new Scaffold(
        resizeToAvoidBottomInset: false, //block the widgets inside the Scaffold to resize themselves when the keyboard opens
        appBar: appBar(),
        backgroundColor: Colors.black,
        body: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment:  MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(padding: const EdgeInsets.all(8.0)),
                    Text(
                        (currFreq==""?loading:f.format(double.parse(currFreq))+"Hz"),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32)
                    ),
                    Padding(padding: const EdgeInsets.all(5.0)),
                    Text(
                        (decreasing ? "Beat Frequency: "+isoBeatMax.toInt().toString()+"Hz to "+isoBeatMin.toInt().toString()+"Hz"
                            :"Beat Frequency: "+isoBeatMin.toInt().toString()+"Hz to "+isoBeatMax.toInt().toString()+"Hz"),
                        textAlign: TextAlign.left,
                        style: textStyle
                    ),
                    sliderBeat(context),
                    Text(
                        "Carrier Frequency: "+frequency.toInt().toString()+"Hz",
                        textAlign: TextAlign.left,
                        style: textStyle
                    ),
                    SliderCustomState(
                        sliderCustom: SliderCustom(
                            value: frequency,
                            valueMin: freqMin,
                            valueMax: freqMax,
                            division: division,
                            function: setFrequency
                        )
                    ),
                    Text(
                        "Time: "+minutes.toInt().toString()+"min",
                        textAlign: TextAlign.left,
                        style: textStyle
                    ),
                    SliderCustomState(
                        sliderCustom: SliderCustom(
                            value: minutes,
                            valueMin: 15.0,
                            valueMax: 60.0,
                            division: 44,
                            function: setMinutes
                        )
                    ),
                    Text(
                        "Waves Volume: "+(volumeWaves).toStringAsFixed(0)+"%",
                        textAlign: TextAlign.left,
                        style: textStyle
                    ),
                    SliderCustomState(
                        sliderCustom: SliderCustom(
                            value: volumeWaves,
                            valueMin: 10.0,
                            valueMax: 100.0,
                            division: 89,
                            function: setVolumeWaves
                        )
                    ),
                    Text(
                        "Music Volume: "+(volumeMusic).toStringAsFixed(0)+"%",
                        textAlign: TextAlign.left,
                        style: textStyle
                    ),
                    SliderCustomState(
                        sliderCustom: SliderCustom(
                            value: volumeMusic,
                            valueMin: 10.0,
                            valueMax: 100.0,
                            division: 89,
                            function: setVolumeMusic
                        )
                    ),
                    Padding(padding: const EdgeInsets.all(3.0)),
                    Row(
                      mainAxisAlignment:  MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                            children: <Widget>[
                              ButtonCustomState(
                                button: ButtonCustom(
                                    label: (isPlaying ? "stop" : "play"),
                                    active: (isPlaying ? true : false),
                                    function: playButton
                                ),
                              ),
                            ]
                        ),
                        Column(children: <Widget>[SizedBox(width:4)]),
                        Column(
                            children: <Widget>[
                              ButtonCustomState(
                                button: ButtonCustom(
                                    label: 'music',
                                    active: (result==null?false:true),
                                    function: (isPlaying==false?(loading == "0Hz"?(result==null?fileBrowser:emptyMusic):null):null),
                                ),
                              ),
                            ]
                        ),
                        Column(children: <Widget>[SizedBox(width:4)]),
                        Column(
                            children: <Widget>[
                              ButtonCustomState(
                                button: ButtonCustom(
                                    label: 'loop',
                                    active: (loop==true?true:false),
                                    function: (isPlaying==false?setLoop:null),
                                ),
                              ),
                            ]
                        ),
                      ]
                    ),
                    Row(
                      mainAxisAlignment:  MainAxisAlignment.center,
                      children: <Widget>[SizedBox(height: 4,)]
                    ),
                    Row(
                      mainAxisAlignment:  MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                            children: <Widget>[
                              ButtonCustomState(
                                button: ButtonCustom(
                                    label: (decreasing==true?'down':'up'),
                                    active: false,
                                    function: (isPlaying==false?setDecreasing:null),
                                ),
                              ),
                            ]
                        ),
                        Column(children: <Widget>[SizedBox(width:4)]),
                        Column(
                            children: <Widget>[
                              ButtonCustomState(
                                button: ButtonCustom(
                                    label: 'save',
                                    active: false,
                                    function: (isPlaying==false?(id==0?addConfig:updateConfig):null),
                                ),
                              ),
                            ]
                        ),
                        Column(children: <Widget>[SizedBox(width:4)]),
                        Column(
                            children: <Widget>[
                              ButtonCustomState(
                                button: ButtonCustom(
                                    label: 'delete',
                                    active: false,
                                    function: (isPlaying==false?(id==0?null:deleteConfig):null)
                                ),
                              ),
                            ]
                        ),
                      ]
                    ),
                  ],
                ),
              ],
            )
          ],
        )
    );
  }

  @override
  void initState(){
    getFrequencies();

    //getConfig();

    super.initState();
  }

  //Get min and max values of frequency from hardware to frequency slider bar
  Future<void> getFrequencies() async{
    String response = "";
    String min;
    String max;

    try {
      final String value = await platform.invokeMethod('init');
      final split = value.split(',');
      final Map<int, String> values = {
        for (int i = 0; i < split.length; i++)
          i: split[i]
      };

      min = values[0];
      max = values[1];

    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
    setState(() {
      freqMin = double.parse(min);
      freqMax = double.parse(max);
      division = freqMax.toInt() - freqMin.toInt() - 1;
    });
  }

  Future<void> addConfig() async {
    String response = "";

    try {
      final String value = await platform.invokeMethod('insert', <String, dynamic>{
        'name': name,
        'frequency': frequency.toInt().toString(),
        'isoBeatMax': isoBeatMax.toString(),
        'isoBeatMin': isoBeatMin.toString(),
        'decreasing': decreasing.toString(),
      });

    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
  }

  Future<void> updateConfig() async {
    String response = "";

    debugPrint("ID : "+id.toString());

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

/*
  Future<void> getConfig() async{
    String response = "";
    String configName;
    String configBeatMin;
    String configBeatMax;
    String configFrequency;

    try {
      final String value = await platform.invokeMethod('config', <String, dynamic>{'id': id});
      final split = value.split(',');
      final Map<int, String> values = {
        for (int i = 0; i < split.length; i++)
          i: split[i]
      };

      configName = values[0];
      configBeatMin = values[1];
      configBeatMax = values[2];
      configFrequency = values[3];

    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
    setState(() {
      name = configName;
      isoBeatMin = double.parse(configBeatMin);
      isoBeatMax = double.parse(configBeatMax);
      frequency = double.parse(configFrequency);
    });
  }

 */
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
  Future<void> play(double volume) async {
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

  Future<String> stop() async {
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
  Future<void> track() async {
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
  Future<void> playing() async {
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
  void startTimer() {
    _start = ((minutes.toInt()+6)*60)+30;

    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(() {
        if (_start < 1) {
          timer.cancel();
        } else {
          track();
          playing();
          _start = _start - 1;
        }
      },
      ),
    );
  }

  //Play float button
  void playButton() {
    if(loading == "0Hz") {
          setState(() {
            if (isPlaying) {
              _timer.cancel();
              stop();
              isPlaying = false;
            } else {
              play(volumeWaves);
              startTimer();
              isPlaying = true;
            }
          });
        }
  }

  Widget appBar () {

    return AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ListConfigPage()))
          ),
        ],
        title: Form(
          key: _formKey,
          child:TextFormField(
            initialValue: name,
            inputFormatters: [new  WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]")),], //Letters and numbers only
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            decoration: InputDecoration(
                labelText: "Config name:",
                labelStyle: TextStyle(
                  color: Colors.white,
                )
            ),
            onChanged: (text) {
              setState(() {
                name = text;
              });
            },
          ),
        )
    );
  }

  //Beat frequency slider bar
  Widget sliderBeat(BuildContext context) {
    RangeValues valuesRange = RangeValues(isoBeatMin, isoBeatMax);
    RangeLabels labels = RangeLabels(isoBeatMin.toInt().toString(), isoBeatMax.toInt().toString());

    return Container(
      width: MediaQuery.of(context).size.width,
      child: RangeSlider(
          divisions: 39,
          min: 1.0,
          max: 40.0,
          values: valuesRange,
          labels: labels,
          onChanged: (values) {
          setState(() {
            if (values.start + 1 > values.end) {
              valuesRange = RangeValues(isoBeatMin, isoBeatMin + 1);
            }else {
              isoBeatMin = values.start;
              isoBeatMax = values.end;
            }
          });
        },
      ),
    );
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

  void emptyMusic(){
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

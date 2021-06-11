
import 'package:binauralsleep/util/style.dart';
import 'package:binauralsleep/util/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config.dart';
import 'package:binauralsleep/util/util.dart';

class ConfigPage extends StatefulWidget {
  int id;
  String name;
  double isoBeatMin;
  double isoBeatMax;
  String waveMin;
  String waveMax;
  String path;
  double frequency;
  bool decreasing;
  ConfigPage(this.id,this.name,this.isoBeatMin,this.isoBeatMax,this.waveMin,this.waveMax,this.path,this.frequency,this.decreasing);
  @override
  Config createState() => new ConfigPageState(this.id,this.name,this.isoBeatMin,this.isoBeatMax,this.waveMin,this.waveMax,this.path,this.frequency,this.decreasing);
}

class ConfigPageState extends Config with WidgetsBindingObserver  {

  ConfigPageState(int id, String name, double isoBeatMin, double isoBeatMax, String waveMin, String waveMax, String path, double frequency, bool decreasing) : super(id, name, isoBeatMin, isoBeatMax, waveMin, waveMax, path, frequency, decreasing);

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return new Scaffold(
        resizeToAvoidBottomInset: false, //block the widgets inside the Scaffold to resize themselves when the keyboard opens
        appBar: AppBarStateCustom(
          appBarCustom: AppBarCustom(
            formKey: formKey,
            name: name,
            icon: Icons.arrow_back,
            label: "Config name:",
            iconBtnFunction: backButton,
            inputTxtFunction: setName,
          ),
        ),
        backgroundColor: Colors.black,
        body: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment:  MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(padding: const EdgeInsets.all(8.0)),
                    (loading=="loading..."?CircularProgressIndicator():
                    Text(
                        f.format(double.parse(currFreq)).toString()+"Hz",
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 32)
                    )),
                    Padding(padding: const EdgeInsets.all(5.0)),
                    Text(
                        (decreasing ? "Beat Frequency: "+waveWord(isoBeatMax)+"["+isoBeatMax.toInt().toString()+"Hz] to "+waveWord(isoBeatMin)+"["+isoBeatMin.toInt().toString()+"Hz]"
                            :"Beat Frequency: "+waveWord(isoBeatMin)+"["+isoBeatMin.toInt().toString()+"Hz] to "+waveWord(isoBeatMax)+"["+isoBeatMax.toInt().toString()+"Hz]"),
                        textAlign: TextAlign.left,
                        style: textStyle
                    ),
                    RangeSliderCustomState(
                      sliderCustom: RangeSliderCustom(
                        isoBeatMin: isoBeatMin,
                        isoBeatMax: isoBeatMax,
                        function: setRangeFreqValues,
                      ),
                    ),
                    Text(
                        "Carrier Frequency: "+frequency.toInt().toString()+"Hz",
                        textAlign: TextAlign.left,
                        style: textStyle
                    ),
                    SliderCustomState(
                        sliderCustom: SliderCustom(
                            value: frequency,
                            valueMin: 100,
                            valueMax: 528,
                            division: 427,
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
                                    label: (isPlaying=="true" ? "STOP" : "PLAY"),
                                    active: (isPlaying=="true" ? true : false),
                                    function: (loading=="loading..."?null:playButton),
                                ),
                              ),
                            ]
                        ),
                        Column(children: <Widget>[SizedBox(width:4)]),
                        Column(
                            children: <Widget>[
                              ButtonCustomState(
                                button: ButtonCustom(
                                    label: 'MUSIC',
                                    active: (path==""||path=="error"?false:true),
                                    function: (isPlaying=="false"?(path==""?musicButton:setEmptyMusic):null),
                                ),
                              ),
                            ]
                        ),
                        Column(children: <Widget>[SizedBox(width:4)]),
                        Column(
                            children: <Widget>[
                              ButtonCustomState(
                                button: ButtonCustom(
                                    label: 'LOOP',
                                    active: (loop==true?true:false),
                                    function: (isPlaying=="false"?loopButton:null),
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
                                    label: (decreasing==true?'DOWN':'UP'),
                                    active: false,
                                    function: (isPlaying=="false"?upDownButton:null),
                                ),
                              ),
                            ]
                        ),
                        Column(children: <Widget>[SizedBox(width:4)]),
                        Column(
                            children: <Widget>[
                              ButtonCustomState(
                                button: ButtonCustom(
                                    label: 'SAVE',
                                    active: false,
                                    function: (isPlaying=="true" || loading=="loading..."?null:(id==0?saveInsertButton:saveUpdateButton)),
                                ),
                              ),
                            ]
                        ),
                        Column(children: <Widget>[SizedBox(width:4)]),
                        Column(
                            children: <Widget>[
                              ButtonCustomState(
                                button: ButtonCustom(
                                    label: 'DELETE',
                                    active: false,
                                    function: (isPlaying=="true" || loading=="loading..."?null:(id==0?null:deleteButton))
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
}

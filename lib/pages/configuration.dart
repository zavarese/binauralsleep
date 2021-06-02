
import 'package:binauralsleep/util/style.dart';
import 'package:binauralsleep/util/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config.dart';

class ConfigPage extends StatefulWidget {
  int id;
  String name;
  double isoBeatMin;
  double isoBeatMax;
  double frequency;
  bool decreasing;
  ConfigPage(this.id,this.name,this.isoBeatMin,this.isoBeatMax,this.frequency,this.decreasing);
  @override
  Config createState() => new ConfigPageState(this.id,this.name,this.isoBeatMin,this.isoBeatMax,this.frequency,this.decreasing);
}

class ConfigPageState extends Config with WidgetsBindingObserver  {

  ConfigPageState(int id, String name, double isoBeatMin, double isoBeatMax, double frequency, bool decreasing) : super(id, name, isoBeatMin, isoBeatMax, frequency, decreasing);

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
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32)
                    )),
                    Padding(padding: const EdgeInsets.all(5.0)),
                    Text(
                        (decreasing ? "Beat Frequency: "+isoBeatMax.toInt().toString()+"Hz to "+isoBeatMin.toInt().toString()+"Hz"
                            :"Beat Frequency: "+isoBeatMin.toInt().toString()+"Hz to "+isoBeatMax.toInt().toString()+"Hz"),
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
                                    label: (isPlaying ? "stop" : "play"),
                                    active: (isPlaying ? true : false),
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
                                    label: 'music',
                                    active: (result==null?false:true),
                                    function: (isPlaying==false?(loading == "0Hz"?(result==null?musicButton:setEmptyMusic):null):null),
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
                                    function: (isPlaying==false?musicButton:null),
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
                                    function: (isPlaying==false?upDownButton:null),
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
                                    function: (isPlaying==true || loading=="loading..."?null:(id==0?saveInsertButton:saveUpdateButton)),
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
                                    function: (isPlaying==true || loading=="loading..."?null:(id==0?null:deleteButton))
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

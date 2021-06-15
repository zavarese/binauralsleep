
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
            label: "config name:",
            iconBtnFunction: backButton,
            inputTxtFunction: setName,
          ),
        ),
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
        child:Column(
          children: <Widget>[
            Row(
              mainAxisAlignment:  MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(padding: const EdgeInsets.all(5.0)),
                    DisplayCustomState(
                      displayCustom: DisplayCustom(
                        value: f.format(double.parse(currFreq)).toString(),
                      ),
                    ),
                  ]
                ),
                Column(
                    children: <Widget>[
                      Padding(padding: const EdgeInsets.all(5.0)),
                      Row(
                          children: <Widget>[
                            SquareCustomState(
                              squareCustom: SquareCustom(
                                value: "START",
                                width: 50,
                                height: 25,
                                borderColor: Color.fromRGBO(63, 111, 66, 1),
                                textStyle: textStyleConfigSquare,
                                backgroundColor: Color.fromRGBO(28, 27, 27, 1),
                              ) ,
                            )
                          ]
                      ),
                      Row(
                          children: <Widget>[
                            SquareCustomState(
                              squareCustom: SquareCustom(
                                value: "STOP",
                                width: 50,
                                height: 25,
                                borderColor: Color.fromRGBO(63, 111, 66, 1),
                                textStyle: textStyleConfigSquare,
                                backgroundColor: Color.fromRGBO(28, 27, 27, 1),
                              ) ,
                            ),
                          ]
                      ),
                    ]
                ),
                Column(
                    children: <Widget>[
                      Padding(padding: const EdgeInsets.all(5.0)),
                      Row(
                          children: <Widget>[
                            SquareCustomState(
                              squareCustom: SquareCustom(
                                value: (decreasing ? isoBeatMax.toInt().toString(): isoBeatMin.toInt().toString())+"Hz",
                                width: 50,
                                height: 25,
                                borderColor: Color.fromRGBO(63, 111, 66, 1),
                                textStyle: textStyleConfigSquare,
                                backgroundColor: Color.fromRGBO(28, 27, 27, 1),
                              ) ,
                            ),
                          ]
                      ),
                      Row(
                          children: <Widget>[
                            SquareCustomState(
                              squareCustom: SquareCustom(
                                value: (decreasing ? isoBeatMin.toInt().toString(): isoBeatMax.toInt().toString())+"Hz",
                                width: 50,
                                height: 25,
                                borderColor: Color.fromRGBO(63, 111, 66, 1),
                                textStyle: textStyleConfigSquare,
                                backgroundColor: Color.fromRGBO(28, 27, 27, 1),
                              ) ,
                            ),
                          ]
                      ),
                    ]
                ),
                Column(
                    children: <Widget>[
                      Padding(padding: const EdgeInsets.all(5.0)),
                      Row(
                          children: <Widget>[
                            SquareCustomState(
                              squareCustom: SquareCustom(
                                value: (decreasing ? waveWord(isoBeatMax): waveWord(isoBeatMin)),
                                width: 50,
                                height: 25,
                                borderColor: Color.fromRGBO(63, 111, 66, 1),
                                textStyle: textStyleConfigSquare,
                                backgroundColor: Color.fromRGBO(28, 27, 27, 1),
                              ) ,
                            ),
                          ]
                      ),
                      Row(
                          children: <Widget>[
                            SquareCustomState(
                              squareCustom: SquareCustom(
                                value: (decreasing ? waveWord(isoBeatMin): waveWord(isoBeatMax)),
                                width: 50,
                                height: 25,
                                borderColor: Color.fromRGBO(63, 111, 66, 1),
                                textStyle: textStyleConfigSquare,
                                backgroundColor: Color.fromRGBO(28, 27, 27, 1),
                              ) ,
                            ),
                          ]
                      ),
                    ]
                ),
              ]
            ),
            Row(
              mainAxisAlignment:  MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(padding: const EdgeInsets.all(8.0)),
                    Text("Beat Frequency: ",
                        textAlign: TextAlign.left,
                        style: textStyleSmallG
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
                        "Beats Volume: "+(volumeWaves).toStringAsFixed(0)+"%",
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
                                    color: Colors.orange,
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
                                    color: Colors.grey,
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
                                    color: Colors.grey,
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
                                    color: Colors.green,
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
                                    color: Colors.grey,
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
                                    function: (isPlaying=="true" || loading=="loading..."?null:(id==0?null:deleteButton)),
                                    color: Colors.grey,
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
    ));
  }
}

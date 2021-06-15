import 'package:binauralsleep/util/components.dart';
import 'package:binauralsleep/util/style.dart';
import 'package:binauralsleep/util/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpPage extends StatefulWidget {
  HelpPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  HelpPageState createState() => new HelpPageState();
}

class HelpPageState extends State {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,]);

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0), // here the desired height
          child: AppBar(
            title: Text("help",
              style: textStyleActBar,
              ),
            ),
          ),
        body: SingleChildScrollView(
          child:Column(
          children: <Widget>[
            Padding(padding: const EdgeInsets.all(4.0)),
            Row(
                children: [
                  SquareCustomState(
                    squareCustom: SquareCustom(
                      value: "BINAURAL BEATS",
                      width: MediaQuery.of(context).size.width,
                      height: 20,
                      borderColor: Colors.blueGrey,
                      textStyle: textStyle,
                      backgroundColor: Color.fromRGBO(28, 27, 27, 1),
                    ),
                  )
                ]
            ),
            Row(
                children: [
                  SquareCustomState(
                    squareCustom: SquareCustom(
                      value: "Binaural beats are generated when the sine waves within a close range are presented to each ear separately. For example, when the 400Hz tone is presented to the left ear and the 440Hz tone to the right, a beat of 40Hz is perceived, which appears subjectively to be located “inside” the head. This is the binaural beat percept.",
                      width: MediaQuery.of(context).size.width,
                      height: 110,
                      borderColor: Colors.blueGrey,
                      textStyle: textStyle,
                      backgroundColor: Color.fromRGBO(28, 27, 27, 1),
                    ),
                  )
                ]
            ),
            Padding(padding: const EdgeInsets.all(4.0)),
            Row(
              children: [
                SquareCustomState(
                  squareCustom: SquareCustom(
                    value: "Characteristics of the Five Basic Brain Waves",
                    width: MediaQuery.of(context).size.width,
                    height: 20,
                    borderColor: Colors.blueGrey,
                    textStyle: textStyle,
                    backgroundColor: Color.fromRGBO(28, 27, 27, 1),
                  ),
                )
              ]
            ),
            rowTable(context, "Gamma("+greekLatter(36)+")", "> 35Hz", "Concentration. Modulate perception and consciousness.", 45),
            rowTable(context, "Beta("+greekLatter(20)+")", "12–35Hz", "They are associated with a state of mental, intellectual activity and outwardly focused concentration. This is basically state of alertness. Anxiety dominant, active, external attention, relaxed.", 130),
            rowTable(context, "Alpha("+greekLatter(7)+")", "8–12Hz", "Very relaxed, passive attention. They are associated with a state of relaxation and represent the brain shifting into an idling gear, waiting to respond when needed.", 95),
            rowTable(context, "Theta("+greekLatter(3)+")", "4–8Hz", "Deeply relaxed, inward focused. Represent a day dreamy, spacey state of mind that is associated with mental inefficiency. Twilight zone between waking and sleep.", 95),
            rowTable(context, "Delta("+greekLatter(36)+")", "1–4Hz", "Sleep. In general, different levels of awareness are associated.", 45),
          ],
        ),
    ));
  }

  Widget rowTable(BuildContext context, String waveName, String frequency, String description, double height) {
    double widthName = 80;
    double widthFreq = 70;
    double widthDesc = MediaQuery.of(context).size.width-(widthName+widthFreq);

    return Row(
      children: [
        Column(
          children: [
            SquareCustomState(
              squareCustom: SquareCustom(
                value: waveName,
                width: widthName,
                height: height,
                borderColor: Colors.blueGrey,
                textStyle: textStyle,
                backgroundColor: Color.fromRGBO(28, 27, 27, 1),
              ) ,
            )
          ],
        ),
        Column(
          children: [
            SquareCustomState(
              squareCustom: SquareCustom(
                value: frequency,
                width: widthFreq,
                height: height,
                borderColor: Colors.blueGrey,
                textStyle: textStyle,
                backgroundColor: Color.fromRGBO(28, 27, 27, 1),
              ) ,
            )
          ],
        ),
        Column(
          children: [
            SquareCustomState(
              squareCustom: SquareCustom(
                value: description,
                width: widthDesc,
                height: height,
                borderColor: Colors.blueGrey,
                textStyle: textStyle,
                backgroundColor: Color.fromRGBO(28, 27, 27, 1),
              ) ,
            )
          ],
        ),
      ],
    );
  }
}
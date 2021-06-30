import 'package:binauralsleep/pages/help.dart';
import 'package:binauralsleep/util/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:segment_display/segment_display.dart';

//*********** Customized Button ***********
class ButtonCustom {
  const ButtonCustom({this.label,this.color,this.active,this.function});

  final String label;
  final Color color;
  final bool active;
  final Function function;
}

class ButtonCustomState extends StatelessWidget {
  const ButtonCustomState({Key key, this.button,}) : super(key: key);
  final ButtonCustom button;

  @override
  Widget build(BuildContext context) {
    Color colorBackground;
    Color colorBorder;
    Color colorText;
    double borderWidth;

    if(button.active){
      colorBackground = button.color;
      colorBorder = button.color;
      colorText = Colors.black;
      borderWidth = 0;
    }else{
      colorBackground = Color.fromRGBO(58, 55, 55, 1);
      colorBorder = Colors.black;
      colorText = button.color;
      borderWidth = 0;
    }

    if(button.function==null){
      colorText = Colors.black;
    }

    if(button.label == "STOP"){
      colorBackground = Colors.red;
      colorBorder = Colors.red;
    }

    return OutlinedButton(
          child: Text(button.label,
            style: TextStyle(color: colorText,fontWeight: FontWeight.bold,fontSize: 13),
          ),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.all(14),
            fixedSize: Size.fromWidth(90),
            side: BorderSide(width: borderWidth, color: colorBorder),
            backgroundColor: colorBackground
          ),
          onPressed: button.function,
    );
  }
}

//*********** Customized Slider Bar ***********
class SliderCustom {
  const SliderCustom({this.value,this.valueMin,this.valueMax,this.division,this.function});

  final double value;
  final double valueMin;
  final double valueMax;
  final int division;
  final Function function;
}

//Carrier frequency slider bar
class SliderCustomState  extends StatelessWidget {
  const SliderCustomState({Key key, this.sliderCustom}) : super(key: key);
  final SliderCustom sliderCustom;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: 45,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackShape: RoundedRectSliderTrackShape(),
          trackHeight: 4.0,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
          overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
          tickMarkShape: RoundSliderTickMarkShape(),
          valueIndicatorShape: PaddleSliderValueIndicatorShape(),
          valueIndicatorTextStyle: TextStyle(
            color: Colors.white,
          ),
        ),
        child: Slider(
          value: sliderCustom.value,
          min: sliderCustom.valueMin,
          max: sliderCustom.valueMax,
          divisions: sliderCustom.division,
          label: sliderCustom.value.toInt().toString(),
          onChanged: sliderCustom.function,
        ),
      ),
    );
  }
}

//*********** Customized App Bar ***********
class AppBarCustom {
  const AppBarCustom({this.formKey,this.name,this.label,this.icon,this.controller,this.iconBtnFunction,this.inputTxtFunction});

  final GlobalKey<FormState> formKey;
  final String name;
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final Function iconBtnFunction;
  final Function inputTxtFunction;
}

class AppBarStateCustom  extends StatelessWidget implements PreferredSizeWidget{

  AppBarStateCustom({Key key, this.appBarCustom}) : super(key: key);
  final AppBarCustom appBarCustom;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(appBarCustom.icon, color: Color.fromRGBO(189, 184, 184, 1)),
              onPressed: appBarCustom.iconBtnFunction
          ),
          IconButton(
              icon: Icon(Icons.help, color: Color.fromRGBO(189, 184, 184, 1)),
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpPage()),
                );
              }
          ),
        ],
        title: Form(
          key: appBarCustom.formKey,
          child:TextFormField(
            controller: appBarCustom.controller,
            initialValue: appBarCustom.name,
            inputFormatters: [ LengthLimitingTextInputFormatter(30),], //WhitelistingTextInputFormatter(RegExp(r"[a-zA-Z0-9]+|\s")),
            keyboardType: TextInputType.text,
            cursorColor: Colors.grey,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            decoration: InputDecoration(
                labelText: appBarCustom.label,
                labelStyle: textStyleActBar
            ),
            onChanged: appBarCustom.inputTxtFunction,
          ),
        )
    );
  }

  @override
  final Size preferredSize = Size.fromHeight(56.0);
}

//*********** Customized Range Slider ***********
class RangeSliderCustom {
  const RangeSliderCustom({this.isoBeatMin,this.isoBeatMax,this.function});

  final double isoBeatMin;
  final double isoBeatMax;
  final Function function;
}

class RangeSliderCustomState  extends StatelessWidget {
  const RangeSliderCustomState({Key key, this.sliderCustom}) : super(key: key);
  final RangeSliderCustom sliderCustom;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 45,
      child: SliderTheme(
        data: SliderThemeData(
          valueIndicatorColor: Color.fromRGBO(63, 111, 66, 1),
          trackHeight: 4.0,
          valueIndicatorTextStyle: TextStyle(
            color: Colors.white,
          ),
        ),
        child: RangeSlider(
        activeColor: Color.fromRGBO(63, 111, 66, 1),
        divisions: 38,
        min: 1.0,
        max: 40.0,
        values: RangeValues(sliderCustom.isoBeatMin, sliderCustom.isoBeatMax),
        labels: RangeLabels(sliderCustom.isoBeatMin.toInt().toString(), sliderCustom.isoBeatMax.toInt().toString()),
        onChanged: sliderCustom.function,
      ),
    ));
  }
}

//*********** Show current beat frequency ***********
class DisplayCustom {
  const DisplayCustom({this.value,});

  final String value;
}

class DisplayCustomState  extends StatelessWidget {
  const DisplayCustomState({Key key, this.displayCustom}) : super(key: key);
  final DisplayCustom displayCustom;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: Color.fromRGBO(63, 111, 66, 1),
          ),
        ),
      width: 168,
      height: 48,
      child: Row(
        children: [
          Text(" "),
          Column(
              children: <Widget>[
                Padding(padding: const EdgeInsets.all(2.0)),
                SevenSegmentDisplay(
                  value: displayCustom.value,
                  size: 3.5,
                  backgroundColor: Colors.black,
                  segmentStyle: DefaultSegmentStyle(
                    enabledColor: Colors.orange,
                  ),
                )
              ]
          ),
          Column(
              children: <Widget>[
                Text(" Hz",
                    style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.normal,
                        fontSize: 30)
                ),
              ]
          ),
        ],
      ),
    );
  }
}

//*********** Square used in config page to show beat frequency information ***********
class SquareCustom {
  const SquareCustom({this.value,this.width,this.height,this.borderColor,this.backgroundColor,this.textStyle});

  final String value;
  final double width;
  final double height;
  final Color borderColor;
  final Color backgroundColor;
  final TextStyle textStyle;
}

class SquareCustomState  extends StatelessWidget {
  const SquareCustomState({Key key, this.squareCustom}) : super(key: key);
  final SquareCustom squareCustom;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: squareCustom.backgroundColor,
        border: Border.all(
          color: squareCustom.borderColor,
        ),
      ),
      width: squareCustom.width,
      height: squareCustom.height,
      child: SelectableText(squareCustom.value,  //Color.fromRGBO(63, 111, 66, 1)
        style: squareCustom.textStyle,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:binauralsleep/util/style.dart';

class ButtonCustom {
  const ButtonCustom({this.label,this.active,this.function});
  final String label;
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

    if(button.active){
      colorBackground = Colors.grey;
      colorBorder = Colors.grey;
      colorText = Colors.black;
    }else{
      colorBackground = Colors.black;
      colorBorder = Colors.grey;
      colorText = Colors.grey;
    }

    return DecoratedBox(
        decoration: ShapeDecoration(shape: Border(), color: colorBackground),
        child: Theme(
        data: Theme.of(context).copyWith(
        buttonTheme: ButtonTheme.of(context).copyWith(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)),
        child: OutlineButton(
          child: Text(button.label,
            style: TextStyle(color: colorText,fontWeight: FontWeight.bold,fontSize: 16),
          ),
          borderSide: BorderSide(
            color: colorBorder,
            width: 2,
          ),
          onPressed: button.function,
          )
        )
    );
  }
}

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

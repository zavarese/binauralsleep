import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//*********** Customized Button ***********
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
      colorBackground = Color.fromRGBO(28, 27, 27, 1);
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
        ],
        title: Form(
          key: appBarCustom.formKey,
          child:TextFormField(
            controller: appBarCustom.controller,
            initialValue: appBarCustom.name,
            inputFormatters: [new  WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]")),], //Letters and numbers only
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            decoration: InputDecoration(
                labelText: appBarCustom.label,
                labelStyle: TextStyle(
                  color: Color.fromRGBO(189, 184, 184, 1),
                  fontStyle: FontStyle.italic,
                )
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
      child: RangeSlider(
        divisions: 39,
        min: 1.0,
        max: 40.0,
        values: RangeValues(sliderCustom.isoBeatMin, sliderCustom.isoBeatMax),
        labels: RangeLabels(sliderCustom.isoBeatMin.toInt().toString(), sliderCustom.isoBeatMax.toInt().toString()),
        onChanged: sliderCustom.function,
      ),
    );
  }
}
import 'package:flutter/material.dart';

String waveWord(double freq){
  String word="";

  if(freq<=4){
    word = "Delta";
  }

  if(freq>4 && freq<=8){
    word = "Theta";
  }

  if(freq>8 && freq<=12){
    word = "Alpha";
  }

  if(freq>12 && freq<=35){
    word = "Beta";
  }

  if(freq>35){
    word = "Gamma";
  }

  return word;
}

void funShowDialog(BuildContext context, String title, String content) {
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // retorna um objeto do tipo Dialog
      return AlertDialog(
        title: new Text(title),
        content: new Text(content),
        actions: <Widget>[
          okButton,
        ],
      );
    },
  );
}
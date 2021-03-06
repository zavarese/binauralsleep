import 'package:flutter/material.dart';

String waveWord(double freq){
  String word="";

  int value = freq.toInt();

  if(value<=4){
    word = "Delta";
  }

  if(value>4 && value<=8){
    word = "Theta";
  }

  if(value>8 && value<=12){
    word = "Alpha";
  }

  if(value>12 && value<=16){
    word = "Beta 1";
  }

  if(value>16 && value<=20){
    word = "Beta 2";
  }

  if(value>20 && value<=30){
    word = "Beta 3";
  }

  if(value>30){
    word = "Gamma";
  }

  return word;
}

String greekLatter(int beatMin){
  String greek;

  if(beatMin<=4){
    greek = "\u03b4"; //Delta
  }

  if(beatMin>4 && beatMin<=8){
    greek = "\u03b8"; //Theta
  }

  if(beatMin>8 && beatMin<=12){
    greek = "\u03b1"; //Alpha
  }

  if(beatMin>12 && beatMin<=30){
    greek = "\u03b2"; //Beta
  }

  if(beatMin>30){
    greek = "\u03b3"; //Gamma
  }

  return greek;
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
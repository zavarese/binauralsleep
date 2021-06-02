import 'package:binauralsleep/model/binaural.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class ListConfig extends State  {
  static const platform = const MethodChannel('com.zavarese.binauralsleep/binaural');
  static final List<Binaural> _listModel = [];
  List<Binaural> searchResult = [];

  var loading = false;
  final formKey = new GlobalKey<FormState>();
  TextEditingController controller = new TextEditingController();


  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<Null> getData() async {
    String message;

    _listModel.clear();
    searchResult.clear();

    setState(() {
      loading = true;
    });

    try {
      final String response = await platform.invokeMethod('list');
      message = response;
      final data = jsonDecode(response);

      setState(() {
        for(Map i in data){
          _listModel.add(Binaural.fromJson(i));
        }

        for(Map i in data){
          searchResult.add(Binaural.fromJson(i));
        }
        loading = false;
      });

    } on PlatformException catch (e) {
      message = "Failed to Invoke: '${e.message}'.";
      debugPrint("Message: '+${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }


  onSearchTextChanged(String text) async {

    searchResult.clear();

    if (text.isEmpty) {
      setState(()
      {
        for (int i = 0; i < _listModel.length; i++) {
          searchResult.add(_listModel[i]);
        }
      });
      return;
    }

    //debugPrint("length: "+listModel.length.toString());

    _listModel.forEach((binaural) {
      if (binaural.name.toLowerCase().contains(text.toLowerCase()) ||
          binaural.frequency.toString().toLowerCase().contains(text.toLowerCase()) ||
          binaural.isoBeatMin.toString().toLowerCase().contains(text.toLowerCase()) ||
          binaural.isoBeatMax.toString().toLowerCase().contains(text.toLowerCase()))
      {
        searchResult.add(binaural);
      }
    });

    setState(() {});
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

    if(beatMin>12 && beatMin<=35){
      greek = "\u03b2"; //Beta
    }

    if(beatMin>35){
      greek = "\u03b3"; //Gamma
    }

    return greek;
  }

}
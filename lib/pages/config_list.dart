import 'package:binauralsleep/model/binaural.dart';
import 'package:binauralsleep/pages/configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:binauralsleep/util/style.dart';
import 'dart:convert';

class ListConfigPage extends StatefulWidget {
  ListConfigPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  ListConfigPageState createState() => new ListConfigPageState();
}

class ListConfigPageState extends State<ListConfigPage> with WidgetsBindingObserver {
  static const platform = const MethodChannel('com.zavarese.binauralsleep/binaural');
  List<Binaural> listModel = [];

  Future<String> getData() async {
    String message;

    try {
      final String response = await platform.invokeMethod('list');
      message = response;
      final data = jsonDecode(response);

      setState(() {
        for(Map i in data){
          listModel.add(Binaural.fromJson(i));
        }
      });

    } on PlatformException catch (e) {
      message = "Failed to Invoke: '${e.message}'.";
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,]);


    return Scaffold(
        backgroundColor: Colors.black,
        appBar:  AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: (){
                showSearch(context: context, delegate: null);
              },
              icon: Icon(Icons.search),
            )
          ],
        centerTitle:false,
        title: Text('Binaural configurations'),
    ),
    floatingActionButton:  FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ConfigPage(0,"Config",3,16,432,true)));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueGrey,
    ),
    body: ListView(
      children: <Widget>[
        Card(
            child: InkWell(
              onTap: () {
                print('Card tapped.');
              },
              child: Container(
                color: Colors.grey,
                width: 300,
                height: 100,
                child: Center(
                  child: ListTile(
                    leading: Text("\u03b1",
                      style: textStyleBig,
                    ),
                    title: Text('Deep Meditation',
                      style: textStyleMid,
                    ),
                    subtitle: Text('Beat frequency: 16Hz to 3 Hz',
                      style: textStyleSmall,
                    ),
                    trailing: Text("432Hz",
                      style: textStyleMid,),
                  ),
                ),
              ),
            )
        ),
        Card(
            child: InkWell(
              onTap: () {
                print('Card tapped.');
              },
              child: Container(
                color: Colors.grey,
                width: 300,
                height: 100,
                child: Center(
                  child: ListTile(
                    leading: Text("\u03b2",
                      style: textStyleBig,
                    ),
                    title: Text('Deep Meditation',
                      style: textStyleMid,
                    ),
                    subtitle: Text('Beat frequency: 16Hz to 3 Hz',
                      style: textStyleSmall,
                    ),
                    trailing: Text("432Hz",
                      style: textStyleMid,),
                  ),
                ),
              ),
            )
        ),
        Card(
            child: InkWell(
              onTap: () {
                print('Card tapped.');
              },
              child: Container(
                color: Colors.grey,
                width: 300,
                height: 100,
                child: Center(
                  child: ListTile(
                    leading: Text("\u03b3",
                      style: textStyleBig,
                    ),
                    title: Text('Deep Meditation',
                      style: textStyleMid,
                    ),
                    subtitle: Text('Beat frequency: 16Hz to 3 Hz',
                      style: textStyleSmall,
                    ),
                    trailing: Text("432Hz",
                      style: textStyleMid,),
                  ),
                ),
              ),
            )
        ),
        Card(
            child: InkWell(
              onTap: () {
                print('Card tapped.');
              },
              child: Container(
                color: Colors.grey,
                width: 300,
                height: 100,
                child: Center(
                  child: ListTile(
                    leading: Text("\u03b4",
                      style: textStyleBig,
                    ),
                    title: Text('Deep Meditation',
                      style: textStyleMid,
                    ),
                    subtitle: Text('Beat frequency: 16Hz to 3 Hz',
                      style: textStyleSmall,
                    ),
                    trailing: Text("432Hz",
                      style: textStyleMid,),
                  ),
                ),
              ),
            )
        ),
        Card(
            child: InkWell(
              onTap: () {
                print('Card tapped.');
              },
              child: Container(
                color: Colors.grey,
                width: 300,
                height: 100,
                child: Center(
                  child: ListTile(
                    leading: Text("\u03b8",
                      style: textStyleBig,
                    ),
                    title: Text('Deep Meditation',
                      style: textStyleMid,
                    ),
                    subtitle: Text('Beat frequency: 16Hz to 3 Hz',
                      style: textStyleSmall,
                    ),
                    trailing: Text("432Hz",
                    style: textStyleMid,),
                  ),
                ),
              ),
            )
        ),
      ],
    )
    );

    /*
    var jsonData = '{ "name" : "Dane", "alias" : "FilledStacks"  }';
    var parsedJson = json.decode(jsonData);
    var name = parsedJson['name'];
    var alias = parsedJson['alias'];

     */

    /*
    var jsonData = '{ "id" : "1", "name" : "Maria" },{ "id" : "2", "name" : "Mario" }';
    var parsedJson = json.decode(jsonData);
    var binaural = Binaural(parsedJson);
    var id = binaural.id;
    var name = binaural.name;

     */
/*
    return Scaffold(
        appBar:  AppBar(
        title: Text('Home Page List User'),
        centerTitle: true,
    ),
    body: Container(
      child: ListView.builder(
        itemCount: listModel.length,
        itemBuilder: (context, i) {
          final nDataList = listModel[i];
          return Container(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) =>
                      ConfigPage(
                        nDataList.id,
                        nDataList.name,
                        nDataList.isoBeatMin,
                        nDataList.isoBeatMax,
                        nDataList.frequency,
                        nDataList.decreasing,
                      )));
                },
                child: Card(
                  color: Colors.amber[100],
                  margin: EdgeInsets.all(15),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(nDataList.name, style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green),),
                        Text(nDataList.isoBeatMin.toString()),
                        Text(nDataList.isoBeatMax.toString()),
                        Text(nDataList.frequency.toString()),
                      ]
                    )
                  )
                )
              )
          );
        }
    )));
    */
  }
}
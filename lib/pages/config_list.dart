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
  var loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  Future<Null> getData() async {
    String message;

    setState(() {
      loading = true;
    });

    try {
      final String response = await platform.invokeMethod('list');
      message = response;
      final data = jsonDecode(response);

      setState(() {
        for(Map i in data){
          listModel.add(Binaural.fromJson(i));
        }
        loading = false;
      });

    } on PlatformException catch (e) {
      message = "Failed to Invoke: '${e.message}'.";
      debugPrint("Message: '+${e.message}'.");
    }
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
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ConfigPage(0,"",3,16,432,true)));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueGrey,
    ),
    body: loading ? Center (child: CircularProgressIndicator()) :ListView.builder(
    itemCount: listModel.length,
    itemBuilder: (context, i) {
      final nDataList = listModel[i];
      return Card(
            color: Colors.black,
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) =>
                    ConfigPage(
                      nDataList.id,
                      nDataList.name,
                      double.parse(nDataList.isoBeatMin.toString()),
                      double.parse(nDataList.isoBeatMax.toString()),
                      double.parse(nDataList.frequency.toString()),
                      nDataList.decreasing,
                    )
                ));
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey,
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                width: 300,
                height: 100,
                child: Center(
                  child: ListTile(
                    leading: Text(greekLatter((nDataList.decreasing?nDataList.isoBeatMin:nDataList.isoBeatMax)),
                      style: textStyleBig,
                    ),
                    title: Text(nDataList.name,
                      style: textStyleMid,
                    ),
                    subtitle: (nDataList.decreasing
                      ?Text('Beat frequency: '+nDataList.isoBeatMax.toString()+'Hz to '+nDataList.isoBeatMin.toString()+'Hz',style: textStyleSmall,)
                      :Text('Beat frequency: '+nDataList.isoBeatMin.toString()+'Hz to '+nDataList.isoBeatMax.toString()+'Hz',style: textStyleSmall,)),
                    trailing: Text(nDataList.frequency.toString(),
                      style: textStyleMid,),
                  ),
                ),
              ),
            )
        );},
      )
    );
  }
}
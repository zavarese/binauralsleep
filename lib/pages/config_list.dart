import 'package:binauralsleep/model/binaural.dart';
import 'package:binauralsleep/pages/configuration.dart';
import 'package:binauralsleep/pages/list.dart';
import 'package:binauralsleep/util/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:binauralsleep/util/style.dart';
import 'package:binauralsleep/util/components.dart';

class ListConfigPage extends StatefulWidget {
  ListConfigPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  ListConfigPageState createState() => new ListConfigPageState();
}

class ListConfigPageState extends ListConfig with WidgetsBindingObserver {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,]);

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBarStateCustom(
          appBarCustom: AppBarCustom(
            formKey: formKey,
            label: "search",
            icon: Icons.search,
            controller: controller,
            inputTxtFunction: onSearchTextChanged
          ),
        ),
    floatingActionButton:  FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ConfigPage(0,"",6,12,"","","",200,true)));
        },
        child: Icon(Icons.add_to_photos_rounded),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Color.fromRGBO(189, 184, 184, 1),
    ),
    body: loading ? Center (child: CircularProgressIndicator()) :ListView.builder(
    itemCount: searchResult.length,
    itemBuilder: (context, i) {
      Binaural nDataList = searchResult[i];
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
                      nDataList.waveMin,
                      nDataList.waveMax,
                      "", //nDataList.path,
                      double.parse(nDataList.frequency.toString()),
                      nDataList.decreasing,
                    )
                ));
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Color.fromRGBO(28, 27, 27, 1),
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                width: MediaQuery.of(context).size.width,
                height: 80,
                child: Center(
                  child: ListTile(
                    leading: Text(greekLatter((nDataList.decreasing?nDataList.isoBeatMin:nDataList.isoBeatMax)),
                      style: textStyleBig,
                    ),
                    title: Text(nDataList.name,
                      overflow: TextOverflow.ellipsis,
                      style: textStyleMid,
                    ),
                    subtitle: (nDataList.decreasing
                      ?Text("\u2193"+f.format(nDataList.isoBeatMax).toString()+'Hz - '+nDataList.waveMax.toLowerCase()+'\n'+
                        "  "+f.format(nDataList.isoBeatMin).toString()+'Hz - '+nDataList.waveMin.toLowerCase(), //\n'+nDataList.hasMusic,
                          style: textStyleSmall,)
                      :Text("\u2193"+f.format(nDataList.isoBeatMin).toString()+'Hz - '+nDataList.waveMin.toLowerCase()+'\n'+
                        "  "+f.format(nDataList.isoBeatMax).toString()+'Hz - '+nDataList.waveMax.toLowerCase(), //\n'+nDataList.hasMusic,
                          style: textStyleSmall,)),
                    trailing: Text(nDataList.frequency.toString()+"Hz",
                      style: textStyleMidO,),
                    //isThreeLine: true,
                  ),
                ),
              ),
            )
        );},
      )
    );
  }
}



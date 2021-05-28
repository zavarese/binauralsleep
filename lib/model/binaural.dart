import 'dart:convert';

List<Binaural> modelUserFromJson(String str) => List<Binaural>.from(json.decode(str).map((x) => Binaural.fromJson(x)));
String modelUserToJson(List<Binaural> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Binaural {
  int id;
  String name;
  int isoBeatMin;
  int isoBeatMax;
  int frequency;
  bool decreasing;

  Binaural({
    this.id,
    this.name,
    this.isoBeatMin,
    this.isoBeatMax,
    this.frequency,
    this.decreasing
  });

  factory Binaural.fromJson(Map<String, dynamic> json) => Binaural(
    id: json["id"],
    name: json["name"],
    isoBeatMin: json["isoBeatMin"],
    isoBeatMax: json["isoBeatMax"],
    frequency: json["frequency"],
    decreasing: json["decreasing"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "isoBeatMin": isoBeatMin,
    "isoBeatMax": isoBeatMax,
    "frequency": frequency,
    "decreasing": decreasing,
  };
}
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences _sharedPrefs;

  init() async {
    if (_sharedPrefs == null) {
      _sharedPrefs = await SharedPreferences.getInstance();
    }
  }
  double get volumeMusic => _sharedPrefs.getDouble("volumeMusic") ?? 90;
  set volumeMusic(double value) => _sharedPrefs.setDouble("volumeMusic", value);

  double get volumeWaves => _sharedPrefs.getDouble("volumeWaves") ?? 40;
  set volumeWaves(double value) => _sharedPrefs.setDouble("volumeWaves", value);

  double get seconds => _sharedPrefs.getDouble("seconds") ?? 30;
  set seconds(double value) => _sharedPrefs.setDouble("seconds", value);
}

final sharedPrefs = SharedPrefs();
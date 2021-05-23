import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences _sharedPrefs;

  init() async {
    if (_sharedPrefs == null) {
      _sharedPrefs = await SharedPreferences.getInstance();
    }
  }

  double get minutes => _sharedPrefs.getDouble("minutes") ?? 60;
  set minutes(double value) => _sharedPrefs.setDouble("minutes", value);

  double get volumeMusic => _sharedPrefs.getDouble("volumeMusic") ?? 1;
  set volumeMusic(double value) => _sharedPrefs.setDouble("volumeMusic", value);

  double get volumeWaves => _sharedPrefs.getDouble("volumeWaves") ?? 1;
  set volumeWaves(double value) => _sharedPrefs.setDouble("volumeWaves", value);
}

final sharedPrefs = SharedPrefs();
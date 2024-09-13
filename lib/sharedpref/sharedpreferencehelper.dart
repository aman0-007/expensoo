import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const _keyLoggedIn = 'logged_in';

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_keyLoggedIn, value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }
}

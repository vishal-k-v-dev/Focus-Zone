import 'package:shared_preferences/shared_preferences.dart';

PreferenceManager preferenceManager = PreferenceManager();

class PreferenceManager{

  late SharedPreferences sharedPreferences;

  Future<void> initalise() async{
    sharedPreferences = await SharedPreferences.getInstance();
  }

  int getInt({required String key, required int defaultValue}) {
    int? value = sharedPreferences.getInt(key);

    if(value != null){
      return value;
    }
    else{
      return defaultValue;
    }
  }

  bool getBool({required String key, required bool defaultValue}) {
    bool? value = sharedPreferences.getBool(key);

    if(value != null){
      return value;
    }
    else{
      return defaultValue;
    }
  }

  List<String> getStringList({required String key, required List<String> defaultValue}){
    List<String>? value = sharedPreferences.getStringList(key);

    if(value != null){
      return value;
    }
    else{
      return defaultValue;
    }
  }

  List<int> getIntList({required String key, required List<int> defaultValue}){
    List<String>? stringListValue = sharedPreferences.getStringList(key);

    if(stringListValue == null){
      return defaultValue;
    }
    else{
      List<int> value = stringListValue.map((stringValue) => int.parse(stringValue)).toList();
      return value;
    }
  }

  Future<void> setInt({required String key, required int value}) async{
    await sharedPreferences.setInt(key, value);
  }

  Future<void> setBool({required String key, required bool value}) async{
    await sharedPreferences.setBool(key, value);
  }

  Future<void> setStringList({required String key, required List<String> value}) async{
    await sharedPreferences.setStringList(key, value);
  }

  Future<void> setIntList({required String key, required List<int> value}) async{
    List<String> stringListValue = value.map((intValue) => intValue.toString()).toList();
    await sharedPreferences.setStringList(key, stringListValue);
  }
}
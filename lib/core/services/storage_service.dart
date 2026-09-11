import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
class StorageService {
 Future<void> saveJsonList(String key,List<Map<String,dynamic>> value) async => (await SharedPreferences.getInstance()).setString(key,jsonEncode(value));
 Future<List<Map<String,dynamic>>> readJsonList(String key) async { final p=await SharedPreferences.getInstance(); final raw=p.getString(key); if(raw==null)return []; return (jsonDecode(raw) as List).cast<Map<String,dynamic>>(); }
}

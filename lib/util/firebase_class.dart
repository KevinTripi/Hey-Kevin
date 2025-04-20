import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseRestAPI {
  String dbUrl;

  FirebaseRestAPI(this.dbUrl) {
    if (dbUrl.endsWith('/')) {
      dbUrl = dbUrl.substring(0, dbUrl.length - 1);
    }
  }

  // 🔧 Helper to get a valid path for auth.json
  Future<File> getAuthFile() async {
    final dir = await getApplicationDocumentsDirectory();
    print('Auth file location: ${dir.path}/auth.json');
    return File('${dir.path}/auth.json');
  }

  Future<void> createAnonymousUser() async {
    final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${dotenv.env['FIREBASE_API_KEY']}');
    final payload = {'returnSecureToken': true};
    final response = await http.post(url, body: json.encode(payload));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Created anonymous user with UID: ${data['localId']}');
      final newData = {
        'idToken': data['idToken'],
        'refreshToken': data['refreshToken'],
        'timestamp': DateTime.now().millisecondsSinceEpoch / 1000
      };
      await saveRefreshedData(newData);
    } else {
      print('Unable to generate anonymous uid and id_token');
    }
  }

  Future<void> saveRefreshedData(Map<String, dynamic> refreshedData) async {
    print('saving refreshed data');
    final file = await getAuthFile();
    await file.writeAsString(json.encode(refreshedData));
  }

  Future<Map<String, dynamic>> refreshIdToken(String refreshToken) async {
    print('refreshing id token');
    final url = Uri.parse('https://securetoken.googleapis.com/v1/token?key=${dotenv.env['FIREBASE_API_KEY']}');
    final payload = {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken
    };
    final response = await http.post(url, body: payload);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'idToken': data['id_token'],
        'refreshToken': data['refresh_token'],
        'timestamp': DateTime.now().millisecondsSinceEpoch / 1000
      };
    }
    throw Exception('Token refresh failed: ${response.body}');
  }

  Future<Map<String, dynamic>> getValidToken() async {
    final currentData = await loadRefreshedData();
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
    if (currentTime - currentData['timestamp'] < 3600) {
      print('token is still valid');
      return currentData;
    } else {
      print('token no longer valid');
      final refreshedData = await refreshIdToken(currentData['refreshToken']);
      await saveRefreshedData(refreshedData);
      return refreshedData;
    }
  }

  Future<Map<String, dynamic>> loadRefreshedData() async {
    print('loading refreshed data');
    final file = await getAuthFile();
    if (!await file.exists()) {
      print('auth.json not found, creating empty file');
      await file.writeAsString('{}');
      return {};
    }
    final contents = await file.readAsString();
    return json.decode(contents);
  }

  Future<List<Map<String, dynamic>>?> get({bool includeKeys = false}) async {

    // Next 3 lines are added for easy run purposes (redundant pushing contents to auth.json)
    final jsons = json.decode(dotenv.env['AUTH_JSON']!);
    final file = await getAuthFile();
    await file.writeAsString(json.encode(jsons));

    final idToken = (await getValidToken())['idToken'];
    final response = await http.get(Uri.parse('$dbUrl/objects.json?auth=$idToken'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data == null) return null;

      if (includeKeys) {
        return null; // Not implemented as per original Python code
      } else {
        final values = (data as Map).values.toList().reversed.toList();
        return List<Map<String, dynamic>>.from(values);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> post(Map<String, dynamic> data) async {
    final idToken = (await getValidToken())['idToken'];
    final response = await http.post(
      Uri.parse('$dbUrl/objects.json?auth=$idToken'),
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return data;
    }
    return null;
  }

  Future<bool> delete(String key) async {
    final idToken = (await getValidToken())['idToken'];
    final response = await http.delete(
      Uri.parse('$dbUrl/objects/$key.json?auth=$idToken'),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteAll() async {
    final idToken = (await getValidToken())['idToken'];
    final response = await http.put(
      Uri.parse('$dbUrl/objects.json?auth=$idToken'),
      body: json.encode({}),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteLastEntry() async {
    final allObjects = await get(includeKeys: true);
    if (allObjects == null || allObjects.isEmpty) {
      return false;
    }
    final latestKey = (allObjects as Map).keys.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
    return await delete(latestKey);
  }
}

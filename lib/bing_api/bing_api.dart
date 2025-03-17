import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;


//BING API VARIABLES + IMAGE
//will need to update imagePath and filepath according to app structure
const String BASE_URI = 'https://api.bing.microsoft.com/v7.0/images/visualsearch';
const String SUBSCRIPTION_KEY = '01ee72049d30418ca29e2256faa752e5';
const String imagePath = "lib/bing_api/dasani-water-217886-64_600.jpg";
const String filePath = "lib/bing_api/result.json";


Future<void> main() async {
  try {
    // Send POST request
    final response = await getData();


    //Will udpate handlers once more complete
    if (response.statusCode != 200) {
      throw Exception('API request failed with status: ${response.statusCode}');
    }

    final file = File(filePath);

    // Write the response
    await file.writeAsString(response.body);

    // Get title names and display text from the JSON
    final unfilteredNames = getTitleNames(filePath);
    final unfilteredDisText = getDisplayText(filePath);
    //final bestRepQuer = bestRepQ(filePath); //Testing

    // Filter based on the first word
    final filteredNames = nameFinder(unfilteredNames);
    final filteredDisText = nameFinder(unfilteredDisText);


    //Testing
    print("${unfilteredNames.length} ${unfilteredDisText.length} ${filteredNames.length} ${filteredDisText.length}");


    //write export JSON
    exportData(filteredNames, filteredDisText);
  } catch (error) {
    print('Error getting data: $error');
  }
}

// Sends the request to API and returns response
Future<http.Response> getData() async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse(BASE_URI))
      ..headers['Ocp-Apim-Subscription-Key'] = SUBSCRIPTION_KEY
      ..files.add(await http.MultipartFile.fromPath('image', imagePath));

    var response = await request.send();
    return await http.Response.fromStream(response);
  } catch (error) {
    throw Exception('Failed to fetch data: $error');
  }
}

// Gets 'names' from returned JSON (unchanged)
List<String> getTitleNames(String filePath) {
  final file = File(filePath);
  final data = jsonDecode(file.readAsStringSync());

  List<String> entries = [];
  var tags = data['tags'] ?? [];
  for (var tag in tags) {
    var actions = tag['actions'] ?? [];
    for (var action in actions) {
      if (action['_type'] == 'ImageModuleAction') {
        var valueList = action['data']['value'] ?? [];
        for (var item in valueList) {
          entries.add(item['name'] ?? '');
        }
      }
    }
  }
  return entries;
}

// Gets 'display_text' from returned JSON (unchanged)
List<String> getDisplayText(String filePath) {
  final file = File(filePath);
  final data = jsonDecode(file.readAsStringSync());

  List<String> entries = [];
  var tags = data['tags'] ?? [];
  for (var tag in tags) {
    var actions = tag['actions'] ?? [];
    for (var action in actions) {
      if (action['_type'] == 'ImageRelatedSearchesAction') {
        var valueList = action['data']['value'] ?? [];
        for (var item in valueList) {
          entries.add(item['displayText'] ?? '');
        }
      }
    }
  }
  return entries;
}

// incomplete do not use
List<String> bestRepQ(String filePath) {
  final file = File(filePath);
  final data = jsonDecode(file.readAsStringSync());

  List<String> entries = [];

  var tags = data['tags'];
  if (tags is List) {
    for (var tag in tags) {
      var actions = tag['actions'];
      if (actions is List) {
        for (var action in actions) {
          if (action['actionType'] == 'BestRepresentativeQuery') {
            //unfinished do not use
          }
        }
      }
    }
  }

  return entries;
}



//
List<String> nameFinder(List<String> names) {
  if (names.isEmpty) return [];

  String find = names.first.split(' ').first;
  return names.where((name) => RegExp(r'\b' + RegExp.escape(find) + r'\b').hasMatch(name)).toList();
}

void exportData(List<String> names, List<String> displayText) {
  try {
    List<Map<String, String>> data = List.generate(
      names.length,
          (i) => {"name": names[i], "displayText": displayText[i]},
    );

    final file = File("lib/bing_api/exported_data.json");
    file.writeAsStringSync(jsonEncode(data));

    print("Data exported successfully to exported_data.json");
  } catch (error) {
    print("Error exporting data: $error");
  }
}

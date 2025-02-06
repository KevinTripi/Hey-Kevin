import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

//BING API VARIABLES + IMAGE
//will need to update imagePath and filepath according to app structure
const String BASE_URI = 'https://api.bing.microsoft.com/v7.0/images/visualsearch';
const String SUBSCRIPTION_KEY = '31013ec018f4420c82d63ae0d73066fe';
const String imagePath = "lib/api_resources/dasani-water-217886-64_600.jpg";  // Provide the correct path to the image
const String filePath = "lib/api_resources/result.json";

Future<void> main() async  {
  try {

    // Send POST request
    final response = await getData();

    final file = File(filePath);

    // write the response
    await file.writeAsString((response.body));

    // Get title names and display text from the JSON
    final unfilteredNames = getTitleNames(filePath);
    final unfilteredDisText = getDisplayText(filePath);

    // filter based off the first word
    final filteredNames = nameFinder(unfilteredNames);
    final filteredDisText = nameFinder(unfilteredDisText);

    // don't invoke print in production code × 6
    print("${unfilteredNames.length} ${unfilteredDisText.length} ${filteredNames.length} ${filteredDisText.length}");
    print(unfilteredNames);
    print(filteredNames);
    print(unfilteredDisText);
    print(filteredDisText);
  } catch (APIERROR) {
    print('Error getting data: $APIERROR');
  }
}

// sends the request to API and returns response
// need to implement an error catch here
Future<http.Response> getData() async {
  var request = http.MultipartRequest('POST', Uri.parse(BASE_URI))
    ..headers['Ocp-Apim-Subscription-Key'] = SUBSCRIPTION_KEY
    ..files.add(await http.MultipartFile.fromPath('image', imagePath));
  var response = await request.send();
  return await http.Response.fromStream(response);
}


//gets 'names' from returned json
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

//gets 'display_text' from returned json
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

// finds the FIRST word in the 'name' and 'displayText' entries. then, use that to parse down
// original returned data lists
List<String> nameFinder(List<String> names) {
  String find = 'NONEXISTENT'; //can implement a test check here later
  if (names.isNotEmpty) {
    find = names[0];
  }
  List<String> found = [];

  for (var name in names) {
    if (RegExp(r'\b' + RegExp.escape(find.split(' ')[0]) + r'\b').hasMatch(name)) {
      found.add(name);
    }
  }
  return found;
}

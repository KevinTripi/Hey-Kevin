import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

//BING API VARIABLES + IMAGE
//will need to update imagePath and filepath according to app structure
const String BASE_URI = 'https://api.bing.microsoft.com/v7.0/images/visualsearch';
const String SUBSCRIPTION_KEY = '';
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
    final repQ = bestRepQ(filePath);
    //print(repQ); //TESTING


    // Filter based on the best rep query
    final filteredNames = nameFinder(unfilteredNames, repQ);
    final filteredDisText = nameFinder(unfilteredDisText, repQ);

    //Testing
    //print("${unfilteredNames.length} ${unfilteredDisText.length} ${filteredNames.length} ${filteredDisText.length}");


    //write export JSON
    exportData(filteredNames, filteredDisText, repQ);
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


List<String> bestRepQ(String filePath) {
  List<String> query = [];

  final file = File(filePath);
  final data = jsonDecode(file.readAsStringSync());

  for (var tag in data['tags'] ?? []) {
    for (var action in tag['actions'] ?? []) {
      if (action['actionType'] == 'BestRepresentativeQuery') {
        query.add(action['displayName']);
      }
    }
  }

  return query;
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


List<String> nameFinder(List<String> names, List<String> query) {
  if (names.isEmpty) return [];

  String find = query.first.split(' ').first;
  return names.where((name) => RegExp(r'\b' + RegExp.escape(find) + r'\b').hasMatch(name)).toList();
}

String exportData(List<String> names, List<String> displayText, List<String> query) {
  try {
    int minLength = [names.length, displayText.length].reduce((a, b) => a < b ? a : b);

    Map<String, dynamic> exportStructure = {
      "query": query, //the best representative query
      "data": List.generate(
        minLength, // Only generate data up to the shortest list length, either names or displayText
            (i) => {"name": names[i], "displayText": displayText[i]},
      ),
    };

    final file = File("lib/bing_api/exported_data.json");
    file.writeAsStringSync(jsonEncode(exportStructure));

    print("Data exported successfully to exported_data.json");
    return jsonEncode(exportStructure);
  } catch (error) {
    print("Error exporting data: $error");
  }
  return "Bing API Exporting Failed.";
}

// Copied straight from main with the exception of the short-curcuit return statment.
// This will be the function that is exposed to the rest of the program; all others can be private.
// Args: image path, returns: json string.
Future<String> bingApiPipeline(String picPath) async {
  return jsonEncode({"query":["Dasani Water"],"data":[{"name":"Dasani 20 oz. Dasani Water 217886 - The Home Depot","displayText":"Dasani 20 Oz"},{"name":"Dasani Water, 24/20oz. Case | RDM Wholesale","displayText":"Dasani Water 24 Pack"},{"name":"Dasani Water 20oz Bottle – The DITCH","displayText":"Dasani 1 Liter"},{"name":"Dasani Purified w-ater 33.8 oz Plastic Bottles - Pack of 12 - Walmart.com","displayText":"Dasani Purified Water"},{"name":"Dasani Water 24 Pk 16.9 Oz - GJ Curbside","displayText":"Dasani Lemon Water"},{"name":"Dasani purified water 20 fl oz bottle – Artofit","displayText":"Dasani Canned Water"},{"name":"Dasani Purified Water 20 oz Plastic Bottles - Pack of 24 - Walmart.com","displayText":"Dasani Flavored Water"},{"name":"Dasani Purified w-a-t-e-r 16.9 oz Plastic Bottles - Pack of 24 ...","displayText":"Dasani Water Salt"},{"name":"Dasani Purified w-a-t-e-r 20 oz Plastic Bottles - Pack of 24 - Walmart ...","displayText":"Agua Dasani"},{"name":"Dasani Purified Water - 20 Fl Oz Bottle : Target","displayText":"Dasani Water Bottle Sizes"},{"name":"Dasani water appreciation post ♥️♥️♥️😄😄😄 : r/everythingaboutwater","displayText":"Dasani Water Ingredients"},{"name":"Dasani Purified Water - 20oz Bottle | Cloverkey Hospital Gift Shops","displayText":"Dasani vs Aquafina"},{"name":"Dasani Purified Water - 20 fl oz Bottle | Dasani water, Dasani bottle ...","displayText":"Dasani Water Bottle Label"},{"name":"Dasani Water - TUSCULUM CAMPUS STORE","displayText":"Dasani Water Case"},{"name":"Dasani Water — Quick Clouds","displayText":"Dasani Logo"},{"name":"Dasani Water – Independence Cafeteria","displayText":"Mini Dasani Water Bottles"},{"name":"Dasani - waterpass","displayText":"Dasani New Bottle"},{"name":"The Perfectly Balanced pH of Dasani Water!","displayText":"24Pk Dasani"},{"name":"Dasani Water | Viking Coke","displayText":"Peach Dasani"},{"name":"Dasani Purified Water Reviews 2022","displayText":"Dasani Drinking Water"},{"name":"Dasani® Purified Water Reviews 2019 | Page 8","displayText":"Dasani Water Bad"},{"name":"Download Free Dasani Water Bottle ICON favicon | FreePNGImg","displayText":"Dasani Bottled Water"},{"name":"Dasani Purified Water (20 oz., 24 pk.) - Sam's Club","displayText":"Dasani Mineral Water"},{"name":"Dasani Bottled Water - Simply Delivery","displayText":"Dasani Sparkling Water"},{"name":"Dasani Water Bottle Sizes","displayText":"16 9 Oz Dasani Water"},{"name":"Dasani Purified Water - Shop Water at H-E-B","displayText":"Dasani Ad"},{"name":"Dasani Water - 1L | Whistler Grocery Service & Delivery","displayText":"Dasani Water Flavorings"},{"name":"Dasani Water With Lemon 20oz -- delivered in minutes","displayText":"Can of Dasani"},{"name":"Dasani Water 500ml x24 | GHC Reid & Co. Ltd.","displayText":"Dasani Water Source"},{"name":"Dasani Water, Purified","displayText":"Dasani 12 Pack"},{"name":"Dasani Purified Water, 24 oz - Walmart.com","displayText":"Dasani Plastic Water Bottle"},{"name":"500 ml. Dasani Pure Drinking Water - Trastar Cafe","displayText":"Dasani Water Brand"},{"name":"Sprite 1 Liter Dasani Water - Walmart.com","displayText":"8 Oz of 20 Oz Dasani Water Bottle"},{"name":"Dasani Purified Water - 20 fl oz Bottle | Water purifier, Bottle ...","displayText":"Dasani Royal Vendors"},{"name":"Dasani Water Mineral Natural Spring Water Wholesale Suppliers - Buy ...","displayText":"Dasani Caps"},{"name":"Dasani Bottled Water, 1L x 12 – Watermans.ca","displayText":"Dasani Sun"},{"name":"Dasani 20oz - Breakroom Choices","displayText":"Dasani Water PNG"},{"name":"Dasani Water 32-Pack Rental","displayText":"10 Oz Dasani Water Bottles"},{"name":"Dasani : Water : Target","displayText":"Dasani Flavored Water Cranberry"},{"name":"Dasani Mineral Water - Gastronomy Inc","displayText":"Dasani Water Vending Lable"},{"name":"Dasani Water Nutrition Label - Label Ideas","displayText":"Dasani Water in Mexico"},{"name":"Dasani® Water :: McDonalds.com | Dasani water, Dasani bottle, Beverage ...","displayText":"Dasani Water Transparent"},{"name":"Dasani Water Bottle Isolated Stock Photos, Pictures & Royalty-Free ...","displayText":"Dasani Water 20 oz Pack"},{"name":"Dasani Raspberry Water Beverage, 20 Fl. Oz. - Walmart.com - Walmart.com","displayText":"Dasani Sparkling Water"},{"name":"Dasani Drinking Water 24x600ml","displayText":"Flavored Dasani Water"}]});
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
    final repQ = bestRepQ(filePath);
    //print(repQ); //TESTING

    // Filter based on the best rep query
    final filteredNames = nameFinder(unfilteredNames, repQ);
    final filteredDisText = nameFinder(unfilteredDisText, repQ);

    //Testing
    //print("${unfilteredNames.length} ${unfilteredDisText.length} ${filteredNames.length} ${filteredDisText.length}");

    //write export JSON
    return exportData(filteredNames, filteredDisText, repQ);
  } catch (error) {
    print('Error getting data: $error');
  }
  return "Bing API Pipeline Failed.";
}

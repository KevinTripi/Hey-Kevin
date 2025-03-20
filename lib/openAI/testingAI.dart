import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// import 'key.dart';

const String apiKey = API_KEY;

// Setting up GPT
const String commentsGenerateMessage = '''
  "Give me a JSON output (do not include ANY other sentence. I strictly need JSON output.
  do not include any whitespace or newline specifiers.
  Generate three different styles of quotes (sarcastic, witty, and funny) about an item I give you next.
  If you struggle to generate the output, you must say 'Nobody is home'.
  Format strictly as: {"sarcastic": "text", "witty": "text", "funny": "text"}.
  Try refraining from using 'Oh great,' and 'Ah, yes' each time.
  If you get a prompt with no words and numbers no matter the size, don't generate a response and throw an error."
''';

/* This function returns 3 comments generated from chatgpt. It runs in the background indefinitely, taking prompts after prompts,
until you type 'exit' */
Future<void> getGptComments() async {
  // While loop for continuous prompts
  while (true) {
    // Get input from user
    stdout.write("Give an item: (type 'exit' to stop): ");
    String userInput = stdin.readLineSync() ?? "";

    if (userInput.toLowerCase() == "exit") {
      break;
    }

    // To catch errors
    try {
      final startTime = DateTime.now(); // for testing API response times
      final response = await fetchGptResponse(userInput);
      final elapsedTime =
          DateTime.now().difference(startTime).inMilliseconds / 1000;

      if (response != null) {
        // Print them out individually, Sarcastic, Witty, Funny, from the JSON that is provided by the API
        final parsedResult = jsonDecode(response);
        parsedResult.forEach((key, value) {
          print("\nGenerated $key comment: $value");
        });
        // Print API response time
        print("\nAPI responded in ${elapsedTime.toStringAsFixed(2)} seconds\n");
      }
    } catch (e) {
      // If there is an exception, we display a fixed prompt
      print("\nError: $e");
      print(
          "\nGenerated sarcastic comment: Error 404: Sarcasm not found. Try again later.");
      print(
          "Generated witty comment: Critical failure: Wit module has crashed. Rebooting… never.");
      print(
          "Generated funny comment: System malfunction: Humor drive corrupted. Attempting emergency joke recovery… failed.\n");
    }
  }
}

// This function sends API request and returns JSON object that contains the comments
Future<String?> fetchGptResponse(String objectTitle) async {
  final url = Uri.parse("https://api.openai.com/v1/chat/completions");

  final headers = {
    "Authorization": "Bearer $apiKey",
    "Content-Type": "application/json",
  };

  final body = jsonEncode({
    "model": "gpt-4o-mini",
    "messages": [
      {
        "role": "user",
        "content": commentsGenerateMessage
      }, // Setting up input message
      {
        "role": "user",
        "content": objectTitle
      } // Attach object title to input message
    ],
    "temperature": 1.5,
    "max_tokens": 100
  });

  // Get response
  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["choices"][0]["message"][
        "content"]; // JSON is located in data["choices"][0]["message"]["content"]
  } else {
    throw Exception("Failed to fetch response: ${response.body}");
  }
}

Future<void> printParsedResult(Map parsedResult) async {
  parsedResult.forEach((key, value) {
    print("\nGenerated $key comment: $value");
  });
}

// This function takes a STRING object_title and generates 3 comments about it from chatgpt
Future<List<List<String>>> singleRunGetGptComments(String objectTitle) async {
  final List<List<String>> retList = [
    [objectTitle, ""],
  ];
  // To catch errors
  try {
    final startTime = DateTime.now(); // for testing API response times
    final response = await fetchGptResponse(objectTitle);
    final elapsedTime =
        DateTime.now().difference(startTime).inMilliseconds / 1000;

    if (response != null) {
      // Print them out individually, Sarcastic, Witty, Funny, from the JSON that is provided by the API
      final parsedResult = jsonDecode(response);
      parsedResult.forEach((key, value) {
        print("\nGenerated $key comment: $value");
        retList.add([key, value]);
      });
      print("\nAPI responded in ${elapsedTime.toStringAsFixed(2)} seconds\n");
    }
  } catch (e) {
    // If there is an exception, we display a fixed prompt
    print("\nError: $e");
    print(
        "\nGenerated sarcastic comment: Error 404: Sarcasm not found. Try again later.");
    print(
        "Generated witty comment: Critical failure: Wit module has crashed. Rebooting… never.");
    print(
        "Generated funny comment: System malfunction: Humor drive corrupted. Attempting emergency joke recovery… failed.\n");
    retList.addAll([
      ["Error", "Error"],
      ["Error", "Error"],
      ["Error", "Error"]
    ]);
  }
  return retList;
}

// main
// void main() async {
//   // await getGptComments();
//   await singleRunGetGptComments("apple");
// }

/* Working on this error detected while running dart file - not detected by py file (root of our issue: API response delays)

Error: Exception: Failed to fetch response: {
    "error": {
        "message": "Rate limit reached for gpt-4o-mini in organization org-71S7UOygwwfrJ7ox1qe2ZhCq on requests per min (RPM): Limit 3, Used 3, Requested 1. Please try again in 20s. Visit https://platform.openai.com/account/rate-limits to learn more.",
        "type": "requests",
        "param": null,
        "code": "rate_limit_exceeded"
    }
}
*/

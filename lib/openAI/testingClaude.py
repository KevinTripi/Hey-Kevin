from anthropic import Anthropic
from key import CLAUDE_API_KEY
import json
import time


# Explaining Claude how to spit out results
set_up_claude_message = """Give me a JSON output (do not include ANY other sentence. I strictly need JSON output).
     Write a short remark about the visual characteristics (object description) and cultural/trendy reference of an object I give you next.
     The visual characteristics should focus on describing the object in a warm manner with minimal but sarcastic humor,
     while the cultural/trendy reference should poke fun in a witty, cultural, and appropriate way.
     Both should be one-liners at all times!!!
     Format strictly as: {"visual_characteristics": "Object name: Text", "cultural_trendy_reference": "Text"}
     Replace "Object name" with the name I give you and capitalize the first letter of every word of the object name here.
     Try refraining from using "Oh great," "sleek", "perfect", "because", and "Ah, yes" each time.
     Give each input an artificial "variation number"
     Example:
     {"visual_characteristics": "Nintendo Switch: A chunky tablet that screams, 'I love gaming but refuse to commit to a console.'",
      "cultural_trendy_reference": "The only device that makes playing Mario Kart a legitimate excuse to skip adulting."}
     {"visual_characteristics": "Microwave: A kitchen box that judges your cooking abilities.",
      "cultural_trendy_reference": "The appliance that watches you wait impatiently."}
      """

def get_claude_comments(object_title):
    client = Anthropic(api_key=CLAUDE_API_KEY)

    # To catch errors
    try:
        start_time = time.time()  # for testing API response times

        messages = [{"role": "user", "content": set_up_claude_message},
                    ({"role": "user", "content": object_title})]

        # Get response
        message = client.messages.create(
            model="claude-3-7-sonnet-latest",
            max_tokens=100,
            top_p=0.9,
            messages=messages
        )

        # JSON is located in message.content[0].text
        json_result = message.content[0].text

        # Print them out individually
        parsed_result = json.loads(json_result)
        for i in parsed_result:
            print("\n", i, "-", parsed_result[i])
        print("\n")

        # Testing API response times
        response_time = time.time() - start_time
        print("API responded in", round(response_time, 2), "seconds")

    # If there is an exception, we display a fixed prompt
    except Exception as e:
        print(e)
        parsed_result = {"visual_characteristics": "Error: Looks like it borrowed its appearance from static on a dead TV channel.",
                         "use_case": "Perfect for confusing both humans and machines—truly a team player in obscurity."}
        for i in parsed_result:
            print("\n", i, "-", parsed_result[i])
        print("\n")
    return parsed_result

# __main__
my_json = get_claude_comments("apple juice")
print(my_json)

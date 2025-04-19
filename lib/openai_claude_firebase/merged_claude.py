from anthropic import Anthropic
from claude_key import CLAUDE_API_KEY
import json
import time
from firebase_class import FirebaseRestAPI
from firebase_variables import HEY_KEVIN_URL

# This function selects a prompt for extracting object name from bing json
def prompt_select(bing_json):
    if len(bing_json["names"]) > 5:
        # "For figuring out most matched name alone"
        set_up_claude_message = f"""
            {bing_json["names"]}

            Above is a list of names of objects.
            I want you to look at the list and tell me what the most matched object name that appears in more lines.
            Only extract the name. It should be an object at all costs. Do NOT include any explanation or comments.
            Format: {{"object_name": "most matched name"}}
            """
    else:
        # "For figuring out most matched name alone"
        set_up_claude_message = f"""
        I have three tasks for you. Handle them separately at all costs. 
        Only return answer in json format in task 3
        Do not give comments or explanations!

        {bing_json["names"]}
        1. Above is a list of names of objects.
        I want you to look at the list and tell me what the most matched object name that appears in more lines.
        Only extract the object name. It should be an object at all costs.Do NOT include any explanation or comments.

        2. Now compare most matched object name to {bing_json["query"]}. Return the more specific object between them.
        If {bing_json["query"]} is not an object, return most matched object name
        If most matched object name is not an object, return {bing_json["query"]}

        3. Return the response in JSON format
        {{"best_name": "most matched name from task 1", "object_name": "more specific name from task 2"}}
        """
    return set_up_claude_message

# This function extracts object name from bing json and returns it as a json
def get_object_name(bing_json):
    claude_prompt = prompt_select(bing_json)
    try:
        claude_json = run_claude(claude_prompt)
        parsed_result = json.loads(claude_json)
    # If there is an exception, we display an error
    except Exception as e:
        print(e)
        parsed_result = {"error": "Error: Object not found..."}
    return parsed_result

# This function is used to run claude for extracting object name
def run_claude(claude_message):
    client = Anthropic(api_key=CLAUDE_API_KEY)
    # To catch errors
    start_time = time.time() # for testing API response times
    # Setting up input message
    messages = [{"role": "user", "content": claude_message}]
    # Get response
    message = client.messages.create(
        model="claude-3-7-sonnet-latest",
        max_tokens=100,
        top_p=0.9,
        messages=messages
    )
    # JSON is located in message.content[0].text
    claude_response = message.content[0].text
    #  Testing API response times
    response_time = time.time() - start_time
    print("API responded in", round(response_time, 2), "seconds")
    return claude_response


# Explaining Claude how to spit out humorous comments
set_up_claude_message = """Give me a JSON output (do not include ANY other sentence. I strictly need JSON output).
     Write a short remark about the visual characteristics (object description) and cultural/trendy reference of an object I give you next.
     The visual characteristics should focus on describing the object in a warm manner with minimal but sarcastic humor,
     while the cultural/trendy reference should poke fun in a witty, cultural, and appropriate way.
     Both should be one-liners at all times!!!
     Format strictly as: {"Visual_characteristics": "Object name: Text", "cultural_trendy_reference": "Text"}
     Replace "Object name" with the name I give you and capitalize the first letter of every word of the object name here.
     Try refraining from using "Oh great," "sleek", "perfect", "because", and "Ah, yes" each time.
     Give each input an artificial "variation number"
     Example:
     {"Visual_characteristics": "Nintendo Switch: A chunky tablet that screams, 'I love gaming but refuse to commit to a console.'",
      "cultural_trendy_reference": "The only device that makes playing Mario Kart a legitimate excuse to skip adulting."}
     {"Visual_characteristics": "Microwave: A kitchen box that judges your cooking abilities.",
      "cultural_trendy_reference": "The appliance that watches you wait impatiently."}
      """

# This function runs claude to generate humorous comments and returns it as a json with 3 key value pairs
# It also posts this entry into firebase
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
            messages=messages,
            temperature=0.5
        )

        # JSON is located in message.content[0].text
        json_result = message.content[0].text

        # Print them out individually
        parsed_result = json.loads(json_result)
        print()
        for i in parsed_result:
            print(i, "-", parsed_result[i])

        # Testing API response times
        response_time = time.time() - start_time
        print("API responded in", round(response_time, 2), "seconds")

        parsed_result["Object_name"] = object_title
        return db.post(parsed_result)

    # If there is an exception, we display a fixed prompt
    except Exception as e:
        print(e)
        parsed_result = {"Visual_characteristics": "Error: Looks like it borrowed its appearance from static on a dead TV channel.",
                         "cultural_trendy_reference": "Perfect for confusing both humans and machines—truly a team player in obscurity."}
        for i in parsed_result:
            print("\n", i, "-", parsed_result[i])
        print("\n")
        return None


# Good files for testing from bing_exports directory
# 13, 103, 106, 107, 108, 110, 115, 120, 126

# __main__
with open('../bing_exports/image-130_export.json', 'r') as file:
    bing_json = json.loads(file.read())

db = FirebaseRestAPI(HEY_KEVIN_URL)

# This function runs the pipeline: bing json -> extract object name using claude -> generate claude comments and post to firebase
def run_pipeline(bingJSON):
    object_name_json = get_object_name(bingJSON)
    if "error" in object_name_json:
        print(object_name_json)
        return
    comment_json = get_claude_comments(object_name_json["object_name"])
    if comment_json:
        print(f"Added new entry to database with object {comment_json['Object_name']}")
    else:
        print("Failed to add the entry to database")

run_pipeline(bing_json)



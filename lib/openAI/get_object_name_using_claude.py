from anthropic import Anthropic
from key import CLAUDE_API_KEY
import time
import json

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


def run_claude(gpt_message):
    client = Anthropic(api_key=CLAUDE_API_KEY)
    # To catch errors
    start_time = time.time() # for testing API response times
    # Setting up input message
    messages = [{"role": "user", "content": gpt_message}]
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
    return(claude_response)


# __main__
with open('bing_exports/image-135_export.json', 'r') as file:
    bing_json = json.loads(file.read())

object_name_json = get_object_name(bing_json)
if "error" in object_name_json:
    print(object_name_json["error"])
else:
    print(object_name_json)
    print(object_name_json["object_name"])

# Good files for testing
# 13, 103, 106, 107, 108, 110, 115, 120, 126
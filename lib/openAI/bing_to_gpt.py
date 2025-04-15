
from openai import OpenAI
from key import GPT_API_KEY
import time
import json

# "For comparing query and most matched name"
# set_up_gpt_message = f"""
#     I have three tasks for you. Handle them separately at all costs.
#
#     {bing_json["names"]}
#     1. Above is a list of names of objects.
#     I want you to look at the list and tell me what the most matched object name that appears in more lines.
#     Only extract the object name. It should be an object at all costs.Do NOT include any explanation or comments.
#
#     2. Now compare most matched object name to {bing_json["query"]}. Return the more specific object between them.
#     If {bing_json["query"]} is not an object, return most matched object name
#     If most matched object name is not an object, return {bing_json["query"]}
#
#     3. Return the response in JSON format:
#     {{"best_name": "most matched name from task 1", "object_name": "more specific name from task 2"}}
#     """

# "For figuring out most matched name alone"
# set_up_gpt_message = f"""
#     {bing_json["names"]}
#
#     Above is a list of names of objects.
#     I want you to look at the list and tell me what the most matched object name that appears in more lines.
#     Only extract the name. It should be an object at all costs. Do NOT include any explanation or comments.
#     Format: {{"object_name": "most matched name"}}
#     """

def get_object_name(bing_json):
    set_up_gpt_message = f"""
        I have three tasks for you. Handle them separately at all costs.

        {bing_json["names"]}
        1. Above is a list of names of objects.
        I want you to look at the list and tell me what the most matched object name that appears in more lines.
        Only extract the object name. It should be an object at all costs.Do NOT include any explanation or comments.

        2. Now compare most matched object name to {bing_json["query"]}. Return the more specific object between them.
        If {bing_json["query"]} is not an object, return most matched object name
        If most matched object name is not an object, return {bing_json["query"]}

        3. Return the response in JSON format:
        {{"best_name": "most matched name from task 1", "object_name": "more specific name from task 2"}}
        """
    try:
        gpt_json = run_gpt(set_up_gpt_message)
        parsed_result = json.loads(gpt_json)
    # If there is an exception, we display an error
    except Exception as e:
        print(e)
        parsed_result = {"error": "Object not found..."}
    return parsed_result


def run_gpt(gpt_message):
    client = OpenAI(api_key= GPT_API_KEY)

    # To catch errors
    start_time = time.time() # for testing API response times

    # Setting up input message
    messages = [{"role": "user", "content": gpt_message}]

    # Get response
    completion = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=messages,
        max_tokens=50
    )

    gpt_response = completion.choices[0].message.content

    #  Testing API response times
    response_time = time.time() - start_time
    print("API responded in", round(response_time, 2), "seconds")

    return(gpt_response)

# __main__
with open('bing_exports/image-135_export.json', 'r') as file:
    bing_json = json.loads(file.read())

object_name = get_object_name(bing_json)
print(object_name)

# Good files for testing
# 13, 103, 106, 107, 108, 110, 115, 120, 126
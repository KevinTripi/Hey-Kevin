from openai import OpenAI
from key import GPT_API_KEY
import time
import json

# look at the names only. Now tell me what the object is. I just want the most matched object name

def get_object_name(bing_json):
    set_up_gpt_message = f"""
    Here is a list of names of items. I want you to look at the list and tell me what the most matched name. 
    Only extract the object name. It should be an object at all costs.
    Strictly return only a single line JSON. Do NOT include any explanation or comments.
    Format: {{"best_name": "most matched object name"}}
    {bing_json["names"]}
     """
    try:
        gpt_json = run_gpt(set_up_gpt_message)
        parsed_result = json.loads(gpt_json)
    # If there is an exception, we display an error
    except Exception as e:
        print(e)
        parsed_result = {"error": "Object not found..."}

    compare_gpt_message = f"""
        I am going to give you 2 items. return the most specific item from them in json format {{"object_name": "specific name"}}
        Only tell me item name and nothing else. No comments or explanation.
        {bing_json["query"]}
        {parsed_result["best_name"]}
    """
    try:
        gpt_specific_name = run_gpt(compare_gpt_message)
        parsed_result = json.loads(gpt_json)
    # If there is an exception, we display an error
    except Exception as e:
        print(e)
        parsed_result = {"error": "Object not found..."}



def run_gpt(gpt_message):
    client = OpenAI(api_key= GPT_API_KEY)

    # To catch errors
    try:
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


def query_or_name(query, name):




# __main__
with open('bing_exports/image-13_export.json', 'r') as file:
    bing_json = json.loads(file.read())

print(f"query: {bing_json['query']}")
print("names: ")
for i in bing_json['names']:
    print(i)
print()
parsed_result = get_object_name(bing_json)
print(parsed_result)
print(parsed_result["name"])





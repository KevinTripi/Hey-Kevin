from openai import OpenAI
from key import API_KEY
import json
import time

# Explaining chatgpt how to spit out results
comments_generate_message = """Give me a JSON output (do not include ANY other sentence. I strictly need JSON output.
     Do not include any whitespace or newline specifiers.
     Generate two different texts (witty visual characteristics, witty use case) about an item I give you next.
     Format strictly as: {"visual_characteristics": "Object name: Text", "use_case": "Text"}
     Replace "Object name" with the name I give you and capitalize the first letter of the object name here.
     Try refraining from using "Oh great," "sleek", and "Ah, yes" each time.
     Make the texts poke fun at the item while keeping it culture friendly.
     If you get a prompt with no words and numbers no matter the size, don't generate a response and throw an error.
     Limit the text to one sentence each
     """

def get_gpt_comments(object_title):
    client = OpenAI(api_key= API_KEY)

    # Setting up GPT
    set_up_gpt_message = comments_generate_message

    # To catch errors
    try:
        start_time = time.time() # for testing API response times

        # Setting up input message
        messages = [{"role": "user", "content": set_up_gpt_message},
                    ({"role": "user", "content": object_title})]

        # Get response
        completion = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=messages,
            temperature=1.5,
            max_tokens=100
        )

        # JSON is located in completion.choices[0].message.content
        json_result = completion.choices[0].message.content

        # Print them out individually, Sarcastic, Witty, Funny, from the JSON that is provided by the API
        parsed_result = json.loads(json_result)
        for i in parsed_result:
            print("\n", i, "-", parsed_result[i])
        print("\n")

        #  Testing API response times
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
my_json = get_gpt_comments("nintendo switch")
print(my_json)

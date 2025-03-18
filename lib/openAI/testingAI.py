from openai import OpenAI
from key import API_KEY
import json
import time

API_KEY = API_KEY

# Explaining chatgpt how to spit out results
comments_generate_message = """"Give me a JSON output (do not include ANY other sentence. I strictly need JSON output. 
     do not include any whitespace or newline specifiers.
     Generate three different styles of quotes (sarcastic, witty, and funny) about an item I give you next.
     If you struggle to generate the output, you must say "Nobody is home").
     Format strictly as: {"sarcastic": "text", "witty": "text", "funny": "text"}.
     Try refraining from using "Oh great," and "Ah, yes" each time.
     If you get a prompt with no words and numbers no matter the size, don't generate a response and throw an error"""

# This function returns 3 comments generated from chatgpt. It runs in the background indefinitely, taking prompts after prompts,
# until you type 'exit'
def get_gpt_comments():
    client = OpenAI(api_key= API_KEY)

    # Setting up GPT
    set_up_gpt_message = comments_generate_message

    # Setting up input message
    messages = [{"role": "user", "content": set_up_gpt_message}]

    # While loop for continuous prompts
    while True:
        user_input = input("Give an item: (type 'exit' to stop): ")
        if user_input.lower() == "exit":
            break

        # Append user message to input message
        messages.append({"role": "user", "content":user_input})

        # To catch errors
        try:
            start_time = time.time() # for testing API response times

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
                print("\nGenerated", i, "comment", ":", parsed_result[i])
            print("\n")

            #  Testing API response times
            response_time = time.time() - start_time
            print("API responded in", round(response_time, 2), "seconds\n")

        # If there is an exception, we display a fixed prompt
        except Exception as e:
            print(e)
            parsed_result = {"sarcastic": "Error 404: Sarcasm not found. Try again later.", "witty": "Critical failure: Wit module has crashed. Rebooting… never.", "funny": "System malfunction: Humor drive corrupted. Attempting emergency joke recovery… failed."}
            for i in parsed_result:
                print("\nGenerated", i, "comment", ":", parsed_result[i])
            print("\n")
            continue

        # Pop last prompt: Testing for API response delays
        messages.pop(1)

# This function takes a STRING object_title and generates 3 comments about it from chatgpt
def single_run_get_gpt_comments(object_title):
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
            print("\nGenerated", i, "comment", ":", parsed_result[i])
        print("\n")

        #  Testing API response times
        response_time = time.time() - start_time
        print("API responded in", round(response_time, 2), "seconds")

    # If there is an exception, we display a fixed prompt
    except Exception as e:
        print(e)
        parsed_result = {"sarcastic": "Error 404: Sarcasm not found. Try again later.", "witty": "Critical failure: Wit module has crashed. Rebooting… never.", "funny": "System malfunction: Humor drive corrupted. Attempting emergency joke recovery… failed."}
        for i in parsed_result:
            print("\nGenerated", i, "comment", ":", parsed_result[i])
        print("\n")
        return

# Working on this error detected while running dart file - not detected by py file (root of our issue: API response delays)
#
# Error: Exception: Failed to fetch response: {
#     "error": {
#         "message": "Rate limit reached for gpt-4o-mini in organization org-71S7UOygwwfrJ7ox1qe2ZhCq on requests per min (RPM): Limit 3, Used 3, Requested 1. Please try again in 20s. Visit https://platform.openai.com/account/rate-limits to learn more.",
#         "type": "requests",
#         "param": null,
#         "code": "rate_limit_exceeded"
#     }
# }

single_run_get_gpt_comments("apple")
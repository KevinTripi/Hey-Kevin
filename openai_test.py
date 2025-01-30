from openai import OpenAI
import json
from api_key import KEY

client = OpenAI(
  api_key=KEY
)

completion = client.chat.completions.create(
  model="gpt-4o-mini",
  store=False,
  messages=[
    {"role": "user", "content": "Give me a JSON output (do not include ANY other sentence. I strictly need JSON output. do not include any whitespace or newline specifiers \
     If you struggle to generate the output, you must say \"Nobody is home...\"), with three different styles of quotes. \
     top value should be quotes, followed by the 3 types of quotes (sarcastic, rude, and funny).\
     example: {\"quotes\": [\"sarcastic\": \"I'm not a complete idiot. Some parts are missing.\", \
        \"rude\": \"I'm not a complete idiot. Some parts are missing.\", \
        \"funny\": \"I'm not a complete idiot. Some parts are missing.\"]}\
     Perform this on item [Samsung S25 Ultra]"},
    #  The quotes should be in a list, and the list should be in a dictionary. \"}
  ]
)

print(completion.choices[0].message.content)



# Print them out individually, Rude, Sarcastic, Funny, from the JSON that is provided by the API
# JSON is located in completion.choices[0].message.content
json_str = completion.choices[0].message.content
json_obj = json.loads(json_str)
print(f"Generated Rude Comment: {json_obj["quotes"][0]["rude"]}")
print(f"Generated Sarcastic Comment: {json_obj["quotes"][0]["sarcastic"]}")
print(f"Generated Funny Comment: {json_obj["quotes"][0]["funny"]}")

# for quote_type in ["rude", "sarcastic", "funny"]:
#     print(f"Generated {quote_type.capitalize()} Comment: {json_obj['quotes'][0][quote_type]}")


# # Print the JSON output as a string
# print(json.dumps(completion.choices[0].message.content, indent=2))
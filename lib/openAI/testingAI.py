from openai import OpenAI
from key import API_KEY
import json
import time

# Explaining chatgpt how to spit out results
comments_generate_message = """Give me a JSON output (do not include ANY other sentence. I strictly need JSON output.
     Do not include any whitespace or newline specifiers.
     Generate three different styles of quotes (object features description, goofy use case, and online review) about an item I give you next.
     If you struggle to generate the output, you must say "Nobody is home" as values to each of the keys of JSON).
     Format strictly as: {"object_features_description": "Object name: text", "goofy_use_case": "text", "online review": "text"}
     Make features description sarcastic, use case witty and online review funny. Don't make dad jokes with the them but make sure they are different.
     Replace "Object name" with the name I give you and capitalize the first letter of the object name here.
     Try refraining from using "Oh great," "sleek", and "Ah, yes" each time.
     If you get a prompt with no words and numbers no matter the size, don't generate a response and throw an error.
     Limit to 100 tokens
     """


# Original comments_generate_message
# comments_generate_message = """"Give me a JSON output (do not include ANY other sentence. I strictly need JSON output.
#      do not include any whitespace or newline specifiers.
#      Generate three different styles of quotes (sarcastic, witty, and funny) about an item I give you next.
#      If you struggle to generate the output, you must say "Nobody is home").
#      Format strictly as: {"sarcastic": "text", "witty": "text", "funny": "text"}.
#      Try refraining from using "Oh great," and "Ah, yes" each time.
#      If you get a prompt with no words and numbers no matter the size, don't generate a response and throw an error"""

# This function takes a STRING object_title and generates 3 comments about it from chatgpt
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
        parsed_result = {"object_features_description": "Failed to extract features. The object refuses to be known.",
                         "goofy_use_case": "Use it as a paperweight for documents you’ll never read—just like this object.",
                         "online review": "1 star...It failed to be known. I bought a mystery, and all I got was confusion and regret."}
        for i in parsed_result:
            print("\n", i, "-", parsed_result[i])
        print("\n")
    return parsed_result

# __main__
my_json = get_gpt_comments("xbox controller")
print(my_json)


# -----------------------COMPARING LLMs------------------------------
# Deepseek-V3
# {"object_features_description": "Yeti Bottle: A glorified thermos with a cult following, designed to keep your water suspiciously cold for longer than any human should realistically need.", "goofy_use_case": "Ideal for pretending you're on an Arctic expedition while sitting in your climate-controlled office, occasionally shaking it to hear the ice clink for dramatic effect.", "online review": "This thing survived a drop from my desk, a trip through the dishwasher, and my dog's attempt to bury it. Still holds ice like a champ. 10/10, would overpay again."}
# {"object_features_description": "Xbox Controller: A sleek, ergonomic masterpiece that somehow still manages to disappear into the couch cushions like it's part of a magic act.", "goofy_use_case": "Perfect for aggressively button-mashing during a cutscene you've seen 100 times, as if it'll somehow change the outcome this time.", "online review": "Bought this to 'enhance my gaming skills.' Turns out, it doesn't auto-dodge attacks in Dark Souls. One star for false advertising."}
#
# Chat gpt 4o
# {"object_features_description":"Yeti Bottle: Because you absolutely need a stainless steel fortress to protect your precious tap water from the harsh realities of room temperature.","goofy_use_case":"Perfect for passive-aggressively slamming on the table during meetings to assert dominance without saying a word.","online review":"Dropped it down a mountain, ran it over with my car, and it still kept my coffee hot. I'm starting to think it's indestructible—or maybe just really stubborn."}
# {"object_features_description":"Xbox Controller: Because your thumbs deserve a throne of plastic and buttons to rule over virtual worlds.","goofy_use_case":"Ideal for practicing your 'rage quit' technique—just be sure to have a soft landing spot.","online review":"I bought this to improve my gaming skills, but now I just use it to navigate Netflix. 5 stars for versatility!"}
#
# Claude 3.7 sonnet
# {"object_features_description": "Yeti bottle: A ridiculously overpriced metal container that somehow convinced us all that lukewarm water tastes better when stored in a vessel that costs more than dinner for two.", "goofy_use_case": "Perfect for hauling around three pounds of empty bottle on your hiking trips so you can feel superior to people using plastic while simultaneously developing stronger shoulder muscles.", "online review": "This indestructible liquid vault has successfully survived being dropped, run over, and thrown at my ex's car, though my bank account is still recovering from the purchase."}
# {"object_features_description": "Xbox controller: An ergonomic hand torture device designed to leave your thumbs permanently calloused and your wallet significantly lighter with each rage-induced replacement.", "goofy_use_case": "Excellent for convincing yourself you're actually exercising as you frantically mash buttons while surrounded by empty energy drink cans and chip bags at 3 AM.", "online review": "This magical frustration rectangle has helped me discover creative new swear word combinations I never knew existed while simultaneously ruining my relationships with both family and online strangers."}
#
# Chatgpt 4o mini
# {"object_features_description": "Yeti Bottle: A fancy thermos that claims to keep your drink cold for 24 hours, but let’s be honest, it’s mostly just a status symbol for people who like their water as cold as their soul.", "goofy_use_case": "For when you need to carry your iced coffee from 7 a.m. to 7 p.m. without a single drop of warmth creeping in, because nothing says ‘I’m an adult’ like over-engineered hydration.", "online_review": "It’s a bottle, but also a lifestyle choice. Keeps drinks cold for so long, you’ll wonder if it’s secretly a time machine. Worth every penny if you’re into hydration that makes you feel superior."}
# {"object_features_description": "Xbox Controller: A device designed to let you mash buttons while pretending to be a pro gamer, but really just hoping the controller doesn't betray you during crucial moments.", "goofy_use_case": "Perfect for those times when you’re too lazy to use your brain and just want to destroy some virtual worlds with mindless button mashing.", "online_review": "It’s like the Swiss Army knife of gaming: everything works, and then you realize you can’t escape the endless cycle of video games. 10/10 would buy again."}
#
#
# ChatGPT 4o analyzes the LLMs:
# Rank	Model	Why
# 1	Claude 3.7 Sonnet	Most bold, irreverent, and creative—exactly matches your tone constraints.
# 2	DeepSeek-V3	Consistently strong and punchy, with witty human-like twists.
# 3	GPT-4o	Polished and humorous, but a bit safer and slightly repetitive.
# 4	GPT-4o Mini	Still funny, but less risk-taking and more generalized phrasing.
#
#
# Deepseek-V3 analyzes the LLMs:
# Tone Spectrum
# From lighthearted to cynical:
# Mini (friendly) → DeepSeek (playful) → ChatGPT 4o (wry) → Claude (dark)
#
# Best For
# DeepSeek: Creative storytelling.
# ChatGPT 4o: Sharp, polished satire.
# Claude: Edgy, self-roasting humor.
# Mini: Quick, relatable giggles.
#
# Winner? Depends on your mood—but Claude wins for style if you love dark comedy, while DeepSeek takes originality.
#
#
# My notes:
# ChatGPT 4o mini: Good for quick, friendly jokes
# DeepSeek V3: Human-like storytelling but might stretch away from what I am trying to achieve with Hey Kevin
# Claude 3.7 Sonnet: Most dark and daring, self roasting - for gen z audience
# ChatGPT 4o: Balanced but dry, polished humor

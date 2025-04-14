from openai import OpenAI
from key import API_KEY
import json
import time


# Explaining chatgpt how to spit out results
comments_generate_message = """Give me a JSON output (do not include ANY other sentence. I strictly need JSON output.
     Write a short remark about the visual characteristics (object description) and cultural/trendy reference of an object I give you next.
     The visual characteristics should focus on describing the object with minimal but sarcastic humor,
     while the cultural/trendy reference should poke fun in a witty, cultural, and appropriate way.
     Both should be one-liners at all times!!!
     Format strictly as: {"visual_characteristics": "Object name: Text", "cultural_trendy_reference": "Text"}
     Replace "Object name" with the name I give you and capitalize the first letter of the object name here.
     Try refraining from using "Oh great," "sleek", "perfect", "because", and "Ah, yes" each time.
     Example:
     {"visual_characteristics": "Nintendo Switch: A chunky tablet that screams, 'I love gaming but refuse to commit to a console.'",
      "cultural_trendy_reference": "The only device that makes playing Mario Kart a legitimate excuse to skip adulting."}
     {"visual_characteristics": "Microwave: A kitchen box that judges your cooking abilities.",
      "cultural_trendy_reference": "The appliance that watches you wait impatiently."}
     """

# Previous best prompt
# comments_generate_message = """Give me a JSON output (do not include ANY other sentence. I strictly need JSON output.
#      Do not include any whitespace or newline specifiers.
#      Write a short, sarcastic one-liner remark about the visual characteristics (object description) and use case of an object I give you next.
#      The visual characteristics should focus on describing the object with minimal,
#      while the use case should poke fun at the object in a cultural, relatable, and appropriate way.
#      Both should be quick one-liners at all times.
#      Format strictly as: {"visual_characteristics": "Object name: Text", "use_case": "Text"}
#      Replace "Object name" with the name I give you and capitalize the first letter of the object name here.
#      Try refraining from using "Oh great," "sleek", "perfect" and "Ah, yes" each time.
#      If you get a prompt with no words and numbers no matter the size, don't generate a response and throw an error.
#      """

# Old prompt
# comments_generate_message = """Give me a JSON output (do not include ANY other sentence. I strictly need JSON output.
#      Do not include any whitespace or newline specifiers.
#      Generate two different texts (witty visual characteristics, witty use case) about an object I give you next.
#      Format strictly as: {"visual_characteristics": "Object name: Text", "use_case": "Text"}
#      Replace "Object name" with the name I give you and capitalize the first letter of the object name here.
#      Try refraining from using "Oh great," "sleek", and "Ah, yes" each time.
#      Make the texts poke fun at the object while keeping it culture friendly and relatable.
#      If you get a prompt with no words and numbers no matter the size, don't generate a response and throw an error.
#      Limit the text to one liners each
#      """

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
            temperature=1.2,
            top_p=0.9,
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
my_json = get_gpt_comments("airforces")
print(my_json)


# Gathering responses for testing. Modified the gpt message as I did more tests below
#
#
# temperature = 1.5, no top_p
#
# shape_characteristics - Xbox Controller: A fancy rectangular blender that somehow becomes our source of terabytes of rage.
# cultural_trendy_reference - If 'Netflix and Chill' had a less productive older brother, it would be 'Xbox and Vanish'.
#
# shape_characteristics - Record Player: Retro circles fighting dust like they’re training for an Olympic event.
# cultural_trendy_reference - Once a museum artifact, now essential for claiming you support local bands over overpriced lattes.
#
# shape_characteristics - Bose QuietComfort 45: It's like wearing softer clouds that would rather not disturb your day with basic noises.
# cultural_trendy_reference - Every influencer on Instagram is waiting for that 'peace and quiet' aesthetic while lounging at the trendy café.
#
# shape_characteristics - Tennis ball: A fuzzy sphere that wonders if Rubik’s Cube-like brainteasers might’ve been mutated.
# cultural_trendy_reference - Perfectly matches the current craze of millennial panic over physics-free summer sports.
#
# shape_characteristics - Resident Assistant: An oversized accountability drone that buzzes around keeping everyone on the straight and narrow.
# cultural_trendy_reference - Just like avocado toast, everyone loves the idea, but no one really asked for the responsibility of nurturing.
#
# shape_characteristics - Nintendo Switch: A clunky tablet that pretends it's thick when chips are on its shoulders.
# cultural_trendy_reference - Nothing says 'I have adult responsibilities' like playing supertitles instead of making dinner.
#
# shape_characteristics - Iphone 16: A thin rectangular piece of metal and glass that begs for a hug while similarly causing existential crises due to its cost.
# cultural_trendy_reference - It's the overpriced successor to Instagram’s digital-glamour where breaking your screen could cause more emotional trauma than a bad breakup.
#
# shape_characteristics - Curtain rod: A sometimes bent, often featureless pole that holds onto fabric like friends trying to keep up appearances at a party.
# cultural_trendy_reference - Universally admired for initiating deep discussions about the vagaries of hanging fabric.
#
#
#
#
# temperature = 1.3, top_p = 0.8
#
# visual_characteristics - Xbox Controller: A glorified gamepad that screams, 'I promise I have friends!'
# cultural_trendy_reference - Because nothing says 'I have my life together' like mastering button mashing in your mom's basement.
#
# visual_characteristics - Record Player: A large, dusty relic that spins circles like it's trying to avoid commitment.
# cultural_trendy_reference - The hipster's choice for enjoying music the same way your grandparents did—minus the charm.
#
# visual_characteristics - Nintendo Switch: A chunky tablet that screams, 'I love gaming but refuse to commit to a console.'
# cultural_trendy_reference - The only device that makes playing Mario Kart a legitimate excuse to skip adulting.
#
# shape_characteristics - Playstation controller: It's like an ergonomic snack for your thumbs, designed for marathon gaming sessions and finger acrobatics.
# cultural_trendy_reference - The modern-day scepter for the couch potato royalty, where 'saving the world' is just a button mash away.
#
#
#
#
# temperature = 1.25, top_p = 0.8
#
#  shape_characteristics - Record player: A round, spinning disc that screams nostalgia while pretending to be vintage cool.
#  cultural_trendy_reference - As trendy as a hipster's coffee order, but at least it doesn't require oat milk.
#
# shape_characteristics - Playstation controller: A love letter to ergonomics, signed with a thousand thumbprints.
# cultural_trendy_reference - The modern-day pacifier for adults who can't deal with real-life boss battles.
#
#  shape_characteristics - Leather wallet: A sad, flat rectangle that holds your dreams and receipts hostage.
#  cultural_trendy_reference - Just like your favorite coffee shop, it’s overpriced and makes you feel sophisticated while it drains your wallet.
#
# shape_characteristics - Macbook Air: A slim rectangle that screams, 'I prioritize my aesthetics over my durability.'
# cultural_trendy_reference - Looks like a tech-savvy hipster's dream, perfect for typing your manifesto in a coffee shop.
#
#
#
#
# After including examples
# temperature = 1.2, top_p = 0.9
#
# visual_characteristics - Xbox Controller: A glorified remote that gives you the illusion of having control over your life while you sit on the couch.
# cultural_trendy_reference - The hand-held ticket to virtual glory, ensuring your thumbs are the only muscles you ever flex.
#
# visual_characteristics - Nintendo Switch: A device that looks like a remote control's confused cousin who went to art school.
# cultural_trendy_reference - The only console that lets you pretend you're socializing while actually avoiding real-life friendships.
#
# visual_characteristics - Malachite Rock: A green stone that looks like Mother Nature's attempt at abstract art gone wrong.
# cultural_trendy_reference - The only rock that gives 'eco-friendly' a run for its money while making you feel fancy and broke.
#
# visual_characteristics - German Stein: A hefty mug that doubles as a weightlifting tool for your wrist while you drink.
# cultural_trendy_reference - The ultimate accessory for anyone who thinks Oktoberfest is a lifestyle, not just a party.
#
#  visual_characteristics - Record Player: A retro contraption that spins vinyls like a DJ in a midlife crisis.
#  cultural_trendy_reference - The hipster's answer to 'How do I make my music collection more difficult to manage?'
#
#  visual_characteristics - Wooden Plank: A flat piece of wood that’s basically a nature-approved alternative to a desk, with zero style points.
#  cultural_trendy_reference - The original multitasker, used by carpenters and hipsters alike to make everything from furniture to questionable art.
#
# visual_characteristics - Skateboard: A wooden plank on wheels that proudly announces, 'I have balance issues.'
# cultural_trendy_reference - The preferred mode of transport for those who want to look cool while definitely not taking the bus.
#
#  visual_characteristics - Night Lamp: A small, glowing orb that pretends to be your bedside guardian while you scroll through your existential dread.
#  cultural_trendy_reference - The only way to signal to your partner that it's time to 'talk about feelings' without turning on the harsh overhead lights.
#
# visual_characteristics - Airforces: Classic sneakers that say, 'I might exercise one day, but today is not that day.'
# cultural_trendy_reference - The shoes that have transformed countless feet into 'I woke up like this' fashion icons.

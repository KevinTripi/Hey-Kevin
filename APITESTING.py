import requests
import json

BASE_URI = 'https://api.bing.microsoft.com/v7.0/images/visualsearch'

""" sign up for a free student azure account or use the S1 plan to 
    search for things. make a bing search resource, and make it's
    resource group at the same time (or just make sure the group is a
    visual search resource)
"""

""" SUBSCRIPTION_KEY = 'insert API KEY' """ 
imagePath = "alice.jpg"

HEADERS = {'Ocp-Apim-Subscription-Key': SUBSCRIPTION_KEY}

file = {'image': ('myfile', open(imagePath, 'rb'))}

def print_json(obj):
    """Print the object as JSON"""
    print(json.dumps(obj, sort_keys=True, indent=2, separators=(',', ': ')))

try:
    response = requests.post(BASE_URI, headers=HEADERS, files=file)
    response.raise_for_status()
    # Saving response JSON to result.json file
    with open("result.json", "w") as f:
        json.dump(response.json(), f, indent=2)
except Exception as ex:
    raise ex 

# Function 
def get_entries(file_path):
    entries = []

    
    # Read the JSON file
    with open(file_path, "r") as f:
        data = json.load(f)
    
    # tags -> actions -> data -> value
    # need to check path for displayText (use displayText data as well?)
    tags = data.get("tags", [])
    for tag in tags:
        actions = tag.get("actions", [])
        for action in actions:
            if action.get("_type") == "ImageModuleAction": 
                value_list = action.get("data", {}).get("value", [])
                
                for item in value_list:
                    name = item.get("name", "")
                    entries.append({
                            "name": name,
                        })
    
    return entries

file_path = "result.json"

# Extract and print Florence-related entries
entries = get_entries(file_path)
print("start",entries,"end please show that this is the end please")
import requests
import json
import re

BASE_URI = 'https://api.bing.microsoft.com/v7.0/images/visualsearch'

""" sign up for a free student azure account or use the S1 plan to 
    search for things. make a bing search resource, and make it's
    resource group at the same time (or just make sure the group is a
    visual search resource) """

SUBSCRIPTION_KEY = '31013ec018f4420c82d63ae0d73066fe' 
imagePath = "dasani-water-217886-64_600.jpg"

HEADERS = {'Ocp-Apim-Subscription-Key': SUBSCRIPTION_KEY}

file = {'image': ('myfile', open(imagePath, 'rb'))}

def print_json(obj):
    #Print the object as JSON
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
def get_title_names(file_path):
    entries = []

    # Read the JSON file
    with open(file_path, "r") as f:
        data = json.load(f)
    
    # tags -> actions -> data -> value
    
    tags = data.get("tags", [])
    for tag in tags:
        actions = tag.get("actions", [])
        for action in actions:
            if action.get("_type") == "ImageModuleAction": 
                value_list = action.get("data", {}).get("value", [])
                
                for item in value_list:
                    name = item.get("name", "")
                    entries.append(name)
    
    return entries
            
def get_display_text(file_path):
    entries = []
    
    # Read the JSON file
    with open(file_path, "r") as f:
        data = json.load(f)
    
    # tags -> actions -> data -> value    
    tags = data.get("tags", [])
    for tag in tags:
        actions = tag.get("actions", [])
        for action in actions:
            if action.get("_type") == "ImageRelatedSearchesAction": 
                value_list = action.get("data", {}).get("value", [])
                
                for item in value_list:
                    displayText = item.get("displayText", "")
                    entries.append(displayText)
    
    return entries

file_path = "result.json"

entries1 = get_title_names(file_path)
entries2 = get_display_text(file_path)

def name_finder(names):
    
    find = names[0]
    found = []
    
    for name in names:
        if(re.search(find, name)):
            found.append(name)
                
    return found

print("start",entries1,"end please show that this is the end please")
print("\n now this is the start of second entries", entries2, "this is where entries2 ends")

print("\n\n")

found1 = name_finder(entries1)

print(len(entries1), " ", len(entries2), " ", len(found1))
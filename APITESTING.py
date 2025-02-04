from ntpath import join
import requests
import string
import json
import re

BASE_URI = 'https://api.bing.microsoft.com/v7.0/images/visualsearch'

SUBSCRIPTION_KEY = '31013ec018f4420c82d63ae0d73066fe' 
imagePath = "alice.jpg"

HEADERS = {'Ocp-Apim-Subscription-Key': SUBSCRIPTION_KEY}

file = {'image': ('myfile', open(imagePath, 'rb'))}

try:
    response = requests.post(BASE_URI, headers=HEADERS, files=file)
    response.raise_for_status()
    # Saving response JSON to result.json file
    with open("result.json", "w") as f:
        json.dump(response.json(), f, indent=2)
except Exception as ex:
    raise AttributeError 

# gets the names for the image
def get_title_names(file_path):
    entries = []

    # Read the JSON file
    with open(file_path, "r") as f:
        data = json.load(f)
    
    # navigate through the json, tags -> actions -> data -> value
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
            
#get the display text of the image
def get_display_text(file_path):
    entries = []
    
    # Read the JSON file
    with open(file_path, "r") as f:
        data = json.load(f)
    
    # navigate through the json, tags -> actions -> data -> value    
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

unfilteredNames = get_title_names(file_path)
unfilteredDisText = get_display_text(file_path)

def contains_whitespace(titles):
    return True in [c in titles for c in string.whitespace]

#finds the first value in the unfiltered lists, then filters based on the first word ONLY
def name_finder(names):
    
    find = names[0]
    found = []
    
    for name in names:
        if(re.search(find.split()[0], name)):
            found.append(name)
                
    return found

filteredNames = name_finder(unfilteredNames)
filteredDisText = name_finder(unfilteredDisText)

print(len(unfilteredNames), " ", len(unfilteredDisText), " ", len(filteredNames), len(filteredDisText))
print("\n\n")
print(unfilteredNames, "\n\n", filteredNames)
print("\n\n")
print(unfilteredDisText, "\n\n", filteredDisText)
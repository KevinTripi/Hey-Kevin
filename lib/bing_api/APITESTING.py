import requests
import json
import re

# BING API VARIABLES + IMAGE
# Will need to update imagePath and filePath according to app structure
BASE_URI = 'https://api.bing.microsoft.com/v7.0/images/visualsearch'
SUBSCRIPTION_KEY = ''
imagePath = "lib/bing_api/dasani-water-217886-64_600.jpg"
filePath = "lib/bing_api/result.json"

HEADERS = {'Ocp-Apim-Subscription-Key': SUBSCRIPTION_KEY}

# Sends the request to API
def get_data():
    try:
        with open(imagePath, 'rb') as image_file:
            response = requests.post(BASE_URI, headers=HEADERS, files={'image': ('myfile', image_file)})
            response.raise_for_status()

            # save response json, with formatting
            with open(filePath, "w") as f:
                json.dump(response.json(), f, indent=2)
    except Exception as ex:
        raise Exception(f"Error fetching data: {ex}")

# Gets 'names' from returned JSON
def get_title_names(filePath):
    entries = []

    # Read the JSON file
    with open(filePath, "r") as f:
        data = json.load(f)

    # navigate through the JSON, tags -> actions -> data -> value
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

# gets 'display_text'
def get_display_text(filePath):
    entries = []

    # Read the JSON file
    with open(filePath, "r") as f:
        data = json.load(f)

    # Navigate through the JSON, tags -> actions -> data -> value
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

# gets best descriptor (query) from JSON
def bestRepQ(filePath):
    queries = []

    # Read the JSON file
    with open(filePath, "r") as f:
        data = json.load(f)

    for tag in data.get("tags", []):
        for action in tag.get("actions", []):
            if action.get("actionType") == "BestRepresentativeQuery":
                queries.append(action.get("displayName"))

    return queries

# finds the first value in the unfiltered lists, then filters based on bestrepq
def name_finder(names, query):
    if not names or not query:
        return []

    find = query[0].split()[0]
    found = []

    for name in names:
        if re.search(r'\b' + re.escape(find) + r'\b', name):
            found.append(name)

    return found

# writes export json and returns json 
def export_data(names, displayText, query):
    try:
        minLength = min(len(names), len(displayText))

        exportStructure = {
            "query": query,  # The best representative query
            "data": [
                {"name": names[i], "displayText": displayText[i]}
                for i in range(minLength)  # Only generate data up to the shortest list length, either names or displayText
            ]
        }

        with open("lib/bing_api/exported_data.json", "w") as f:
            json.dump(exportStructure, f, indent=2)

        print("Data exported successfully to exported_data.json")
        return json.dumps(exportStructure, indent=2)

    except Exception as error:
        print(f"Error exporting data: {error}")
        return json.dumps({"error": "An error occurred during the process."})

# Main execution
def main():
    try:
        # Send POST request
        get_data()

        # get title names and display text from the JSON
        unfilteredNames = get_title_names(filePath)
        unfilteredDisText = get_display_text(filePath)
        repQ = bestRepQ(filePath)

        # print(repQ)  # TESTING

        # filter based on the best representative query
        filteredNames = name_finder(unfilteredNames, repQ)
        filteredDisText = name_finder(unfilteredDisText, repQ)

        # Testing
        print(len(unfilteredNames), len(unfilteredDisText), len(filteredNames), len(filteredDisText))

        # write export JSON and return the data
        exportedJson = export_data(filteredNames, filteredDisText, repQ)
        #print(exportedJson) #TESTING
        return exportedJson

    except Exception as error:
        print(f"Error in main: {error}")
        return json.dumps({"error": "An error occurred during execution."})

if __name__ == "__main__":
    main()
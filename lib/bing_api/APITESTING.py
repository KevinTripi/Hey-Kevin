import requests
import json
import re
#pip install opencv-python
import cv2
import os
from dotenv import load_dotenv

# BING API VARIABLES + IMAGE
BASE_URI = 'https://api.bing.microsoft.com/v7.0/images/visualsearch'
load_dotenv()
SUBSCRIPTION_KEY = os.getenv('SUBSCRIPTION_KEY')
imagePath = "lib/bing_api/img_resized.jpg"
filePath = "lib/bing_api/result.json"

HEADERS = {'Ocp-Apim-Subscription-Key': SUBSCRIPTION_KEY}

# Resize and compress image to <= 1MB
def compress_img(input_path, output_path):
    img = cv2.imread(input_path)

    max_size_mb=1.0
    scale_factor = 0.4  # Adjust as needed to get desired size
    quality = 95  # keeps the return quality of the image high

    #SEE: https://stackoverflow.com/questions/66311867/how-to-scale-down-an-image-to-1mb
    #SEE: https://docs.opencv.org/4.x/d4/da8/group__imgcodecs.html#ga8ac397bd09e48851665edbe12aa28f25
    width = int(img.shape[1] * scale_factor)
    height = int(img.shape[0] * scale_factor)
    resized = cv2.resize(img, (width, height), interpolation=cv2.INTER_LINEAR)

    cv2.imwrite(output_path, resized, [cv2.IMWRITE_JPEG_QUALITY, quality])
    file_size = os.path.getsize(output_path) / (1024 * 1024)

    print(f"Image resized to {width}x{height} and compressed to {file_size:.2f} MB")

    if file_size > max_size_mb:
        print(f"Warning: Image size exceeds {max_size_mb}MB.")
        #in which case reduced quality or scale would help
        #need to add error handling to this

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
#note: added check for empty returns, though this may already be implemented in server 
def export_data(names, displayText, query):
    try:
        # Check if both query and data are empty...whoops
        if not query and not names:
            return json.dumps({"error": "No query and no data available."})

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
        return json.dumps({"error": str(error)})

# Main execution
def main():
    try:
        
        compress_img("lib/bing_api/img.jpg", imagePath)
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

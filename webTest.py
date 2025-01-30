#Copyright (c) Microsoft Corporation. All rights reserved.
#Licensed under the MIT License.

# -*- coding: utf-8 -*-

import json
from pprint import pprint
import requests

# Add your Bing Search V7 subscription key and endpoint to your environment variables.
subscription_key = '31013ec018f4420c82d63ae0d73066fe'
endpoint = 'https://api.bing.microsoft.com' + "/v7.0/search"

# Query term(s) to search for. 
query = "Florence and the Machine"

# Construct a request
mkt = 'en-US'
params = { 'q': query, 'mkt': mkt }
headers = { 'Ocp-Apim-Subscription-Key': subscription_key }

# Call the API
try:
    response = requests.get(endpoint, headers=headers, params=params)
    response.raise_for_status()

    print("\nHeaders:\n")
    print(response.headers)

    print("\nJSON Response:\n")
    pprint(response.json())

    with open("result2.json", "w") as f:
        json.dump(response.json(), f, indent=2)
    
except Exception as ex:
    raise ex
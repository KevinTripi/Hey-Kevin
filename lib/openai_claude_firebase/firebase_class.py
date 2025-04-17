import requests
import time
import json
from firebase_variables import *

class FirebaseRestAPI:
    def __init__(self, db_url):
        self.db_url = db_url.rstrip("/")

    # This function generates uid and id_token for authentication to firebase using anonymous login
    # This uid should be manually added to firebase settings for read, write permissions
    def create_anonymous_user(self):
        url = f"https://identitytoolkit.googleapis.com/v1/accounts:signUp?key={API_KEY}"
        payload = {"returnSecureToken": True}
        response = requests.post(url, json=payload)
        if response.status_code == 200:
            data = response.json()
            print(f"Created anonymous user with UID: {data['localId']}")
            new_data = {
                "idToken": data["idToken"],
                "refreshToken": data["refreshToken"],
                "timestamp": time.time()
            }
            print(data)
            self.save_refreshed_data(new_data)
        else:
            print("Unable to generate anonymous uid and id_token")

    # This function saves the new refreshed data in "auth.json"
    def save_refreshed_data(self, refreshed_data):
        print("saving refreshed data")
        with open("auth.json", "w") as f:
            json.dump(refreshed_data, f)

    # This function refreshes the id_token after expiration
    def refresh_id_token(self, refresh_token):
        print("refreshing id token")
        url = f"https://securetoken.googleapis.com/v1/token?key={API_KEY}"
        payload = {
            "grant_type": "refresh_token",
            "refresh_token": refresh_token
        }
        response = requests.post(url, data=payload)
        if response.status_code == 200:
            data = response.json()
            print(data)
            return {
                "idToken": data["id_token"],
                "refreshToken": data["refresh_token"],
                "timestamp": time.time()
            }
        raise Exception(f"Token refresh failed: {response.json()}")

    # This function extracts data from "auth.json". It also refreshes the id_token if it has expired after an hour
    # This is called everytime we get, post, or delete from firebase
    def get_valid_token(self):
        current_data = self.load_refreshed_data()
        current_time = time.time()
        #If token is still valid (< 1 hour old), reuse existing token
        if current_time - current_data["timestamp"] < 3600:
            print("token is still valid")
            return current_data
        else:
            print("token no longer valid")
            refreshed_data = self.refresh_id_token(current_data["refreshToken"])
            self.save_refreshed_data(refreshed_data)
            return refreshed_data

    # This function reads data from "auth.json"
    def load_refreshed_data(self):
        print("loading refreshed data")
        with open("auth.json", "r") as f:
            data = json.load(f)
            return data

    # GET all data under "objects"
    # This function returns a json with pairs in alphabetical order of keys
    def get(self, include_keys=False):
        id_token = self.get_valid_token()["idToken"]
        response = requests.get(f"{self.db_url}/objects.json?auth={id_token}")
        if response.status_code == 200 and not include_keys and response.json():
            return list(response.json().values())[::-1]
        elif response.status_code == 200 and include_keys:
            return response.json()
        else:
            return None

    # POST new data under "objects" (auto-generates key associated with each entry)
    def post(self, data):
        id_token = self.get_valid_token()["idToken"]
        response = requests.post(f"{self.db_url}/objects.json?auth={id_token}", json=data)
        if response.status_code == 200:
            return data
        return None

    # DELETE entry by key under "objects".
    # NOT TO BE USED OUTSIDE THIS CLASS
    def delete(self, key):
        id_token = self.get_valid_token()["idToken"]
        response = requests.delete(f"{self.db_url}/objects/{key}.json?auth={id_token}")
        return response.status_code == 200

    # DELETE all entries under "objects"
    def delete_all(self):
        id_token = self.get_valid_token()["idToken"]
        response = requests.put(f"{self.db_url}/objects.json?auth={id_token}", json={})
        return response.status_code == 200

    # DELETE the most recent object using Firebase-generated key
    def delete_last_entry(self):
        all_objects = self.get(True)
        if not all_objects:
            return False
        latest_key = max(all_objects.keys())
        return self.delete(latest_key)


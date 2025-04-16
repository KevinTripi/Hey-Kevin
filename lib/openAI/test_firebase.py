from firebase_class import FirebaseRestAPI
from firebase_variables import *
import requests

# This function generates uid and id_token for authentication to firebase using anonymous login
def get_anonymous_id_token():
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signUp?key={API_KEY}"
    payload = {"returnSecureToken": True}
    response = requests.post(url, json=payload)
    if response.status_code == 200:
        data = response.json()
        return {
            "id_token": data["idToken"],
            "uid": data["localId"]
        }
    else:
        print("Unable to generate anonymous uid and id_token")
        return None

# To create an instance of firebase
db = FirebaseRestAPI(HEY_KEVIN_URL, ID_TOKEN)

# This function posts an entry to firebase
# Only to be used after GPT/Claude generates comments
def test_post():
    json = {"object_name": "1" , "b": "5", "c": "6"}
    posted_name = db.post(json)
    if posted_name:
        print(f"Added new entry to database with name {posted_name}")
    else:
        print("Failed to add the entry to database")

# This function shows all entries in firebase
# For GUI: Reorder keys in order: 2nd key, 3rd key, 1st key
def show_history():
    get_json = db.get()
    if get_json:
        for entry in get_json:
            print(entry)
    else:
        print("Crickets everywhere...")


# This function clears all entries of firebase
def clear_history():
    if db.delete_all():
        print(f"Deleted all history")
    else:
        print("Failed to delete all history")


# This function clears last entry in firebase
def clear_last_entry_in_history():
    if db.delete_last_entry():
        print("Deleted latest entry")
    else:
        print("Failed to delete latest entry")

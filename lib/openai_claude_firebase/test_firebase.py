from firebase_class import FirebaseRestAPI
from firebase_variables import *

# To create an instance of firebase
db = FirebaseRestAPI(HEY_KEVIN_URL)
# db.create_anonymous_user()

# This function posts an entry to firebase
# Only to be used after GPT/Claude generates comments
def test_post(db):
    json = {"Object_name": "1" , "b": "5", "c": "6"}
    posted_name = db.post(json)
    if posted_name:
        print(f"Added new entry to database with object {posted_name}")
    else:
        print("Failed to add the entry to database")
# test_post(db)


# This function shows all entries in firebase
# For GUI: Reorder keys in order: 2nd key, 3rd key, 1st key
def show_history(db):
    get_json = db.get()
    if get_json:
        for entry in get_json:
            print(entry)
    else:
        print("Crickets everywhere...")
# show_history(db)


# This function clears all entries of firebase
def clear_history(db):
    if db.delete_all():
        print(f"Deleted all history")
    else:
        print("Failed to delete all history")
# clear_history(db)


# This function clears last entry in firebase
def clear_last_entry_in_history(db):
    if db.delete_last_entry():
        print("Deleted latest entry")
    else:
        print("Failed to delete latest entry")
# clear_last_entry_in_history(db)

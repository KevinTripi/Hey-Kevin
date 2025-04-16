from firebase_class import FirebaseRestAPI
from firebase_url import url

db = FirebaseRestAPI(url)

json = {"b": "2", "c": "3"}

new_json = {"d": "1"}
new_json["e"] = json["b"]
new_json["f"] = json["c"]
posted_name = db.post(new_json)
if posted_name:
    print(f"Added new entry with name {posted_name}")
else:
    print("Failed to add to database")

# get_json = db.get()
# for i in get_json:
#     print(get_json[i])

# if db.delete_all():
#     print(f"Deleted all")
# else:
#     print("Failed to delete all")
#
# get_json = db.get()
# if get_json:
#     for i in get_json:
#         print(get_json[i])
# else:
#     print("Nothing in firebase")
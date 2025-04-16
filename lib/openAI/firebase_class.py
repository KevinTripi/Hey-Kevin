import requests

class FirebaseRestAPI:
    def __init__(self, db_url, id_token):
        self.db_url = db_url.rstrip("/")
        self.id_token = id_token

    # GET all data under "objects"
    # This function returns a json with pairs in alphabetical order of keys
    def get(self, include_keys=False):
        response = requests.get(f"{self.db_url}/objects.json?auth={self.id_token}")
        if response.status_code == 200 and not include_keys and response.json():
            return list(response.json().values())[::-1]
        elif response.status_code == 200 and include_keys:
            return response.json()
        else:
            return None

    # POST new data under "objects" (auto-generates key)
    def post(self, data):
        response = requests.post(f"{self.db_url}/objects.json?auth={self.id_token}", json=data)
        if response.status_code == 200:
            return data["object_name"]
        return None

    # DELETE entry by key under "objects".
    # NOT TO BE USED OUTSIDE THIS CLASS
    def delete(self, key):
        response = requests.delete(f"{self.db_url}/objects/{key}.json?auth={self.id_token}")
        return response.status_code == 200

    # DELETE all entries under "objects"
    def delete_all(self):
        response = requests.put(f"{self.db_url}/objects.json?auth={self.id_token}", json={})
        return response.status_code == 200

    # DELETE the most recent object using Firebase-generated key
    def delete_last_entry(self):
        all_objects = self.get(True)
        if not all_objects:
            return False
        latest_key = max(all_objects.keys())
        return self.delete(latest_key)


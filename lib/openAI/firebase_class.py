import requests

class FirebaseRestAPI:
    def __init__(self, db_url):
        self.db_url = db_url.rstrip("/")

    # GET all data under "objects"
    def get(self):
        response = requests.get(f"{self.db_url}/objects.json")
        if response.status_code == 200:
            return response.json()
        return None

    # POST new data under "objects" (auto-generates key)
    def post(self, data):
        response = requests.post(f"{self.db_url}/objects.json", json=data)
        if response.status_code == 200:
            return data["d"]        # Needs to be updated
        print("empty data")
        return None

    # DELETE entry by key under "objects". Not to be used outside the class
    def delete(self, key):
        response = requests.delete(f"{self.db_url}/objects/{key}.json")
        return response.status_code == 200

    # DELETE all entries under "objects"
    def delete_all(self):
        response = requests.put(f"{self.db_url}/objects.json", json={})
        return response.status_code == 200

    # DELETE the most recent object using Firebase-generated key
    def delete_last_entry(self):
        all_objects = self.get()
        if not all_objects:
            return False
        latest_key = sorted(all_objects.keys())[-1]
        return self.delete(latest_key)
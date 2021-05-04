import json

def load_config(file_path: str = "../config.json"):
    with open(file_path) as config_file:
        data = json.load(config_file)
    return data

if __name__ == "__main__":
    print("Example config usage:")
    print(load_config("../config.json"))


import requests  # pip install requests
from pprint import pprint

TDB_DB_URL = "https://avdwgroup.engin.brown.edu/"


def get_tdb_db_data_for_elements(elements):
    request_url = f"{TDB_DB_URL}getdbid.php?element={','.join(elements)}"
    print("request_url", request_url)
    response = requests.get(request_url)
    data = response.json()
    return data


def main():
    elements = ['H', 'Ni', 'Mn']
    pprint('elements', elements)
    data = get_tdb_db_data_for_elements(elements)
    pprint(data)


__name__ == '__main__' and main()

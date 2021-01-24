import requests
import shutil
import os
import tarfile
import json
from zipfile import ZipFile

WORKSPACE_DIR = '.'
DEFAULT_VERSION = 'master'
BASE_URL = 'https://github.com/'

def read_dependencies():
    json_content = open(WORKSPACE_DIR + '/dependencies.json', 'r').read()
    return json.loads(json_content)

def download_file(url):
    local_filename = url.split('/')[-1]
    with requests.get(url, stream=True) as r:
        with open(local_filename, 'wb') as f:
            shutil.copyfileobj(r.raw, f)

    return local_filename

def extract_file(filename, destination):
    if not os.path.exists(destination):
    	os.makedirs(destination)

    with ZipFile(filename, 'r') as file:
    	file.extractall(destination)
	file.close()

data = read_dependencies()
for dependency in data["dependencies"]:
    account = dependency['account']
    name = dependency['name']
    
    version = DEFAULT_VERSION
    if 'version' in dependency:
        version = dependency['version']

    destination = dependency['destination']
    
    url = BASE_URL + account + '/' + name + '/archive/' + version + '.zip'
    file = download_file(url)   
    print("Dependency downloaded: " + file + " version " + version)

    directory = WORKSPACE_DIR + '/downloads/'
    extract_file(file, directory)
    print("Directory " + directory + " created")

    os.remove(file)

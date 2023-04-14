import zipfile
import json
import argparse

def manifest_key(d, key):
    if key in d:
        return d[key]
    for k in d:
        if isinstance(d[k], dict):
            item = manifest_key(d[k], key)
            if item is not None:
                return item

# Create parser
parser = argparse.ArgumentParser(description='Extract ID value from a JSON file within a compressed file')
# Add path to the compressed file
parser.add_argument('--path', help='Path to compressed file')
#Set args
args = parser.parse_args()

# Set the arguments
file_name = 'manifest.json'
zip_path = args.path

# Open the zip file in read mode
with zipfile.ZipFile(zip_path, 'r') as myzip:
    # Open json within the zip archive
    with myzip.open(file_name) as myfile:
        # Load JSON data
        data = json.load(myfile)
        # Print ID key
        print(manifest_key(data, 'id'))
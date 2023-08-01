import argparse
import os
import re
import shutil

# Set Adobe ServiceConfig.xml path for Windows / MacOS
if os.name == 'nt':  # Windows
   file_path = "C:\\Program Files (x86)\\Common Files\\Adobe\\OOBE\\Configs\\ServiceConfig.xml"
   backup_file_path = "C:\\Program Files (x86)\\Common Files\\Adobe\\OOBE\\Configs\\ServiceConfig_backup.xml"
else:  # macOS
   file_path = "/Library/Application Support/Adobe/OOBE/Configs/ServiceConfig.xml"
   backup_file_path = "/Library/Application Support/Adobe/OOBE/Configs/ServiceConfig_backup.xml"

# Backup the config file with the original just in case
def backup_config(file_path, backup_file_path):
   if not os.path.exists(backup_file_path):
      shutil.copyfile(file_path, backup_file_path)
# Push the config file change
def update_config(file_path, feature, value):
   backup_config(file_path, backup_file_path)
   # Open as r+ to allow edit / read
   with open(file_path, 'r+') as file:
      content = file.read()
      # Reg ex pattern to find line
      pattern = f'(<feature>\s*<name>{feature}</name>\s*<enabled>)(true|false)(</enabled>\s*</feature>)'
      replacement = f'\\1{value}\\3'
      updated_content = re.sub(pattern, replacement, content, flags=re.MULTILINE | re.DOTALL)
      file.seek(0)
      file.write(updated_content)
      file.truncate()
# Check the current file if it is set to true or false
def check_file_status(file_path, feature):
   with open(file_path, 'r') as file:
      content = file.read()
      pattern = f'<feature>\s*<name>{feature}</name>\s*<enabled>(true|false)</enabled>\s*</feature>'
      match = re.search(pattern, content, flags=re.MULTILINE | re.DOTALL)
      if match:
         print(f'Feature: {feature}, status: {match.group(1)}')
         print(f'XML file location: {file_path}')
      else:
         print(f'Feature: {feature} not found in the file.')
         print(f'XML file location: {file_path}')

# set up argparse arguments
parser = argparse.ArgumentParser(description='Update XML configuration.')
parser.add_argument('--AUSST-Fallback', type=str, choices=['true', 'false'], help='Set the bypass status for AdobeFallbackForAUSST')
parser.add_argument('--check-status', action='store_true', help='Check AdobeFallbackForAUSST status in ServiceConfig.xml')

args = parser.parse_args()

# if check_file_status argument is passed, print the status; else update configuration
if args.check_status:
   check_file_status(file_path, 'AdobeFallbackForAUSST')
elif args.AUSST_Fallback is not None:
   update_config(file_path, 'AdobeFallbackForAUSST', args.AUSST_Fallback)

# Do we do something? or twiddle our thumbs...
if args.check_status is False and args.AUSST_Fallback is None:
   print('Should we do something? Please see --help')
   print(f'Exiting...')
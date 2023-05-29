import argparse
import datetime
import glob
import re
import subprocess
import sys


def run_command_with_args(command_args, log_file=None):
    if log_file:
         try:
            result = subprocess.run(command_args, check=True, capture_output=True, text=True)
            log_return = f"Command was successful with return code: {result.returncode}\n"
            print(log_return)
         except subprocess.CalledProcessError as e:
            e_log_return = f"Command failed with return code: {e.returncode}"
            print(e_log_return)
            with open(log_file, 'a') as f:
                f.write(f"\n\n")
                f.write(f"------------------------------------------------------------------------------\n")
                f.write(f"-------------------------------------WinGet-----------------------------------\n")
                f.write(f"---------------------------------Snap-in failed-------------------------------\n")
                f.write("\n")
                f.write(f"Date: {datetime.datetime.now()}\n")
                f.write("\n")
                f.write(f"{e.output}")
                f.write("\n")
                f.write(f"{e_log_return}\n")
                f.write(f"------------------------------------------------------------------------------\n")
                f.write(f"\n\n")
            sys.exit(e.returncode)
         else:
            with open(log_file, 'a') as f:
                f.write(f"\n\n")
                f.write(f"------------------------------------------------------------------------------\n")
                f.write(f"-------------------------------------WinGet-----------------------------------\n")
                f.write(f"-------------------------------Snap-in successful-----------------------------\n")
                f.write("\n")
                f.write(f"Date: {datetime.datetime.now()}\n")
                f.write("\n")
                f.write(f"{result.stdout}")
                f.write("\n")
                f.write(f"{log_return}\n")
                f.write(f"------------------------------------------------------------------------------\n")
                f.write(f"\n\n")
    else:
        try:
            subprocess.run(command_args, check=True)
        except subprocess.CalledProcessError as e:
            print(f"Command failed with return code: {e.returncode}")
            sys.exit(e.returncode)

def find_binary(binary_pattern):
    binary_path = next(glob.iglob(binary_pattern, recursive=True), None)
    if binary_path:
        return binary_path
    else:
        print("WinGet not found.\n")
        sys.exit(1) # Exit with a non-zero error code

# Specify glob pattern for winget.exe
binary_pattern = r'C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller*\**\winget.exe'

# Find winget
binary_path = find_binary(binary_pattern)

# Set argparse
parser = argparse.ArgumentParser()
parser.add_argument('-l', '--log', help='Log file for output')
parser.add_argument('command', nargs=argparse.REMAINDER, help='Commands for WinGet')

args = parser.parse_args()

# Pass all arguments to the subprocess of winget
input_args = args.command

# Additional forced arguments
forced_args = ['--accept-source-agreements', '--accept-package-agreements', '--silent', '--disable-interactivity']

# Check if any of the inputted arguments contain "install"
if any(re.fullmatch(r'.*\binstall\b.*', arg.lower()) for arg in input_args):
    # Add the forced arguments if "install" is found
    command_args = [binary_path] + input_args + forced_args
else:
    # Otherwise, use only the inputted arguments
    command_args = [binary_path] + input_args

# run winget command with args
run_command_with_args(command_args, log_file=args.log)
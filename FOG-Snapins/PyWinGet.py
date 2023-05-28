import glob
import subprocess
import sys

# Should allow winget commands to be passed directly to winget with an output.
# Can be converted into an exe with Auto Py to Exe to allow FOG to run WinGet commands

def run_command_with_args(command_args):
    try:
        result = subprocess.run(command_args, check=True)
        print(f"Command was successful with return code: {result.returncode} \n")
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

# Pass all arguments to the subprocess of winget
input_args = sys.argv[1:]

# Additional forced arguments
forced_args = ['--accept-source-agreements', '--accept-package-agreements', '--silent', '--disable-interactivity']

# Check if any of the inputted arguments contain "install"
if any('install' in arg.lower() for arg in input_args):
    # Add the forced arguments if "install" is found
    command_args = [binary_path] + input_args + forced_args
else:
    # Otherwise, use only the inputted arguments
    command_args = [binary_path] + input_args

# run winget command with args
run_command_with_args(command_args)
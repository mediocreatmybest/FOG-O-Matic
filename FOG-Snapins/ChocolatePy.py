import glob
import subprocess
import sys
# Should allow Choco commands to be passed directly to Choco with an output.
# Can be converted into an exe with Auto Py to Exe to allow FOG to run Choco commands

def run_command_with_args(command_args):
    try:
        result = subprocess.run(command_args, check=True)
        print(f"Command was successfull with return code: {result.returncode} \n")
    except subprocess.CalledProcessError as e:
        print(f"Command failed with return code: {e.returncode}")
        sys.exit(e.returncode)

def find_binary(binary_pattern):
    binary_path = next(glob.iglob(binary_pattern, recursive=True), None)
    if binary_path:
        return binary_path
    else:
        print("Choco not found.\n")
        sys.exit(1) # Exit with a non-zero error code

# Specify glob pattern for choco.exe
binary_pattern = r'C:\ProgramData\chocolatey\**\*\choco.exe'

# Find choco
binary_path = find_binary(binary_pattern)

# Pass all arguments to the subprocess of choco
command_args = [binary_path] + sys.argv[1:]

# run choco command with args
run_command_with_args(command_args)
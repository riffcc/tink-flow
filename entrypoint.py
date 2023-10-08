import os
import subprocess
import sys

def run_build_script():
    try:
        result = subprocess.check_output(['python3', 'build.py'])
        return result.decode()
    except subprocess.CalledProcessError as e:
        print(f"Error running build.py: {e}")
        return None

def print_help_menu():
    print("Usage:")
    print("  tink-flow.py [option]")
    print("tink-flow is a 'compiler' for Tinkerbell. It generates valid Tinkerbell Workflows, Templates and Hardware objects from a set of YAML files.")
    print("Run without any options, it generates a values.yaml file and then applies it with helmfile apply.")
    print("Options:")
    print("  template, dryrun  : Runs helmfile template")
    print("  --interactive     : Runs helmfile apply in interactive mode")
    print("  help, --help      : Displays this help menu")

def main():
    folder_path = "/machines/"
    if not os.path.exists(folder_path):
        print(f"Directory '{folder_path}' not found.")
        return

    if not any(fname.endswith(('.yaml', '.yml')) for fname in os.listdir(folder_path)):
        print(f"No valid YAML files found in {folder_path}")
        return

    run_build = run_build_script()
    print(run_build)
    sys.stdout.flush()

    values_file_path = os.path.join(os.getcwd(), 'values.yaml')
    print(f"Generated values.yaml at {values_file_path}")
    sys.stdout.flush()

    payload = ['helmfile']

    if len(sys.argv) == 1:
        payload.append('apply')
    elif sys.argv[1] in ['template', 'dryrun']:
        payload.append('template')
    elif sys.argv[1] == '--interactive':
        payload.extend(['apply', '--interactive'])
    elif sys.argv[1] in ['help', '--help']:
        print_help_menu()
        return
    else:
        print("Invalid argument. Use 'template', 'dryrun', '--interactive', or 'help'.")
        return

    subprocess.run(payload)

if __name__ == "__main__":
    main()

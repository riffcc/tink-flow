import os
import yaml

def read_yaml(file_path):
    try:
        with open(file_path, 'r') as f:
            return yaml.safe_load(f)
    except yaml.YAMLError as e:
        print(f"Error parsing {file_path}: {e}")
        return None
    except IOError as e:
        print(f"Error reading {file_path}: {e}")
        return None

def main():
    folder_path = "/machines/"
    all_machines = []
    seen_ips = {}
    seen_macs = {}

    try:
        files = [f for f in os.listdir(folder_path) if f.endswith('.yaml') and f != 'values.yaml']
    except FileNotFoundError:
        print("Directory '/machines/' not found.")
        return
    except PermissionError:
        print("Permission denied when accessing '/machines/'.")
        return

    for file in files:
        file_path = os.path.join(folder_path, file)
        yaml_data = read_yaml(file_path)

        if yaml_data is None:
            continue

        default_data = yaml_data.get('defaults', {})

        for machine in yaml_data.get('machines', []):
            hostname = machine.get('hostname')
            ip = machine.get('ipAddress')
            mac = machine.get('macAddress')

            if ip in seen_ips:
                print(f"Warning: Duplicate IP address {ip} for machines {seen_ips[ip]} and {hostname}")
            else:
                seen_ips[ip] = hostname

            if mac in seen_macs:
                print(f"Warning: Duplicate MAC address {mac} for machines {seen_macs[mac]} and {hostname}")
            else:
                seen_macs[mac] = hostname

            machine.update(default_data)
            all_machines.append(machine)

    output_data = {'machines': all_machines}

    try:
        with open("values.yaml", "w") as f:
            yaml.dump(output_data, f)
    except IOError as e:
        print(f"Error writing to values.yaml: {e}")

if __name__ == "__main__":
    main()

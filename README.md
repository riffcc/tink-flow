# tink-flow
Tinkerbell at scale. Manage fleets of machines with simple syntax.

This is in ALPHA QUALITY, and is currently not useful without modification, basically for demonstration purposes.

The plan is to evolve it and make it more and more applicable to as many people as possible over time.

(PRs and issues welcome!)

## Requirements
* Podman or Docker
* A running Kubernetes cluster running Tinkerbell
* A "machine folder"
* (Optional) FUTURE FEATURE - Custom tink-flow charts (hint: `-v /path/to/your/charts:/app/charts/`)

## Making a machine folder
* Create one or more files using this format:
```
# Defaults for this set of machines
defaults:
  os:
    name: debian
    os_slug: debian_12
    version: 12
  tags: production

# The machines to create
machines:
  - hostname: netbird01
    macAddress: "76:C4:AE:50:3D:A1"
    ipAddress: "10.1.1.7"
  - hostname: netbird02
    macAddress: "22:89:CA:79:12:F6"
    ipAddress: "10.1.1.8"
  - hostname: netbird03
    macAddress: "6E:7B:EB:5D:88:FD"
    ipAddress: "10.1.1.9"
```
You can set defaults for the group of machines you are deploying, but you can also override those settings per machine:
```
# Defaults for this set of machines
defaults:
  os:
    name: debian
    os_slug: debian_12
    version: 12
  tags: production

# The machines to create
machines:
  - hostname: netbird01
    macAddress: "76:C4:AE:50:3D:A1"
    ipAddress: "10.1.1.7"
    tags: test
  - hostname: netbird02
    macAddress: "22:89:CA:79:12:F6"
    ipAddress: "10.1.1.8"
  - hostname: netbird03
    macAddress: "6E:7B:EB:5D:88:FD"
    ipAddress: "10.1.1.9"
```

Once you've created the definition, save it as a file (like `netbird.yaml`) in a folder, and record the path for later.

## Usage
`docker run -v ~/.kube/config:/kubeconfig -v /path/to/your/machine/folder:/machines/ zorlin/tink-flow`

(eg: `docker run -v ~/.kube/config:/kubeconfig -v ~/projects/rifflab/machines:/machines/ zorlin/tink-flow`)

We recommend using a specific tag when running this container.

Example output:
```
wings:tink-flow/ (main) $ docker run -v $(pwd)/values.yaml:/app/values.yaml -v ~/.kube/config/:/kubeconfig -v /Users/wings/projects/rifflab/machines:/machines/ zorlin/tink-flow
Building machine definitions from lotus-worker.yaml
Building machine definitions from netbird.yaml
Building machine definitions from haproxy.yaml

Generated values.yaml at /app/values.yaml
Building dependency release=tink-flow-release, chart=charts/tink-flow
Comparing release=tink-flow-release, chart=charts/tink-flow
... lots of output displaying whatever changes we just made ...
Upgrading release=tink-flow-release, chart=charts/tink-flow
Release "tink-flow-release" has been upgraded. Happy Helming!
NAME: tink-flow-release
LAST DEPLOYED: Tue Oct 10 02:46:02 2023
NAMESPACE: tink-system
STATUS: deployed
REVISION: 2
TEST SUITE: None

Listing releases matching ^tink-flow-release$
tink-flow-release	tink-system	2       	2023-10-10 02:46:02.141403949 +0000 UTC	deployed	tink-flow-0.1.1	1.0


UPDATED RELEASES:
NAME                CHART                VERSION   DURATION
tink-flow-release   ./charts/tink-flow   0.1.1           5s
```

## Credits
* Docker image and build infrastructure based on the excellent [alpine-docker/k8s](https://github.com/alpine-docker/k8s)

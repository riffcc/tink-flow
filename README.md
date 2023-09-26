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

## Usage
`docker run -v ~/.kube/config:/kubeconfig -v /path/to/your/machine/folder:/machines/ zorlin/tink-flow`

(eg: `docker run -v ~/.kube/config:/kubeconfig -v ~/projects/rifflab/machines:/machines/ zorlin/tink-flow`)

We recommend using a specific tag when running this container.

## Credits
* Docker image and build infrastructure based on the excellent [alpine-docker/k8s](https://github.com/alpine-docker/k8s)
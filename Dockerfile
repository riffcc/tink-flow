FROM alpine

# Don't update versions directly here, use --build-arg to pass in the versions.
# docker build --no-cache --build-arg KUBECTL_VERSION=${tag} --build-arg HELM_VERSION=${helm} --build-arg KUSTOMIZE_VERSION=${kustomize_version} -t ${image}:${tag} .
ARG HELM_VERSION=3.12.3
ARG KUBECTL_VERSION=0.28.2
ARG KUSTOMIZE_VERSION=v5.1.1
ARG HELMFILE_VERSION=v0.161.0

ENV KUBECONFIG=/kubeconfig

# Install helm (latest release)
RUN case `uname -m` in \
    x86_64) ARCH=amd64; ;; \
    armv7l) ARCH=arm; ;; \
    aarch64) ARCH=arm64; ;; \
    ppc64le) ARCH=ppc64le; ;; \
    s390x) ARCH=s390x; ;; \
    *) echo "Unsupported architecture, exiting..."; exit 1; ;; \
    esac && \
    echo "export ARCH=$ARCH" > /envfile && \
    cat /envfile

RUN . /envfile && echo $ARCH && \
    apk add --update --no-cache curl ca-certificates bash git && \
    curl -sL https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz | tar -xvz && \
    mv linux-${ARCH}/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-${ARCH}

# add helm-diff
RUN helm plugin install https://github.com/databus23/helm-diff && rm -rf /tmp/helm-*

# Install kubectl
RUN . /envfile && echo $ARCH && \
    curl -sLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

# Install helmfile (latest release)
RUN . /envfile && echo $ARCH && \
    mkdir -p /tmp/helmfile && \
    echo https://github.com/helmfile/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION#v}_linux_${ARCH}.tar.gz && \
    curl -sLO https://github.com/helmfile/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION#v}_linux_${ARCH}.tar.gz && \
    tar xvzf helmfile_${HELMFILE_VERSION#v}_linux_${ARCH}.tar.gz -C /tmp/helmfile && \
    mv /tmp/helmfile/helmfile /usr/bin/helmfile && \
    chmod +x /usr/bin/helmfile && \
    rm -r /tmp/helmfile helmfile_${HELMFILE_VERSION#v}_linux_${ARCH}.tar.gz

# Install kustomize (latest release)
RUN . /envfile && echo $ARCH && \
    curl -sLO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz && \
    tar xvzf kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz && \
    mv kustomize /usr/bin/kustomize && \
    chmod +x /usr/bin/kustomize && \
    rm kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz

# Install jq
RUN apk add --update --no-cache jq yq

# Install for envsubst
RUN apk add --update --no-cache gettext

# Install Python3
RUN apk add --no-cache python3 py3-pip

# Use pip3 to install necessary libraries
RUN pip3 install --break-system-packages --upgrade pip && \
    pip3 install --break-system-packages --no-cache-dir pyyaml

# Clean up
RUN rm -rf /var/cache/apk/*

# Install the application itself
COPY build.py entrypoint.py helmfile.yaml /app/

# Install the charts
ADD charts/ /app/charts

WORKDIR /app

ENTRYPOINT [ "/usr/bin/python3", "/app/entrypoint.py" ]

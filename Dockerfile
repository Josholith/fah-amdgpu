FROM ubuntu:18.04

ARG AMDGPU_PRO_VERSION=17.40-492261
ARG FAH_CLIENT_VERSION=7.6.9
ARG FAH_CLIENT_MAJOR_V=7.6

ENV DEBIAN_FRONTEND noninteractive

# Install prerequisite packages and nice to have tools
RUN apt-get update && \
    apt-get -y install --no-install-recommends wget ca-certificates apt-utils xz-utils clinfo

# Fetch and extract the AMDGPU userland driver
RUN cd /tmp && \
    wget -qO- --referer=http://support.amd.com https://www2.ati.com/drivers/linux/ubuntu/amdgpu-pro-${AMDGPU_PRO_VERSION}.tar.xz | \
    tar -C /tmp -Jx 

# Install the AMDGPU userland driver
RUN cd /tmp/amdgpu-pro-${AMDGPU_PRO_VERSION} && \
    ./amdgpu-pro-install -y --compute && \
    rm -r /tmp/amdgpu-pro-${AMDGPU_PRO_VERSION}

# Fetch the F@H Client
RUN wget -qO /tmp/fah.deb https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/v${FAH_CLIENT_MAJOR_V}/fahclient_${FAH_CLIENT_VERSION}_amd64.deb

# Install the F@H Client
RUN mkdir -p /usr/share/doc/fahclient && \
    touch /usr/share/doc/fahclient/sample-config.xml && \
    dpkg --install --no-triggers /tmp/fah.deb && rm /tmp/fah.deb

# Setup the unprivileged user to run F@H Client
RUN addgroup --gid 870 fah && \
    adduser --uid 870 --gid 870 --gecos "Folding at Home" --disabled-password fah && \
    usermod -aG video fah

USER fah

# Plant the GPU whitelist file (F@H Client is supposed to automatically
# download this as needed, but I've seen mixed results depending on such.)
COPY GPUs.txt /home/fah/GPUs.txt

WORKDIR /home/fah

CMD FAHClient
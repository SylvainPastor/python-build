FROM debian:buster
LABEL maintainer="Sylvain Pastor <sylvain@rtone.fr>"

# Install dependencies
RUN apt-get update
RUN apt-get install -y  \
	gcc-arm-linux-gnueabihf \
	g++-arm-linux-gnueabihf \
	python3 git \
	lsb-release \
	wget \
	make
	
# Install python3.8 from source
## installing the packages necessary to build Python
RUN apt-get install -y  \
	build-essential \
	zlib1g-dev \
	libncurses5-dev \
	libgdbm-dev \
	libnss3-dev \
	libssl-dev \
	libsqlite3-dev \
	libreadline-dev \
	libffi-dev \
	libbz2-dev
## build
RUN mkdir -pv /python_src
COPY ["build_x86_64-linux-gnu.sh", "/python_src"]
RUN /python_src/build_x86_64-linux-gnu.sh

# Install armhf required libs
RUN dpkg --add-architecture armhf
RUN apt-get update
RUN apt-get install -y \
	libssl-dev:armhf \
	zlib1g-dev:armhf \
	libc6-dev-armhf-cross

# Add user "builder"
ENV USERNAME builder
ARG host_uid=1000
ARG host_gid=1000

RUN groupadd -g ${host_gid} ${USERNAME} \
    && useradd -u ${host_uid} -g ${USERNAME} -d /home/${USERNAME} ${USERNAME} \
    && mkdir /home/${USERNAME} \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}


# Perform the build as user builder (not as root).
USER ${USERNAME}

WORKDIR /home/${USERNAME}

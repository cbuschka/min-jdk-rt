FROM openjdk:17-buster

RUN export DEBIAN_FRONTEND=noninteractive; \
	apt update -y \
	&& apt install -y make binutils \
        && apt-get autoremove -y \
        && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /work
WORKDIR /work

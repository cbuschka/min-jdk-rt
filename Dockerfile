FROM openjdk:11-jdk

RUN export DEBIAN_FRONTEND=noninteractive; \
	apt-get update \
	&& apt-get install make binutils \
        && apt-get autoremove -y \
        && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /work
WORKDIR /work

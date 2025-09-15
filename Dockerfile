# FROM ubuntu:latest

# WORKDIR /home/search_vulns
# RUN apt-get update >/dev/null && \
#     DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata locales sudo git build-essential gcc >/dev/null && \
#     git clone --quiet --depth 1 https://github.com/ra1nb0rn/search_vulns.git . && \
#     ./install.sh && \
#     rm -rf /var/lib/apt/lists/*

# RUN sed -i -e "s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen && \
#     dpkg-reconfigure --frontend=noninteractive locales && \
#     update-locale LANG=en_US.UTF-8
# ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8   

FROM python:3.10-slim

WORKDIR /home/search_vulns

# Install dependencies
RUN apt-get update && apt-get install -y \
    tzdata \
    locales \
    gcc \
    git \
    build-essential && \
    rm -rf /var/lib/apt/lists/*

# Set locale
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Clone repo and patch install.sh to remove 'sudo'
RUN git clone --quiet --depth 1 https://github.com/satyam235/search_vulns.git . && \
    ls -la && \
    chmod +x install.sh && \
    sed -i 's/sudo //g' install.sh && \
    bash ./install.sh

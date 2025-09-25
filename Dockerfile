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

# -----------------------------------------------------------------------------------

# FROM python:3.10-slim

# WORKDIR /home/search_vulns

# # Install dependencies
# RUN apt-get update && apt-get install -y \
#     tzdata \
#     locales \
#     gcc \
#     git \
#     build-essential && \
#     rm -rf /var/lib/apt/lists/*

# # Set locale
# ENV LANG=en_US.UTF-8
# ENV LANGUAGE=en_US:en
# ENV LC_ALL=en_US.UTF-8

# # Clone repo and patch install.sh to remove 'sudo'
# RUN git clone --quiet --depth 1 https://github.com/satyam235/search_vulns.git . && \
#     ls -la && \
#     chmod +x install.sh && \
#     sed -i 's/sudo //g' install.sh && \
#     bash ./install.sh

# --------------------------------------------------------------------------------------



# EXPOSE 5000

# CMD ["python3", "./web_server.py"]



# --- Build stage ---
# FROM python:3.10-slim AS build

# WORKDIR /home/search_vulns

# # Install build-time dependencies
# RUN apt-get update && apt-get install -y \
#     tzdata \
#     locales \
#     gcc \
#     git \
#     bash \ 
#     build-essential && \
#     rm -rf /var/lib/apt/lists/*

# # Set locale
# ENV LANG=en_US.UTF-8
# ENV LANGUAGE=en_US:en
# ENV LC_ALL=en_US.UTF-8

# # Clone repo and patch install.sh to remove 'sudo'
# RUN git clone --quiet --depth 1 https://github.com/satyam235/search_vulns.git . && \
#     chmod +x install.sh && \
#     sed -i 's/sudo //g' install.sh && \
#     bash ./install.sh

# # --- Final distroless runtime stage ---
# FROM gcr.io/distroless/python3-debian12:nonroot

# WORKDIR /home/search_vulns

# # Copy application and installed dependencies from the build stage
# COPY --from=build /home/search_vulns /home/search_vulns

# Expose port (optional if needed)
# EXPOSE 5000

# # Set the entrypoint
# CMD ["python3", "./web_server.py"]




# 1️⃣ Build Stage
FROM python:3.10-slim as builder

WORKDIR /home/search_vulns

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    git \
    libsqlite3-dev \
    libmariadb-dev \
    locales \
    bash \
    wget \
    curl && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Clone the repo
RUN git clone --quiet --depth 1 https://github.com/satyam235/search_vulns.git .

COPY install.sh /home/search_vulns/install.sh
RUN chmod +x install.sh && ./install.sh

# 2️⃣ Final Minimal Stage
FROM python:3.10-slim

WORKDIR /home/search_vulns

# Set locale
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Copy only installed packages & code
COPY --from=builder /home/search_vulns /home/search_vulns
COPY --from=builder /usr/local/lib/python3.10 /usr/local/lib/python3.10
COPY --from=builder /usr/local/bin /usr/local/bin

EXPOSE 5000

CMD ["python3", "./web_server.py"]
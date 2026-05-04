FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Copy your local filebrowser binary directly into the container's bin path
COPY ./files/filebrowser /opt/filebrowser

# Ensure the binary is executable
RUN chmod +x /opt/filebrowser

# Create the standard Coder user (UID 1000) and grant passwordless sudo
RUN useradd -m -s /bin/bash -u 1000 coder && echo "coder ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers

# Set the default user and working directory
USER coder

WORKDIR /home/coder

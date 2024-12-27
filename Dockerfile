# Use the latest Ubuntu base image
FROM ubuntu:latest

# Set environment variables for Maven and Java
ENV MAVEN_HOME="/usr/share/maven"
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"

# Install dependencies: Maven, OpenJDK 8, Python3, and other required tools
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    maven \
    python3 \
    python3-pip \
    bash \
    && apt-get clean

RUN useradd -ms /bin/bash user && \
    echo 'user:password' | chpasswd && \
    usermod -aG sudo user

USER user

WORKDIR /home/user

# Set up working directory
#WORKDIR /usr/src/app

# Copy the script and additional required files to the container
COPY execute.sh execute.sh
COPY test-visibility-checker test-visibility-checker
COPY pom-modify pom-modify
COPY parse_test_xml.py parse_test_xml.py
COPY javaagent-listener javaagent-listener

# Ensure the script has execute permissions
RUN chmod +x execute.sh
RUN chmod +x pom-modify/modify-project.sh

# Default command to run the script
# You can override this at runtime using Docker run arguments
CMD ["bash", "execute.sh"]
FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    maven

# Set environment variables
ENV MAVEN_HOME="/usr/share/maven"
ENV JAVA_HOME="/usr/java/jdk1.8.0_341/"

# Copy the bash script to the container
COPY clone_project.sh ./clone_project.sh
COPY java_projects.csv ./java_projects.csv

# Set the script as the entry point
ENTRYPOINT ["/bin/bash", "-x", "./clone_project.sh"]
# Use the latest Ubuntu base image
FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies: Maven, OpenJDK 8, Python3, and other required tools
RUN apt-get -y update --fix-missing &&  \
    apt-get install -y openjdk-8-jdk  maven python3.9 python3-pip bash &&  \
    apt-get clean

# Set environment variables for Maven and Java
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-arm64"
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV MAVEN_HOME="/usr/share/maven"
ENV PATH="${MAVEN_HOME}/jre/bin:${PATH}"

RUN update-alternatives --config java
RUN echo "JAVA_HOME is set to: $JAVA_HOME" &&  \
    echo "Java version:" && java -version &&  \
    echo "Javac version:" && javac -version &&  \
    echo "Maven version:" && mvn --version

RUN useradd -ms /bin/bash user &&  \
    echo 'user:password' | chpasswd &&  \
    usermod -aG sudo user

USER user

WORKDIR /home/user

COPY --chown=user viscount.sh viscount.sh
COPY --chown=user test-visibility-checker test-visibility-checker
COPY --chown=user pom-modify pom-modify
COPY --chown=user parse_test_xml.py parse_test_xml.py
COPY --chown=user javaagent-listener javaagent-listener
COPY --chown=user requirements.txt requirements.txt

# Ensure the script has execute permissions
RUN chmod +x viscount.sh pom-modify/modify-project.sh

RUN pip3 install -r requirements.txt

# Default command to run the script
# You can override this at runtime using Docker run arguments
ENTRYPOINT ["bash", "viscount.sh"]
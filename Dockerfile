# Build variable store
ARG ls_address=127.0.0.1
ENV ls_address=$ls_address

# Linux image to run application on
FROM ubuntu:16.04
MAINTAINER Nathan Wright <nathan.wright@smartbear.com>

# Update OS and add java package
RUN apt-get update
RUN ((echo "Y")) | apt-get install default-jre
RUN ((echo "Y")) | apt-get install openjfx
EXPOSE 80
EXPOSE 8080
EXPOSE 1099
EXPOSE 10991

# Stand up internal file server OR pull from repository? Pass in test file for starters w/docker repo

# ///// HANDLE READY API /////
# Create unpack directory, move test script into test folder, license acquirement JAR into licensing
RUN mkdir ./readyapi
COPY ./licensing/ready-api-license-manager-1.2.2.jar ./readyapi/licensing/
COPY ./startup_test/basic-project-readyapi-project.xml ./readyapi/startup_test/

# Download 2.3.0 tarball from Smartbear + unpack
ADD http://dl.eviware.com/ready-api/2.3.0/ReadyAPI-2.3.0-linux-bin.tar.gz ./readyapi/
RUN tar -xzf ./readyapi/ReadyAPI-2.3.0-linux-bin.tar.gz --directory ./readyapi/

# Clean up
RUN rm ./readyapi/ReadyAPI-2.3.0-linux-bin.tar.gz

# Acquire license, make testrunner executable
RUN ((echo "1")) | java -jar ./readyapi/licensing/ready-api-license-manager-1.2.2.jar -s ${ls_address}:1099
RUN chmod +x ./readyapi/ReadyAPI-2.3.0/bin/testrunner.sh
# Test run from container
RUN sh ./readyapi/ReadyAPI-2.3.0/bin/testrunner.sh "-EDefault environment" ./readyapi/startup_test/basic-project-readyapi-project.xml
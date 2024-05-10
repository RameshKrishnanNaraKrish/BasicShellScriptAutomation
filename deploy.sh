#!/bin/bash

echo "Update package, Install unzip, Install java, Install Maven, Install Tomcat, Install sonarqube"

echo "Update Package"
sudo apt update
echo "update package is successfull"

echo "Install unzip"
sudo apt install unzip
echo "Unzip installed"

echo "Install OpenJdk 17"
sudo apt install openjdk-17-jre-headless -y
echo "Installed OpenJDK 17"

echo "Install Maven"
sudo apt install maven -y
echo "Maven installed sucessfully"


echo "Download Apache tomcat and extract and rename to tomcat"
sudo wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.89/bin/apache-tomcat-9.0.89.tar.gz
echo "download sucessful"

echo "Extrac Tar file"
tar -xzf apache-tomcat-9.0.89.tar.gz
echo "*************"
mv apache-tomcat-9.0.89 tomcat
echo "rename folder to tomcat"

echo "Download Sonarqube extract and move to sonarqube folder"
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.5.0.89998.zip
unzip sonarqube-10.5.0.89998.zip
mv sonarqube-10.5.0.89998 sonarqube
echo "Sonarqube - download and extract sucessfull"


echo "Clone git repo"
git clone https://github.com/bkrrajmali/helloworld.git
echo "Git clone of helloworld project"

PROJECT_DIR="/home/ubuntu/helloworld/webapp"
# POM.xml directory
POM_PATH="$PROJECT_DIR/pom.xml"
# Define the directory where the built artifact (e.g., WAR file) will be created
ARTIFACT_DIR="$PROJECT_DIR/target"
# Define the name of the built artifact
ARTIFACT_NAME="webapp.war"
# Define the directory where Tomcat's webapps are located
TOMCAT_WEBAPPS_DIR="/home/ubuntu/tomcat/webapps"

# Start an infinite loop to continuously watch for file changes
    # Use inotifywait to monitor changes in the project directory
#    inotifywait -r -e modify,move,create,delete "$PROJECT_DIR" || continue

    # When a change is detected, run Maven package
    echo "Change detected. Building the project..."
    cd "$PROJECT_DIR" || exit
    mvn clean package

    # Check if the Maven build was successful
if [ $? -eq 0 ]; then
        echo "Build successful. Copying artifact to Tomcat..."
        # Copy the built artifact to Tomcat's webapps directory
        cd $TOMCAT_WEBAPPS_DIR
        rm -rf webapp*
        cp "$ARTIFACT_DIR/$ARTIFACT_NAME" "$TOMCAT_WEBAPPS_DIR"
        echo "Artifact copied successfully."
    else
        echo "Build failed. Please check your code."
    fi


# Start Tomcat
echo "Moving to bin directory of tomcat"
TOMCAT_DIR="/home/ubuntu/tomcat/bin"
cd "$TOMCAT_DIR" || exit
echo "Start tomcat server"
sh startup.sh
echo "tomcat server started"


POMSONAR_DIR="/home/ubuntu/"

# update pom.xml 
echo "updating pom.xml for sonarscanner"
cd "$POMSONAR_DIR" || exit
sh pomsonar.sh

SONARQUBE_DIR="/home/ubuntu/"


SONAR_BIN="/home/ubuntu/sonarqube/bin/linux-x86-64"
cd "$SONAR_BIN" || exit
echo " starting sonar qube"
sh sonar.sh start

# Getting token for sonarqube
echo "Enter the Sonarqube token"
read SONARQUBE_ADMIN_TOKEN
echo "The token is: ${SONARQUBE_ADMIN_TOKEN}"

# Scanning project
cd "${PROJECT_DIR}" || exit
mvn clean verify sonar:sonar -Dsonar.projectKey=helloworld \
  -Dsonar.projectName='helloworld' \
  -Dsonar.host.url=http://52.15.80.215:9000 \
  -Dsonar.token="$SONARQUBE_ADMIN_TOKEN"

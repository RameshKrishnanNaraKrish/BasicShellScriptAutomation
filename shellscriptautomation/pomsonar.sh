#!/bin/bash

# Define the XML snippet for the plugin
plugin_xml="<plugin>
                <groupId>org.sonarsource.scanner.maven</groupId>
                <artifactId>sonar-maven-plugin</artifactId>
                <version>3.7.0.1746</version>
            </plugin>"

# Define the path to the pom.xml file
pom_file="/home/ubuntu/helloworld/webapp/pom.xml"

# Check if the pom.xml file exists
if [ ! -f "$pom_file" ]; then
    echo "Error: pom.xml file not found at $pom_file"
    exit 1
fi

# Add the plugin XML snippet to the pom.xml file
sed -i "/<\/plugins>/i ${plugin_xml}" "${pom_file}"

echo "Plugin added successfully to pom.xml"


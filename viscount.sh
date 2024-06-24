#!/bin/bash

# bash execute.sh <project_name> <project_path> <report_path>
# EXAMPLE "bash execute.sh javapoet /path/to/project /path/to/report"

# update MAVEN_HOME path
# export MAVEN_HOME="/usr/local/Cellar/maven/3.9.6/libexec"

# update JAVA_HOME path
# export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home"


SCRIPT_DIR=$(dirname "$(readlink -f "$BASH_SOURCE")")
name=$1
project_path=$2
report_path=$3

if [[ ! $project_path == *"/" ]]; then
  project_path="$project_path/"
fi

if [[ ! $report_path == *"/" ]]; then
  report_path="$report_path/"
fi

set -e

echo "Running TestVisibilityChecker for $name project"
cd $project_path
mvn dependency:build-classpath --quiet -Dmdep.outputFile=APP_SOURCE.cp
mvn dependency:build-classpath --quiet -Dmdep.outputFile=TEST_SOURCE.cp
java -DabsPath=$project_path -DreportPath=$report_path -jar $SCRIPT_DIR/test-visibility-checker/target/test-visibility-checker.jar

exit_status=$?
if [ $exit_status -ne 0 ]; then
  echo "Fail on fetching production code details"
  exit 1
fi

fetch_classes=$(cat ${report_path}${name}.txt) # format in text file: {CUTs}_whynotutopia_{TestClasses}
echo "Project Path:"
cd $project_path

mvn clean --quiet
echo "Updating pom.xml file for $name to add Maven Surefire Plugin"
bash $SCRIPT_DIR/pom-modify/modify-project.sh $project_path
echo "Executing tests with instrumentation...."
mvn test -Drat.skip=true -Dmaven.test.failure.ignore=true --quiet -DargLine="-javaagent:$SCRIPT_DIR/javaagent-listener/target/javaagent-1.0-SNAPSHOT-jar-with-dependencies.jar=$fetch_classes" >> ${report_path}${name}_mvnlog.txt 

if [ $exit_status -ne 0 ]; then
  echo "Fail on execiting tests"
  exit 1
fi

rm ${report_path}${name}_mvnlog.txt 
echo "Done executing tests!"
exit_status=$?

if [ $exit_status -eq 0 ]; then
  echo "Parsing XML Report...."
  python3.10 $SCRIPT_DIR/parse_test_xml.py $name $project_path $report_path
  rm ${report_path}${name}.txt
  echo "Done parsing XML Report!"
fi

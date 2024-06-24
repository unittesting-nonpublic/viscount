#!/bin/bash

export MAVEN_HOME="/usr/local/Cellar/maven/3.8.6/libexec"
export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home"
# ./clone_project.sh https://github.com/italiangrid/https-utils 15face31a5b0fbf44968139560149111d550118b ~/Desktop/projects/ /home/firhard/Desktop/reports_tmp/
# shuf ./java_projects.csv > ./java_projects_shuffle.csv
# 14:28 on June 27

name=$1
echo "Record is : $name"
set -e

# -- HELPER FUNCTIONS
function debug_echo {
[[ "${DEBUG}" = 1 ]] && echo "$@"
}

# -- CONSTANTS
DEBUG=1
RESULT_DIR="/results"

# -- PARSE ARGS
REPOSITORY_DIR="/Users/firhard/Desktop/projects/"
REPORT_PATH="/Users/firhard/Desktop/reports-tmp2/"
REPORT_PATH2="/Users/firhard/Desktop/mvn-test2/"
PROJECT_NAME=$name

# -- DEBUG OUTPUT
echo "-- $0"
debug_echo "    Project name:         $PROJECT_NAME"
debug_echo "    Report path:          $REPORT_PATH2"
debug_echo "    REPOSIORY_DIR:        $REPOSITORY_DIR"

CWD=$(pwd)
# mkdir $CWD/projects

cd "${REPOSITORY_DIR}${PROJECT_NAME}/"

# execute project
# /Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/bin/java \
# -DabsPath="${REPOSITORY_DIR}${PROJECT_NAME}/" \
# -DreportPath="${REPORT_PATH}" \
# -classpath /Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/charsets.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/deploy.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/ext/cldrdata.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/ext/dnsns.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/ext/jaccess.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/ext/jfxrt.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/ext/localedata.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/ext/nashorn.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/ext/sunec.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/ext/sunjce_provider.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/ext/sunpkcs11.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/ext/zipfs.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/javaws.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/jce.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/jfr.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/jfxswt.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/jsse.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/management-agent.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/plugin.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/resources.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/jre/lib/rt.jar:/Users/firhard/Desktop/test-visibility-checker/target/classes:/Users/firhard/.m2/repository/junit/junit/4.13.1/junit-4.13.1.jar:/Users/firhard/.m2/repository/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar:/Users/firhard/.m2/repository/org/junit/platform/junit-platform-engine/1.9.0/junit-platform-engine-1.9.0.jar:/Users/firhard/.m2/repository/org/opentest4j/opentest4j/1.2.0/opentest4j-1.2.0.jar:/Users/firhard/.m2/repository/org/junit/platform/junit-platform-commons/1.9.0/junit-platform-commons-1.9.0.jar:/Users/firhard/.m2/repository/org/apiguardian/apiguardian-api/1.1.2/apiguardian-api-1.1.2.jar:/Users/firhard/.m2/repository/org/junit/platform/junit-platform-launcher/1.9.0/junit-platform-launcher-1.9.0.jar:/Users/firhard/.m2/repository/org/junit/platform/junit-platform-reporting/1.9.0/junit-platform-reporting-1.9.0.jar:/Users/firhard/.m2/repository/org/apache/ant/ant-junit/1.10.12/ant-junit-1.10.12.jar:/Users/firhard/.m2/repository/org/apache/ant/ant/1.10.12/ant-1.10.12.jar:/Users/firhard/.m2/repository/org/apache/ant/ant-launcher/1.10.12/ant-launcher-1.10.12.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_331.jdk/Contents/Home/lib/tools.jar:/Users/firhard/.m2/repository/org/apache/maven/shared/maven-invoker/3.0.0/maven-invoker-3.0.0.jar:/Users/firhard/.m2/repository/org/codehaus/plexus/plexus-utils/3.0.24/plexus-utils-3.0.24.jar:/Users/firhard/.m2/repository/org/codehaus/plexus/plexus-component-annotations/1.7/plexus-component-annotations-1.7.jar:/Users/firhard/.m2/repository/fr/inria/gforge/spoon/spoon-core/9.1.0/spoon-core-9.1.0.jar:/Users/firhard/.m2/repository/eu/stamp-project/test-runner/3.0.0/test-runner-3.0.0-jar-with-dependencies.jar:/Users/firhard/.m2/repository/eu/stamp-project/descartes/1.2.4/descartes-1.2.4.jar:/Users/firhard/.m2/repository/org/pitest/pitest-entry/1.6.7/pitest-entry-1.6.7.jar:/Users/firhard/.m2/repository/org/pitest/pitest/1.6.7/pitest-1.6.7.jar:/Users/firhard/.m2/repository/commons-io/commons-io/2.10.0/commons-io-2.10.0.jar:/Users/firhard/.m2/repository/org/jacoco/org.jacoco.core/0.8.7/org.jacoco.core-0.8.7.jar:/Users/firhard/.m2/repository/org/ow2/asm/asm/9.1/asm-9.1.jar:/Users/firhard/.m2/repository/org/ow2/asm/asm-commons/9.1/asm-commons-9.1.jar:/Users/firhard/.m2/repository/org/ow2/asm/asm-analysis/9.1/asm-analysis-9.1.jar:/Users/firhard/.m2/repository/org/ow2/asm/asm-tree/9.1/asm-tree-9.1.jar:/Users/firhard/.m2/repository/org/jacoco/org.jacoco.agent/0.8.7/org.jacoco.agent-0.8.7-runtime.jar:/Users/firhard/.m2/repository/org/junit/jupiter/junit-jupiter-api/5.3.2/junit-jupiter-api-5.3.2.jar:/Users/firhard/.m2/repository/org/junit/jupiter/junit-jupiter-engine/5.3.2/junit-jupiter-engine-5.3.2.jar:/Users/firhard/.m2/repository/org/junit/jupiter/junit-jupiter-params/5.3.2/junit-jupiter-params-5.3.2.jar:/Users/firhard/.m2/repository/org/slf4j/slf4j-api/1.7.25/slf4j-api-1.7.25.jar:/Users/firhard/.m2/repository/org/slf4j/slf4j-log4j12/1.7.25/slf4j-log4j12-1.7.25.jar:/Users/firhard/.m2/repository/log4j/log4j/1.2.17/log4j-1.2.17.jar:/Users/firhard/.m2/repository/org/pitest/pitest-junit5-plugin/0.8/pitest-junit5-plugin-0.8.jar:/Users/firhard/.m2/repository/com/opencsv/opencsv/5.7.1/opencsv-5.7.1.jar:/Users/firhard/.m2/repository/org/apache/commons/commons-lang3/3.12.0/commons-lang3-3.12.0.jar:/Users/firhard/.m2/repository/org/apache/commons/commons-text/1.10.0/commons-text-1.10.0.jar:/Users/firhard/.m2/repository/commons-beanutils/commons-beanutils/1.9.4/commons-beanutils-1.9.4.jar:/Users/firhard/.m2/repository/commons-logging/commons-logging/1.2/commons-logging-1.2.jar:/Users/firhard/.m2/repository/commons-collections/commons-collections/3.2.2/commons-collections-3.2.2.jar:/Users/firhard/.m2/repository/org/apache/commons/commons-collections4/4.4/commons-collections4-4.4.jar:/Users/firhard/.m2/repository/fr/inria/gforge/spoon/spoon-decompiler/0.1.0/spoon-decompiler-0.1.0.jar:/Users/firhard/.m2/repository/org/jboss/windup/decompiler/fernflower/fernflower/2.5.0.Final/fernflower-2.5.0.Final.jar:/Users/firhard/.m2/repository/org/benf/cfr/0.146/cfr-0.146.jar:/Users/firhard/.m2/repository/org/bitbucket/mstrobel/procyon-compilertools/0.5.36/procyon-compilertools-0.5.36.jar:/Users/firhard/.m2/repository/org/bitbucket/mstrobel/procyon-core/0.5.36/procyon-core-0.5.36.jar \
# org.example.TestVisibilityChecker || {
#    echo "TEST-VISIBILITY-CHECKER FAIL"
#    echo "${PROJECT_NAME},$(date +"%Y-%m-%d %H:%M:%S"),TVC_FAIL" >> "${REPORT_PATH}zzz_fail_project.csv"
#    continue
# }

if [ ! -f $REPORT_PATH2/$PROJECT_NAME-mvn-test.log ]; then
    if [ ! -f $REPORT_PATH2/$PROJECT_NAME-mvn-test.log.zip ]; then
        mvn test -Drat.skip=true -l $REPORT_PATH2/$PROJECT_NAME-mvn-test.log -DargLine="-javaagent:/Users/firhard/Desktop/javaagent-example/target/javaagent-1.0-SNAPSHOT-jar-with-dependencies.jar" -Dmaven.test.failure.ignore
        debug_echo "$REPORT_PATH2/$PROJECT_NAME-mvn-test.log Mvn test executed: ${REPOSITORY_DIR}${PROJECT_NAME}/, $(date +"%Y-%m-%d %H:%M:%S")"

        mvn clean -l mvn-clean.log
        debug_echo "Mvn clean executed: ${REPOSITORY_DIR}${PROJECT_NAME}/, $(date +"%Y-%m-%d %H:%M:%S")"
    fi
fi


# run mvn install / mvn package to get the jar file
# when finish change this to execute project

#!/bin/bash

# export MAVEN_HOME="/usr/share/maven" \
#  export JAVA_HOME="/usr/java/jdk1.8.0_341/"
# ./clone_project.sh https://github.com/italiangrid/https-utils 15face31a5b0fbf44968139560149111d550118b ~/Desktop/projects/ /home/firhard/Desktop/reports_tmp/
# shuf ./java_projects.csv > ./java_projects_shuffle.csv
# 14:28 on June 27 clone to folder name using last '/' of url
while IFS="," read -r name url hash; do
    echo "Record is : $name, $url, $hash"
    set -e

    # -- HELPER FUNCTIONS
    function debug_echo {
    [[ "${DEBUG}" = 1 ]] && echo "$@"
    }

    # -- CONSTANTS
    DEBUG=1
    RESULT_DIR="/results"

    # -- PARSE ARGS
    PROJECT_URL=$url
    PROJECT_HASH=$hash
    REPOSITORY_DIR="/Users/firhard/Desktop/projects/"
    REPORT_PATH="/Users/firhard/Desktop/reports-tmp/"
    PROJECT_NAME=$name

    # -- DEBUG OUTPUT
    echo "-- $0"
    debug_echo "    Project name:         $PROJECT_NAME"
    debug_echo "    Project url:          $PROJECT_URL"
    debug_echo "    Project hash:         $PROJECT_HASH"
    debug_echo "    Report path:          $REPORT_PATH"
    debug_echo "    REPOSIORY_DIR:        $REPOSITORY_DIR"

    CWD=$(pwd)
    # mkdir $CWD/projects
    

    # -- CLONE / COPY REPO
    debug_echo "    Clone Repository into ${REPOSITORY_DIR}${PROJECT_NAME}/"
    if [[ $PROJECT_URL == http* ]]
    then
        if [ -d "${REPOSITORY_DIR}${PROJECT_NAME}/" ] && [ ! -z "$(ls -A "${REPOSITORY_DIR}${PROJECT_NAME}/")" ]; then
            echo "${REPOSITORY_DIR}${PROJECT_NAME}/ CLONED"
            continue
        elif [ -f "${REPOSITORY_DIR}${PROJECT_NAME}.zip" ] && [ ! -z "$(ls -A "${REPOSITORY_DIR}${PROJECT_NAME}.zip")" ]; then
            echo "${REPOSITORY_DIR}${PROJECT_NAME}/ CLONED2"
            continue
        else
            timeout 20s git clone "${PROJECT_URL}" "${REPOSITORY_DIR}${PROJECT_NAME}/" || :
            if [ $? -eq 124 ]; then
                echo "${PROJECT_NAME},$(date +"%Y-%m-%d %H:%M:%S"),TOO LONG/PRIVATE" >> "${REPORT_PATH}zzz_fail_project.csv"
                continue
            fi
        fi
        
        if [[ -n "$PROJECT_HASH" ]]; then
            cd "${REPOSITORY_DIR}/${PROJECT_NAME}" || continue
            git reset --hard "${PROJECT_HASH}" || continue
            cd "${CWD}" || continue
        fi
        REPO_HASH=$(git --git-dir="${REPOSITORY_DIR}${PROJECT_NAME}/.git" rev-parse HEAD)
    else
        cp -r "${PROJECT_URL}" "${REPOSITORY_DIR}${PROJECT_NAME}/" || continue
    fi

    cd "${REPOSITORY_DIR}${PROJECT_NAME}/"

    echo "COMPILING MAVEN,$(date +"%Y-%m-%d %H:%M:%S")"
    timeout 180s mvn compile -l mvn-compile.log -Drat.skip=true || {
        echo "COMPILATION TOO LONG"
        echo "${PROJECT_NAME},$(date +"%Y-%m-%d %H:%M:%S"),COMPILATION TOO LONG" >> "${REPORT_PATH}zzz_fail_project.csv"
        continue 
    }

    if [ $? -eq 124 ]; then
        echo "COMPILATION TOO LONG"
        echo "${PROJECT_NAME},$(date +"%Y-%m-%d %H:%M:%S"),COMPILATION TOO LONG" >> "${REPORT_PATH}zzz_fail_project.csv"
        continue
    fi

    if grep "BUILD FAILURE" $(pwd)/mvn-compile.log; then
        echo "Build failure"
        continue
    fi

    # echo "COPY DEPENDENCIES,$(date +"%Y-%m-%d %H:%M:%S")"
    # mvn dependency:copy-dependencies -l mvn-dependencies.log || { 
    #     echo "FAIL to copy dependencies"
    #     echo "${PROJECT_NAME},$(date +"%Y-%m-%d %H:%M:%S"),DEPENDENCIES" >> "${REPORT_PATH}zzz_fail_project.csv"
    #     continue 
    # }

    # exit on JUnit3 as tests cannot be shuffled
    # if grep "junit-3" $(pwd)/mvn-dependencies.log; then
    #     # echo "JUnit 3 will not be included in this experiment"
    #     timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    #     DATA="${PROJECT_NAME},${timestamp},JUNIT3"
    #     echo "FAIL due to JUNIT3" 
    #     echo "$DATA" >> "${REPORT_PATH}zzz_fail_project.csv"
    #     continue
    # fi

    echo "EXECUTING TESTS,$(date +"%Y-%m-%d %H:%M:%S")"
    timeout 600s mvn test -l mvn-test.log -Drat.skip=true -Dmaven.test.failure.ignore || {
        echo "TEST FAIL"
        echo "${PROJECT_NAME},$(date +"%Y-%m-%d %H:%M:%S"),TEST TOO BIG" >> "${REPORT_PATH}zzz_fail_project.csv"
        continue 
    }

    if [ $? -eq 124 ]; then
        echo "TEST FAIL"
        echo "${PROJECT_NAME},$(date +"%Y-%m-%d %H:%M:%S"),TEST TOO BIG" >> "${REPORT_PATH}zzz_fail_project.csv"
        continue
    fi

    RESULT=$(grep "Tests run:" $(pwd)/mvn-test.log | grep -v "Time elapsed:") || { 
        echo "TEST FAIL"
        echo "${PROJECT_NAME},$(date +"%Y-%m-%d %H:%M:%S"),TESTS_RESULT" >> "${REPORT_PATH}zzz_fail_project.csv"
        continue
    }
    debug_echo $RESULT

    debug_echo ""
    debug_echo ""
    debug_echo ""
    debug_echo "    Execute Project:         ${REPOSITORY_DIR}${PROJECT_NAME}/, $(date +"%Y-%m-%d %H:%M:%S")"

    # execute project
    /usr/java/jdk1.8.0_341/bin/java \
    -DabsPath="${REPOSITORY_DIR}${PROJECT_NAME}/" \
    -DreportPath="${REPORT_PATH}" \
    -classpath /usr/java/jdk1.8.0_341/jre/lib/charsets.jar:/usr/java/jdk1.8.0_341/jre/lib/deploy.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/cldrdata.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/dnsns.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/jaccess.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/jfxrt.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/localedata.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/nashorn.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/sunec.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/sunjce_provider.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/sunpkcs11.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/zipfs.jar:/usr/java/jdk1.8.0_341/jre/lib/javaws.jar:/usr/java/jdk1.8.0_341/jre/lib/jce.jar:/usr/java/jdk1.8.0_341/jre/lib/jfr.jar:/usr/java/jdk1.8.0_341/jre/lib/jfxswt.jar:/usr/java/jdk1.8.0_341/jre/lib/jsse.jar:/usr/java/jdk1.8.0_341/jre/lib/management-agent.jar:/usr/java/jdk1.8.0_341/jre/lib/plugin.jar:/usr/java/jdk1.8.0_341/jre/lib/resources.jar:/usr/java/jdk1.8.0_341/jre/lib/rt.jar:/usr/java/jdk1.8.0_341:/home/firhard/Desktop/test-visibility-checker/target/classes:/home/firhard/.m2/repository/junit/junit/4.13.1/junit-4.13.1.jar:/home/firhard/.m2/repository/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar:/home/firhard/.m2/repository/org/junit/platform/junit-platform-engine/1.9.0/junit-platform-engine-1.9.0.jar:/home/firhard/.m2/repository/org/opentest4j/opentest4j/1.2.0/opentest4j-1.2.0.jar:/home/firhard/.m2/repository/org/junit/platform/junit-platform-commons/1.9.0/junit-platform-commons-1.9.0.jar:/home/firhard/.m2/repository/org/apiguardian/apiguardian-api/1.1.2/apiguardian-api-1.1.2.jar:/home/firhard/.m2/repository/org/junit/platform/junit-platform-launcher/1.9.0/junit-platform-launcher-1.9.0.jar:/home/firhard/.m2/repository/org/junit/platform/junit-platform-reporting/1.9.0/junit-platform-reporting-1.9.0.jar:/home/firhard/.m2/repository/org/apache/ant/ant-junit/1.10.12/ant-junit-1.10.12.jar:/home/firhard/.m2/repository/org/apache/ant/ant/1.10.12/ant-1.10.12.jar:/home/firhard/.m2/repository/org/apache/ant/ant-launcher/1.10.12/ant-launcher-1.10.12.jar:/usr/java/jdk1.8.0_341/lib/tools.jar:/home/firhard/.m2/repository/org/apache/maven/shared/maven-invoker/3.0.0/maven-invoker-3.0.0.jar:/home/firhard/.m2/repository/org/codehaus/plexus/plexus-utils/3.0.24/plexus-utils-3.0.24.jar:/home/firhard/.m2/repository/org/codehaus/plexus/plexus-component-annotations/1.7/plexus-component-annotations-1.7.jar:/home/firhard/.m2/repository/fr/inria/gforge/spoon/spoon-core/7.0.0/spoon-core-7.0.0.jar:/home/firhard/.m2/repository/org/eclipse/jdt/org.eclipse.jdt.core/3.13.102/org.eclipse.jdt.core-3.13.102.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.core.resources/3.19.0/org.eclipse.core.resources-3.19.0.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.core.expressions/3.9.0/org.eclipse.core.expressions-3.9.0.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.osgi/3.18.400/org.eclipse.osgi-3.18.400.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.core.runtime/3.27.0/org.eclipse.core.runtime-3.27.0.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.equinox.common/3.18.0/org.eclipse.equinox.common-3.18.0.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.core.jobs/3.14.0/org.eclipse.core.jobs-3.14.0.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.equinox.registry/3.11.200/org.eclipse.equinox.registry-3.11.200.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.equinox.preferences/3.10.200/org.eclipse.equinox.preferences-3.10.200.jar:/home/firhard/.m2/repository/org/osgi/org.osgi.service.prefs/1.1.2/org.osgi.service.prefs-1.1.2.jar:/home/firhard/.m2/repository/org/osgi/osgi.annotation/8.0.1/osgi.annotation-8.0.1.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.core.contenttype/3.9.0/org.eclipse.core.contenttype-3.9.0.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.equinox.app/1.6.200/org.eclipse.equinox.app-1.6.200.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.core.filesystem/1.10.0/org.eclipse.core.filesystem-1.10.0.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.text/3.13.0/org.eclipse.text-3.13.0.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.core.commands/3.11.0/org.eclipse.core.commands-3.11.0.jar:/home/firhard/.m2/repository/com/martiansoftware/jsap/2.1/jsap-2.1.jar:/home/firhard/.m2/repository/log4j/log4j/1.2.17/log4j-1.2.17.jar:/home/firhard/.m2/repository/commons-io/commons-io/2.5/commons-io-2.5.jar:/home/firhard/.m2/repository/org/apache/maven/maven-model/3.3.9/maven-model-3.3.9.jar:/home/firhard/.m2/repository/org/apache/commons/commons-lang3/3.5/commons-lang3-3.5.jar:/home/firhard/.m2/repository/com/fasterxml/jackson/core/jackson-databind/2.9.2/jackson-databind-2.9.2.jar:/home/firhard/.m2/repository/com/fasterxml/jackson/core/jackson-annotations/2.9.0/jackson-annotations-2.9.0.jar:/home/firhard/.m2/repository/com/fasterxml/jackson/core/jackson-core/2.9.2/jackson-core-2.9.2.jar:/home/firhard/.m2/repository/eu/stamp-project/test-runner/3.0.0/test-runner-3.0.0-jar-with-dependencies.jar:/home/firhard/.m2/repository/eu/stamp-project/descartes/1.2.4/descartes-1.2.4.jar:/home/firhard/.m2/repository/org/pitest/pitest-entry/1.6.7/pitest-entry-1.6.7.jar:/home/firhard/.m2/repository/org/pitest/pitest/1.6.7/pitest-1.6.7.jar:/home/firhard/.m2/repository/org/jacoco/org.jacoco.core/0.8.7/org.jacoco.core-0.8.7.jar:/home/firhard/.m2/repository/org/ow2/asm/asm/9.1/asm-9.1.jar:/home/firhard/.m2/repository/org/ow2/asm/asm-commons/9.1/asm-commons-9.1.jar:/home/firhard/.m2/repository/org/ow2/asm/asm-analysis/9.1/asm-analysis-9.1.jar:/home/firhard/.m2/repository/org/ow2/asm/asm-tree/9.1/asm-tree-9.1.jar:/home/firhard/.m2/repository/org/jacoco/org.jacoco.agent/0.8.7/org.jacoco.agent-0.8.7-runtime.jar:/home/firhard/.m2/repository/org/junit/jupiter/junit-jupiter-api/5.3.2/junit-jupiter-api-5.3.2.jar:/home/firhard/.m2/repository/org/junit/jupiter/junit-jupiter-engine/5.3.2/junit-jupiter-engine-5.3.2.jar:/home/firhard/.m2/repository/org/junit/jupiter/junit-jupiter-params/5.3.2/junit-jupiter-params-5.3.2.jar:/home/firhard/.m2/repository/org/slf4j/slf4j-api/1.7.25/slf4j-api-1.7.25.jar:/home/firhard/.m2/repository/org/slf4j/slf4j-log4j12/1.7.25/slf4j-log4j12-1.7.25.jar:/home/firhard/.m2/repository/org/pitest/pitest-junit5-plugin/0.8/pitest-junit5-plugin-0.8.jar:/home/firhard/.m2/repository/com/opencsv/opencsv/5.7.1/opencsv-5.7.1.jar:/home/firhard/.m2/repository/org/apache/commons/commons-text/1.10.0/commons-text-1.10.0.jar:/home/firhard/.m2/repository/commons-beanutils/commons-beanutils/1.9.4/commons-beanutils-1.9.4.jar:/home/firhard/.m2/repository/commons-logging/commons-logging/1.2/commons-logging-1.2.jar:/home/firhard/.m2/repository/commons-collections/commons-collections/3.2.2/commons-collections-3.2.2.jar:/home/firhard/.m2/repository/org/apache/commons/commons-collections4/4.4/commons-collections4-4.4.jar:/home/firhard/.m2/repository/fr/inria/gforge/spoon/spoon-decompiler/0.1.0/spoon-decompiler-0.1.0.jar:/home/firhard/.m2/repository/org/jboss/windup/decompiler/fernflower/fernflower/2.5.0.Final/fernflower-2.5.0.Final.jar:/home/firhard/.m2/repository/org/benf/cfr/0.146/cfr-0.146.jar:/home/firhard/.m2/repository/org/bitbucket/mstrobel/procyon-compilertools/0.5.36/procyon-compilertools-0.5.36.jar:/home/firhard/.m2/repository/org/bitbucket/mstrobel/procyon-core/0.5.36/procyon-core-0.5.36.jar \
    org.example.TestVisibilityChecker || {
        echo "TEST-VISIBILITY-CHECKER FAIL"
        echo "${PROJECT_NAME},$(date +"%Y-%m-%d %H:%M:%S"),TVC_FAIL" >> "${REPORT_PATH}zzz_fail_project.csv"
        continue
    }

# run mvn install / mvn package to get the jar file
# when finish change this to execute project

# /usr/java/jdk1.8.0_341/bin/java \
# -DabsPath="${REPOSITORY_DIR}${PROJECT_NAME}/" \
# -DreportPath=/home/firhard/Desktop/reports/ \
# -classpath /usr/java/jdk1.8.0_341/jre/lib/charsets.jar:/usr/java/jdk1.8.0_341/jre/lib/deploy.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/cldrdata.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/dnsns.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/jaccess.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/jfxrt.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/localedata.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/nashorn.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/sunec.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/sunjce_provider.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/sunpkcs11.jar:/usr/java/jdk1.8.0_341/jre/lib/ext/zipfs.jar:/usr/java/jdk1.8.0_341/jre/lib/javaws.jar:/usr/java/jdk1.8.0_341/jre/lib/jce.jar:/usr/java/jdk1.8.0_341/jre/lib/jfr.jar:/usr/java/jdk1.8.0_341/jre/lib/jfxswt.jar:/usr/java/jdk1.8.0_341/jre/lib/jsse.jar:/usr/java/jdk1.8.0_341/jre/lib/management-agent.jar:/usr/java/jdk1.8.0_341/jre/lib/plugin.jar:/usr/java/jdk1.8.0_341/jre/lib/resources.jar:/usr/java/jdk1.8.0_341/jre/lib/rt.jar:/usr/java/jdk1.8.0_341:/home/firhard/Desktop/test-visibility-checker/target/test-visibility-checker.jar:/home/firhard/.m2/repository/junit/junit/4.13.1/junit-4.13.1.jar:/home/firhard/.m2/repository/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar:/home/firhard/.m2/repository/org/junit/platform/junit-platform-engine/1.9.0/junit-platform-engine-1.9.0.jar:/home/firhard/.m2/repository/org/opentest4j/opentest4j/1.2.0/opentest4j-1.2.0.jar:/home/firhard/.m2/repository/org/junit/platform/junit-platform-commons/1.9.0/junit-platform-commons-1.9.0.jar:/home/firhard/.m2/repository/org/apiguardian/apiguardian-api/1.1.2/apiguardian-api-1.1.2.jar:/home/firhard/.m2/repository/org/junit/platform/junit-platform-launcher/1.9.0/junit-platform-launcher-1.9.0.jar:/home/firhard/.m2/repository/org/junit/platform/junit-platform-reporting/1.9.0/junit-platform-reporting-1.9.0.jar:/home/firhard/.m2/repository/org/apache/ant/ant-junit/1.10.12/ant-junit-1.10.12.jar:/home/firhard/.m2/repository/org/apache/ant/ant/1.10.12/ant-1.10.12.jar:/home/firhard/.m2/repository/org/apache/ant/ant-launcher/1.10.12/ant-launcher-1.10.12.jar:/usr/java/jdk1.8.0_341/lib/tools.jar:/home/firhard/.m2/repository/org/apache/maven/shared/maven-invoker/3.0.0/maven-invoker-3.0.0.jar:/home/firhard/.m2/repository/org/codehaus/plexus/plexus-utils/3.0.24/plexus-utils-3.0.24.jar:/home/firhard/.m2/repository/org/codehaus/plexus/plexus-component-annotations/1.7/plexus-component-annotations-1.7.jar:/home/firhard/.m2/repository/fr/inria/gforge/spoon/spoon-core/7.0.0/spoon-core-7.0.0.jar:/home/firhard/.m2/repository/org/eclipse/jdt/org.eclipse.jdt.core/3.13.102/org.eclipse.jdt.core-3.13.102.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.core.resources/3.19.0/org.eclipse.core.resources-3.19.0.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.core.expressions/3.9.0/org.eclipse.core.expressions-3.9.0.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.osgi/3.18.400/org.eclipse.osgi-3.18.400.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.core.runtime/3.27.0/org.eclipse.core.runtime-3.27.0.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.equinox.common/3.18.0/org.eclipse.equinox.common-3.18.0.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.core.jobs/3.14.0/org.eclipse.core.jobs-3.14.0.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.equinox.registry/3.11.200/org.eclipse.equinox.registry-3.11.200.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.equinox.preferences/3.10.200/org.eclipse.equinox.preferences-3.10.200.jar:/home/firhard/.m2/repository/org/osgi/org.osgi.service.prefs/1.1.2/org.osgi.service.prefs-1.1.2.jar:/home/firhard/.m2/repository/org/osgi/osgi.annotation/8.0.1/osgi.annotation-8.0.1.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.core.contenttype/3.9.0/org.eclipse.core.contenttype-3.9.0.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.equinox.app/1.6.200/org.eclipse.equinox.app-1.6.200.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.core.filesystem/1.10.0/org.eclipse.core.filesystem-1.10.0.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.text/3.13.0/org.eclipse.text-3.13.0.jar:/home/firhard/.m2/repository/org/eclipse/platform/org.eclipse.core.commands/3.11.0/org.eclipse.core.commands-3.11.0.jar:/home/firhard/.m2/repository/com/martiansoftware/jsap/2.1/jsap-2.1.jar:/home/firhard/.m2/repository/log4j/log4j/1.2.17/log4j-1.2.17.jar:/home/firhard/.m2/repository/commons-io/commons-io/2.5/commons-io-2.5.jar:/home/firhard/.m2/repository/org/apache/maven/maven-model/3.3.9/maven-model-3.3.9.jar:/home/firhard/.m2/repository/org/apache/commons/commons-lang3/3.5/commons-lang3-3.5.jar:/home/firhard/.m2/repository/com/fasterxml/jackson/core/jackson-databind/2.9.2/jackson-databind-2.9.2.jar:/home/firhard/.m2/repository/com/fasterxml/jackson/core/jackson-annotations/2.9.0/jackson-annotations-2.9.0.jar:/home/firhard/.m2/repository/com/fasterxml/jackson/core/jackson-core/2.9.2/jackson-core-2.9.2.jar:/home/firhard/.m2/repository/eu/stamp-project/test-runner/3.0.0/test-runner-3.0.0-jar-with-dependencies.jar:/home/firhard/.m2/repository/eu/stamp-project/descartes/1.2.4/descartes-1.2.4.jar:/home/firhard/.m2/repository/org/pitest/pitest-entry/1.6.7/pitest-entry-1.6.7.jar:/home/firhard/.m2/repository/org/pitest/pitest/1.6.7/pitest-1.6.7.jar:/home/firhard/.m2/repository/org/jacoco/org.jacoco.core/0.8.7/org.jacoco.core-0.8.7.jar:/home/firhard/.m2/repository/org/ow2/asm/asm/9.1/asm-9.1.jar:/home/firhard/.m2/repository/org/ow2/asm/asm-commons/9.1/asm-commons-9.1.jar:/home/firhard/.m2/repository/org/ow2/asm/asm-analysis/9.1/asm-analysis-9.1.jar:/home/firhard/.m2/repository/org/ow2/asm/asm-tree/9.1/asm-tree-9.1.jar:/home/firhard/.m2/repository/org/jacoco/org.jacoco.agent/0.8.7/org.jacoco.agent-0.8.7-runtime.jar:/home/firhard/.m2/repository/org/junit/jupiter/junit-jupiter-api/5.3.2/junit-jupiter-api-5.3.2.jar:/home/firhard/.m2/repository/org/junit/jupiter/junit-jupiter-engine/5.3.2/junit-jupiter-engine-5.3.2.jar:/home/firhard/.m2/repository/org/junit/jupiter/junit-jupiter-params/5.3.2/junit-jupiter-params-5.3.2.jar:/home/firhard/.m2/repository/org/slf4j/slf4j-api/1.7.25/slf4j-api-1.7.25.jar:/home/firhard/.m2/repository/org/slf4j/slf4j-log4j12/1.7.25/slf4j-log4j12-1.7.25.jar:/home/firhard/.m2/repository/org/pitest/pitest-junit5-plugin/0.8/pitest-junit5-plugin-0.8.jar:/home/firhard/.m2/repository/com/opencsv/opencsv/5.7.1/opencsv-5.7.1.jar:/home/firhard/.m2/repository/org/apache/commons/commons-text/1.10.0/commons-text-1.10.0.jar:/home/firhard/.m2/repository/commons-beanutils/commons-beanutils/1.9.4/commons-beanutils-1.9.4.jar:/home/firhard/.m2/repository/commons-logging/commons-logging/1.2/commons-logging-1.2.jar:/home/firhard/.m2/repository/commons-collections/commons-collections/3.2.2/commons-collections-3.2.2.jar:/home/firhard/.m2/repository/org/apache/commons/commons-collections4/4.4/commons-collections4-4.4.jar \
# org.example.TestVisibilityChecker
done < $1
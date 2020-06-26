!/usr/bin/env bash

set -e
echo "*****************************************************************************************"
echo "******************************* Install Java version 8 *************************************"
echo "*****************************************************************************************"
set -e
apt-get update
apt-get install openjdk-8-jre -y
echo "*****************************************************************************************"
echo "******************************* Add Jenkins to soure list *******************************"
echo "*****************************************************************************************"

wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

echo "*****************************************************************************************"
echo "******************************* Install Update and Jenkins ******************************"
echo "*****************************************************************************************"
apt-get update
apt-get install jenkins -y


echo "*****************************************************************************************"
echo "********************************* Config Jenkins ****************************************"
echo "*****************************************************************************************"
mkdir /var/lib/jenkins/init.groovy.d
mkdir /var/lib/jenkins/jobs/test1

cat <<-GROOVY > /var/lib/jenkins/init.groovy.d/00-off-setupwizard.groovy
#!groovy

import jenkins.model.*
import hudson.util.*;
import jenkins.install.*;

def instance = Jenkins.getInstance()

instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
GROOVY

cat <<-GROOVY > /var/lib/jenkins/init.groovy.d/01-admin-pwd.groovy
#!groovy
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)

hudsonRealm.createAccount("god","root")
instance.setSecurityRealm(hudsonRealm)
instance.save()
GROOVY


cat <<-JOB > /var/lib/jenkins/jobs/test1/config.xml
<?xml version='1.1' encoding='UTF-8'?>
<project>
  <actions/>
  <description>test1 </description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <jenkins.model.BuildDiscarderProperty>
      <strategy class="hudson.tasks.LogRotator">
        <daysToKeep>2</daysToKeep>
        <numToKeep>2</numToKeep>
        <artifactDaysToKeep>-1</artifactDaysToKeep>
        <artifactNumToKeep>-1</artifactNumToKeep>
      </strategy>
    </jenkins.model.BuildDiscarderProperty>
  </properties>
  <scm class="hudson.scm.NullSCM"/>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>echo &quot;------------------------Start build---------------------&quot;
cat &lt;&lt;TTT &gt; /var/www/html/index.html
&lt;html&gt;
&lt;body&gt; Hello 4 you 2 &lt;/body&gt;
&lt;/html&gt;
TTT

echo &quot;-------------------------Finish-------------------------&quot;</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>
JOB



service jenkins restart && sleep 120s && wget http://127.0.0.1:8080/jnlpJars/jenkins-cli.jar
java -jar jenkins-cli.jar -auth god:root -s http://127.0.0.1:8080/ install-plugin publish-over-ssh publish-over ace-editor ant antisamy-markup-formatter apache-httpcomponents-client-4-api bouncycastle-api branch-api build-timeout cloudbees-folder command-launcher credentials-binding credentials display-url-api durable-task email-ext git-client git-server git github-api github-branch-source github gradle handlebars jackson2-api jdk-tool jquery-detached jsch junit ldap lockable-resources mailer mapdb-api matrix-auth matrix-project momentjs pam-auth pipeline-build-step pipeline-github-lib pipeline-graph-analysis pipeline-input-step pipeline-milestone-step pipeline-model-api pipeline-model-definition pipeline-model-extensions pipeline-rest-api pipeline-stage-step pipeline-stage-tags-metadata pipeline-stage-view plain-credentials resource-disposer scm-api script-security ssh-credentials ssh-slaves structs subversion timestamper token-macro trilead-api workflow-aggregator workflow-api workflow-basic-steps workflow-cps-global-lib workflow-cps workflow-durable-task-step workflow-job workflow-multibranch workflow-scm-step workflow-step-api workflow-support ws-cleanup

chown -R jenkins:jenkins /var/lib/jenkins/

rm -rf /var/www && ln -fs /vagrant /var/www && mkdir /var/www/html
service jenkins restart

echo "*****************************************************************************************"
echo "********************************* Jenkins is ready  ****************************************"
echo "********************************* Login - god ****************************************"
echo "********************************* Password root ****************************************"
echo "**********************************http://192.168.99.10:8080/*****************************************"
echo "*****************************************************************************************"







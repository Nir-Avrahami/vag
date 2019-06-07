#!/bin/bash

##PARAMS
JENKINS_REPO_URI="jenkins-2.164.1-1.1"
## END PARAMS

function installPreReq(){
    echo "±±±±±±±±±±±±±>installPreReq"
    yum update -y
    yum install -y yum-utils git jq aws-cli docker bind-utils nano java wget unzip bash-completion
}

function installKubectl(){
  curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  mv ./kubectl /usr/bin/kubectl
  echo "source <(kubectl completion bash)" >> ~/.bashrc
}

function installDocker(){
  yum install -y docker
  systemctl enable docker
  systemctl start docker
}

function installJenkins(){
  echo "±±±±±±±±±±±±±>install jenkins"
  yum install -y https://prodjenkinsreleases.blob.core.windows.net/redhat-stable/${JENKINS_REPO_URI}.noarch.rpm java
  systemctl enable jenkins
  systemctl start jenkins
}

function installTerraform(){
  wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
  unzip terraform_*
  mv terraform /usr/bin/
  rm -rf terraform_*

}
function installAnsible(){
  yum install -y  ansible
}

function installMaven(){
  sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
  sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
  sudo yum install -y apache-maven
  mvn --version
}

function praperMVN() {
    git clone https://github.com/zivkashtan/course.git
    cd course/
    sed -i "s/<java.version>.*<\/java.version>/<java.version>1.7<\/java.version>/" pom.xml
    mvn package
    cd ../
    rm -rf course/
}

function installNexusArtifactory(){
  NEXUS_REPO_URI="https://sonatype-download.global.ssl.fastly.net/nexus/3/nexus-3.15.2-01-unix.tar.gz"
  wget $NEXUS_REPO_URI
  tar -xvf nexus-*.tar.gz
  mkdir /app && cd /app
  rm -f nexus-*.tar.gz
  mv nexus-* nexus
  adduser nexus
  chown -R nexus:nexus /app/nexus
  echo "run_as_user=\"nexus\"" >> /app/nexus/bin/nexus.rc

  sudo ln -s /app/nexus/bin/nexus /etc/init.d/nexus
  chkconfig --add nexus
  chkconfig --levels 345 nexus on
  systemctl enable nexus
  systemctl start nexus
}

function install_tomcat(){
  yum install -y tomcat-*
  systemctl enable tomcat
  systemctl start tomcat
}


function configDocker(){
    cat << EOF > /etc/docker/daemon.json
{
 "insecure-registries": [
    "localhost:8082",
    "172.16.11.100:8083"
  ],
"disable-legacy-registry": true,
"hosts": ["tcp://0.0.0.0:2375", "unix:///var/run/docker.sock"],
  "metrics-addr" : "0.0.0.0:9323",
  "experimental" : true
}
EOF

  groupadd docker
  usermod -G docker vagrant
  service docker restart

}
function main(){

  installPreReq
  install_tomcat
  installDocker

}
main

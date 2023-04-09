#!/bin/bash

DIRECTORY="jobs"
LIST_JOBS="./jobs/out.txt"
JENKINS_CLI=jenkins-cli.jar
SHORT=o:,n:,u:,p:,U:,P:,h
LONG=old-jenkins:,new-jenkins:,old-jenkins-user:,old-jenkins-password:,new-jenkins-user:,new-jenkins-password:,help
OPTS=$(getopt -a -n jenkins --options $SHORT --longoptions $LONG -- "$@")

if [ $? -ne 0 ]; 
  then echo -e "ERROR: You are using one of the invalid parameters! \n"; 
  exit 1; 
fi

help()
{
  echo -e "These are the possible options to use: \n"
  echo -e "        [ -o | --old-jenkins ]          Specify the address of the Old Jenkins from which you want to export jobs.
        [ -n | --new-jenkins ]          Specify the address of the Old Jenkins where you want to import the jobs.
        [ -u | --old-jenkins-user ]     Specify a user in Old Jenkins to access jobs.
        [ -p | --old-jenkins-password ] Specify a password for user in Old Jenkins to access jobs.
        [ -U | --new-jenkins-user ]     Specify a user in New Jenkins to upload jobs.
        [ -P | --new-jenkins-password ] Specify a password for user in New Jenkins to upload jobs.
        [ -h | --help ]                 General information about all options. \n"
  echo -e "Usage: ./migrate-jobs.sh [OPTIONS] [ARGS]"
  exit 2
}

prepare()
{
  rm -rf ${DIRECTORY}
  mkdir -p ${DIRECTORY}
}

eval set -- "$OPTS"

while :
do
  case "$1" in
    -o | --old-jenkins )
      OLD_JENKINS="$2"
      shift 2
      ;;
    -n | --new-jenkins )
      NEW_JENKINS="$2"
      shift 2
      ;;
    -u | --old-jenkins-user )
      OLD_JENKINS_LOGIN="$2"
      shift 2
      ;;
    -p | --old-jenkins-password )
      OLD_JENKINS_PASSWORD="$2"
      shift 2
      ;;
    -U | --new-jenkins-user )
      NEW_JENKINS_LOGIN="$2"
      shift 2
      ;;
    -P | --new-jenkins-password )
      NEW_JENKINS_PASSWORD="$2"
      shift 2
      ;;
    -h | --help)
      help
      ;;
    --)
      shift;
      break
      ;;
  esac
done

prepare

if [ ! -e "$JENKINS_CLI" ]; then
    echo -e "Downloads jenkins cli to successfully apply the script: \n"
    wget "$OLD_JENKINS"/jnlpJars/jenkins-cli.jar
else
    echo -e "Jenkins cli already exists on your path: \n"
fi

java -jar jenkins-cli.jar -s "$OLD_JENKINS" -auth "$OLD_JENKINS_LOGIN":"$OLD_JENKINS_PASSWORD" list-jobs > "$LIST_JOBS"

while IFS= read -r line <&3; do
  java -jar jenkins-cli.jar -s "$OLD_JENKINS" -auth "$OLD_JENKINS_LOGIN":"$OLD_JENKINS_PASSWORD" get-job "$line" > ./"$DIRECTORY"/"$line";
done 3<"$LIST_JOBS"

while IFS= read -r line <&3; do
  java -jar jenkins-cli.jar -s "$NEW_JENKINS" -auth "$NEW_JENKINS_LOGIN":"$NEW_JENKINS_PASSWORD" create-job "$line" < ./"$DIRECTORY"/"$line";
done 3<"$LIST_JOBS"

rm -rf "$DIRECTORY"

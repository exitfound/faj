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
    wget "$OLD_JENKINS"/jnlpJars/"$JENKINS_CLI"
else
    echo -e "Jenkins cli already exists on your path: \n"
fi

java -jar "$JENKINS_CLI" -s http://192.168.88.210:8080 -auth admin:Lekain1997 groovy = < list-jobs.groovy > "$LIST_JOBS"

sed -i 's/\//\\/g' "$LIST_JOBS"

# https://stackoverflow.com/questions/21843343/while-read-line-stops-after-first-iteration
# Решение для while, потому что без дескриптора не работало. Падало на первой строке.

while IFS= read -r line <&3; do
  new_export_line=$( echo $line | sed 's/\\/\//g' )
  java -jar "$JENKINS_CLI" -s "$OLD_JENKINS" -auth "$OLD_JENKINS_LOGIN":"$OLD_JENKINS_PASSWORD" get-job "$new_export_line" > ./"$DIRECTORY"/"$line";
done 3<"$LIST_JOBS"

while IFS= read -r line <&3; do
  new_import_line=$( echo $line | sed 's/\\/\//g' )
  java -jar "$JENKINS_CLI" -s "$NEW_JENKINS" -auth "$NEW_JENKINS_LOGIN":"$NEW_JENKINS_PASSWORD" create-job "$new_import_line" < ./"$DIRECTORY"/"$line"; 
done 3< "$LIST_JOBS"

rm -rf "$DIRECTORY"

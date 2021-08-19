#!/bin/bash

declare -A dictionary


#Function 

function printMessage() 
{
	# printf '%s %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%S")" "$1";
    printf '%s\n' "$1";
}

function parseDagDefToDic()
{
	printMessage "Present Working Directory $1, Input dag definition file $2"
	gitClonedDir=$1
	inputDefinitionFile=$2
	
	completeFileNameWithDir="$gitClonedDir/$inputDefinitionFile"
    printMessage "Complete Path for dag definition file $completeFileNameWithDir"
	
	while IFS="" read -r line || [ -n "$line" ]
    do
        if [[ $line != "#"* ]]; 
        then
            printMessage $line
            key=$(echo $line | cut -d "=" -f1)
            data=$(echo $line | cut -d "=" -f2)
            dictionary[$key]="$data"
        fi
    done <"$completeFileNameWithDir"	
}

function getValueFromDic() 
{
    echo "${dictionary[$1]}"
}

function copyConfigs() 
{
    airflow_home=$1
    clonedRepoDir=$2
    configsList=$3
    cd $clonedRepoDir

    tempIFS=$IFS
    export IFS=","
    for confFile in $configsList; 
    do
        mkdir -p $airflow_home/conf
        mkdir -p $airflow_home/scripts
        mkdir -p $airflow_home/requirements
        printMessage "Copy Dag configurations from $clonedRepoDir/$confFile to Airflow home $airflow_home/[conf/scripts]"
        if [ ! -f "$airflow_home/$confFile" ]; 
        then
            cp --parents $confFile $airflow_home
        else
            printMessage "Already the file $confFile exists in $airflow_home/[conf/scripts] skipping copying "
        fi
        
    done

    export IFS=$tempIFS
}

function copyDagDefinition()
{
    airflow_home=$1
    clonedRepoDir=$2
    dagFileLoc=$3

    cd $clonedRepoDir
    
    printMessage "Copy Dag Definitions from $clonedRepoDir/$dagFileLoc to Airflow home $airflow_home/dags"

    if [ ! -f "$airflow_home/$dagFileLoc" ]; 
    then
        cp --parents $dagFileLoc $airflow_home
    else
        printMessage "Already the file $dagFileLoc exists in $airflow_home/dags skipping copying "
    fi
}


#Input Parameters
github_url=$1

printMessage "Cloning URL $github_url "
inputTemplate=$2

printMessage "Input dag definition file $inputTemplate"

#Setting Airflow Home

if [ -z "${AIRFLOW_HOME}" ]; then 
    airflow_home='/root/airflow'
else 
    airflow_home=${AIRFLOW_HOME}
fi

printMessage "Airflow Home $airflow_home"

#Preparing Environment
currentDir=/tmp/AIRFLOW_DONOT_DELETE/$(date +%N)

printMessage "Current cloning directory $currentDir"

printMessage  "Creating directory $currentDir"

mkdir -p $currentDir

cd $currentDir

git clone "$github_url"

repo_name=$(basename $github_url)

repo_dir=$(echo $repo_name| cut -d'.' -f 1)
printMessage "Repository name $repo_dir"

cd $repo_dir

parseDagDefToDic $PWD $inputTemplate

echo "${dictionary[@]}"

if [ ! -z ${dictionary[dagfileName]} ]; 
then
    echo "dagfileName exists in dictionary"
    dagDefinitionFile=$(getValueFromDic "dagfileName")
    printMessage "Dag Definition file $dagDefinitionFile"
    copyDagDefinition $airflow_home $PWD $dagDefinitionFile
else
    printMessage "dagfileName is mandatory to create a DAG"
    exit 5
fi

if [ ! -z ${dictionary[requirements_file]} ]; 
then
    echo "requirements_file exists in dictionary"
    requirements_file=$(getValueFromDic "requirements_file")
    printMessage "Requirement file $requirements_file"
    copyConfigs $airflow_home $PWD $requirements_file
else
    printMessage "There are no requirements_file"
fi

if [ ! -z ${dictionary[dependencies]} ]; 
then
    echo "requirements_file exists in dictionary"
    dependencies=$(getValueFromDic "dependencies")
    printMessage "Dag Dependencies file $dependencies"
    copyConfigs $airflow_home $PWD $dependencies
else
    printMessage "There are no dependencies"
fi

if [ -f "$airflow_home/$requirements_file" ]; 
then
    printMessage "Installing necessary modules from requirements file $requirements_file at $airflow_home"
    /bin/python3 -m pip install -r $airflow_home/$requirements_file
fi

printMessage "Cleaning Up directory $currentDir"

rm -r $currentDir
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
        printMessage "Copy Dag configurations from $clonedRepoDir/$confFile to Airflow home $airflow_home/conf"
        if [ ! -f "$airflow_home/$confFile" ]; 
        then
            printMessage "Copying new file $confFile to $airflow_home/[conf/scripts] "
            cp --parents $confFile $airflow_home
        else
            printMessage "Already the file $confFile exists in $airflow_home/[conf/scripts] updating the definition "
            cp --parents -R $confFile $airflow_home
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

    if [ -f "$airflow_home/$dagFileLoc" ]; 
    then
        printMessage "Already the file $dagFileLoc exists in $airflow_home/dags updating the existing DAG "
        cp --parents $dagFileLoc $airflow_home
    else
        printMessage "No DAG file def exist for $dagFileLoc in $airflow_home/dags. Please create DAG first, skipping copying "
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

dagDefinitionFile=$(getValueFromDic "dagfileName")
printMessage "Dag Definition file $dagDefinitionFile"

dependencies=$(getValueFromDic "dependencies")
printMessage "Dag Dependencies file $dependencies"

requirements_file=$(getValueFromDic "requirements_file")
printMessage "Requirement file $requirements_file"

copyDagDefinition $airflow_home $PWD $dagDefinitionFile
copyConfigs $airflow_home $PWD $dependencies
copyConfigs $airflow_home $PWD $requirements_file

if [ -f "$airflow_home/$requirements_file" ]; 
    then
    printMessage "Installing necessary modules from requirements file $requirements_file at $airflow_home"
    /bin/python3 -m pip install -r $airflow_home/$requirements_file
fi

printMessage "Cleaning Up directory $currentDir"

rm -r $currentDir
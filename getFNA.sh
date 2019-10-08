#!/bin/bash
# Program: getFNA
# Author: Caleb Cornett
# Usage: ./getFNA.sh
# Description: Quick and easy way to install a local copy of FNA and its native libraries.

# Checks if dotnet is installed
function checkDotnet()
{
	# || { echo >&2 "ERROR: dotnet is not installed. Please install dotnet to download the t4 tool."; exit 1; }
	command -v dotnet > /dev/null 2>&1
    if [ ! $? -eq 0 ]; then
        echo >&2 "ERROR: dotnet is not installed. Please install dotnet to download the t4 tool."
        exit 1
    fi
}

# Checks if t4 is installed and installs it if it isnt
function installT4()
{
	checkDotnet
	command -v t4 > /dev/null 2>&1
    if [ ! $? -eq 0 ]; then
		dotnet tool install -g dotnet-t4
    fi
}

# Checks if git is installed
function checkGit()
{
    git --version > /dev/null 2>&1
    if [ ! $? -eq 0 ]; then
        echo >&2 "ERROR: Git is not installed. Please install git to download FNA."
        exit 1
    fi
}

# Clones FNA from the git master branch
function downloadFNA()
{
    checkGit
	echo "Downloading FNA..."
	git -C $MY_DIR clone https://github.com/FNA-XNA/FNA.git --recursive
	if [ $? -eq 0 ]; then
		echo "Finished downloading!"
	else
		echo >&2 "ERROR: Unable to download successfully. Maybe try again later?"
	fi
}

# Pulls FNA from the git master branch
function updateFNA()
{
    checkGit
    echo "Updating to the latest git version of FNA..."
	git -C "$MY_DIR/FNA" pull --recurse-submodules
	if [ $? -eq 0 ]; then
		echo "Finished updating!"
	else
		echo >&2 "ERROR: Unable to update."
		exit 1
	fi
}


# Downloads and extracts prepackaged archive of native libraries ("fnalibs")
function getLibs()
{
    # Downloading
    echo "Downloading latest fnalibs..."
    curl http://fna.flibitijibibo.com/archive/fnalibs.tar.bz2 > "$MY_DIR/fnalibs.tar.bz2"
    if [ $? -eq 0 ]; then
        echo "Finished downloading!"
    else
        >&2 echo "ERROR: Unable to download successfully."
        exit 1
    fi

    # Decompressing
    echo "Decompressing fnalibs..."
    mkdir -p $MY_DIR/fnalibs
    tar xjC $MY_DIR/fnalibs -f $MY_DIR/fnalibs.tar.bz2
    if [ $? -eq 0 ]; then
        echo "Finished decompressing!"
        echo ""
        rm $MY_DIR/fnalibs.tar.bz2
    else
        >&2 echo "ERROR: Unable to decompress successfully."
        exit 1
    fi
}

# Get the directory of this script
MY_DIR=$(dirname "$BASH_SOURCE")


# gather input

# FNA
if [ ! -d "$MY_DIR/FNA" ]; then
    read -p "Download FNA (y/n)? " shouldDownload
else
    read -p "Update FNA (y/n)? " shouldUpdate
fi

if [ ! -d "$MY_DIR/fnalibs" ]; then
    read -p "Download fnalibs (y/n)? " shouldDownloadLibs
else 
    read -p "Redownload fnalibs (y/n)? " shouldDownloadLibs
fi


# act on the input

# FNA
if [[ $shouldDownload =~ ^[Yy]$ ]]; then
    downloadFNA
elif [[ $shouldUpdate =~ ^[Yy]$ ]]; then
    updateFNA
fi

# FNALIBS
if [[ $shouldDownloadLibs =~ ^[Yy]$ ]]; then
    getLibs
fi


# install t4 engine
installT4



# Only proceed from here if we have not yet renamed the project
if [ ! -d "$MY_DIR/project_name" ]; then
	# old project_name folder already renamed so we are all done here
	exit 1
fi


read -p "Enter the project name to use for your folder and csproj file or 'exit' to quit: " newProjectName
if [[ $newProjectName = 'exit' || -z "$newProjectName" ]]; then
    exit 1
fi

# any files that need to have project_name replaced with the new project name should be here
files=(project_name.sln .gitignore project_name/project_name.csproj project_name/Game1.cs project_name/DemoComponent.cs project_name/DefaultScene.cs project_name/Program.cs .vscode/tasks.json .vscode/settings.json .vscode/launch.json .vscode/buildEffects.sh .vscode/processT4Templates.sh)
for file in "${files[@]}"; do
    sed -i '' "s/project_name/$newProjectName/g" $file
done

mv project_name.sln "$newProjectName.sln"
mv project_name/project_name.sln "project_name/$newProjectName.sln"
mv project_name/project_name.csproj "project_name/$newProjectName.csproj"
mv project_name/project_name.csproj.user "project_name/$newProjectName.csproj.user"
mv project_name "$newProjectName"

git init
git submodule add https://github.com/prime31/Nez.git
cd Nez
git submodule init
git submodule update

command -v pbcopy > /dev/null 2>&1
if [ ! $? -eq 0 ]; then
	printf "\n\nManually run the following command:\n\nnuget restore Nez/Nez.sln && msbuild Nez/Nez.sln && msbuild /t:restore $newProjectName && msbuild $newProjectName.sln\n\n"
else
	echo "nuget restore Nez/Nez.sln && msbuild Nez/Nez.sln && msbuild /t:restore $newProjectName && msbuild $newProjectName.sln" | pbcopy
	echo ""
	echo "A build command was copied to your clipboard. Paste and run it now."
	echo ""
fi

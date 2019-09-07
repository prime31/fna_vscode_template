#!/bin/bash
# Program: getFNA
# Author: Caleb Cornett (converted to powershell to work with windows)
# Usage: ./getFNA.sh
# Description: Quick and easy way to install a local copy of FNA and its native libraries.

# Checks if dotnet is installed
function checkDotnet() 
{
    try { dotnet | Out-Null }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        Write-Output "ERROR: Dotnet is not installed. Please install dotnet to download the t4 tool."
        exit
    }
}

function checkMsbuild ()
{
    try { msbuild | Out-Null }
    catch [System.Management.Automation.CommandNotFoundException] 
    {
        Write-Output "ERROR: Msbuild is not available, please ensure msbuild.exe is installed and added to the PATH Environment Variable."
        exit
    }
}

function check7zip ()
{
    if ((Test-Path "C:\Program Files\7-Zip") -eq 0)
    {
        Write-Output "ERROR: 7zip is not installed, please install 7zip and try again."
        exit
    }
}

function installT4 () 
{
    if (checkDotnet) { Invoke-Expression 'dotnet tool install -g dotnet-t4' }
}

function checkGit () 
{
    try { git | Out-Null }
    catch [System.Management.Automation.CommandNotFoundException] 
    {
        Write-Output "ERROR: Git is not installed. Please install git to download FNA."
        exit
    }
}

function downloadFNA()
{
    checkGit
    git -C $PSScriptRoot clone https://github.com/FNA-XNA/FNA.git --recursive

    if ($? -eq 1) { Write-Output "Finished Downloading!" }
    else { Write-Output "ERROR: Download failed, try again later?" exit}
    
}

function updateFNA ()
{
    checkGit
    Write-Output "Updating to the latest git version of FNA..."

    git -C "${PSScriptRoot}\FNA" pull --recurse-submodules
    
    if ($? -eq 1) { Write-Output "Finished updating!" }
    else { Write-Output "ERROR: Unable to update." exit}
}



function getLibs ()
{
    Write-Output "Downloading the latest FNAlibs..."
    Invoke-WebRequest -Uri http://fna.flibitijibibo.com/archive/fnalibs.tar.bz2 -OutFile "${PSScriptRoot}/fnalibs.tar.bz2"
    if ($? -eq 1) { Write-Output "Finished downloading!" }
    else { Write-Output "ERROR: Unable to download successfully." exit}

    Write-Output "Decompressing fnalibs..."
    check7zip
    if ((Test-Path "${PSScriptRoot}\fnalibs") -eq 0)
    {
        & "C:\Program Files\7-Zip\7z.exe" x "fnalibs.tar.bz2"
        if ($? -eq 1){ Remove-Item "fnalibs.tar.bz2"} 
        else { Write-Output "ERROR: Unable to decompress successfully." exit }
        & "C:\Program Files\7-Zip\7z.exe" x "fnalibs.tar" -ofnalibs
        if ($? -eq 1)
        {  
            Remove-Item "fnalibs.tar" 
            Write-Output "Finished decompressing!"
        } 
        else { Write-Output "ERROR: Unable to decompress successfully." exit }
    }
    
}

checkMsbuild

if (Test-Path "${PSScriptRoot}\FNA")
{
    #if ((Read-Host -Prompt "Update FNA (y/n)?") -like 'y') { $shouldUpdate = true }
    $shouldUpdate = Read-Host -Prompt "Update FNA (y/n)?"
}
else 
{
    #if ((Read-Host -Prompt "Download FNA (y/n)?") -like 'y') { $shouldDownload = true }
    $shouldDownload = Read-Host -Prompt "Download FNA (y/n)?"
}

if (Test-Path "${PSScriptRoot}\fnalibs")
{
    #if ((Read-Host -Prompt "Redownload fnalibs (y/n)?") -like 'y') { $shouldDownloadLibs = true }
    $shouldDownloadLibs = Read-Host -Prompt "Redownload fnalibs (y/n)?"
}
else 
{
    #if ((Read-Host -Prompt "Download fnalibs (y/n)?") -like 'y') { $shouldDownloadLibs = true }
    $shouldDownloadLibs = Read-Host -Prompt "Download fnalibs (y/n)?"
}

if ((Test-Path "${PSScriptRoot}\project_name") -eq 1)
{
    $newProjectName = Read-Host -Prompt "Enter the project name to use for your folder and csproj file or 'exit' to quit: "
}

if ($shouldDownload -like 'y') { downloadFNA }
elseif ($shouldUpdate -like 'y') { updateFNA }

if ($shouldDownloadLibs -like 'y') { getLibs }

installT4

# Only proceed from here if we have not yet renamed the project
if ((Test-Path "${PSScriptRoot}\project_name") -ne 1) { exit }


if ($newProjectName -eq "exit" -or $newProjectName -eq "") { exit }

$files= "project_name.sln", 
        ".gitignore", 
        "project_name/project_name.csproj", 
        "project_name/Game1.cs", 
        "project_name/DemoComponent.cs", 
        "project_name/DefaultScene.cs", 
        "project_name/Program.cs", 
        ".vscode/tasks.json", 
        ".vscode/settings.json", 
        ".vscode/launch.json", 
        ".vscode/buildEffects.sh", 
        ".vscode/processT4Templates.sh", 
        ".vscode/buildEffects.ps1", 
        ".vscode/processT4Templates.ps1"

foreach ($file in $files)
{
    ((Get-Content -Path $file -Raw) -replace 'project_name', $newProjectName) | Set-Content -Path $file
}

Rename-Item -Path "project_name.sln"                        -NewName "${newProjectName}.sln"
Rename-Item -Path "project_name/project_name.csproj"        -NewName "${newProjectName}.csproj"
Rename-Item -Path "project_name/project_name.csproj.user"   -NewName "${newProjectName}.csproj.user"
Rename-Item -Path "project_name"                            -NewName $newProjectName

git init
git submodule add https://github.com/prime31/Nez.git
Set-Location Nez
git submodule init
git submodule update

"Restoring..."
Set-Location $PSScriptRoot
dotnet restore "Nez/Nez.sln"

"Building..."
msbuild "Nez/Nez.sln"
msbuild -t:restore $newProjectName
msbuild -t:buildcontent $newProjectName
msbuild "${newProjectName}.sln"

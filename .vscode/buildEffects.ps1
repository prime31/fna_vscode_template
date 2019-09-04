#!/bin/bash
# buildEffects
# Compiles all .fx files found in the project's Content directory.
# Intended for usage with VS Code Build Tasks tooling.
# You may need to change the path to fxc.exe depending on your installation.

Write-Output "Starting build process..."

Set-Location $PSScriptRoot
Set-Location ../project_name


$fxc = "C:\Program Files (x86)\Microsoft DirectX SDK (June 2010)\Utilities\bin\x86\fxc.exe"

$files = Get-ChildItem -Path "Content\*" -Recurse -Include *fx 

foreach ($file in $files)
{
    $fileName = $file.BaseName
    $filePath = $file.FullName
    & $fxc /T fx_2_0 $filePath /Fo "${filePath}b"

    Write-Output "Built ${fileName}.fx to ${filePath}b"
}



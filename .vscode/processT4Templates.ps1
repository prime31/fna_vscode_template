#!/bin/bash
# buildEffects
# Compiles all .fx files found in the project's Content directory.
# Intended for usage with VS Code Build Tasks tooling.
# You may need to change the path to fxc.exe depending on your installation.

Write-Output "Starting T4 processing..."

Set-Location $PSScriptRoot
Set-Location ..\project_name

# create our output directory
if ((Test-Path("T4Templates\Output")) -eq 0) { New-Item  -ItemType "directory" -Path "T4Templates\Output" }

$files = Get-ChildItem ".\T4Templates\*" -Include *.tt

foreach ($file in $files)
{
    $fileName = $file.BaseName
    # Build the template
    t4 -r System.dll -r mscorlib.dll -r netstandard.dll -r System.IO.FileSystem.dll -r System.Linq.dll -r System.Text.RegularExpressions -o "T4Templates\Output\${fileName}.cs" "T4Templates\${fileName}.tt"
    
    Write-Output "Built ${fileName}.cs from ${fileName}.tt"
}




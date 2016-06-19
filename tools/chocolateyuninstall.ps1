
$ErrorActionPreference = 'Stop';

$uninstalled = $false;
$AppDataNVM = "$env:APPDATA\nvm";

nvm off;
Remove-Item $AppDataNVM -Force -Recurse;
Install-ChocolateyEnvironmentVariable -VariableName "NVM_HOME" -VariableValue $null -VariableType User
Install-ChocolateyEnvironmentVariable -VariableName "NVM_SYMLINK" -VariableValue $null -VariableType Machine
# TODO - remove "%NVM_HOME%;%NVM_SYMLINK%"
# Uninstall-ChocolateyPath "%NVM_HOME%;%NVM_SYMLINK%" -PathType Machine;

# Uninstall-ChocolateyEnvironmentVariable -VariableName "NVM_HOME" -VariableType User;
# Uninstall-ChocolateyEnvironmentVariable -VariableName "NVM_SYMLINK" -VariableType Machine;

$uninstalled = $true
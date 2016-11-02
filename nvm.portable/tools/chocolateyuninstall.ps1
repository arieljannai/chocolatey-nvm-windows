
$ErrorActionPreference = 'Stop';

$uninstalled = $false;
$packageName= 'nvm' # arbitrary name for the package, used in messages
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$zipName = "nvm-noinstall.zip"
$nvmPath = Join-Path $toolsDir $packageName
#$AppDataNVM = "$env:APPDATA\nvm";

& $nvmPath/nvm off

#Remove-Item $AppDataNVM -Force -Recurse;
Uninstall-ChocolateyZipPackage $packageName $zipName

# Backwards compatible to pre 0.9.10 Choco
Install-ChocolateyEnvironmentVariable -VariableName "NVM_HOME" -VariableValue $null -VariableType User
Install-ChocolateyEnvironmentVariable -VariableName "NVM_SYMLINK" -VariableValue $null -VariableType Machine

# TODO - remove "%NVM_HOME%;%NVM_SYMLINK%"
# Uninstall-ChocolateyPath "%NVM_HOME%;%NVM_SYMLINK%" -PathType Machine;

# My hackery
#$cleanPath = $env:PATH -replace '%NVM_HOME%;','' -replace '%NVM_SYMLINK%;',''
#$cleanPath
#$cleanPath = $env:PATH #-split ";" | foreach { $_ -replace

# Better hackery
# Via @DarwinJS on GitHub as a temp workaround, https://github.com/chocolatey/choco/issues/310
#Using .NET method prevents expansion (and loss) of environment variables (whether the target of the removal or not)
#To avoid bad situations - does not use substring matching, regular expressions are "exact" matches
#Removes duplicates of the target removal path, Cleans up double ";", Handles ending "\"


[regex] $PathsToRemove = "^(%NVM_HOME%|%NVM_SYMLINK%)"
$environmentPath = [Environment]::GetEnvironmentVariable("PATH","Machine")
$environmentPath
[string[]]$newpath = ''
foreach ($path in $environmentPath.split(';'))
{
  If (($path) -and ($path -notmatch $PathsToRemove))
    {
        [string[]]$newpath += "$path"
        "$path added to `$newpath"
    } else {
        "Bad path found: $path"
    }
}
$AssembledNewPath = ($newpath -join(';')).trimend(';')
$AssembledNewPath

[Environment]::SetEnvironmentVariable("PATH",$AssembledNewPath,"Machine")
$newEnvironmentPath = [Environment]::GetEnvironmentVariable("PATH","Machine")
$env:PATH = $newEnvironmentPath
$env:PATH

# Below requires Choco >=0.9.10
# Uninstall-ChocolateyEnvironmentVariable -VariableName "NVM_HOME" -VariableType User;
# Uninstall-ChocolateyEnvironmentVariable -VariableName "NVM_SYMLINK" -VariableType Machine;

$uninstalled = $true

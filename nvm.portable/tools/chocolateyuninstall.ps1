
$ErrorActionPreference = 'Stop';

$uninstalled = $false;
$packageName= 'nvm' # arbitrary name for the package, used in messages
$zipName = "nvm-noinstall.zip"
$nvm = (& where.exe $packageName)

# Gets just the base path where nvm was located
$nvmPath = Split-Path $nvm

Uninstall-ChocolateyZipPackage $packageName $zipName
# If uninstalling and not just upgrading
# we will remove all node versions that were installed
# and therefore any globally installed modules
Remove-Item $nvmPath -Force -Recurse;

# Backwards compatible to pre 0.9.10 Choco
Install-ChocolateyEnvironmentVariable -VariableName "NVM_HOME" -VariableValue $null -VariableType Machine
Install-ChocolateyEnvironmentVariable -VariableName "NVM_SYMLINK" -VariableValue $null -VariableType Machine

# Remove installed variable(s) from PATH
# Loop via @DarwinJS on GitHub as a temp workaround, https://github.com/chocolatey/choco/issues/310
#To avoid bad situations - does not use substring matching, regular expressions are "exact" matches
#Removes duplicates of the target removal path, Cleans up double ";", Handles ending "\"

# Need to escape any backslash in the regex
[regex] $PathsToRemove = "^(%NVM_HOME%|%NVM_SYMLINK%)"
$environmentPath = Get-EnvironmentVariable -Name 'PATH' -Scope $EnvVariableType -PreserveVariables
$environmentPath
[string[]]$newpath = ''
foreach ($path in $environmentPath.split(';'))
{
  If (($path) -and ($path -notmatch $PathsToRemove))
    {
        [string[]]$newpath += "$path"
        "$path added to `$newpath"
    } else {
        "Path to remove found: $path"
    }
}
$AssembledNewPath = ($newpath -join(';')).trimend(';')
$AssembledNewPath

Install-ChocolateyEnvironmentVariable -variableName 'PATH' -variableValue $AssembledNewPath -variableType $EnvVariableType
"Path with variables"
$newEnvironmentPath = Get-EnvironmentVariable -Name 'PATH' -Scope $EnvVariableType -PreserveVariables
"Path with values instead of variables"
$env:PATH

# Below requires Choco >=0.9.10
# Uninstall-ChocolateyEnvironmentVariable -VariableName "NVM_HOME" -VariableType User;
# Uninstall-ChocolateyEnvironmentVariable -VariableName "NVM_SYMLINK" -VariableType Machine;

$uninstalled = $true

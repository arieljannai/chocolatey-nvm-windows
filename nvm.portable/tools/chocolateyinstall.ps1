
$ErrorActionPreference = "Stop";

$packageName= 'nvm'
$url        = "https://github.com/coreybutler/nvm-windows/releases/download/1.1.1/nvm-noinstall.zip"

$nodePath = "$env:SystemDrive\Program Files\nodejs"
# Install nvm to its own directory, not in the chocolatey lib folder
# If requesting per user install use $env:APPDATA else $env:ProgramData
$nvmPath = Join-Path $env:ProgramData $packageName
$OsBits = Get-ProcessorBits
$NvmSettingsFile = Join-Path $nvmPath "settings.txt"

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $nvmPath
  url           = $url

  checksum      = 'D2AC6DD3859B463A4D9249680E3A0BAB104652CBB63987C262767A1F8E058B4AA07405668732E33D06907AAA76208FAFFC7DE85398C5A0A36A90D9E484C06068'
  checksumType  = 'sha512'
}
Install-ChocolateyZipPackage @packageArgs

#New-Item "$NvmSettingsFile" -type file -force -value `
# $("root: $nvmPath `r`npath: $nodePath `r`narch: $OsBits`r`nproxy: none");

# This pattern will be easier to maintain if new settings are added
# If existing settings file, read and create dictionary of values
$NvmSettingsDict = [ordered]@{}
if (Test-Path $NvmSettingsFile) {
    $NvmSettings = Get-Content $NvmSettingsFile
    $NvmSettings | Foreach-Object { $NvmSettingsDict.add($_.split(':',2)[0],$_.split(':',2)[1]) }
    Write-Output "Detected existing settings file"
    $NvmSettingsDict.GetEnumerator() | % { "$($_.Name): $($_.Value)" } | Write-Verbose
}
# only set values if not present or missing from existing settings
if (!($NvmSettingsDict['root'])) { $NvmSettingsDict['root'] = $nvmPath }
if (!($NvmSettingsDict['path'])) { $NvmSettingsDict['path'] = $nodePath }
if (!($NvmSettingsDict['arch'])) { $NvmSettingsDict['arch'] = $OsBits }
if (!($NvmSettingsDict['proxy'])) { $NvmSettingsDict['proxy'] = "none" }

# Essentially writing a YAML file
# The ASCII type is required for NVM to read the file properly
$NvmSettingsDict.GetEnumerator() | % { "$($_.Name): $($_.Value)" } | Write-Verbose
$NvmSettingsDict.GetEnumerator() | % { "$($_.Name): $($_.Value)" } | Out-File "$NvmSettingsFile" -Force -Encoding ascii

# If you don't install to the toolsDir Chocolatey won't create a shim
# This would avoid creating an nvm.exe shim in the $chocolateyRoot\bin folder that is in the path
#$files = get-childitem $nvmPath -include *.exe -recurse

#foreach ($file in $files) {
#  #generate an ignore file
#  New-Item "$file.ignore" -type file -force | Out-Null
#}

# Could install per user variables if not running node as a service or other users
Install-ChocolateyEnvironmentVariable -VariableName "NVM_HOME" -VariableValue "$nvmPath" -VariableType Machine;
Install-ChocolateyEnvironmentVariable -VariableName "NVM_SYMLINK" -VariableValue "$nodePath" -VariableType Machine;

# Adding NVM_HOME to the path isn't required if you use the shim, it IS required if you don't use the shim (ie install outside of $toolsDir or ignore above)
# Having it on the PATH twice could be confusing even though it is the "same" file
Install-ChocolateyPath -PathToInstall "%NVM_HOME%" -PathType Machine;

# This allows nvm and other tools to find the node binaries.
Install-ChocolateyPath -PathToInstall "%NVM_SYMLINK%" -PathType Machine;

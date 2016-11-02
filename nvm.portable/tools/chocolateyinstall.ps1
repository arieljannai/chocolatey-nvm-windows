
$ErrorActionPreference = "Stop";

$packageName= 'nvm'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = "https://github.com/coreybutler/nvm-windows/releases/download/1.1.1/nvm-noinstall.zip"

$nodePath = "$env:SystemDrive\Program Files\nodejs"
$nvmPath = Join-Path $toolsDir $packageName
$OsBits = Get-ProcessorBits
$NvmSettings = Join-Path $nvmPath "settings.txt"

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $nvmPath
  url           = $url

  checksum      = 'D2AC6DD3859B463A4D9249680E3A0BAB104652CBB63987C262767A1F8E058B4AA07405668732E33D06907AAA76208FAFFC7DE85398C5A0A36A90D9E484C06068'
  checksumType  = 'sha512'
}
Install-ChocolateyZipPackage @packageArgs

#New-Item "$NvmSettings.newitem" -type file -force -value `
# $("root: $nvmPath `r`npath: $nodePath `r`narch: $OsBits`r`nproxy: none");

# This pattern will be easier to maintain if new settings are added
$NvmSettingsDict = [ordered]@{}
$NvmSettingsDict['root'] = $nvmPath
$NvmSettingsDict['path'] = $nodePath
$NvmSettingsDict['arch'] = $OsBits
$NvmSettingsDict['proxy'] = "none"

# Essentially writing a YAML file
# The ASCII type is required for NVM to read the file properly
$NvmSettingsDict.GetEnumerator() | % { "$($_.Name): $($_.Value)" } | Write-Verbose
$NvmSettingsDict.GetEnumerator() | % { "$($_.Name): $($_.Value)" } | Out-File "$NvmSettings" -Force -Encoding ascii

# This would avoid creating an nvm.exe shim in the $chocolateyRoot\bin folder that is in the path
#$files = get-childitem $toolsDir -include *.exe -recurse

#foreach ($file in $files) {
#  #generate an ignore file
#  New-Item "$file.ignore" -type file -force | Out-Null
#}

Install-ChocolateyEnvironmentVariable -VariableName "NVM_HOME" -VariableValue "$nvmPath" -VariableType Machine;
Install-ChocolateyEnvironmentVariable -VariableName "NVM_SYMLINK" -VariableValue "$nodePath" -VariableType Machine;

# Adding NVM_HOME to the path isn't required if you use the shim, it IS required if you don't
# Having it on the PATH twice could be confusing even though it is the "same" file
#Install-ChocolateyPath -PathToInstall "%NVM_HOME%" -PathType Machine;

# This allows nvm and other tools to find the node binaries.
Install-ChocolateyPath -PathToInstall "%NVM_SYMLINK%" -PathType Machine;

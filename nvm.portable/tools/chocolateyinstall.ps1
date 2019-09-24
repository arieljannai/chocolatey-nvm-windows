
$ErrorActionPreference = "Stop"

$packageName= 'nvm'
$url        = "https://github.com/coreybutler/nvm-windows/releases/download/1.1.7/nvm-noinstall.zip"

# Get Package Parameters
$pp = Get-PackageParameters

# Install nvm to its own directory, not in the chocolatey lib folder
# If requesting per user install use $env:APPDATA else $env:ProgramData
if (!$pp.InstallationPath) { $pp.InstallationPath = Join-Path $env:ProgramData $packageName }
if (!$pp.NodePath) { $pp.NodePath = "$env:SystemDrive\Program Files\nodejs" }

$OsBits = Get-ProcessorBits
$NvmSettingsFile = Join-Path $pp.InstallationPath "settings.txt"

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $pp.InstallationPath
  url           = $url

  checksum      = 'c6f957081d28639e4b2665df92e42b0e6c40de495390dd5184d625fd9cde1e4defd7ca218207ccd5f99e29f11a266a2849175667ffae8d196ec0061cd6c1781e'
  checksumType  = 'sha512'
}
Install-ChocolateyZipPackage @packageArgs

#New-Item "$NvmSettingsFile" -type file -force -value `
# $("root: $pp.InstallationPath `r`npath: $pp.NodePath `r`narch: $OsBits`r`nproxy: none");

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
if (!($NvmSettingsDict['root'])) { $NvmSettingsDict['root'] = $pp.InstallationPath }
if (!($NvmSettingsDict['path'])) { $NvmSettingsDict['path'] = $pp.NodePath }
if (!($NvmSettingsDict['arch'])) { $NvmSettingsDict['arch'] = $OsBits }
if (!($NvmSettingsDict['proxy'])) { $NvmSettingsDict['proxy'] = "none" }

# Essentially writing a YAML file
# The ASCII type is required for NVM to read the file properly
$NvmSettingsDict.GetEnumerator() | % { "$($_.Name): $($_.Value)" } | Write-Verbose
$NvmSettingsDict.GetEnumerator() | % { "$($_.Name): $($_.Value)" } | Out-File "$NvmSettingsFile" -Force -Encoding ascii

# If you don't install to the toolsDir Chocolatey won't create a shim
# This would avoid creating an nvm.exe shim in the $chocolateyRoot\bin folder that is in the path
#$files = get-childitem $pp.InstallationPath -include *.exe -recurse

#foreach ($file in $files) {
#  #generate an ignore file
#  New-Item "$file.ignore" -type file -force | Out-Null
#}

# Could install per user variables if not running node as a service or other users
Install-ChocolateyEnvironmentVariable -VariableName "NVM_HOME" -VariableValue "$($pp.InstallationPath)" -VariableType Machine;
Install-ChocolateyEnvironmentVariable -VariableName "NVM_SYMLINK" -VariableValue "$($pp.NodePath)" -VariableType Machine;

# Adding NVM_HOME to the path isn't required if you use the shim, it IS required if you don't use the shim (ie install outside of $toolsDir or ignore above)
# Having it on the PATH twice could be confusing even though it is the "same" file
Install-ChocolateyPath -PathToInstall "%NVM_HOME%" -PathType Machine;

# This allows nvm and other tools to find the node binaries.
Install-ChocolateyPath -PathToInstall "%NVM_SYMLINK%" -PathType Machine;


$ErrorActionPreference = "Stop";

$packageName= 'nvm' # arbitrary name for the package, used in messages
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = "https://github.com/coreybutler/nvm-windows/releases/download/1.1.1/nvm-noinstall.zip"

#$AppDataNVM = "$env:APPDATA\nvm";
#$NodeJsInstall = "C:\Program Files\nodejs";
$nodePath = "$env:SystemDrive\Program Files\nodejs"
$nvmPath = Join-Path $toolsDir $packageName
$OsBits = Get-ProcessorBits
$NvmSettings = Join-Path $nvmPath "settings.txt"

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $nvmPath
  url           = $url

  checksum      = ''
  checksumType  = 'md5' #default is md5, can also be sha1, sha256 or sha512
  checksum64    = ''
  checksumType64= 'md5' #default is checksumType
}
Install-ChocolateyZipPackage @packageArgs
#Install-ChocolateyZipPackage -PackageName "nvm" -Url  $ZipUrl -UnzipLocation $AppDataNVM;

New-Item $NvmSettings -type file -force -value `
 $("root: $nvmPath `r`npath: $nodePath `r`narch: $OsBits`r`nproxy: none");

#$NvmSettingsDict = [ordered]@{}
#$NvmSettingsDict['root'] = $nvmPath
#$NvmSettingsDict['path'] = $nodePath
#$NvmSettingsDict['arch'] = $OsBits
#$NvmSettingsDict['proxy'] = "none"
#$NvmSettingsDict.GetEnumerator() | % { "$($_.Name):$($_.Value)" } | Write-Verbose
#$NvmSettingsDict.GetEnumerator() | % { "$($_.Name):$($_.Value)" } | Out-File $NvmSettings

Install-ChocolateyEnvironmentVariable -VariableName "NVM_HOME" -VariableValue "$nvmPath" -VariableType Machine;
Install-ChocolateyEnvironmentVariable -VariableName "NVM_SYMLINK" -VariableValue "$nodePath" -VariableType Machine;

Install-ChocolateyPath -PathToInstall "%NVM_HOME%" -PathType Machine;
Install-ChocolateyPath -PathToInstall "%NVM_SYMLINK%" -PathType Machine;

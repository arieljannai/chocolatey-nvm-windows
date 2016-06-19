
$ErrorActionPreference = "Stop";
$AppDataNVM = "$env:APPDATA\nvm";
$NodeJsInstall = "C:\Program Files\nodejs";
$OsBits = Get-ProcessorBits;
$NvmSettings = "$AppDataNVM\settings.txt";
$ZipUrl = "https://github.com/coreybutler/nvm-windows/releases/download/1.1.0/nvm-noinstall.zip";

# Following the manual installation guide - https://github.com/coreybutler/nvm-windows/wiki#manual-installation

Install-ChocolateyZipPackage -PackageName "nvm" -Url  $ZipUrl -UnzipLocation $AppDataNVM;

New-Item $NvmSettings -type file -force -value `
 $("root: $AppDataNVM`r`npath: $NodeJsInstall`r`narch: $OsBits`r`nproxy: none");

Install-ChocolateyEnvironmentVariable -VariableName "NVM_HOME" -VariableValue "$AppDataNVM" -VariableType User;
Install-ChocolateyEnvironmentVariable -VariableName "NVM_SYMLINK" -VariableValue "$NodeJsInstall" -VariableType Machine;

Install-ChocolateyPath -PathToInstall  "%NVM_HOME%;%NVM_SYMLINK%" -PathType Machine;

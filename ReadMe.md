# Looking for maintainers
I'm not using nvm those days, looking for someone who wants to handle the repo

# Chocolatey [nvm-windows](https://github.com/coreybutler/nvm-windows) package

Basically, following the [manual installation guide](https://github.com/coreybutler/nvm-windows/wiki#manual-installation).

## Installation process
* Extract the `noinstall` zip
* Creates the settings.txt file with default values (and matching arch)
* Creating `NVM_HOME` and `NVM_SYMLINK` environment variables
* Adding the nvm environment variables to the path

## Uninstallation process
* Calling `nvm off` to unlink the nodejs install folder from program files.
* Removing the nvm folder recursively with force
* Removing `NVM_HOME` and `NVM_SYMLINK` environment variables

## TODO
- [X] Remove the environment variables from path on uninstall.
- [X] Create script for updating (save settings.txt and not to overwrite it).
- [ ] Add package parameters to choose the install folders.
- [ ] Allow installing specific nodejs version with the installation.
- [ ] Option to uninstall nvm but keep the files.

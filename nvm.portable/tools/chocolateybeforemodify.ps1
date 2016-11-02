
$ErrorActionPreference = 'Stop';

$packageName= 'nvm' # arbitrary name for the package, used in messages
# This next part assumes nvm is on your path currently
$nvm = (& where.exe $packageName)

& $nvm off

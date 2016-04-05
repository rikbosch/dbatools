Remove-Module dbatools -ErrorAction SilentlyContinue
$url = 'https://github.com/rikbosch/dbatools/archive/master.zip'
$path = Join-Path -Path (Split-Path -Path $profile) -ChildPath '\Modules\dbatools'
$temp = ([System.IO.Path]::GetTempPath()).TrimEnd("\")
$zipfile = "$temp\sqltools.zip"

if (!(Test-Path -Path $path)){
	Write-Output "Creating directory: $path"
	New-Item -Path $path -ItemType Directory | Out-Null 
} else { 
	Write-Output "Deleting previously installed module"
	Remove-Item -Path "$path\*" -Force -Recurse 
}

Write-Output "Downloading archive from github"
try
{
	Invoke-WebRequest $url -OutFile $zipfile
} catch {
   #try with default proxy and usersettings
   Write-Output "Probably using a proxy for internet access, trying default proxy settings"
   (New-Object System.Net.WebClient).Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
   Invoke-WebRequest $url -OutFile $zipfile
}

# Unblock if there's a block
Unblock-File $zipfile -ErrorAction SilentlyContinue

Write-Output "Unzipping"
# Keep it backwards compatible
$shell = New-Object -COM Shell.Application
$zipPackage = $shell.NameSpace($zipfile)
$destinationFolder = $shell.NameSpace($temp)
$destinationFolder.CopyHere($zipPackage.Items())

Write-Output "Cleaning up"
Move-Item -Path "$temp\dbatools-master\*" $path
Remove-Item -Path "$temp\dbatools-master"
Remove-Item -Path $zipfile

Write-Output "Done! Please report any bugs to clemaire@gmail.com."
if ((Get-Command -Module dbatools).count -eq 0) { Import-Module "$path\dbatools.psd1" }
Get-Command -Module dbatools
Write-Output "`n`nIf you experience any function missing errors after update, please restart PowerShell or reload your profile."
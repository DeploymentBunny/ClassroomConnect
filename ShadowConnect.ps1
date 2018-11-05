<#
.Synopsis
    ShadowConnect.ps1 -ServerName
.DESCRIPTION
    The script will find the session id for the user on the remote server with the name that has the same name as the user, so if the server namen is SERVER15 it will find a user that is namned Something15.This is used in classroom scenarios
.EXAMPLE
    ShadowConnect.ps1 -ServerName
.NOTES
    Created:	 Nov 4, 2018
    Version:	 1.0

    Author - Mikael Nystrom
    Twitter: @mikael_nystrom
    Blog   : http://deploymentbunny.com

    Author - Johan Arwidmark
    Twitter: @jarwidmark
    Blog   : http://deploymentresearch.com

    Disclaimer:
    This script is provided 'AS IS' with no warranties, confers no rights and 
    is not supported by the authors or Deployment Artist.
.LINK
    http://www.deploymentfundamentals.com
#>

Param(
    $ServerName = "ROGUE-015"
)

#Part of the code below is from https://gallery.technet.microsoft.com/PowerShell-script-to-Find-d2ba4252#content
Function Connect-RDPUsingSessionNumber {
    Param(
        $ServerName
    )
    $queryResults = (qwinsta /server:$ServerName | foreach { (($_.trim() -replace "\s+",","))} | ConvertFrom-Csv)
    $ID = ($ServerName -split "-")[1]
    $session = $queryResults | Where-Object UserName -like *$ID*
    mstsc /v:$ServerName /shadow:$($session.id) /control /noconsentprompt
}

Connect-RDPUsingSessionNumber $ServerName


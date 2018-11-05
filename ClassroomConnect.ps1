<#
.Synopsis
    ClassroomConnect
.DESCRIPTION
    The script will get all computers from an OU, specified in the settings.xml file and present 3 methods of connecting
.EXAMPLE
    ClassroomConnect
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

#Requires -RunAsAdministrator

$DLL = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
Add-Type -MemberDefinition $DLL -name NativeMethods -namespace Win32
$Process = (Get-Process PowerShell | Where-Object MainWindowTitle -like '*Connect*').MainWindowHandle
# Minimize window
[Win32.NativeMethods]::ShowWindowAsync($Process, 2)

#Get Env:
$RootFolder = $MyInvocation.MyCommand.Path | Split-Path -Parent

#Get Data
[XML]$XMLData = Get-Content -Path $RootFolder\settings.xml

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
$Font = 'Microsoft Sans Serif,12'
#region begin GUI{ 

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '700,355'
$Form.text                       = "Classroom Connect"
$Form.TopMost                    = $false
$Form.StartPosition              = "CenterScreen"
$Form.Icon = "$RootFolder\deploymentbunny-w175.ico"

$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "Direct RDP"
$Button1.width                   = 250
$Button1.height                  = 25
$Button1.location                = New-Object System.Drawing.Point(400,150)
$Button1.Font                    = $Font

$Button2                         = New-Object system.Windows.Forms.Button
$Button2.text                    = "Shadow RDP"
$Button2.width                   = 250
$Button2.height                  = 25
$Button2.location                = New-Object System.Drawing.Point(400,180)
$Button2.Font                    = $Font

$Button3                         = New-Object system.Windows.Forms.Button
$Button3.text                    = "Remote Assist"
$Button3.width                   = 250
$Button3.height                  = 25
$Button3.location                = New-Object System.Drawing.Point(400,210)
$Button3.Font                    = $Font

$ButtonClose                     = New-Object system.Windows.Forms.Button
$ButtonClose.text                = "Close"
$ButtonClose.width               = 250
$ButtonClose.height              = 25
$ButtonClose.location            = New-Object System.Drawing.Point(400,300)
$ButtonClose.Font                = $Font

$ListBox1                        = New-Object system.Windows.Forms.ListBox
$ListBox1.text                   = "listBox"
$ListBox1.width                  = 350
$ListBox1.height                 = 307
$ListBox1.Font                   = $Font
$ListBox1.location               = New-Object System.Drawing.Point(19,24)

$PictureBox1 = New-Object system.Windows.Forms.PictureBox
$PictureBox1.width = 150
$PictureBox1.height  = 130
$PictureBox1.location  = New-Object System.Drawing.Point(500,15)
$PictureBox1.imageLocation  = "$RootFolder\image.png"
$PictureBox1.SizeMode  = [System.Windows.Forms.PictureBoxSizeMode]::zoom

$Form.controls.AddRange(@($Button1,$Button2,$Button3,$ButtonClose,$ListBox1,$PictureBox1))

#region gui events {
$Button1.Add_Click({ Connect1 })
$Button2.Add_Click({ Connect2 })
$Button3.Add_Click({ Connect3 })
$ButtonClose.Add_Click({ Close })
#endregion events }

#endregion GUI }


#Write your logic code here
Function Close{
    $Form.Close()
}

#Connect using RDP
Function Connect1{
    $Selection1 = $ListBox1.SelectedItem
    & mstsc.exe /v:$Selection1
}

#Write your logic code here
Function Connect2{
    $Selection1 = $ListBox1.SelectedItem
    & $RootFolder\ShadowConnect.ps1 -Servername $Selection1
}

#Write your logic code here
Function Connect3{
    $Selection1 = $ListBox1.SelectedItem
    & msra.exe /offerRA $Selection1
}

#Get all AD Computers from OU

$Computers = Get-ADComputer -Filter * -SearchBase $($xmldata.settings.oupath) | Sort-Object
foreach($item in $Computers.name){
    [void] $ListBox1.Items.Add($item)
}

[void]$Form.ShowDialog()




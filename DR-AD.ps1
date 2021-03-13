<#	
	.NOTES
	===========================================================================
	 Updated:   	Mars, 2021
	 Created by:   	Dakhama Mehdi
	 Special Thanks for help to : Baudin Nicolas, Vierman Loic
	 Advice : DEMAN-BARCELO, Cortes Sylvain
	 Organization : CADIM.org
	 Filename:      Detect-request-AD.ps1
	 Tool Name :    DR-AD 
	===========================================================================
	.DESCRIPTION
	This script, help to detect, track and prevent in real time, the malicious request, attack, or collects information request from AD,
	to protect valuable information like ( accounts admins, password, and GPO ...)
			
#>

# choose a path to extract the list of attributes to monitor by replacing the export-csv 
$dbpath= 'C:\Test\array.csv'
if ((Test-Path $path) -eq $false) {

Write-Host "Chargement et export de la liste des attributs en cours" `n

$array = $null
$array = @()

# you can edit this filter, if you want to monitor only (GPO, or Admins account, or passwords)  
Get-ADObject -SearchBase (Get-ADRootDSE).schemaNamingContext -LDAPFilter '(schemaIDGUID=*)' -Properties name, schemaIDGUID |  ForEach-Object {


$box = New-Object PSObject
$box | Add-Member -MemberType NoteProperty -Name "Nom" -Value "$_.name"
$box | Add-Member -MemberType NoteProperty -Name "GUID" -Value ([String][System.GUID]$_.schemaIDGUID)
$array += $box

}

$array |Export-Csv $dbpath

} 

else {
$array = [System.Collections.ArrayList]@()
$array = Import-Csv -Path $dbpath
}

#import the whitelist contains the name object to exclude like (accountname and computer), use only 'SamAccountName'
$whitelist= Import-Csv -Path C:\Test\user.csv

$result = [System.Collections.ArrayList]@()

$user1 = $obj1 = $null

Get-WinEvent -FilterHashtable @{Logname="Security"; ID = "4662"; startTime = (([DateTime]::Now).AddSeconds(-10))} -ErrorAction SilentlyContinue | ? {$whitelist.name -notcontains $_.properties.value[1]  }  | select -First 50 | foreach {

$val = $null

$user= $_.properties.value[1]

$val= (($_.properties.value -split ("{")) -split ("}"))

if (($array | select GUID) -match $val[6] -or ($array | select GUID) -match $val[18] )

 { 

$typeobjet=  (($array -match $val[6]).nom  -split ("CN="))[1]

$nomobjet= $array -match $val[18]
 
$Object = New-Object PSObject -Property @{
        Utilisateur      = $user
        Objet            = $typeobjet
        classe           = $nomobjet.nom
        "Nature d audit" = $_.KeywordsDisplayNames

    }
    $result += $Object

  }
  
  if (($user -ne $user1) ) { 
 function ShowBalloonTipInfo 
{
 
[CmdletBinding()]
param
(
[Parameter()]
$Text,
 
[Parameter()]
$Title,
 
$Icon = 'Warning'
)
 
Add-Type -AssemblyName System.Windows.Forms
 
#So your function would have to check whether there is already an icon that you can reuse.This is done by using a "shared variable", which really is a variable that has "script:" scope.
if ($script:balloonToolTip -eq $null)
{
#we will need to add the System.Windows.Forms assembly into our PowerShell session before we can make use of the NotifyIcon class.
$script:balloonToolTip = New-Object System.Windows.Forms.NotifyIcon 
}
 
$path = Get-Process -id $pid | Select-Object -ExpandProperty Path
$balloonToolTip.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balloonToolTip.BalloonTipIcon = $Icon
$balloonToolTip.BalloonTipText = $Text
$balloonToolTip.BalloonTipTitle = $Title
$balloonToolTip.Visible = $true
 
#I thought to display the tool tip for 15 seconds,so i used 15000 milliseconds when I call ShowBalloonTip.
$balloonToolTip.ShowBalloonTip(15000)
}

$Message= "an request is detected from $user on :  $typeobjet , pls wait, the account will be disabled" 
ShowBalloonTipInfo ("$Message","")

 [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
 
 $user1 = $user
 $obj1 = $typeobjet
 #Disable-ADAccount $user1 
 } 


}

if ($result) {

# if you use wait pls disable sleep at line 135 and 134, you can also chose to send mail in this step
#$result | Out-GridView -Title "AD security Audit" -Wait
$result | Out-GridView -Title "AD security Audit"
sleep -Seconds 10
# force quit script, same times a have a problem with sleep when the session is locked, exit have resolve this problem
exit
}



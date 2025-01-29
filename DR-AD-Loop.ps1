<#	
	.NOTES
	===========================================================================
	 Updated:   	Fevrier 08, 2021
	 Created by:   	Dakhama Mehdi, www.dakhama-mehdi.com, 
	 Organization: 	
	 Filename:      Detect-request-AD.ps1
	 Special Thanks for help to : 
     Tool Name :    DR-AD 
	===========================================================================
	.DESCRIPTION 
        Detection en continue, période de 10 secondes
        Ce script facilite la détéction et les opérations de maintenance sur les requetes d'acces ayx objets dimportant d'annuaire GPO, groupes admins, password, schema
        il offre une lecture simple et facile, si vous souhaitez automatiser avec Powershell, qui retourne des ID illisibles (GUID)
			
#>


# choose a path to extract the list of attributes to monitor by replacing the export-csv 
$dbpath= 'C:\Temp\array.csv'
if ((Test-Path $dbpath) -eq $false) {

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
$array = [System.Collections.ArrayList]@()
$array = Import-Csv -Path $dbpath

} 
else {
$array = [System.Collections.ArrayList]@()
$array = Import-Csv -Path $dbpath
}

#import the whitelist contains the name object to exclude like (accountname and computer), use only 'SamAccountName'
$whitelist= 'C:\Temp\myWhiteList.csv'
if ((Test-Path $whitelist) -eq $false) {

# Retrieve all groups protected by AdminSDHolder
$AdminGroups = Get-ADGroup -Filter {AdminCount -eq 1}

# List the members of each group without displaying their names

$AdminGroups | ForEach-Object {
    #Write-Host "Groupe : $($_.Name)" -ForegroundColor Green
    Get-ADGroupMember -Identity $_ -Recursive | Select-Object name,distinguishedName,SamAccountName | export-csv c:\temp\myWhiteList.csv -append
}

} 

$whitelist= Import-Csv -Path C:\Temp\myWhiteList.csv

$result = [System.Collections.ArrayList]@()

$user1 = $obj1 = $null

$startdate = (([DateTime]::Now).AddSeconds(-10))
$enddate = ([DateTime]::Now)

do {

Write-Host "Process started"
Write-Host "Nothing to report"
 
$result = $null 
$user1 = $obj1 = $null
$result = [System.Collections.ArrayList]@()
$box = $null


Get-WinEvent -FilterHashtable @{Logname="Security"; ID = "4662"; startTime = (([DateTime]::Now).AddSeconds(-10))} -ErrorAction SilentlyContinue | ? {$whitelist.SamAccountName -notcontains $_.properties.value[1]  }  | select -First 50 | foreach {

$val = $null

$user= $_.properties.value[1]

$val= (($_.properties.value -split ("{")) -split ("}"))
$classe = $null

if (($array | select GUID) -match $val[6] -or ($array | select GUID) -match $val[18] )

 { 

$typeobjet =  (($array -match $val[6]).nom  -split ("CN="))[1]

$nomobjet= $array -match $val[18]

$classe = $nomobjet.nom
 
$Object = New-Object PSObject -Property @{
        Username      = $user
        Objet            = $typeobjet
        classe           = $classe
        "Audit type" = $_.KeywordsDisplayNames

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

# Function to write an event to the custom Windows Event Log
function Write-EventToLog {
    param (
        [string]$message,
        [string]$eventType = "Information" # By default, it is an Information event (can be "Error", "Warning", etc.)
    )

    # Custom event log name and source
    $logName = "Alerte-Request-AD"
    $source = "DR-AD"

    # Check if the source exists, otherwise create it
    if (-not (Get-EventLog -List | Where-Object {$_.Log -eq $logName})) {
        New-EventLog -LogName $logName -Source $source
    }

    # Define the event type (Information, Warning, Error)
    $eventTypeEnum = [System.Diagnostics.EventLogEntryType]::$eventType

    # Write the event to the log
    Write-EventLog -LogName $logName -Source $source -EntryType $eventTypeEnum -EventId 1001 -Message $message
}


$Message= "an request is detected from $user on : $classe  pls wait, the account will be disabled" 
$Messagelogs = "an request is detected from $user on : $classe  type d'object $typeobjet"
ShowBalloonTipInfo ("$Message","")

Write-EventToLog -message $Messagelogs -eventType "Warning"



 [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
 
 $user1 = $user
 $obj1 = $typeobjet
 #You can edit this part to disable Account, or deny access to AD, or send email
 #Disable-ADAccount $user1 
 } 

}

if ($result) {
$result | Out-GridView -Title "AD security Audit" 
$result = $null
cls

}

Write-Host $enddate
Write-Host "Listening"
sleep -Seconds 10
$startdate= $startdate.AddSeconds(9)
$enddate= $enddate.AddSeconds(10)
Write-Host $enddate


  } until ($val -eq "test")


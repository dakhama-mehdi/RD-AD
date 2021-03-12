<#	
	.NOTES
	===========================================================================
	 Updated:   	Fevrier 08, 2021
	 Created by:   	Dakhama Mehdi, www.dakhama-mehdi.com
	 Organization: 	
	 Filename:      Detect-request-AD.ps1
	 Special Thanks for help to : 
     Tool Name :    DR-AD 
	===========================================================================
	.DESCRIPTION
	Ajouter le script à la tache d'evenement
        Ce script facilite la détéction et les opérations de maintenance sur les requetes d'acces ayx objets dimportant d'annuaire GPO, groupes admins, password, schema
        il offre une lecture simple et facile, si vous souhaitez automatiser avec Powershell, qui retourne des ID illisibles (GUID)
			
#>

# choisissez un chemin pour extraire la liste des attributs à surveiller en remplaçant la ligne export-csv n36 par le votre

if ((Test-Path C:\Test\array.csv) -eq $false) {

Write-Host "Chargement et export de la liste des attributs en cours" `n

$array = $null
$array = @()

# vous pouvez alleger le filtre des attributs en ne séléctionnant que les passwords, groupes admins, et gpo par exemple, dans notre exemple nous avons tous séléctionné
Get-ADObject -SearchBase (Get-ADRootDSE).schemaNamingContext -LDAPFilter '(schemaIDGUID=*)' -Properties name, schemaIDGUID |  ForEach-Object {


$box = New-Object PSObject
$box | Add-Member -MemberType NoteProperty -Name "Nom" -Value "$_.name"
$box | Add-Member -MemberType NoteProperty -Name "GUID" -Value ([String][System.GUID]$_.schemaIDGUID)
$array += $box

}

$array |Export-Csv C:\Test\array.csv

Write-Host "Patientez avant de démarrer le processus"
sleep -Seconds 15

} 

else {
$array = [System.Collections.ArrayList]@()
$array = Import-Csv -Path C:\Test\array.csv
}

#importer la liste blanche
$whitelist= Import-Csv -Path C:\Test\user.csv


Write-Host "Processus démarrer" 

Write-Host "Rien à signaler" 
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
 
#It must be 'None','Info','Warning','Error'
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
 
#I thought to display the tool tip for one seconds,so i used 1000 milliseconds when I call ShowBalloonTip.
$balloonToolTip.ShowBalloonTip(15000)
}

$Message= "une requete est détéctée de $user sur :  $typeobjet , veuillez patienter, le compte sera desactive" 
ShowBalloonTipInfo ("$Message","")

 [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
 
 $user1 = $user
 $obj1 = $typeobjet
 #Disable-ADAccount $user1 
 } 


}

if ($result) {
$result | Out-GridView -Title "AD security Audit" -Wait
$result = $null
cls

}



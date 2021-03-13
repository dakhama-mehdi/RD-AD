#RD-AD (Requests-Detect on AD)

this script, help to detect, track and prevent in real time, the malicious request, attack, or collects information request from AD,  to protect valuable information like ( accounts admins, password, and GPO ...) from tools like BloodHound, Mimikatz....

They allow to easily read the events, convert GUID, and be notified with a action summary, use the whitelist to exclude the detection on specific servers or accounts.
you can edit it to send mail, block or disable account, .....

#About :

requests-detect AD : help to detect and monitor the AD, to give more security.

the script can be used on two way: 

First : add to event on task schedule, this way is very fast, but need an configuration.

Second : turn the script on loop, all X secondes, to check and generate alert, this way is slower that first way, but easy to configure.


# PREREQUISITE 

* enable AD DS audit object
* optional : create a folder to extract schema details, only one times
* create whitlist to exclude same account or machines 

# How to use :

* enable AD DS audit object

you can edit a default domain controllers pollicy or create a new GPO, and enable AD DS succezss and Faillure on 
"Computer Configuration\Windows Settings\Security Settings\Audit Policies\DS Access\Audit Directory Service Access"

* Create a folder 
create a folder to extract the object that you want to monitor, this step let the detection very fast
by defaut i use the folder test in C:\test, but you can change this value on $dbpath

* create exclude csv file
you can use get-adgroupmember or get-adcomputer to create a list that contains only the name of object that you want to exclude from detection, like DC or same server that need to query the schema, also the admin account work on AD

it is preferead to put whitelist in same folder as our path export $dbpath

Now pre-requist is respected, We suggere to run the script the first time with right admin to create a list object to monitor.


# Run the script

we have two way to do start detection, by use Scheduletask or run loop script

* USE Scheduletask

if the script is executed on first time without error, go to event security and attach the event 4662 to our script, the script must be start with powershell, you can use this settings on Action tabs :

Program : Powershell.exe
ADD arguments : -WindowStyle Hidden -file your-path\DR-AD-direct.ps1
then run the script with highest privileges

* Use loop Script

you must only run the script DR-AD-loop.ps1, on your ISE with admin rights, you can convert it to exe or service if you want

* trying now detection or attack

Try to luanch a bloodhound or another tools request, and check the detection

* disable account and edit script

you can disable AD-account, or block it ... if you want, for this enable this variable at line 133 #Disable-ADAccount $user1

you can also edit the script to send an mail .....

# Thanks  :

i would like to thank some leader french community, for their advice, hepful and contribution

DEMAN-BARCELO Thierry : leader french MCP community infra, exchange and Microsoft 365

Cortes Sylvain  : leaders french cybersecurity Active Directory

Veirman Loic  : Consultant, expert expert Active Directory (Hardening, defensive)

Baudin Nicolas : Expert Powershell

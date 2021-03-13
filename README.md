# RD-AD (Requests-Detect on AD)

This script, helps to detect, tracks and prevents in real time, the malicious requests, attacks, or collect information requests from AD,  to protect valuable information like ( accounts admins, password, and GPO ...) from tools like BloodHound, Mimikatz....

They allow to easily read the events, convert GUID, and be notified with a action summary, use the whitelist to exclude the detection on specific servers or accounts.
you can edit it to send mail, block or disable account, .....

![RD-AD](https://user-images.githubusercontent.com/49924401/111032743-04362d00-840e-11eb-866d-8420ccfb9d85.gif)

# About :

requests-detect AD : helps to detect and monitor the AD, to give more security

the script can be used on two way: 

First : adding an event in task schedule, this way is very fast, but needs an configuration.

Second : turning the script on loop, all X secondes, to check and generate alert, this way is slower than the first way, but easier to configure.


# PREREQUISITE 

* enable AD DS audit object
* optional : create a folder to extract schema details, only one times
* create a whitelist to exclude same account or machines 

# How to use :

* Enable AD DS audit object

you can edit the default domain controller policy or create a new GPO, and enable AD DS success and Failure on  
"Computer Configuration\Windows Settings\Security Settings\Audit Policies\DS Access\Audit Directory Service Access"

* Create a folder 
Create a folder to extract the object that you want to monitor, this step let the detection very fast
by defaut i use the folder test in C:\test, but you can change this value on $dbpath

* Create exclude csv file
You can use get-adgroupmember or get-adcomputer to create a list that contains only the name of object that you want to exclude from detection, like DC or same server that need to query the schema, also the admin account work on AD

* Note 
it is preferead to put whitelist in same folder as our path export $dbpath

Now pre-requist is respected, We suggere to run the script the first time with right admin to create a list object to monitor.


# Run the script

We have two way to start detection, by using Scheduletask or running a loop script

* USING Scheduletask

If the script is executed at first time without error, go to event security and attach the event 4662 to our script, the script must be start with powershell, you can use this settings on Action tabs :

Program : Powershell.exe
ADD arguments : -WindowStyle Hidden -file your-path\DR-AD-direct.ps1
then run the script with highest privileges

* RUNNING a loop Script

you must only run the script DR-AD-loop.ps1, on your ISE with admin rights, you can convert it to exe or service if you want

* trying now detection or attack

Try to launch a bloodhound or another tool request, and check the detection

* disable account and edit script

you can disable AD-account, or block it ... if you want, to enable that, the variable is at line 133 #Disable-ADAccount $user1

you can also edit the script to send an email .....

you can edit the object to filter at line 28, add only the same filter distinguishedname like (GPO, or Passwords, or Admins account)

# Thanks  :

I would like to thank some leader french community, for their advices, helps and contributions

DEMAN-BARCELO Thierry : leader french MVP community expert (infra, exchange and Microsoft 365)

Cortes Sylvain  : leaders french cybersecurity Active Directory

Veirman Loic  : Consultant, expert Active Directory (Hardening, defensive)

Baudin Nicolas : Expert Powershell

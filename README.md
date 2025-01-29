# RD-AD (Requests-Detect on AD) 

This script will help you to detect, prevent and protect your Active Directory against malicious request, on-going penetration and discovering data collect in a nearly real-time manner. Valuable information like Administrator accounts, password hashes, GPO will be protected more efficiently against known toolkit used by hackers and security teams (BloodHound, Mimikatz, ...). 

While reading the events log pool, the script search for specific event and notify you with an action summary in a human readable format (GUID are converted). You can also customize it with white-lists (server or account exclusion) and set it up to send you an email, automatically block or disable a suspicious account, ...

![RD-AD](https://user-images.githubusercontent.com/49924401/111032743-04362d00-840e-11eb-866d-8420ccfb9d85.gif)

# About :

requests-detect AD : Monitor Active Directory to enhance your security footprint

This script can be used by either:
- Using the TaskScheduler to monitor for a specific event ID and run the script upon it ; this is the fastest way to go but needs some extra efforts.
- Let the script run in an infinite loop, which is the simplest way to use it with the cost of a slower processing.

# PREREQUISITE 

* ADDS Audit for Object should be enabled
* Schema Data to be added in a folder for referal (optional)
* White-list with computer/user objects to exclude 

# How to use :

1. To enable ADDS Audit for Object:
--> Create a GPO and link it to the Domain Controllers container.
--> Go to "Computer Configuration\Windows Settings\Security Settings\Audit Policies\DS Access\Audit Directory Service Access" and enable the option for success and failure

2. Running the Script Properly. 
Run the script as an administrator DR-ad-loop.ps1 or schedule DR-ad.ps1 as a task triggered by Event 4662.
The script will automatically create the required files in C:\Temp:
A whitelist file to exclude admin accounts.
An array file to extract sensitive schema objects.


* Video How to use
https://youtu.be/8svJT7lL3W4
* Note 
it is preferead to put whitelist in same folder as our path export $dbpath

Now pre-requist is respected, We suggere to run the script the first time with right admin to create a list object to monitor.


# Run the script

Using TaskScheduler:
Create a new Task and set the schedule to act on event detection. Then, add event ID 4662 as trigger and add as command line "Powershell.exe" ; arguments should be "-WindowStyle Hidden -file your-path\DR-AD-direct.ps1". Before closing, set the schedule to run as System and activate the option "run the script with highest privileges".

Using a script loop:
fire-up Powershell.exe in an elevated Shell, then run the script "DR-AD-loop.ps1".

Ensuring scripts functionnality:
You can ensure the script is properly working by running a BloodHound request, or any other tools.

Disabling Account automatically:
Edit the script and move toward line 133: remove the comment sign ("#") at the beginning of #Disable-ADAccount $user1

you can also edit the script to send an email .....

you can edit the object to filter at line 28, add only the same filter distinguishedname like (GPO, or Passwords, or Admins account)

# Thanks  :

I would like to thank some leader french community, for their advices, helps and contributions

DEMAN-BARCELO Thierry : leader french MVP community expert (infra, exchange and Microsoft 365)

Cortes Sylvain  : leaders french cybersecurity Active Directory

Veirman Loic  : Consultant, expert Active Directory (Hardening, defensive)

Baudin Nicolas : Expert Powershell

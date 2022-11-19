# **Archived Project Warning:** This project is archived  
After zero updates in five years, this respository is being archived. If ShareFile offers a free developer subscription, please let me know! If that becomes the case, then I would be happy to continue exploring work on this repository!  

# Sharefile PowerShell Scripts
Scripts in this area are meant to provide Citrix ShareFile Administrators a way to better manage their
Citrix Sharefile environment. 

You can learn more about Sharefile by visiting [here](https://www.sharefile.com). 

## Getting Started... 
To use these scripts, you will need access to a Sharefile account with administrative rights and permissions to run 
PowerShell on your workstation.
Also, you will need the [ShareFile PowerShell SDK](https://github.com/citrix/ShareFile-PowerShell) to 
access the [ShareFile API](http://api.sharefile.com/rest/).

Grab the latest version of the PowerShell SDK by clicking [here](https://github.com/citrix/ShareFile-PowerShell/releases)

Once the ShareFile PowerShell SDK is installed, you can use it by simply launching PowerShell and using this command:

    Add-PSSnapIn ShareFile

For a more exhaustive guide, visit the ShareFile wiki by clicking [here](https://github.com/citrix/ShareFile-PowerShell/wiki/Getting-Started).

## The Functions
[**Set-SFPassword**](https://github.com/jstrong013/ShareFile/blob/master/Set-SFPassword.ps1) - Sets an employee's password to a new value provided.
    
	Set-SFPassword -Identity jstrong013@users.noreply.github.com -NewPassword 'P@ssw0rdThatMeetsOrgRequirements'

[**Send-SFWelcomeNotification**](https://github.com/jstrong013/ShareFile/blob/master/Send-SFWelcomeNotification.ps1) - Sends a welcome notification to
a specified ShareFile account.

    Send-SFWelcomeNotification -email jstrong013@users.noreply.github.com
	Send-SFWelcomeNotification -email jstrong013@users.noreply.github.com -welcomeMessage 'Hello' -employeeAccount
	
[**Remove-SFUser**](../master/Remove-SFUser.ps1) - Removes a ShareFile Account and optionally reasigns data to another ShareFile employee account. 

    Remove-SFUser -email jstrong013@users.noreply.github.com 
	Remove-SFUser -email jstrong013@users.noreply.github.com -reassignEmail sharefileEmployeeAccount@example.com 

	
## A quick note on licensing... 
All ShareFile PowerShell scripts are released under the [MIT license](https://github.com/jstrong013/ShareFile/blob/master/LICENSE.txt) unless otherwise 
noted.

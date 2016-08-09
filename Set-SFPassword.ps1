<#
.Synopsis
   Sets the Sharefile Password for an employee account.
.DESCRIPTION
   The Set-SFPassword gets an Employee (not a client) account and sets a new password for the account. 
   The function will prompt for ShareFile credentials to perform the action. The account credentials provided 
   in the prompt must be a ShareFile Administrator account for the Employee account to have the new password value set.  
   
   The Identity parameter specifies the ShareFile Employee account to have their password reset. 
   
   The password is set to the value specified in the NewPassword parameter. The password must pass the complexity requirements 
   defined by the ShareFile organization account.
    
.EXAMPLE
   ---------------------------------- EXAMPLE 1 ----------------------------------------------------------

   C:\PS>Set-SFPassword -Identity jstrong013@users.noreply.github.com -NewPassword 'P@ssw0rdThatMeetsOrgRequirements'

   Description 

   -----------

   The ShareFile Employee account associated with jstrong013@users.noreply.github.com will have their password set to P@ssw0rdThatMeetsOrgRequirements

#>
function Set-SFPassword
{
    [CmdletBinding()]
    Param
    (
        # Specifies a ShareFile employee object by providing the email address of the employee.
        #   Email
        #   Example: jstrong013@users.noreply.github.com 
        [Parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Identity,

        # Specifies the new password value.
        #   Password must fullfill the requirements on password construction as defined by the Organization Sharefile Account.
        [Parameter(Mandatory=$true)]
        [Alias("Password","PW")]
        [ValidateNotNullOrEmpty()]
        [string]
        $NewPassword
    )

    Begin
    {
        # Need the ShareFile Snapin
        Add-PSSnapin ShareFile -ErrorAction Stop   
        $sfClient = New-SfClient -Name $env:TEMP\sfclient.sfps
    }
    Process
    {
        # Grab the Sharefile employee account
        $employee = Send-SfRequest -Client $sfClient -Method GET -Entity Accounts\Employees | Where-Object { $PSItem.Email -match $Identity }
        
        # Verify that we have the appropriate # of accounts.
        if ($Identity.Count -ne $employee.Count ) {
            Write-Error "Sharefile Account $identity could not be located or multiple employee accounts exist. Script ending... " 
            exit 13
        }

        # Grab the indvidual user account of the employee
        # http://api.sharefile.com/rest/docs/resource.aspx?name=Users 
        $user = Send-SfRequest -Client $sfClient -Entity Users -Id $employee.Id

        # Generate json to reset password - see API documentation for exact syntax (in case of changes)     
        $json = @{"NewPassword"= "$NewPassword"} | ConvertTo-Json 

        # Must be a ShareFile Administrator to issue this call (to only include the new password & not provide the old password) 
        # Reset password on employee
        send-SfRequest -Client $sfClient -Method POST -Entity Users -Id $user.Id -Navigation ResetPassword -BodyText $json | Out-Null
        Write-Verbose -Message "Sharefile password for account $Identity has been reset to $Password"
    }
    End
    {
        Remove-Item -Path $env:TEMP\sfclient.sfps -Force
        Remove-PSSnapin ShareFile -ErrorAction SilentlyContinue
    }
} # End Set-SFPassword
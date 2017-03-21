<#
 .Synopsis
    Resends the ShareFile welcome email to the specified user

 .DESCRIPTION
    The Send-SFWelcomeNotification cmdlet will resend the ShareFile welcome message to an existing ShareFile user.

    The user must exist in order to send the ShareFile welcome message otherwise an error will be prompted. 

    You may specify to send the Welcome message to an employee account or a client account. By default, the cmdlet 
    sends a welcome notification to a ShareFile client account. 

 .PARAMETERS
    -Email <String[]> 
        Specifies the email account or accounts you wish to send a Welcome notification. Must be in the format of 
        myemail@domain.com. If not in the appropriate email pattern, the parameter will not be accepted (e.g. 'notanemail'
        would not be a valid email).
    
    -WelcomeMessage <String> 
        Specifies a welcome message to add to the welcome notification. 

    -EmployeeAccount [<SwitchParameter>] 
        Indicates that the given account is a ShareFile employee Account to send the welcome notification to an employee. 

        By default, the welcome notification is only sent to client accounts. 

 .EXAMPLE
    ---------------------------------- EXAMPLE 1 ----------------------------------------------------------
   
   C:\PS>Send-SFWelcomeNotification -email jstrong013@users.noreply.github.com
   
   Description 
   -----------

   The ShareFile client account associated with jstrong013@users.noreply.github.com will have a welcome email sent to them

 .EXAMPLE
    ---------------------------------- EXAMPLE 2 ----------------------------------------------------------
   
   C:\PS>Send-SFWelcomeNotification -email jstrong013@users.noreply.github.com -employeeAccount
   
   Description 
   -----------

   The ShareFile employee account associated with jstrong013@users.noreply.github.com will have a welcome email sent to them

 .EXAMPLE
    ---------------------------------- EXAMPLE 3 ----------------------------------------------------------
   
   C:\PS>Send-SFWelcomeNotification -email jstrong013@users.noreply.github.com -welcomeMessage 'Welcome to
   secure file sharing'
   
   Description 
   -----------

   The ShareFile client account associated with jstrong013@users.noreply.github.com will have a welcome email sent to them 
   with a custom message "Welcome to secure file sharing" 
 
 .EXAMPLE
    ---------------------------------- EXAMPLE 4 ----------------------------------------------------------
   
   C:\PS> jstrong013@users.noreply.github.com | Send-SFWelcomeNotification
   
   Description 
   -----------

   The ShareFile client account associated with jstrong013@users.noreply.github.com will have a welcome email sent to them
 #>
 function Send-SFWelcomeNotification {

     [CmdletBinding()]
     Param (
         # email The email associated with ShareFile account
         [Parameter(Mandatory=$true,
                    ValueFromPipeline=$true,
                    Position=0)]
         [ValidateNotNullOrEmpty()]
         [ValidatePattern("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")]
         [string[]]$email,
 
         # WelcomeMessage an optional value to specify a custom message to the user when sending the welcome email.
         [String] $welcomeMessage,

         # employeeAccount A switch if the account is an employee ShareFile account
         [switch] $employeeAccount
     )
 
     Begin {
        try {
            Add-PSSnapin ShareFile -ErrorAction Stop
        }
        catch {
            Write-Error -Message "ShareFile Snapin is required. Welcome notification not sent." 
            Return
        }

        try {

            $sfClient = New-SfClient -Name "$env:TEMP\sfClient.sfps" -ErrorAction Stop
        }
        catch {
            Write-Error -Message "Unable to retrieve ShareFile Credentials to run commands. Exiting..." 
            Exit 13
        }
     }
     Process {
        
        foreach ($identity in $email) {

           
           if (!$employeeAccount) {
                $client = Send-SfRequest -Client $sfClient -Entity Accounts\Clients -Method GET | Where-Object { $PSItem.Email -match $identity } 

                if ($client -and $client.Count -eq 1) {
                    Send-SfRequest -Client $sfClient -Entity Users -Method POST -Id $client.Id -Navigation ResendWelcome -Parameters @{ "customMessage" = "$welcomeMessage" }
                    Write-Verbose -Message "Welcome Message sent to $($client.Name) at email address $($client.Email) with message '$($welcomeMessage)'"
                }
                else {
                    Write-Error -Message "Welcome message failed to send for $email." -RecommendedAction "Check if ShareFile Account exists or verify it is a client account."
                }

           }


           if ($employeeAccount) {
                $employee = Send-SfRequest -Client $sfClient -Entity Accounts\Employees -Method GET | Where-Object { $PSItem.Email -match $identity }

                if ($employee -and $employee.Count -eq 1) {
                    Send-SfRequest -Client $sfClient -Entity Users -Method POST -Id $employee.Id -Navigation ResendWelcome -Parameters @{ "customMessage" = "$welcomeMessage" }
                    Write-Verbose -Message "Welcome Message sent to $($employee.Name) at email address $($employee.Email) with message '$($welcomeMessage)'" 
                }
                else {
                    Write-Error -Message "Welcome message failed to send for $email." -RecommendedAction "Check if ShareFile Account exists or verify it is an Employee account."
                }

           }
        } # end forEach

     }
     End {
        # Remove stored Client Credentials
        if (Test-Path "$env:Temp\sfclient.sfps") {
            Remove-Item -Path "$env:TEMP\sfclient.sfps" -Force
        }
     }
 } # End Send-SFWelcomeNotification
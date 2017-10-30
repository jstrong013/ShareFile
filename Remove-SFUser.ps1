Function Remove-SFUser{

    [cmdletbinding(
    SupportsShouldProcess=$true,
    ConfirmImpact = 'High')]
    Param (  
        # Email of the ShareFile account you want to remove
        [Parameter(Mandatory=$true)]
        [alias("mail")] 
        [validatenotnullorempty()]
        [ValidatePattern("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")]
        [string[]]$Email,

        # Email of the ShareFile account to reassign the data of the removed account provided in the Email parameter
        [ValidatePattern("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")]
        [Alias("AssignTo","ItemsReassignTo")]
        [string]$ReassignEmail,

        [ValidateScript( { Test-Path $_ -PathType Leaf } )]
        [string]$Client
    )

    
    begin {


        try {
            Add-PSSnapin ShareFile -ErrorAction Stop
            # Check if credentials are being provided
            if ($Client) {
                $sfClient = Get-SfClient -Name $Client -ErrorAction Stop
                Write-Verbose "Credentials obtained at path: $client" 
            }
            else {
                #Credential path not provided, prompt for ShareFile credentials
                $sfClient = New-SfClient -Name "$env:TEMP\sfClient.sfps" -ErrorAction Stop
            }
        }
        catch { 
            Write-Error "Unable to load ShareFile Snapin or get ShareFile credentials"
            if ( -not $Client) {
                Remove-Item $sfClient.Path -Force 
            }
            Remove-PSSnapin ShareFile 
            exit
        }
    
        # Check if a reassignment email was specified for data to be assigned - Not a Pipeline Parameter
        try {
            #Find account associated to the email address that is to be fully removed   
            $sfUserAssign = Send-SfRequest -Client $sfClient -Method GET -Entity Users -Parameters @{"EmailAddress"="$reassignEmail"} -ErrorAction Stop
        }
        catch {
            Write-Error "Unable to find ShareFile Account for data assignment"
            if ( -not $Client) {
                Remove-Item $sfClient.Path -Force
            }
            Remove-PSSnapin ShareFile
            exit
        }

    }#end Begin block

    process {

        foreach ($address in $email) {
            try {
                # Locate ShareFile account to be fully removed via email address
                $sfUserTerm = Send-SfRequest -Client $sfClient -Method GET -Entity Users -Parameters @{"EmailAddress"="$address"} -ErrorAction Stop
            }
            catch {
                Write-Error "Unable to remove $address"
                return
            }
            # If item reassignment specified and confirmation to fully remove from ShareFile, then delete SF User
            if ($sfUserAssign -and $PSCmdlet.ShouldProcess($($sfUserTerm.FullName),"Complete removal of ShareFile Account and data reassignment to $($sfUserAssign.FullName)")) {
                    # ShareFile handles the error if attempting to assign to Client User - Can only Assign to an Employee Account    
                    Send-SfRequest -Client $sfClient -Method DELETE -Uri $sfUserTerm.url.AbsoluteUri -Parameters @{"Completely"="True";"itemsReassignTo"="$($sfUserAssign.Id)"}
                    Write-Verbose -Message "ShareFile account associated with email address $email has been completely removed from ShareFile and contents assigned to Employee associated with email $reassignEmail"
                }
            # No reassignment of items - just remove ShareFile User
            else {
                # confirm the removal of the shareFile User
                if($PSCmdlet.ShouldProcess("Performing removal operation of $($sfUserTerm.FullName) from ShareFile completely")) {
                    Send-SfRequest -Client $sfClient -Method DELETE -Uri $sfUserTerm.url.AbsoluteUri -Parameters @{"Completely"="True"}
                    Write-Verbose -Message "Client associated with email address $email has been removed completely from ShareFile"
                }
            }
            
       }#foreach  
    }#end Process block

    end {
        #Clean Up (delete cred file if created above)
        if ( -not $client) { 
            Remove-Item -Path $sfClient.Path -Force
        }
        Remove-PSSnapin ShareFile
        Write-Verbose "ShareFile credentials removed local machine"
    }# end End block

} #end Remove-SFUser
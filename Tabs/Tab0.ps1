#-----------------------------------------------
#Functions for Username
#-----------------------------------------------
Function CleanUpText {
param($text)
    $finaltext = $text -replace "`n",""
    return $finaltext.Trim()
}


Function Get-CUDetails {
param($name, $type)
    #Show all returned values in array instead of just first 3 or 4 (this is needed for fields such as AcceptMessagesOnlyFrom that have more than 4 variables
    $script:FormatEnumerationLimit = -1    

    #Individual Users Email
    if($type -eq "UserMailbox"){
        $InfoDirty = Get-ADUser -Identity $name -Properties * | Select DisplayName, mail, otherMailbox, Title, Created, LastLogonDate, PasswordExpired, PasswordLastSet, LastBadPasswordAttempt, BadPWDCount, LockedOut | Format-list | Out-String -Width 300
        $UserInfo = CleanupText -text $InfoDirty        
        return $Userinfo
    }
    #Distribution Group Email
    elseif($type -eq "MailUniversalDistributionGroup"){        
        $InfoDirty = Get-CLDistributionGroup -Identity $name | Select Identity, PrimarySMTPAddress, IsDirSynced, ManagedBy, AcceptMessagesOnlyFrom, AcceptMessagesOnlyFromDLMembers, AcceptMessagesOnlyFromSendersOrMembers, WhenCreated | Out-String -Width 300
        $DGInfo = CleanupText -text $InfoDirty        
        return $DGInfo
    }
    #SharedMailbox Group
    elseif($type -eq "SharedMailbox"){
        $InfoDirty = Get-CLMailbox -Identity $name | Select UserPrincipalName, DisplayName, GrantSendOnBehalfTo, WhenCreated, RecipientTypeDetails | Format-List | Out-String
        $SharedInfo = CleanupText -text $InfoDirty        
        return $SharedInfo
    }
    #Rooms (Usually Calendar only status for these)
    elseif($type -eq "RoomMailbox"){
        $InfoDirty = Get-CLMailbox -Identity $name | Select UserPrincipalName, DisplayName, WhenCreated, RecipientTypeDetails | Format-List | Out-String
        $RoomInfo = CleanupText -text $InfoDirty        
        return $RoomInfo

    }
    #Anything else? Supposed to only be list.up.edu contacts
    elseif($type -eq "MailContact"){
        $InfoDirty = Get-CLMailContact -Identity $name | Select DisplayName, PrimarySMTPAddress | Format-List | Out-String
        $CleanInfo = CleanUpText -text $InfoDirty
        $MailContactInfo = "This mailbox cannot be edited by this tool, please see admin for further instructions`n`n" + $CleanInfo
        return $MailContactInfo
    }
    elseif($type -eq "MailUniversalSecurityGroup"){
        $InfoDirty = Get-CLDistributionGroup -Identity $name | Select Identity, PrimarySMTPAddress, IsDirSynced, ManagedBy, AcceptMessagesOnlyFrom, AcceptMessagesOnlyFromDLMembers, AcceptMessagesOnlyFromSendersOrMembers, WhenCreated | Out-String -Width 300
        $SecurityGroupInfo = CleanUpText -text $InfoDirty        
        return $SecurityGroupInfo
        
    }
    #What are you trying to edit? I don't know what you're trying to do...
    else{
        $errormessage = "Not supported. Please see admin for more information`n`nMailbox Recipient Type isn't a sharedmailbox, user, dg, room, or mailcontact"
        return $errormessage
    }
}
#-----------------------------------------------
#Functions that effect other Gui elements
#-----------------------------------------------
Function Set-TypeTextblock{
param($type)
    $WPFCUType_Textblock.Visibility = "Visible"    
    if($type -eq "UserMailbox"){$WPFCUType_Textblock.Text = "User Mailbox"}
    elseif($type -eq "MailUniversalDistributionGroup"){$WPFCUType_Textblock.Text = "Distribution Group"}
    elseif($type -eq "MailUniversalSecurityGroup"){$WPFCUType_Textblock.Text = "Security Group"}
    elseif($type -eq "SharedMailbox"){$WPFCUType_Textblock.Text = "Shared Mailbox"}
    elseif($type -eq "RoomMailbox"){$WPFCUType_Textblock.Text = "Room Mailbox"}
    elseif($type -eq "MailContact"){$WPFCUType_Textblock.Text = "List.UP.Edu"}
    else{$WPFCUType_Textblock.Text = "Unknown"}
}

#-----------------------------------------------
#Check Username Tab Event Handlers
#-----------------------------------------------

#$stopwatch = [system.diagnostics.stopwatch]::StartNew()
#$a=-1500

#A bad Autocomplete
#$WPFCUName_TextBox.Add_TextChanged({
#    $DifferenceSeconds = $stopwatch.elapsedmilliseconds-$a
#    if($WPFCUName_TextBox.Text.Length -gt 2 -and $DifferenceSeconds -gt 1500){
#        $WPFCUUsername_ListBox.Visibility = "Visible"
#        $Recipients = @(Get-Recipient -Anr $WPFCUName_TextBox.Text -ResultSize 15 | Select DisplayName, Identity, RecipientTypeDetails)
#        $WPFCUUsername_ListBox.ItemsSource = $Recipients
#        $script:a = $stopwatch.elapsedmilliseconds
#    }
#})

$WPFCUSearch_Button.Add_Click({
    $WPFCUUsername_ListBox.Visibility = "Visible"
    $Recipients = @(Get-CLRecipient -Anr $WPFCUName_TextBox.Text -ResultSize 15 | Select DisplayName, Identity, RecipientTypeDetails)
    $WPFCUUsername_ListBox.ItemsSource = $Recipients    
})

$WPFCUUsername_ListBox.Add_MouseDoubleClick({
    $username = $WPFCUUsername_ListBox.SelectedItem.Identity
    $type = $WPFCUUsername_ListBox.SelectedItem.RecipientTypeDetails
    $WPFCUName_TextBox.Text = $username
    $Details = Get-CUDetails -name $username -type $type
    $WPFCUDetails_TextBox.Text = $Details
    Set-TypeTextblock -type $type  
})


#This only did MSOLUsers - didn't get all the different types of mailboxes
#$WPFCUName_TextBox.Add_TextChanged({
#write-host $stopwatch.ElapsedMilliseconds
#    $DifferenceSeconds = $stopwatch.elapsedmilliseconds-$a
    #if($WPFCUName_TextBox.Text.Length -gt 2 -and $DifferenceSeconds -gt 1)
#    if($DifferenceSeconds -gt 750){
#        $PossibleUsers = @(Get-MSOLUser -SearchString $WPFCUName_TextBox.Text -MaxResults 10)    
#        $WPFCUUsername_ListBox.ItemsSource = $PossibleUsers
#        $script:a = $stopwatch.elapsedmilliseconds
#        }
#})




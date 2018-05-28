#------------------------------------------------------------------------
#DISTRIBUTION GROUPS - Tab 4
#------------------------------------------------------------------------

#----------------------------------
#tab 4 functions
#-----------------------------------

#Changes CanonicalName to just plain username - easier to read listviews
Function Get-UsernameFromCanonical{
param($usernameRaw)
    if($usernameRaw -eq $null){
        return $usernameRaw
    }
    else{
        $usernameRaw = $usernameRaw | out-string
        $indexnow = $usernameRaw.IndexOf("/")                
        while($indexnow -ge 0){
            $indexnow = $usernameRaw.IndexOf("/", $index+1)
            if($indexnow -ge 0){$index = $indexnow}            
        }        
        #$OnlyUsername = $usernameRaw.subString(($usernameRaw.IndexOf("/", 14)+1))
        $OnlyUsername = $usernameRaw.Substring($index+1)
        return $OnlyUsername.trim()
    }
}

#Change username to canonicalname e.g: campus.up.edu/blah/blah/username
Function Get-CanonicalName {
param($name)
    $recipient = Get-OPRecipient -Identity $name
    $canon = $recipient.identity
    return $canon
}

Function Get-DistGroupMembers{
param($name, $type)
    if($type -eq "ADDG" -or $type -eq "ADSecurityGroup"){
        return Get-OPDistributionGroupMember -Identity $name
    }
    elseif($type -eq "CloudDG"){
        return Get-CLDistributionGroupMember -Identity $name
    }    
}

Function Remove-DGMembers{
param($name, $member, $type)
    if($type -eq "ADSecurityGroup"){
        $DG = Get-OPDistributionGroup -Identity $name
        $realname = $DG.name
        $membername = Get-UsernameFromCanonical -usernameRaw $member
        Remove-ADGroupMember -Identity $realname -Members $membername -Confirm:$false
    }
    if($type -eq "ADDG"){
        Remove-OPDistributionGroupMember -Identity $name -Member $member -Confirm:$false        
    }
    elseif($type -eq "CloudDG"){
        Remove-CLDistributionGroupMember -Identity $name -Member $member -Confirm:$false
    }
}

Function Add-DGMembers{
param($name, $member, $type)
    if($type -eq "ADSecurityGroup"){
        $DG = Get-OPDistributionGroup -Identity $name
        $realname = $DG.name        
        Add-ADGroupMember -Identity $realname -Members $member
    }
    elseif($type -eq "ADDG"){
        Add-OPDistributionGroupMember -Identity $name -Member $member
    }
    elseif($type -eq "CloudDG"){
        Add-CLDistributionGroupMember -Identity $name -Member $member
    }
}

Function Get-DGApprovedSenders{
param($name, $type)
    if($type -eq "ADDG" -or $type -eq "ADSecurityGroup"){        
        $distgroupinfo = Get-OPDistributionGroup -Identity $name        
        $ApprovedSenders = $distgroupinfo.AcceptMessagesOnlyFromSendersOrMembers | % {Get-UsernameFromCanonical -usernameRaw $_}
        return $ApprovedSenders
    }
    elseif($type -eq "CloudDG"){
        $distgroupinfo = Get-CLDistributionGroup -Identity $name    
        return $distgroupinfo.AcceptMessagesOnlyFromSendersOrMembers
    }    
}

Function Get-DGOwners{
param($name, $type)
    if($type -eq "ADDG" -or $type -eq "ADSecurityGroup"){
        $distgroupinfo = Get-OPDistributionGroup -Identity $name
        $Owners = $distgroupinfo.Managedby | % {Get-UsernameFromCanonical -usernameRaw $_}
        return $Owners
    }
    elseif($type -eq "CloudDG"){
        $distgroupinfo = Get-CLDistributionGroup -Identity $name    
        return $distgroupinfo.Managedby
    }        
}

Function Remove-DGOwners{
param($name, $OwnerstoRemove, $type)
    $CurrentOwnersArray = @()
    $FinalOwnersArray = @()

    if($type -eq "ADDG" -or $type -eq "ADSecurityGroup"){
        $DG = Get-OPDistributionGroup -Identity $name
        $CurrentOwners = $DG.Managedby
        $CurrentOwnersArray = $CurrentOwners | % {$_}
        $CanonOwnerstoRemove = Get-CanonicalName -name $OwnerstoRemove.trim()        
        $FinalOwnersArray = $CurrentOwnersArray | % {if ($CanonOwnerstoRemove -notcontains $_){$_}}
        Set-OPDistributionGroup -Identity $name -ManagedBy $FinalOwnersArray
    }
    elseif($type -eq "CloudDG"){
        $DG = Get-CLDistributionGroup -Identity $name
        $CurrentOwners = $DG.Managedby
        $CurrentOwnersArray = $CurrentOwners | % {$_}
        $FinalOwnersArray = $CurrentOwnersArray | % {if ($OwnerstoRemove -notcontains $_){$_}}
        Set-CLDistributionGroup -Identity $name -ManagedBy $FinalOwnersArray
    }
}

Function Add-DGOwner{
param($name, $OwnertoAdd, $type)
    $FinalOwnerList = @()
    if($type -eq "ADSecurityGroup"){
        $DG = Get-OPDistributionGroup -Identity $name       
        $realname = $DG.name #AD can be picky        
        $NewOwner = Get-AdUser -Identity $OwnertoAdd
        $NewOwnerDN = $NewOwner.DistinguishedName
        Set-ADGroup -Identity $realname -ManagedBy $NewOwnerDN
    }
    elseif($type -eq "ADDG"){
        $DG = Get-OPDistributionGroup -Identity $name
        $CurrentOwners = $DG.Managedby        

        $CanonOwnerstoAdd = Get-CanonicalName -name $OwnertoAdd
        $FinalOwnerList = $CurrentOwners += $CanonOwnerstoAdd
        Set-OPDistributionGroup -Identity $name -ManagedBy $FinalOwnerList
    }
    elseif($type -eq "CloudDG"){
        $DG = Get-CLDistributionGroup -Identity $name
        $Currentowners = $DG.ManagedBy

        $FinalOwnerList = $CurrentOwners += $OwnertoAdd
        Set-CLDistributionGroup -Identity $name -ManagedBy $FinalOwnerList
    }
}

Function Remove-DGSender{
param($name, $SenderstoRemove, $type)
    $FinalSenderList = @()    
    if($type -eq "ADDG" -or $type -eq "ADSecurityGroup"){
        $DG = Get-OPDistributionGroup -Identity $name
        $CurrentSenders = $DG.AcceptMessagesOnlyFromSendersOrMembers        
        $CanonSenderstoRemove = Get-CanonicalName -name $SenderstoRemove.trim()        
        $FinalSenderList = $CurrentSenders | % {if ($CanonSenderstoRemove -notcontains $_){$_}}
        Set-OPDistributionGroup -Identity $name -AcceptMessagesOnlyFromSendersOrMembers $FinalSenderList
    }
    elseif($type -eq "CloudDG"){
        $DG = Get-CLDistributionGroup -Identity $name    
        $CurrentSenders = $DG.AcceptMessagesOnlyFromSendersOrMembers
        $FinalSenderList = $CurrentSenders | % {if ($SenderstoRemove -notmatch $_){$_}}                
        Set-CLDistributionGroup -Identity $name -AcceptMessagesOnlyFromSendersOrMembers $FinalSenderList
    }    
}

Function Add-DGSender{
param($name, $SendertoAdd, $type)
    $FinalSenderList = @()
    if($type -eq "ADDG" -or $type -eq "ADSecurityGroup"){
        $DG = Get-OPDistributionGroup -Identity $name
        $CurrentSenders = $DG.AcceptMessagesOnlyFromSendersOrMembers        
        $CanonSenderstoAdd = Get-CanonicalName -name $SendertoAdd.trim()        
        $FinalSendersList = $CurrentSenders += $CanonSenderstoAdd
        Set-OPDistributionGroup -Identity $name -AcceptMessagesOnlyFromSendersOrMembers $FinalSendersList
    }
    elseif($type -eq "CloudDG"){
        $DG = Get-CLDistributionGroup -Identity $name
        $CurrentSenders = $DG.AcceptMessagesOnlyFromSendersOrMembers
        $FinalSenderList = $CurrentSenders += $SendertoAdd        
        Set-CLDistributionGroup -Identity $name -AcceptMessagesOnlyFromSendersOrMembers $FinalSenderList
    }
}

Function Get-DGRecipientType{
param($name)
    $ADSecurityGroup = "ADSecurityGroup"
    $CloudDG = "CloudDG"
    $ADDG = "ADDG"

    $DG = Get-CLDistributionGroup -Identity $name
    $isAD = $DG.isDirSynced #return true for AD only
    $TypeofGroup = $DG.RecipientTypeDetails

    if(($isAD -eq $true) -and ($TypeofGroup -eq "MailUniversalSecurityGroup")){
        return $ADSecurityGroup
    }
    elseif(($isAD -eq $true) -and ($TypeofGroup -eq "MailUniversalDistributionGroup")){
        return $ADDG
    }
    elseif(($isAD -eq $false) -and ($TypeofGroup -eq "MailUniversalDistributionGroup")){
        return $CloudDG
    }
    else{
        return "ERROR"
    }
 }

#-----
#tab4 other gui
#-----

Function Set-DGSyncLocationTextBlock {
param($Type)
    if ($Type -eq "ADDG"){
        $WPFDGAD_TextBlock.Visibility="Visible"
        $WPFDGCloud_TextBlock.Visibility="Hidden"
        $WPFDGADSecurityGroup_TextBlock.Visibility="Hidden"
        $WPFDGError_TextBlock.Visibility="Hidden"
    }
    elseif($Type -eq "CloudDG"){        
        $WPFDGAD_TextBlock.Visibility="Hidden"
        $WPFDGCloud_TextBlock.Visibility="Visible"
        $WPFDGADSecurityGroup_TextBlock.Visibility="Hidden"
        $WPFDGError_TextBlock.Visibility="Hidden"

    }
    elseif($Type -eq "ADSecurityGroup"){
        $WPFDGAD_TextBlock.Visibility="Hidden"
        $WPFDGCloud_TextBlock.Visibility="Hidden"
        $WPFDGADSecurityGroup_TextBlock.Visibility="Visible"
        $WPFDGError_TextBlock.Visibility="Hidden"

    }
    else{
        $WPFDGAD_TextBlock.Visibility="Hidden"
        $WPFDGCloud_TextBlock.Visibility="Hidden"
        $WPFDGADSecurityGroup_TextBlock.Visibility="Hidden"
        $WPFDGError_TextBlock.Visibility="Visible"
        }
}

 #------------------------------------------------------------------------
 #DISTRIBUTION GROUP TAB EVENTS - Tab4
 #------------------------------------------------------------------------
 $WPFDGView_Button.Add_Click({
    $WPFDGMembers_ListView.Items.Clear()
    $WPFDGSenders_ListView.Items.Clear()
    $WPFDGOwners_ListView.Items.Clear()
    #Set the sync locations so you use the correct commands
    $Type = Get-DGRecipientType -name $WPFDGName_Textbox.Text
    Set-DGSyncLocationTextBlock -Type $Type
    Get-DistGroupMembers -name $WPFDGName_Textbox.Text -type $type| % {$WPFDGMembers_ListView.AddChild($_)}
    Get-DGApprovedSenders -name $WPFDGName_Textbox.Text -type $type | % {$WPFDGSenders_ListView.AddChild($_)}
    #gets owners
    Get-DGOwners -name $WPFDGName_Textbox.Text -type $Type | % {$WPFDGOwners_ListView.AddChild($_)}
    if($type -eq "ADSecurityGroup"){$WPFDGRemoveOwner_Button.Visibility = "Hidden"}
    else{$WPFDGRemoveOwner_Button.Visibility = "Visible"}    
 })

 $WPFDGRemoveMember_Button.Add_Click({
    $type = Get-DGRecipientType -name $WPFDGName_TextBox.Text
    $WPFDGMembers_ListView.SelectedItems | % {Remove-DGMembers -name $WPFDGName_TextBox.Text -Member "$($_)" -type $type}
    $WPFDGMembers_ListView.Items.Clear()
    Get-DistGroupMembers -name $WPFDGName_Textbox.Text -type $type | % {$WPFDGMembers_ListView.AddChild($_)}
 })

 $WPFDGAddMember_Button.Add_Click({
    $type = Get-DGRecipientType -name $WPFDGName_TextBox.Text    
    Add-DGMembers -name $WPFDGName_TextBox.Text -Member $WPFDGUsernameAdd_TextBox.Text -type $type
    $WPFDGMembers_ListView.Items.Clear()
    Get-DistGroupMembers -name $WPFDGName_Textbox.Text -type $type | % {$WPFDGMembers_ListView.AddChild($_)}
 })

 $WPFDGRemoveSender_Button.Add_Click({    
    $type = Get-DGRecipientType -name $WPFDGName_Textbox.Text
    $SendertoString  = $WPFDGSenders_ListView.SelectedItems | out-string
    Remove-DGSender -name $WPFDGName_TextBox.Text -SenderstoRemove $SendertoString -type $type
    
    $WPFDGSenders_ListView.Items.Clear()
    Get-DGApprovedSenders -name $WPFDGName_Textbox.Text -type $type| % {$WPFDGSenders_ListView.AddChild($_)}
 })

 $WPFDGAddSender_Button.Add_Click({
    $type = Get-DGRecipientType -name $WPFDGName_Textbox.Text
    Add-DGSender -name $WPFDGName_Textbox.Text -SendertoAdd $WPFDGUsernameSend_TextBox.Text -type $type
    $WPFDGSenders_ListView.Items.Clear()
    Get-DGApprovedSenders -name $WPFDGName_Textbox.Text -type $type| % {$WPFDGSenders_ListView.AddChild($_)}
 })

 $WPFDGRemoveOwner_Button.Add_Click({
    $Selected = $WPFDGOwners_ListView.SelectedItems | out-string
    $type = Get-DGRecipientType -name $WPFDGName_Textbox.Text
    Remove-DGOwners -name $WPFDGName_TextBox.Text -OwnerstoRemove $Selected -type $type

    $WPFDGOwners_ListView.Items.Clear()
    Get-DGOwners -name $WPFDGName_Textbox.Text -type $type| % {$WPFDGOwners_ListView.AddChild($_)}
 })

 $WPFDGAddOwner_Button.Add_Click({
    $type = Get-DGRecipientType -name $WPFDGName_Textbox.Text
    Add-DGOwner -name $WPFDGName_Textbox.Text -OwnertoAdd $WPFDGAddOwner_TextBox.Text -type $type
    
    $WPFDGOwners_ListView.Items.Clear()
    Get-DGOwners -name $WPFDGName_Textbox.Text -type $type | % {$WPFDGOwners_ListView.AddChild($_)}
 })


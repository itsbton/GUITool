#------------------------------------------------------------------------
#SHARED MAILBOX - Tab 2
#------------------------------------------------------------------------


#-----
#tab 2 functions
#-----

Function Check-CLSharedPermissions {
param($username)
   Get-CLMailboxPermission "$($username)" | Where-Object {($_.IsInherited -eq $false) -and -not ($_.User -like "NT AUTHORITY\SELF")} | Select-Object @{Name='User';Expression={$_.User}}, @{Name='AccessRights';Expression={$_.AccessRights}}
}
 
 #------------------------------------------------------------------------
 #SHARED MAILBOX TAB EVENTS - Tab 2
 #------------------------------------------------------------------------
 
 $WPFSMCheck_Button.Add_Click({
    $WPFSM_ListView.Items.Clear()
    $WPFSMRemoveUser_TextBox.Text=""
    $Username=$WPFSMUsername_TextBox.Text
    $MailboxName = Get-CLMailbox -Identity $Username
    

    if($MailboxName.RecipientTypeDetails -ne "SharedMailbox"){
        $WPFSMError_TextBlock.Visibility="Visible"
    }
    else{
        $WPFSMError_TextBlock.Visibility="Hidden"
        Check-CLSharedPermissions -username $WPFSMUsername_TextBox.Text | % {$WPFSM_ListView.AddChild($_)}
    }
 })

 #Gives access to shared mailbox
 $WPFSMAdd_Button.Add_Click({
    $Username = $WPFSMUsername_TextBox.Text
    $UsertoAdd = $WPFSMAddUser_TextBox.Text

    Add-CLMailboxPermission $Username -User $UsertoAdd -AccessRights FullAccess -InheritanceType all
    Add-CLRecipientPermission -Identity $Username -AccessRights SendAs -Confirm:$false -Trustee $UsertoAdd
    $WPFSM_ListView.Items.Clear()
    Check-CLSharedPermissions -username $WPFSMUsername_TextBox.Text | % {$WPFSM_ListView.AddChild($_)}
    $WPFSMAddUser_TextBox.Text = ""
})

 $WPFSMRemove_Button.Add_Click({
    $Username = $WPFSMUsername_TextBox.Text
    $UsertoRemove = $WPFSMRemoveUser_TextBox.Text

    Remove-CLMailboxPermission $Username -User $UsertoRemove -AccessRights FullAccess -Confirm:$false
    Remove-CLRecipientPermission -Identity $Username -AccessRights SendAs -Confirm:$false -Trustee $UsertoRemove
    $WPFSM_ListView.Items.Clear()
    Check-CLSharedPermissions -username $WPFSMUsername_TextBox.Text | % {$WPFSM_ListView.AddChild($_)}
    $WPFSMRemoveUser_TextBox.Text = ""
})

#double click list to set calendar permissions on selected user
$WPFSM_ListView.add_MouseDoubleClick({
    $castSelect = $WPFSM_ListView.SelectedItem
    $WPFSMRemoveUser_TextBox.Text = $castSelect."User"
})
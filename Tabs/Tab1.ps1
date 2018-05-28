#------------------------------------------------------------------------
#CALENDAR PERMISSIONS - Tab 1
#------------------------------------------------------------------------

#-----
#tab 1 functions
#-----

Function Get-CLCalendarInfo {
param($username)
    Get-CLMailboxFolderPermission "$($username):\Calendar" | Select-Object @{Name='User';Expression={$_.User}}, @{Name='AccessRights';Expression={$_.AccessRights}
}
                                   }

Function Set-CLCalendarPermissions {
param($usernameperm, $username, $permlevel)
    Set-CLMailboxFolderPermission -Identity "$($username):\Calendar" -User $usernameperm -AccessRights $permlevel
}

Function Remove-CalendarPermissions {
param($usernameperm, $username)
    Remove-CLMailboxFolderPermission -Identity "$($username):\Calendar" -User $usernameperm -Confirm:$false
}

Function Add-CLCalendarPermissions {
param($usernameperm, $username, $permlevel)
    Add-CLMailboxFolderPermission -Identity "$($username):\Calendar" -User $usernameperm -AccessRights $permlevel
}

#------------------------------------------------------------------------
 #CALENDAR TAB EVENTS - Tab 1
 #------------------------------------------------------------------------

 #Click event that changes permissions of currently selected user

$WPFCalPermChange_Button.Add_Click({
    $PermissionsLevel=""
    if($WPFCalPermChOwner_Radio.IsChecked){$PermissionsLevel=$WPFCalPermChOwner_Radio.Content}
    elseif($WPFCalPermChEditor_Radio.IsChecked){$PermissionsLevel=$WPFCalPermChEditor_Radio.Content}
    elseif($WPFCalPermChReviewer_Radio.IsChecked){$PermissionsLevel=$WPFCalPermChReviewer_Radio.Content}
    elseif($WPFCalPermChAvail_Radio.IsChecked){$PermissionsLevel=$WPFCalPermChAvail_Radio.Content}

    Set-CLCalendarPermissions -usernameperm $WPFCalPermUserEdit_Textbox.Text -username $WPFCalPermUser_TextBox.Text -permlevel $PermissionsLevel
    $WPFCalPerm_ListView.Items.Clear()
    Get-CLCalendarInfo -username $WPFCalPermUser_TextBox.Text | % {$WPFCalPerm_ListView.AddChild($_)}
})

#Click event that adds permissions of user
$WPFCalPermAdd_Button.Add_Click({
    $PermissionsLevel=""
    if($WPFCalPermAddOwner_Radio.IsChecked){$PermissionsLevel=$WPFCalPermAddOwner_Radio.Content}
    elseif($WPFCalPermAddEditor_Radio.IsChecked){$PermissionsLevel=$WPFCalPermAddEditor_Radio.Content}
    elseif($WPFCalPermAddReviewer_Radio.IsChecked){$PermissionsLevel=$WPFCalPermAddReviewer_Radio.Content}
    elseif($WPFCalPermAddAvail_Radio.IsChecked){$PermissionsLevel=$WPFCalPermAddAvail_Radio.Content}
        
    Add-CLCalendarPermissions -username $WPFCalPermUser_Textbox.Text -usernameperm $WPFCalPermUserAdd_TextBox.Text -permlevel $PermissionsLevel
    $WPFCalPerm_ListView.Items.Clear()
    Get-CLCalendarInfo -username $WPFCalPermUser_TextBox.Text | % {$WPFCalPerm_ListView.AddChild($_)}
    $WPFCalPermUserAdd_TextBox.Text = ""
})

#Click event that fills listview/grid with the calendar permissions
$WPFCalPermCheck_Button.Add_Click({
    $WPFCalPerm_ListView.Items.Clear()
    $WPFCalPermUserEdit_TextBox.Text=""
    Get-CLCalendarInfo -username $WPFCalPermUser_TextBox.Text | % {$WPFCalPerm_ListView.AddChild($_)}
})

#Event handler for Remove Permissions
$WPFCalPermRemove_Button.Add_Click({
    Remove-CalendarPermissions -username $WPFCalPermUser_TextBox.Text -usernameperm $WPFCalPermUserEdit_TextBox.Text
    $WPFCalPerm_ListView.Items.Clear()
    Get-CLCalendarInfo -username $WPFCalPermUser_TextBox.Text | % {$WPFCalPerm_ListView.AddChild($_)}
    $WPFCalPermUserEdit_TextBox.Text = ""
})

#double click list to set calendar permissions on selected user
$WPFCalPerm_ListView.add_MouseDoubleClick({
    $castSelect = $WPFCalPerm_ListView.SelectedItem
    $WPFCalPermUserEdit_TextBox.Text = $castSelect."User"
})
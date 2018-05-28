#------------------------------------------------------------------------
#UNIFIED GROUPS - Tab5
#------------------------------------------------------------------------

#-----
#tab 5 other gui events
#-----

Function Set-UGDetailsAll {
param($name)
    $WPFUGMembers_ListView.ITEMS.Clear()
    $WPFUGOwners_ListView.ITEMS.Clear()
    $GroupDetails = Get-CLUnifiedGroup -Identity $name
    $WPFUGDisplayName_TextBox.Text = $GroupDetails.DisplayName 
    $WPFUGEmailAddress_TextBox.Text= $GroupDetails.PrimarySMTPAddress
    $WPFUGMemberCount_Textbox.Text = $GroupDetails.GroupMemberCount
    $WPFUGCreatedOn_TextBox.Text = $GroupDetails.WhenCreated
    $WPFUGNotes_Textbox.Text = $GroupDetails.Notes    

    Get-CLUnifiedGroupLinks -Identity $name -LinkType Members | % {$WPFUGMembers_ListView.AddChild($_)}

    Get-CLUnifiedGroupLinks -Identity $name -LinkType Owners | % {$WPFUGOwners_ListView.AddChild($_)}

    if($GroupDetails.AccessType -eq "Private"){$WPFUGPrivate_RadioButton.IsChecked = $true}
    elseif($GroupDetails.AccessType -eq "Public"){$WPFUGPublic_RadioButton.IsChecked = $true}
}
 #------------------------------------------------------------------------
 #UNIFIED GROUP TAB EVENTS - Tab5
 #------------------------------------------------------------------------
 #View Details button click
 $WPFUGView_Button.Add_Click({
    Set-UGDetailsAll -name $WPFUGName_TextBox.Text
 })

 #Change visibility of group button click
 $WPFUGChangeVis_Button.Add_Click({
 })

 $WPFUGRemoveMember_Button.Add_Click({
    $WPFUGMembers_ListView.SelectedItems | % {Remove-CLUnifiedGroupLinks -Identity $WPFUGName_TextBox.Text -LinkType Members -Links $_.tostring() -Confirm:$false}
    Set-UGDetailsAll -name $WPFUGName_TextBox.Text
 })

 $WPFUGAddMember_Button.Add_Click({
    Add-CLUnifiedGroupLinks -Identity $WPFUGName_TextBox.Text -LinkType Members -Links $WPFUGAddMember_TextBox.Text
    Set-UGDetailsAll -name $WPFUGName_TextBox.Text
 })

 $WPFUGRemoveOwner_Button.Add_Click({
    $WPFUGOwners_ListView.SelectedItems | % {Remove-CLUnifiedGroupLinks -Identity $WPFUGName_TextBox.Text -LinkType Owners -Links $_.tostring() -Confirm:$false}
    Set-UGDetailsAll -name $WPFUGName_TextBox.Text
 })

 $WPFUGAddOwner_Button.Add_Click({
    Add-CLUnifiedGroupLinks -Identity $WPFUGName_TextBox.Text -LinkType Owners -Links $WPFUGAddOwner_TextBox.Text
    Set-UGDetailsAll -name $WPFUGName_TextBox.Text
 })
#-----
#tab 3 functions
#-----

Function ConvertHTMLto-Text {
param($HTMLinput)
    $textoutput = $HTMLinput -replace  ‘<[^>]+>’,'' -replace "&nbsp;"," " -replace "&#65279;", "" -replace "&amp;", "&"
    return $textoutput.trim()
}

Function ConvertTextto-HTML {
param($Textinput)  
    $HTMLoutput = $Textinput -replace "`n","<br>"
    return $HTMLoutput
}

Function Set-CLOOO {
param($username, $Message, $state)
    $NowD = Get-Date -UFormat %D
    $NowT = Get-Date -UFormat %T
    $Now = "$NowD $NowT"

    $Month = (Get-Date).AddDays(30)
    $Later = $Month.ToString("yyyy/MM/dd hh:mm:ss")

    Set-CLMailboxAutoReplyConfiguration -identity "$($username)" -AutoReplyState $state -InternalMessage $Message -ExternalMessage $Message -StartTime $Now -EndTime $Later
}

Function Get-CLOOO {
param($username)
    $Mailbox = Get-CLMailboxAutoReplyConfiguration -identity "$($username)"
    $MailboxOOO = $Mailbox.InternalMessage
    return ConvertHTMLto-Text -HTMLinput $MailboxOOO
}

Function Set-CLOOOtoOff {
param($username)
    Set-CLMailboxAutoReplyConfiguration -Identity "$($username)" -AutoReplyState Disabled
}

Function Check-CLOOOStatus {
param($username)
    $Mailbox = Get-CLMailboxAutoReplyConfiguration -Identity "$($username)"
    if($Mailbox.AutoReplyState -eq "Disabled"){return $false}
    else{return $true}
}

Function Check-CLOOOSchedule {
param($username)
    $OOOConfig = Get-CLMailboxAutoReplyConfiguration -Identity "$($username)"
    $State = $OOOConfig.AutoReplyState
    return $State
}

Function Get-CLOOOEndDate{
param($username)
    $OOOConfig = Get-CLMailboxAutoReplyConfiguration -Identity "$($username)"
    $OOOEndDate = $OOOConfig.EndTime
    return $OOOEndDate
}

#-------
#tab 3 other gui events
#--------

Function Set-CLOOORadioButton {
param($username)
    $State = Check-CLOOOSchedule -username $username
    if($State -eq "Enabled"){$WPFOOOIndef_RadioButton.IsChecked=$true}
    elseif($State -eq "Scheduled"){$WPFOOO30Days_RadioButton.IsChecked=$true}
    else{
        $WPFOOOIndef_RadioButton.IsChecked=$false
        $WPFOOO30Days_RadioButton.IsChecked=$false
    }
}

Function Set-CLOOOEndDate {
param($username)
    $state = Check-CLOOOSchedule -username $username
    if($state -eq "Scheduled"){
        $WPFOOOEndDate_TextBlock.Text = Get-CLOOOEndDate -username $WPFOOOUsername_TextBox.Text
    }
    else{$WPFOOOEndDate_TextBlock.Text = "No End Date"}
}

Function Set-CLOOOStatusTextBlock {
param($username)
    if(Check-CLOOOStatus -username $username){
        $WPFOOOOn_TextBlock.Visibility="Visible"
        $WPFOOOOff_TextBlock.Visibility="Hidden"
    }
    else{
        $WPFOOOOff_TextBlock.Visibility="Visible"
        $WPFOOOOn_TextBlock.Visibility="Hidden"
    }
}

#------------------------------------------------------------------------
 #OUT OF OFFICE MESSAGE TAB EVENTS - Tab3
 #------------------------------------------------------------------------
 $WPFOOOView_Button.Add_Click({
    $WPFOOOMessage_TextBox.Text = Get-CLOOO -username $WPFOOOUsername_TextBox.Text
    Set-CLOOORadioButton -username $WPFOOOUsername_TextBox.Text
    Set-CLOOOStatusTextBlock -username $WPFOOOUsername_TextBox.Text    
    Set-CLOOOEndDate -username $WPFOOOUsername_TextBox.Text    
 })

 $WPFOOOAdd_Button.Add_Click({
    #Convert plain text to HTML so it can be viewed properly
    $HTMLtext = ConvertTextto-HTML -Textinput $WPFOOOMessage_Textbox.Text

    #Check whether or not it should be on for 30 days or on indefinitely
    if($WPFOOO30Days_RadioButton.IsChecked){$state="Scheduled"}
    else{$state="Enabled"}
    Set-CLOOO -username $WPFOOOUsername_TextBox.Text -Message $HTMLtext -state $state

    #Double check that the OOO message is what you typed
    $WPFOOOMessage_Textbox.Text = Get-CLOOO -username $WPFOOOUsername_TextBox.Text
    Set-CLOOOStatusTextBlock -username $WPFOOOUsername_TextBox.Text    
    Set-CLOOORadioButton -username $WPFOOOUsername_TextBox.Text
    Set-CLOOOEndDate -username $WPFOOOUsername_TextBox.Text    
 })

 $WPFOOOTurnOff_Button.Add_Click({
    Set-CLOOOtoOff -username $WPFOOOUsername_TextBox.Text
    Set-CLOOOStatusTextBlock -username $WPFOOOUsername_TextBox.Text
    Set-CLOOORadioButton -username $WPFOOOUsername_TextBox.Text
    Set-CLOOOEndDate -username $WPFOOOUsername_TextBox.Text    
 })

 $WPFOOOClear_Button.Add_Click({
    $WPFOOOMessage_Textbox.Text=""
    Set-CLOOO -username $WPFOOOUsername_TextBox.Text -Message $WPFOOOMessage_Textbox.Text -state "Enabled"
    Set-CLOOOtoOff -username $WPFOOOUsername_TextBox.Text
    Set-CLOOOStatusTextBlock -username $WPFOOOUsername_TextBox.Text
    Set-CLOOORadioButton -username $WPFOOOUsername_TextBox.Text
    Set-CLOOOEndDate -username $WPFOOOUsername_TextBox.Text    
 })
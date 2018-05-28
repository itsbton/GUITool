#------------------------------------------------------------------------
#SSPR Information - Tab6
#------------------------------------------------------------------------

#----------------------------------
#tab 6 functions
#-----------------------------------
Function Get-SSPRPrincipalName{
param($name)
    if($name -like "*@up.edu*"){
        return $name
    }
    else{
        $data = Get-CLRecipient -Identity $name | select PrimarySMTPAddress
        $principalname = $data.PrimarySMTPAddress
        return $principalname
    }
}

Function Get-SSPRData{
param($name)
    $data = Get-MsolUser -UserPrincipalName $name | Select -ExpandProperty StrongAuthenticationUserDetails
    return $data
}

Function Get-SSPRAuthEmail {
param($name)
    $principalName = Get-SSPRPrincipalName -name $name
    $email = Get-SSPRData -name $principalName | % {$_.email}
    return $email
}

Function Get-SSPRAuthPhone {
param($name)
    $principalName = Get-SSPRPrincipalName -name $name
    $Phone = Get-SSPRData -name $principalName | % {$_.PhoneNumber}
    return $Phone
}

Function Check-SSPRValidUser{
param($name)
    $check = Get-CLRecipient -anr $name
    $type = $check.RecipientTypeDetails
    if($check -and $type -eq "UserMailbox"){
        return $true
    }
    else{
        return $False
    }
}
#-----
#tab 6 other gui events
#-----


 #------------------------------------------------------------------------
 #SSPR TAB EVENTS - Tab5
 #------------------------------------------------------------------------
 #View Details button click
 $WPFSSPRSearch_Button.Add_Click({
    #Start fresh
    $name = $WPFSSPRName_TextBox.Text

    $WPFSSPRFirstName_TextBox.Text = ""
    $WPFSSPRLastName_TextBox.Text = ""
    $WPFSSPREmail_TextBox.Text = ""
    $WPFSSPRPhone_TextBox.Text = ""
    $WPFSSPRError_TextBlock.Visibility = "Hidden"

    #check valid
    if(Check-SSPRValidUser -name $name){
        $GeneralData = Get-CLRecipient -Identity $name

        $WPFSSPRFirstName_TextBox.Text = $GeneralData.Firstname
        $WPFSSPRLastName_TextBox.Text = $GeneralData.LastName

        $email = Get-SSPRAuthEmail -name $name
        $WPFSSPREmail_TextBox.Text = $email

        $phone = Get-SSPRAuthPhone -name $name
        $WPFSSPRPhone_TextBox.Text = $phone
       }
    else{        
        $WPFSSPRError_TextBlock.Visibility = "Visible"
    }

})
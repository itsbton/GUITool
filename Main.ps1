
$BeginXML = @"
<Window x:Class="O365AdminTools.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:O365AdminTools"        
        mc:Ignorable="d"
        Title="One Stop Shop" Height="515" Width="725">
    <Grid>
        <TabControl>
"@

$EndXML = @"
        </TabControl>
    </Grid>
</Window>
"@       

$secondXML

# Load xml for each tab
$Tab0XML = get-content .\Tabs\Tab0.XML #General Search
$Tab1XML = get-content .\Tabs\Tab1.XML #Calendar Permissions
$Tab2XML = get-content .\Tabs\Tab2.XML #Shared Mailbox
$Tab3XML = get-content .\Tabs\Tab3.XML #OOO Messages
$Tab4XML = get-content .\Tabs\Tab4.XML #Distribution Groups
$Tab5XML = get-content .\Tabs\Tab5.XML #Unified Groups
$Tab6XML = get-content .\Tabs\Tab6.XML #SSPR Information


$inputXML = $beginXML + $Tab0XML + $Tab1XML + $Tab2XML + $Tab3XML + $Tab4XML + $Tab5XML + $Tab6XML + $EndXML

$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
  try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."}
 
#===========================================================================
# Load XAML Objects In PowerShell
#===========================================================================
 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}
 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}
 
Get-FormVariables
 
#===========================================================================
# Actually make the objects work
#===========================================================================
#Connect to O365 Exchange
if ( (get-pssession).computername -eq "outlook.office365.com" ) {
    #"Already connected to " + (get-pssession).computername
} else {
    Write-Output "Connecting to Exchange Online..."
    $UserCredential = Get-Credential -Message "Office365 Login (don't forget @up.edu)"
    Connect-MsolService -Credential $UserCredential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
    Import-PSSession $Session -Prefix CL
}

#Connect to On-Prem Exchange
if ( (get-pssession).computername -eq "ON PREM ADDRESS" ) {    
} else {
    Write-Output "Connecting to On-Premise Exchange..."
    $UserCredentialOnPrem = Get-Credential -Message "Exchange On-Prem Login "
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "ONPREMADDRESS" -Credential $UserCredentialOnPrem -Authentication Kerberos
    Import-PSSession $Session -Prefix OP
}


#Import functions/events from tabs

. .\Tabs\Tab0.ps1 #General Search
. .\Tabs\Tab1.ps1 #Calendar Permissions
. .\Tabs\Tab2.ps1 #Shared Mailbox
. .\Tabs\Tab3.ps1 #Out of office
. .\Tabs\Tab4.ps1 #Distribution Groups
. .\Tabs\Tab5.ps1 #Unified O365 Groups
. .\Tabs\Tab6.ps1 #SSPR Information

#===========================================================================
# Shows the form
#===========================================================================
write-host "To show the form, run the following" -ForegroundColor Cyan
'$Form.ShowDialog() | out-null'

$Form.ShowDialog() | out-null

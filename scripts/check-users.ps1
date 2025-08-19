# Check existing users in M365 tenant
Connect-MicrosoftTeams
Get-CsOnlineUser | Select-Object DisplayName, UserPrincipalName | Format-Table -AutoSize
Disconnect-MicrosoftTeams


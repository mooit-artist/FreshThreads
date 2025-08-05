# Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName procurement@freshthreadsllc.com

# Add alias: bryan@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='bryan@freshthreadsllc.com'}
# Add alias: info@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='info@freshthreadsllc.com'}
# Add alias: support@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='support@freshthreadsllc.com'}
# Add alias: orders@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='orders@freshthreadsllc.com'}
# Add alias: sales@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='sales@freshthreadsllc.com'}
# Add alias: marketing@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='marketing@freshthreadsllc.com'}
# Add alias: billing@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='billing@freshthreadsllc.com'}
# Add alias: returns@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='returns@freshthreadsllc.com'}
# Add alias: press@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='press@freshthreadsllc.com'}
# Add alias: partnerships@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='partnerships@freshthreadsllc.com'}
# Add alias: design@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='design@freshthreadsllc.com'}
# Add alias: creative@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='creative@freshthreadsllc.com'}
# Add alias: submissions@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='submissions@freshthreadsllc.com'}
# Add alias: shipping@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='shipping@freshthreadsllc.com'}
# Add alias: quality@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='quality@freshthreadsllc.com'}
# Add alias: affiliate@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='affiliate@freshthreadsllc.com'}
# Add alias: admin@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='admin@freshthreadsllc.com'}
# Add alias: accounting@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='accounting@freshthreadsllc.com'}
# Add alias: legal@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='legal@freshthreadsllc.com'}
# Add alias: privacy@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='privacy@freshthreadsllc.com'}
# Add alias: security@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='security@freshthreadsllc.com'}
# Add alias: inventory@freshthreadsllc.com
Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='inventory@freshthreadsllc.com'}

# Verify aliases
Get-Mailbox procurement@freshthreadsllc.com | Select-Object EmailAddresses

# Disconnect
Disconnect-ExchangeOnline

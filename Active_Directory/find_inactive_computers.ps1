# find_inactive_computers.ps1
# Script to find inactive computer objects by looking at the last time the computer logged onto AD
# this script takes into consideration the max 14 day lastlogon time offset
# Usage:  .\find_inactive_computers.ps1 <OU to search (full LDAP format)> <DATE of how long ago for last logon>
#         .\find_inactive_computers.ps1 "OU=Workstations,OU=AI,OU=_OIT,DC=ad,DC=gatech,DC=edu" "4/06/2016"

Param ($OU, $Date) 
Search-ADAccount -SearchBase $OU -AccountInactive -DateTime $Date -ComputersOnly  | get-adcomputer -properties * | ft name, CanonicalName, IPv4Address, OperatingSystem, LastLogonDate
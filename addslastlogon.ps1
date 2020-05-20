#HTML based report
#Must have RSAT installed or run on a domain controller
#Update the DOMAINNAME with the appropriate domain name
#Update the appropriate path as needed

$Date= Get-date     
Import-Module activedirectory 
 
$HTMLHead=@" 
<title>Last Logon Report</title> 
 <Head>
 <STYLE>
 BODY{background-color :#FFFFF} 
TABLE{Border-width:thin;border-style: solid;border-color:Black;border-collapse: collapse;} 
TH{border-width: 1px;padding: 1px;border-style: solid;border-color: black;background-color: ThreeDShadow} 
TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color: Transparent} 
</STYLE>
</HEAD>

"@ 
 

# Gets time stamps for all User in the domain that have NOT logged in since after specified date  
$domain = "DOMAINNAME"   
$DaysInactive = 180   
$time = (Get-Date).Adddays(-($DaysInactive))  
   
# Get all AD User with lastLogonTimestamp less than our time and set to enable  
$lldata = Get-ADUser -Filter {LastLogonTimeStamp -lt $time -and enabled -eq $true} -Properties LastLogonTimeStamp |  select-object Name,@{Name="Date of Last Logon"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('yyyy-MM-dd_hh:mm:ss')}} | ConvertTo-HTML
$LLCount = $lldata.Count




#HTML Body Content
$HTMLBody = @"
<CENTER>

<Font size=4><B>Last Logon Report</B></font></BR>

<I>Script last run:$date</I><BR />
Objective: Show user accounts that have not logged on in the last 180 days or greater. Service Accounts should be an exception.</BR>

<B>Last Logon in 180 Days Report</B><BR />
<TABLE>
<TR>
<TD>$lldata</TD>
</TR>
</TABLE>
</BR>

<B>Last Logon 180 days Count</B><BR />
<TABLE>
<TR>
<TD>Last Logon</TD>
</TR>
<TR>
<TD>$LLCount</TD>
</TR>
</TABLE>
</CENTER></BR>
</CENTER></BR>
"@
  
#Export to HTML

$StatusUpdate | ConvertTo-HTML -head $HTMLHead -body $HTMLBody | out-file "C:\temp\llreport.html" -Append 

#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html><head><title>Bash as CGI"
echo "</title></head><body>"
 
echo "<h1>General system information for host $(hostname)</h1>"
echo ""
 
echo "<h1>Uptime</h1>"
echo "<pre> $(uptime) </pre>"
 
echo "<h1>Memory Info</h1>"
echo "<pre> $(free -m) </pre>"
 
echo "<h1>Disk Info:</h1>"
echo "<pre> $(df -h) </pre>"
 
echo "<h1>Logged in user</h1>"
echo "<pre> $(w) </pre>"
 
echo "<h1>auth</h1>"
echo "<pre> $(sudo /usr/bin/tail -n 30 /var/log/auth.log) </pre>"
 
echo "<h1>Cherokee access</h1>"
echo "<pre> $(sudo /bin/cat /var/log/cherokee/cherokee.access) </pre>"
 
echo "<h1>netstat</h1>"
echo "<pre> $(netstat -W) </pre>"
 
echo "<center>Information generated on $(date)</center>"
echo "</body></html>"

for i in 172.16.0.{1..254};do (ping -c1 $i > /dev/null && echo $_) &done > pinged-hosts


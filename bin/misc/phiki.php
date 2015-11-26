 <?$p=$_SERVER[PHP_SELF];$e=htmlentities($_GET[t]);if($e)`echo "$e">.$p`
 &header("Location:$p");$n=`cat .$p`;echo preg_replace('~htt\S+|([A-Z]\w+){2,}~'
 ,'<a href=$0>$0</a>',`ls -t|head`."<hr><h1>$p</h1><pre>$n"),"<form action=.$p>
 <input type=submit>\n<textarea name=t cols=80 rows=16>$n";
/* Command to start the PHP built-in webserver
 $ php -d error_reporting=0 -d short_open_tag=On -S localhost:8000 wiphiki.php
*/

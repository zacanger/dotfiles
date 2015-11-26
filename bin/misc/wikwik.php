  <?php function p($c){$r=preg_replace(array("~^ +([^\n]+)~m",'~^-\s+(.*)$~m',
  "~-{4,}\r?\n~",'~(http(?:s)?)://([^\s]+)~i','~\n~'),array('<code>$1</code>','<li>$1',
  '<hr>','<a href=$1://$2>$2</a>','<br>'),$c);preg_match_all('~([A-Z]\w+){2,}~',$r,
  $x);foreach(array_unique($x[0])as$m){$r=str_replace($m,x($m)? "<a href=?$m>$m</a>":
  "$m<a href=?e=$m>?</a>",$r);}return$r;}function f($f){@mkdir('wik');return
  @file_get_contents("wik/$f.w");}function b($b){echo"<h1><a href=?$b>Backlinks $b"
  ."</a></h1><div id=c>";foreach(glob('wik/*.w')as$f){$f=substr($f,4,-2);if(strpos(
  f($f),$b)!==false)echo"<a href=?$f>$f</a><br>";}echo"</div>";}function x($f){
  return file_exists("wik/$f.w");}function e($p){$p=$p?$p:$_GET['e'];echo"<h1>Edit"
  ." $p</h1><form action='?$p' method=post><textarea name=c cols=50 rows=10>".f($p)
  ."</textarea><br><input type=submit value=Save>";}$p=preg_replace('~(e|b)=(.*)~'
  ,'',$_SERVER[QUERY_STRING]);$c=$_POST[c];$e=$_GET[e];$b=$_GET[b];if(!$p&&!$e)$p=
  'MainPage';if($c){@file_put_contents("wik/$p.w",htmlspecialchars($c));header(
  "Location: ?$p");}echo"<title>Wik Wiki</title>";if(!$e){if(!$b){echo x($p)?
  "<h1><a href=?b=$p>$p</a></h1><div id=c>".p(f($p))."</div><hr><a href=?e=$p>"
  ."Edit</a> | <small>Modified: ".date('d.m.Y @ H:i:s', @filemtime("wik/$p.w"))
	:e($p);}else b($b);}else e($e);


#!/usr/bin/python2.2
import re,string,cgi,time
z=cgi.FieldStorage().getvalue
a=["Looked for ","value=","<input name=","><input type=hidden name=",'<form action=qiki.py method=post>','<textarea name=x cols=80 rows=15>',"<a href='qiki.py?a=",'<button type=submit>edit</button',"</a></h1><p>","Backlinks: ","</title></head><body><h1>"]
x=[["\r",""],["<","&lt;"],[">","&gt;"],["''(.*?)''","<i>\\1</i>"],["__(.*?)__","<b>\\1</b>"],["\[([\w ]+)\]","<a href='qiki.py?a=&p=\\1'>\\1</a>"],["\[(.*?:.*?.j?pn?g)\]","<img src='\\1'>"],["\[(.*?:.*?)\]","<a href='\\1'>\\1</a>"],["\n\n","\n<p>\n"],["\n---+","<hr>"],["\n( |!*) (.*?)(?=\n)","<\\1>\\2</\\1>"],["!!!>","h1>"],["!!>","h2>"],["!>","h3>"],[" >","pre>"]]
f=open('qiki.txt','r+');i=f.readline;e=string;v=''
def k(s,w):
 f.seek(0);d={};y=1;s=re.sub("[^. \w]",'',s)
 if w==0:d[s]='?';s="^"+s+"$"
 while y:
  m=y=i()[:-1];b=i()[:-1];t=i()[:-1]
  if w>0:m=b
  if w<0:b,y=y,t
  if re.search(s,m):
   d[y]=b
   if t==j:break
 return d
tr=lambda s:e.translate(s,e.maketrans('\a\n','\n\a'))
c=z('a');l=p=z('p','home page');j=z('t')
if c=='p':z=z('x');f.seek(0,2);f.write(p+"\n"+tr(z)+"\n"+time.strftime("%Y-%m-%d %H:%M.%S",time.localtime())+"\n");c=''
else: z=tr(k(p,0)[p])
if c=='b':c='s';l='\['+p+r'\]';a[0]=a[9]
if not c:v=reduce(lambda x,y:re.sub(y[0],y[1],x),x,'\n'+z)+a[4]+a[7]+a[3]+"a "+a[1]+"e"+a[3]+"p "+a[1]+"'"+p+"'></form>"
elif c=='e':v=a[4]+a[5]+z+"</textarea>"+a[7]+a[3]+"a "+a[1]+"p"+a[3]+"p "+a[1]+"'"+p+"'></form>"
elif c=='s':
 g=k(l,1).keys();v=a[0]+p+a[8];g.sort()
 for q in g:v+="<br>"+a[6]+"&p="+q+"'>"+q+"</a>"
else:
 g=k(c,-1);d=g.keys();d.sort();d.reverse();p=c
 for q in d[:20]:v+="<br>"+a[6]+"&p="+g[q]+"&t="+q+"'>"+q+" : "+g[q]+"</a>"
v+=a[4]+'<hr>Go:'+a[2]+'p value=help'+a[3]+"a value=''></form>"+a[4]+'Find:'+a[2]+'p'+a[3]+'a value=s></form>'+a[6]+".&p="+p+"'>What's new</a> | "+a[6]+"'>Home</a></body></html>"
print "Content-Type: text/html\n\n<html><head><style>"+file('qiki.css','r').read()+"</style><title>",p,a[10],a[6]+"b&p="+p+"'>",p,a[8],a[6]+p+"'>History</a><hr>",v

#!/usr/bin/python
import re,os,cgi;d,h=os.listdir('.'),'<a href=wy?';p,e,g,s=tuple(map(cgi.parse(
).get,'pegs'));f=lambda s:reduce(lambda s,(r,q):re.sub('(?m)'+r,q,s),(('\r','')
,('([A-Z][a-z]+){2,}',lambda m:('%s'+h+'e=%s>?</a>',h+'g=%s>%s</a>')[m.group(0)
in d]%((m.group(0),)*2)),('^{{$','<ul>'),('^# ','<li>'),('^}}$','</ul>'),('(ht\
tp:[^<>"\s]+)',h[:-3]+r'\1>\1</a>'),('\n\n','<p>')),s);o,g=lambda y:(y in d and
cgi.escape(open(y).read()))or'',(g or p and[open(p[0].strip('./'),'w').write(s[
0])or p[0]]or[0])[0];print'Content-Type:text/html\n\n'+(s and', '.join([f(n)for
n in d if s[0]in o(n)])or'')+(e and'<form action=wy?p=%s method=POST><textarea\
 name=s rows=8 cols=50>%s</textarea><input type=submit></form>'%(e[0],o(e[0]))
or'')+(g and'<h1>%ss=%s>%s</a>,%se=%s>edit</a></h1>'%(h,g,g,h,g)+f(o(g))or'')


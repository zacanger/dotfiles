import geometry_dev;
size(10cm,0);

line d=line(E,W); draw(d);
draw(line(S+W,false,S+E), 3mm+red);
point P=S, Q=S+E; dot(P^^Q);

// boucle
for (int i=0; i < 4; ++i) {
  point Pp=curpoint(d,-1+i);
  dot(Pp);
  draw(line(P,Pp),dotted);
  draw(line(Q,Pp),dashed);
}

// marges
addMargins(1cm,1cm);
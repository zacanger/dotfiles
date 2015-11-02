unitsize(1cm);
import geometry_dev;

// Definitions de constantes et points
real r = 3;
real a = 59;

point pO = (0,0);
point pN = (-r,0);
point pP = (r,0);
point pM = rotate(180-2*a,pO)*pP;
real a = abs(pO-pN);
write(a);

// Labels pointés
dot(Label("$O$",align=S),pO);
dot(Label("$N$",align=SW),pN);
dot(Label("$P$",align=SE),pP);
dot(Label("$M$",align=NE),pM);

// Tracé de la figure
draw(pN--pP,StickIntervalMarker(2,1,size=6,angle=-45,red));
draw(pO--pM,StickIntervalMarker(1,1,size=6,angle=-45,red));
draw(pN--pM--pP);

// Marquage des angles
markangle(Label("$58^\circ$"),pM,pP,pN,radius=5mm,blue);
markangle(Label("$?$"),pP,pN,pM,radius=10mm,blue);

/* un truc
à travailler */
shipout(bbox(xmargin=1mm,invisible));

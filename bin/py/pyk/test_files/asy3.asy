unitsize(0.65cm);
import geometry_dev;
import trembling_pi;
import base_pi;

point pA = (0,0);
point pB = (6,0);
point pC = rotate(-90,pB)*pA;
point pD = pC+4*(rotate(-38)*unit(pB-pC));
point pE = pA+8*(rotate(-78)*unit(pA-pB));

dot(Label("$A$",align=SW),pA);
dot(Label("$B$",align=SE),pB);
dot(Label("$C$",align=NE),pC);
dot(Label("$D$",align=SW),pD);
dot(Label("$E$",align=N),pE);

// main levée
draw(tremble(pA--pB,frequency=0.15),StickIntervalMarker(1,2,size=6,angle=-45,red,true));
draw(tremble(pB--pC,frequency=0.15),StickIntervalMarker(1,2,size=6,angle=-45,red,true));
draw(tremble(pC--pD,frequency=0.15));
draw(tremble(pA--pE,frequency=0.15));

label("$6 \; cm$",pA--pB,S);
label(rotate(dir(pE--pA))*"$8 \; cm$",pE--pA);
label(rotate(dir(pC--pD))*"$4 \; cm$",pC--pD);

markrightangle(pA,pB,pC,blue);
markangle(Label("$126^\circ$"),pE,pA,pB,radius=6mm,blue);
markangle(Label("$38^\circ$"),pB,pC,pD,radius=12mm,blue);

shipout(bbox(xmargin=1mm,invisible));
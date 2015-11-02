unitsize(1cm);
import geometry_dev;
usepackage("pifont");

// Les points
point pO = (0,0);
point pA = (2,0);
point pB = (5,0);
point pC = (3,3);

// Les labels pointés
dot(Label("$O$",align=SW),pO);
dot(Label("$A$",align=S),pA);
dot(Label("$B$",align=S),pB);
dot(Label("$C$",align=N),pC);

// labels pour les directions
draw(Label("$x$",Relative(1),S),line(pO,false,pA));
draw(Label("$z$",Relative(1),SE),line(pO,false,pC));
draw(Label("$y$",Relative(1),SE),line(pB,false,pB+pC));

// le triangle
draw(pA--pC--pB);

// les angles
markangle(Label("\ding{172}"),pA,pO,pC,radius=5mm,blue);
markangle(Label("\ding{173}"),pO,pA,pC,radius=3mm,blue);
markangle(Label("\ding{174}"),pA,pC,pO,radius=8mm,blue);
markangle(Label("\ding{175}"),pC,pA,pB,radius=5mm,blue);
markangle(Label("\ding{176}"),pC,pB,pA,radius=3mm,blue);
markangle(Label("\ding{177}"),pA,pC,pB,radius=4mm,blue);
markangle(Label("\ding{178}"),pB+(1,0),pB,pB+pC,radius=6mm,blue);

addMargins(0mm,0mm,45mm,15mm);
shipout(bbox(xmargin=1mm,invisible));
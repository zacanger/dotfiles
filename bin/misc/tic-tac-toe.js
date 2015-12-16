var P='X';var N='O';var C=0;var p=process;var i=p.stdin;i.setRawMode(1);
i.resume();i.setEncoding('utf8');var o=p.stdout;var b=[1,2,3,4,5,6,7,8,9];
function d(){o.write('\033c'+b[0]+'|'+b[1]+'|'+b[2]+'\n'+b[3]+'|'+b[4]+'|'+b[5]
+'\n'+b[6]+'|'+b[7]+'|'+b[8]+'\n');}function t(f){if(typeof b[f-1]=='number'){
b[f-1]=P;if(P=='X'){P='O';N='X';}else{P='X';N='O';}C++;}}function W(){
if((b[0]==b[4]&&b[4]==b[8])||(b[2]==b[4]&&b[4]==b[6])||(b[0]==b[1]&&b[1]==b[2])
||(b[3]==b[4]&&b[4]==b[5])||(b[6]==b[7]&&b[7]==b[8])||(b[0]==b[3]&&b[3]==b[6])
||(b[1]==b[4]&&b[4]==b[7])||(b[2]==b[5]&&b[5]==b[8])) return 1;}i.on('data',
function(k){if(k=='q')p.exit();if(k>0&&k<=9)t(k);d();if(W()){o.write(N+' WINS'+
'\n');p.exit();}if(C>8){o.write("It's a draw!\n");p.exit();}});d();
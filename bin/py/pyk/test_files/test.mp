beginfig(1)
    boxjoin(a.se = b.sw ; a.ne = b.nw) ; % a et b sont les noms conventionnels de deux boites consécutives
    boxit.zero  (btex \strut\quad etex) ;
    boxit.un    (btex \strut\quad etex) ;
    boxit.deux  (btex \strut $\ldots$ etex) ;
    boxit.trois (btex \strut\quad etex) ;
    boxit.quatre(btex \strut $\ldots$ etex) ;
    zero.c = (0,0) ; % pourquoi pas ?

    numeric largeur ;
    largeur = xpart (un.c - zero.c) ;
    drawboxed(zero,un,deux,trois,quatre) ;

    % les huit points cardinaux des boites : n, ne, e, se, s, sw, w, nw
    fill (quatre.ne -- quatre.se -- (quatre.se shifted (4bp,0)) -- (quatre.ne shifted (4bp,0)) -- cycle)
            shifted (-2bp,0) withcolor white ;
    draw ((0,0) -- (largeur,0)) shifted trois.ne ;
    draw ((0,0) -- (largeur,0)) shifted trois.se ;
    draw ((largeur,0) -- (largeur + 2cm,0)) shifted trois.ne dashed evenly ;
    draw ((largeur,0) -- (largeur + 2cm,0)) shifted trois.se dashed evenly ;
    label.urt("0",zero.nw) ; label.urt("1",un.nw) ; label.urt(btex $n$ etex,trois.nw) ;
    label.top(btex \rlap{Table de hachage} etex,zero.nw shifted (0,16pt)) ;
    dotlabel("",trois.c) ;

    boxjoin(a.se = b.sw ; a.ne = b.nw) ; boxit.b0(btex $(x_0,y_0)$ etex) ; boxit.p0(" ") ;
    boxjoin(a.se = b.sw ; a.ne = b.nw) ; boxit.b1(btex $(x_1,y_1)$ etex) ; boxit.p1(" ") ;
    boxjoin(a.se = b.sw ; a.ne = b.nw) ; boxit.b2(btex $(x_2,y_2)$ etex) ; boxit.p2(" ") ;

    pair delta ;
    delta = (23mm,0) ;
    b0.c = trois.c shifted (-5mm,-35mm) ;
    b1.c = b0.c shifted delta ;
    b1.c = 1/2[b0.c,b2.c] ;
    drawboxed(b0,p0,b1,p1,b2,p2) ;

    boxjoin(a.se = b.sw ; a.ne = b.nw) ; boxit.bp(btex $(x_p,y_p)$ etex) ; boxit.pp(" ") ;
    bp.c = b2.c shifted (b2.c - b0.c) ;
    drawboxed(bp,pp) ;

    drawarrow trois.c{down}..{down}b0.c cutafter bpath b0 ;
    dotlabel("",p0.c) ; dotlabel("",p1.c) ; dotlabel("",p2.c) ; dotlabel("",pp.c) ;
    drawarrow p0.c{up}..{down}b1.c cutafter bpath b1 ;
    drawarrow p1.c{up}..{down}b2.c cutafter bpath b2 ;
    drawarrow p2.c{up}..{down}(b2.c shifted delta) cutafter (bpath b2) shifted delta ;
    drawarrow (1/2[p2.c,pp.c]){up}..{down}bp.c cutbefore (bpath p2) shifted delta cutafter bpath bp ;
    drawarrow pp.c{up}..{down}(bp.c shifted delta) ;
    % la terre
    z0 = bp.c shifted delta ;
    draw z0 - (4mm,0) -- z0 + (4mm,0) ;

    picture etape ; etape = currentpicture ; % garde le dessin courant
    currentpicture := nullpicture ; % on efface tout et on recommence
    path pochoir ; pochoir = z0 - (4mm,0) -- z0 + (4mm,0) -- z0 + (4mm,-2mm) -- z0 - (4mm,2mm) -- cycle ;
    for i=0 upto 14: draw ((0,0)--(-4mm,-4mm)) shifted ((z0 - (4mm,0)) shifted (i*mm,0)) ; endfor
    clip currentpicture to pochoir ;
    addto currentpicture also etape ;
endfig ;

end

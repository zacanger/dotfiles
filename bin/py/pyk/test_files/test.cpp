class Point
{
    private:
    //Les coordonnées x et y du point
    int x, y;

    //La vitesse du point
    int xVel, yVel;

    public:
    //Initialisation des variables
    Point();

    //Recupere la touche pressee et ajuste la vitesse du point
    void handle_input();

    //Bouge le point
    void move();

    //Montre le point sur l'ecran
    void show();

    //Met la camera sur le point
    void set_camera();
};

void Point::move()
{
    //Bouge le point à gauche ou à droite
    x += xVel;

    //Si le point se rapproche trop des limites(gauche ou droite) de l'ecran
    if( ( x < 0 ) || ( x + POINT_WIDTH > LEVEL_WIDTH ) )
    {
        //On revient
        x -= xVel;
    }

    //Bouge le point en haut ou en bas
    y += yVel;

    //Si le point se rapproche trop des limites(haute ou basse) de l'ecran
    if( ( y < 0 ) || ( y + POINT_HEIGHT > LEVEL_HEIGHT ) )
    {
        //On revient
        y -= yVel;
    }
}
		
//Tant que l'utilisateur n'a pas quitter
    while( quit == false )
    {
        //On demarre le timer fps
        fps.start();

        //Tant qu'il y a un événement
        while( SDL_PollEvent( &event ) )
        {
            //On recupere l'evenement pour le point
            monPoint.handle_input();

            //Si l'utilisateur a cliqué sur le X de la fenêtre
            if( event.type == SDL_QUIT )
            {
                //On quitte the programme
                quit = true;
            }
        }

        //Bouge le point
        monPoint.move();

        //Met la camera
        monPoint.set_camera();

        //Affiche le fond
        apply_surface( 0, 0, background, screen, &camera );

        //Affiche le point sur l'écran
        monPoint.show();
			


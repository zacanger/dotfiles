#define PORT 8080 /* port d'écoute du serveur web */
#define REPERTOIRE "www" /* répertoire de base du serveur web */
#define BACKLOG 10 /* Nombre maxi de connections acceptées en file */
#define TAILLE_BUFFER 1024
#define DELIMITEUR " \t\n"

#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <sys/wait.h>
#include <signal.h>
#include <errno.h>

void terminaison_fils()
{
  while (waitpid(-1,NULL,WNOHANG)>0);
  signal(SIGCHLD,terminaison_fils);
}

void terminaison_pere()
{
  terminaison_fils;
  exit(0);
}

void erreur(const char message[])
{
  fprintf(stderr,"Erreur: %s\n",message);
  exit(1);
}

int main(int argc,char *argv[])
{
  int sock_ecoute,sock_service;
  struct sockaddr_in mon_adr,son_adr;
  int lgadr=sizeof(struct sockaddr_in);
  char buffer[TAILLE_BUFFER],*mot;
  FILE *fic;
  int lus;
  struct hostent *hote;

  signal(SIGCHLD,terminaison_fils);
  signal(SIGTERM,terminaison_pere);
  signal(SIGINT,terminaison_pere);

  if ((sock_ecoute=socket(AF_INET,SOCK_STREAM,0))==-1)
    erreur("echec de la fonction socket");

  mon_adr.sin_port=htons(PORT);
  mon_adr.sin_addr.s_addr=INADDR_ANY;
  mon_adr.sin_family=AF_INET;
  bzero(&(mon_adr.sin_zero),sizeof(mon_adr.sin_zero));
  if (bind(sock_ecoute,(struct sockaddr *)&mon_adr,sizeof(struct sockaddr))==-1)
    erreur("echec de la fonction bind");
  
  if (listen(sock_ecoute,BACKLOG)==-1)
    erreur("echec de la fonction listen");

  if (chdir(REPERTOIRE)==-1)
    erreur("mauvais repertoire de base");

  for (;;) /* boucle principale accept() */
  {
    while ((sock_service=accept(sock_ecoute,(struct sockaddr *)&son_adr,&lgadr))==-1)
      if (errno!=EINTR) erreur("echec de la fonction accept");

    if (!fork()) /* gestion de la requete */
    {
      close(sock_ecoute); /* le fils n'a pas besoin de cela */
      hote=gethostbyaddr((char *)&(son_adr.sin_addr),sizeof(struct in_addr),AF_INET);
      printf("%s (%s) - ",hote->h_name,inet_ntoa(son_adr.sin_addr));
      recv(sock_service,buffer,TAILLE_BUFFER,0);
      mot=(char *)strtok(buffer,DELIMITEUR);
      if (strcmp(mot,"GET")==0)
      {
	mot=(char *)strtok(NULL,DELIMITEUR);
	if (mot[0]!='/') printf("url invalide : %s\n",mot);
	else
 	{
	  if (mot[strlen(mot)-1]=='/') strcpy(&mot[strlen(mot)],"index.html");
          mot++;
	  if ((fic=fopen(mot,"r"))==NULL)
	  {
	    printf("GET /%s [404]\n",mot);
	    send(sock_service,"HTTP/1.0 404 Not Found\nServeur: Royale/0.2\nContent-type: text/html\n\n<h1>Page non trouv&eacute;e</h1>",100,0);
	  }
	  else
	  {
	    printf("GET /%s [200]\n",mot);
	    send(sock_service,"HTTP/1.0 200 OK\nServeur: Royale/0.2\nContent-type: text/html\n\n",61,0);
	    while (lus=fread(buffer,1,TAILLE_BUFFER,fic))
	      send(sock_service,buffer,lus,0);
	    fclose(fic);
	  }
	}
      }
      else printf("%s : méthode non implémentée !\n",mot);
      close(sock_service);
      exit(0);
    }

    close(sock_service); /* le père n'a pas besoin de cela */
  }

  close(sock_ecoute);
}

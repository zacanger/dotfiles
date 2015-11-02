.. [tit]ConfigParser[/tit]
.. [date]2007 12 14 11 29[/date]
.. [tags]Configuration,Parsing[/tags]


On a très souvent besoin dans une application d'un fichier de configuration,
ne serait-ce que pour donner par défaut à certaines variables, et enregistrer 
les changements effectués par l'utilisateur le cas échéant.

C'est le module ``ConfigParser`` qui se charge de cette tâche [Il en existe d'
autres, bien entendu].

Pour importer ce module, on écrira :

.. sourcecode:: python

    import ConfigParser

Un fichier de configuration est composé de sections. Dans chacune,
on peut associer un nom à :

- une chaîne
- un entier
- un décimal 
- booléen

Exemple d'un fichier simple ``maConfig.conf`` ::

    [MonBlog]
    BlogHomePage : http://moi.free.fr/MonSite/
    Host : ftpperso.free.fr
    User : moi
    Password : tr8zb9
    RemoteDir : MonSite

Ce fichier est composé d'une section ``MonBlog`` encadrée par les balises
 ``[`` et ``]`` .

.. attention::

    Notez un point très important (je me suis fais prendre au piège) : les valeurs 
    sont telles quelles, pas besoin de les encadrer par des guillemets, même si se
    sont des chaînes.

Lire le fichier de config
-------------------------

Une fois importé le module, on créé une instance de ``ConfigParser`` et il 
suffit alors de lire le fichier par la méthode 'read'. Ensuite, on capture les
valeurs de la config par la méthode 'get', comme ceci:

.. sourcecode:: python

    config = ConfigParser.ConfigParser()
    config.read(os.path.join(configdir,'maConfig.conf'))

    away = config.get('Away', 'BlogHomePage')
    host = config.get('Away', 'Host')
    user = config.get('Away', 'User')
    passw = config.get('Away', 'Password')
    remote = config.get('Away', 'RemoteDir')

A suivre ...

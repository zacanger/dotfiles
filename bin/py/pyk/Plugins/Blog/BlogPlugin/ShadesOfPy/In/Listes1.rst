.. [tit]Lister le contenu d'un répertoire[/tit]
.. [date]2007 12 13 20 22[/date]
.. [tags]Fichiers,Répertoires[/tags]


.. contents::


Il existe (au moins!) deux méthodes pour lister le contenu d'un répertoire 
donné avec Python. Nous allons les examiner ici et les comparer,car si elles 
réalisent le même travail, elles ne le font pas de la même façon et suivant les
cas, vous risquez d'avoir besoin de l'une ou l'autre.

Première méthode
----------------

Elle utilise la méthode ``listdir`` du module ``os`` :: 

    os.listdir(path)

Cette méthode renvoie une liste des noms de tous les fichiers et répertoires 
de path.

.. sourcecode:: python

    import os
    os.listdir('/home/kib/Public')

Une fois éxécuté, on aura en sortie :

.. sourcecode:: pycon

    ['Implementation_de_Plugins', 'BlogPerso', 'reStInPeace', 'Editor_With_Snippets', 'Japes', 'TabEditor', 'Mixins', 'Essais', 'genericTextEditor']    

Seconde méthode
---------------

Elle utilise la méthode ``glob`` du module ``glob``. On notera la différence 
par rapport à la méthode précédente : on peut spécifier une extension, ou 
utiliser l'étoile pour signifier que l'on prend tout.

La signature de cette méthode est la suivante : ::

    glob.glob(path)

Elle renvoie une liste contenant le chemin complet des fichiers ou répertoires
contenus dans ``path``.

Encore plus fort, si on veut lister tous les fichiers d'extension ``.py``,
il suffit d'écrire ``"*.py"``.

Notez aussi la différence en sortie : les noms des fichiers ou dossiers sont
complets (chemin + nom).

.. sourcecode:: python

    import glob
    glob.glob('/home/kib/Public/*')

En sortie, nous obtenons la liste suivante qui comparée à la première comporte
aussi le chemin des fichiers ou répertoires trouvés:

.. sourcecode:: pycon

    ['/home/kib/Public/Implementation_de_Plugins', '/home/kib/Public/BlogPerso', '/home/kib/Public/reStInPeace', '/home/kib/Public/Editor_With_Snippets', '/home/kib/Public/Japes', '/home/kib/Public/TabEditor', '/home/kib/Public/Mixins', '/home/kib/Public/Essais', '/home/kib/Public/genericTextEditor']
    

Comparaison
-----------

Les méthodes se valent grosso-modo en rapidité.


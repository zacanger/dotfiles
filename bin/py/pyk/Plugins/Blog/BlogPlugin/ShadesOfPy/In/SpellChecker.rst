.. [tit]Un correcteur syntaxique en 25 lignes de code[/tit]
.. [date]2007 12 13 23 59[/date]
.. [tags]Parsing,Texte[/tags]


Le script n'est évidemment pas le mien, mais tiré d'un article de `Peter Norvig [Directeur de Recherche chez Google] <http://www.norvig.com/spell-correct.html>`_ .   

.. sourcecode:: python

    import re, collections
    
    def words(text): return re.findall('[a-z]+', text.lower()) 
    
    def train(features):
        model = collections.defaultdict(lambda: 1)
        for f in features:
            model[f] += 1
        return model
    
    NWORDS = train(words(file('big.txt').read()))
    
    alphabet = 'abcdefghijklmnopqrstuvwxyz'
    
    def edits1(word):
        n = len(word)
        return set([word[0:i]+word[i+1:] for i in range(n)] +                     # deletion
                   [word[0:i]+word[i+1]+word[i]+word[i+2:] for i in range(n-1)] + # transposition
                   [word[0:i]+c+word[i+1:] for i in range(n) for c in alphabet] + # alteration
                   [word[0:i]+c+word[i:] for i in range(n+1) for c in alphabet])  # insertion
    
    def known_edits2(word):
        return set(e2 for e1 in edits1(word) for e2 in edits1(e1) if e2 in NWORDS)
    
    def known(words): return set(w for w in words if w in NWORDS)
    
    def correct(word):
        candidates = known([word]) or known(edits1(word)) or known_edits2(word) or [word]
    return max(candidates, key=lambda w: NWORDS[w])

En action !

.. sourcecode:: pycon

    >>> correct('speling')
    'spelling'
    >>> correct('korrecter')
    'corrector'

Hallucinant non ? 

Pour davantage de théorie, notamment sur les probas, je vous laisse regarder l'
article en question qui se trouve être très intéressant. Du reste, l'algo n'est
pas implémenté qu'en Python, mais aussi avec beaucoup d'autres languages...mais
c'est Python qui remporte le nombre de lignes minimal :)
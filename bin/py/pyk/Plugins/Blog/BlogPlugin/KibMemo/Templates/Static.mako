## -*- coding: utf-8 -*-
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Kib's Memo</title>
    <meta http-equiv="Content-Language" content="English" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="author" content="Kibleur Christophe" />
    <meta name="description" content="Articles" />
    <meta name="keywords" content="python, c++, LaTeX" />
    <meta name="Robots" content="index,follow" />
    <meta name="Generator" content="sNews 1.5" />
    <link rel="stylesheet" type="text/css" href="css/main.css" media="screen" />
    <link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="http://kib2.free.fr/Articles/kibmemo.xml" />
</head>
<body>


<div id="topbar">
        <div class="content">
            <div id="icons">
                    <a href="index.html" title="Home page"><img src="http://kib2.free.fr/images/home.gif" alt="Home" /></a>
                    <a href="/contact/" title="Contact us"><img src="http://kib2.free.fr/images/contact.gif" alt="Contact" /></a>

                    <a href="/sitemap/" title="Sitemap"><img src="http://kib2.free.fr/images/sitemap.gif" alt="Sitemap" /></a>
            </div>
            <div class="url">
                <a href="http://kib2.free.fr/Articles/index.html" title="">Kib's Memo</a>
            </div>
        </div>
</div>

<div id="top">
    <div class="content">

            <div id="menu">
                <ul>
                    <li><a href="http://kib2.free.fr/Articles/index.html" title="home"><span>Kib's Memo</span></a></li>
                    <li><a href="http://kib2.free.fr/Articles/kibmemo.xml" title="Affiliates"><span>RSS</span></a></li>
                    <li><a class="current" href="http://kib2.free.fr/Articles/a_propos.html" title="A propos du site"><span>A PROPOS</span></a></li>
                    <li><a href="http://kib2.free.fr/Articles/contact.html" title="Contact"><span>CONTACT</span></a></li>
                </ul>
            </div>
            <h1><a href="http://kib2.free.fr/Articles/index.html" title="">Kib's memo</a></h1>
            <h2>C’est bien la peine d’être brillant si la lumière est éteinte…[Santiago Lema]</h2>
    </div>
</div>


<div class="content">
    <div id="main">
        <div class="right_side">
            <div class="pad">
                <h3>Merci d'être ici!</h3>
                <p>
                <a href="http://kib2.free.fr/Articles/index.html" title="">Kib's memo</a> a été réalisé entièrement avec Python.
                <br /><a href="http://kib2.free.fr/Articles/a_propos.html" title="Read more">En savoir plus...</a>
                </p>
                <h3>Derniers Articles:</h3>
                        <ul>
                        % for post in articles:
                            <li><a href=" ${post.url} "> ${post.title} </a></li>
                        % endfor
                        </ul>

                <h3>Catégories:</h3>
                    <ul>
                    % for t in tags:
                        <li><a href=" ${t.url} "> ${t.tagname} (${t.get_number_of_posts})</a></li>
                    % endfor
                    </ul>

                <h3>Projets:</h3>
                    <ul>
                        <li><a href="http://kib2.webfactional.com/SnipEdit/" title="SnipEdit est un widget texte écrit avec wxPython qui permet les snippets"> SnipEdit </a></li>
                        <li><a href="http://kib2.webfactional.com/SnipEditCtrl/" title="SnipEditCtrl est un exemple d'utilisation de SnipEdit, qui peut aussi servir pour qui veut programmer avec le wxStyledTextCtrl"> SnipEditCtrl </a></li>
                        <li><a href="http://kib2.free.fr/Articles//geoPyX/geoPyX.html" title="Un module de géométrie Euclidienne"> géoPyX </a></li>
                        <li><a href="http://kib2.free.fr/Articles//reSTinPeace/" title="Un éditeur/convertisseur pour vos fichiers reSTructuredText"> reStInPeace </a></li>
                        <li><a href="http://kib2.free.fr/Articles//documents/InType/" title="Contributions perso à InType"> InType place </a></li>
                        <li><a href="http://kib2.free.fr/Articles//documents/Vim/" title="Contributions perso à Vim"> Vim place </a></li>
                        <li><a href="http://kib2.free.fr/Articles//documents/etexteditor/" title="Contributions perso à eTextEditor"> eTextEditor place </a></li>
                    </ul>

                    <a href="http://kib2.free.fr/Articles/kibmemo.xml" title="RSS Feed"><img src="images/rss.jpg" alt="RSS Feed" /></a>

            </div>
        </div>

        <div class="right_side">
            <div class="pad">
                <h3>Ailleurs:</h3>
                    <ul>
                    <li><a href="http://a.shortbrain.org/" title="Le blog de Vincent">ShortBrain</a></li>
                    <li><a href="http://www.biologeek.com/" title="Le blog de David">Biologeek</a></li>
                    <li><a href="http://programmation-python.org/sections/blog" title="Le blog de Tarek">Tarek</a></li>
                    <li><a href="http://www.unelectronlibre.info/" title="Le blog de NiCoS">Un electron libre</a></li>
                    <li><a href="http://www.kagou.fr" title="Le site de Kagou">Site de Kagou</a></li>
                    </ul>
                <h3>Programmation</h3>
                    <ul>
                    <li><a href="http://www.developpez.com/" title="">Développez</a></li>
                    <li><a href="http://www.siteduzero.com/" title="">Le site du zéro</a></li>
                    <li><a href="http://www.programmez.com/" title="">Programmez!</a></li>
                    </ul>

                <h3>Editeurs-IDE:</h3>
                    <ul>
                    <li><a href="http://intype.info/home/index.php" title="InType l'éditeur futuresque">InType</a></li>
                    <li><a href="http://e-texteditor.com/" title="Clône de TextMate">eTextEditor</a></li>
                    <li><a href="http://www.vim.org/" title="éditeur à tout faire">Vim</a></li>
                    <li><a href="http://www.gnu.org/software/emacs/" title="éditeur à tout faire">EMacs</a></li>
                    </ul>

                <h3>Liens Python:</h3>
                    <ul>
                    <li><a href="http://www.python.org/" title="Python">Python</a></li>
                    <li><a href="http://planet.python.org/" title="Les news sur Planet Python">Planet Python</a></li>
                    <li><a href="http://effbot.org/" title="Effbot">Effbot</a></li>
                    </ul>

                <h3>Liens LaTeX:</h3>
                    <ul>
                    <li><a href="http://melusine.eu.org/syracuse/" title="Certainement l'endroit où vous trouverez le plus de choses intéressantes.">Syracuse</a></li>
                    <li><a href="http://forum.mathematex.net/?sid=b24ce2d95d5cb3f95642d19f9d7aff00" title="Le forum de MathemaTeX">MathemaTeX</a></li>
                    <li><a href="http://wiki.mathematex.net/doku.php" title="Le wiki de MathemaTeX">Wiki MathemaTeX</a></li>
                    </ul>
            </div>
        </div>

        <div id="left_side">
            <div class="intro">
                <div class="pad"><p>Vous lisez ici une page statique.</p>
                </div>
            </div>
            <div class="mpart">
                <div class="post-entry">
               ${static}
                </div>
            </div>
        </div>
    </div>
    <div id="footer">

        <div class="right">&copy; Copyright Septembre 2007, Kib² sur un design inspiré pris sur le site <a href="http://www.free-css-templates.com">Free Css Templates</a></div>
            <a href="http://kib2.free.fr/Articles/kibmemo.xml" title="RSS Feed">RSS Feed</a> - <a href="http://validator.w3.org/check?uri=referer" title="Validate">XHTML</a> - <a href="http://jigsaw.w3.org/css-validator/check/referer" title="Validate">CSS</a>
            <a href="#"><img src="http://kib2.free.fr/images/python-powered.png" width="100" height="40" alt="Feed" /></a>
            <a href="http://www.haloscan.com/"><img width="88" height="31" src="http://www.haloscan.com/halolink.gif" border="0" alt="Weblog Commenting and Trackback by HaloScan.com" /></a>
    </div>
</div>

</body>
</html>

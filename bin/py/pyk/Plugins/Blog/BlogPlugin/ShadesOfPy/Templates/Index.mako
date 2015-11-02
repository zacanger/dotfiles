<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <title>Shades Of Py</title>
    <meta http-equiv="Content-Language" content="English" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="author" content="Kibleur Christophe" />
    <meta name="description" content="Python memo" />
    <meta name="keywords" content="Python" />
    <meta name="Robots" content="index,follow" />
    <meta name="Generator" content="sNews 1.5" />
    <link rel="stylesheet" type="text/css" href="main.css" media="screen" />
</head>

<!-- zero margin = wide layout -->
<body style="margin: 0;">

<div class="container">

    <div class="header">
        <a href="index.html"><span>Shades of Py</span></a>
    </div>

    <div class="stripes"><span></span></div>

    <div class="nav">
        <a href="index.html">Home</a>
        <a href="a_propos.html">A Propos</a>
        <a href="contact.html">Contact</a></li>
        <div class="clearer"><span></span></div>
    </div>

    <div class="stripes"><span></span></div>

    <div class="main">

        <div class="left">

            <div class="content">

                % for post in articles[:10]:
                <h1><a class="post" href=" ${post.url} ">${post.title}</a></h1>
                <div class="descr">
                    Snippet ${post.realid} écrit ${post.get_time} dans les catégories :
                    % for t in post.tags:
                            <a href=" ${t.url} "> ${t.tagname} </a>
                    % endfor
                </div>
                ${post.html_content}
                % endfor

            </div>

        </div>

        <div class="right">

            <div class="subnav">

                <h1>Shades of Py</h1>
                <p>Un memo perso sur Python</p>

                <h1>Les 10 Derniers Snippets</h1>
                <ul>
                % for p in articles[:10]:
                    <li><a href=" ${p.url} "> ${p.title} </a></li>
                % endfor
                </ul>

                <h1>Tags</h1>
                <ul>
                    % for t in tags:
                        <li><a href=" ${t.url} "> ${t.tagname} (${t.get_number_of_posts})</a></li>
                    % endfor
                </ul>

                <h1>Python Liens Officiels</h1>
                <ul>
                    <li><a href="http://www.python.org/" title="Python">Python</a></li>
                    <li><a href="http://planet.python.org/" title="Les news sur Planet Python">Planet Python</a></li>
                    <li><a href="http://effbot.org/" title="Effbot">Effbot</a></li>
                </ul>

                <h1>Python Blogs</h1>
                <ul>
                    <li><a href="http://lucumr.pocoo.org/">Armin Ronacher</a></li>
                    <li><a href="http://www.doughellmann.com/projects/PyMOTW/">Doug Hellmann's Module Of The Week</a></li>
                    <li><a href="index.html">semper</a></li>
                    <li><a href="index.html">magna sed purus</a></li>
                </ul>

                <h1>Python Docs</h1>
                <ul>
                    <li><a href="index.html">sociis natoque</a></li>
                    <li><a href="index.html">magna sed purus</a></li>
                    <li><a href="index.html">tincidunt</a></li>
                </ul>

            </div>

        </div>

        <div class="clearer"><span></span></div>

    </div>

    <div class="footer">

            <div class="col3">

                <h2>Copinage</h2>
                <ul>
                    <li><a href="http://a.shortbrain.org/" title="Le blog de Vincent">ShortBrain</a></li>
                    <li><a href="http://www.biologeek.com/" title="Le blog de David">Biologeek</a></li>
                    <li><a href="http://programmation-python.org/sections/blog" title="Le blog de Tarek">Tarek</a></li>
                </ul>

            </div>

            <div class="col3center">
                <h2>Ecoute-Visionnage</h2>
                <ul>
                    <li><a href="http://www.radiohead.com/deadairspace/">Radiohead</a></li>
                    <li><a href="http://www.emi.no/madrugada/">Madrugada</a></li>
                </ul>
            </div>

            <div class="col3">
                <h2>Lecture</h2>
                <ul>
                    <li><a href="http://www.amazon.fr/Programmation-Python-Tarek-Ziad%C3%A9/dp/2212116772/ref=pd_bbs_sr_2?ie=UTF8&s=books&qid=1197632917&sr=8-2">Programmation Python</a></li>
                    <li><a href="http://www.amazon.fr/Au-coeur-Python-Notions-fondamentales/dp/2744021482/ref=pd_bbs_6?ie=UTF8&s=books&qid=1197632917&sr=8-6">Au coeur de Python</a></li>
                    <li><a href="http://www.amazon.fr/Rapid-GUI-Programming-Python-Definitive/dp/0132354187/ref=pd_bbs_10?ie=UTF8&s=english-books&qid=1197632917&sr=8-10">Rapid GUI Programming with Python and Qt4</a></li>
                </ul>
            </div>

            <div class="bottom">

                <span class="left">&copy; 2007 <a href="index.html">Website.com</a>. Valid <a href="http://jigsaw.w3.org/css-validator/check/referer">CSS</a> &amp; <a href="http://validator.w3.org/check?uri=referer">XHTML</a>.</span>

                <span class="right"><a href="http://templates.arcsin.se">Website template</a> by <a href="http://arcsin.se">Arcsin</a></span>

                <div class="clearer"><span></span></div>

            </div>

    </div>


</div>

</body>

</html>

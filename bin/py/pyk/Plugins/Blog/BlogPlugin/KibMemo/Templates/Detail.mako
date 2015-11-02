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
        <a href="index2.html">Projects</a>
        <a href="index3.html">Contact</a></li>
        <div class="clearer"><span></span></div>
    </div>

    <div class="stripes"><span></span></div>

    <div class="main">

        <div class="left">

            <div class="content">

                <h1><a href=" ${p.url} ">${p.title}</a></h1>
                <div class="descr">
                    Article numéro ${p.realid} écrit ${p.get_time} dans les catégories :
                    % for t in p.tags:
                            <a href=" ${t.url} "> ${t.tagname} </a>
                    % endfor
                </div>
                ${p.html_content}

            </div>

        </div>

        <div class="right">

            <div class="subnav">

                <h1>Shades of Py</h1>
                <p>Just a little Python memo.</p>

                <h1>Tags</h1>
                <ul>
                    % for t in tags:
                        <li><a href=" ${t.url} "> ${t.tagname} (${t.get_number_of_posts})</a></li>
                    % endfor
                </ul>

                <h1>Python Official Links</h1>
                 <ul>
                    <li><a href="http://www.python.org/" title="Python">Python</a></li>
                    <li><a href="http://planet.python.org/" title="Les news sur Planet Python">Planet Python</a></li>
                    <li><a href="http://effbot.org/" title="Effbot">Effbot</a></li>
                </ul>

                <h1>Python Blogs</h1>
                <ul>
                    <li><a href="http://lucumr.pocoo.org/">Armin Ronacher</a></li>
                    <li><a href="index.html">sem justo</a></li>
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

                <h2>Tincidunt</h2>
                <ul>
                    <li><a href="index.html">consequat molestie</a></li>
                    <li><a href="index.html">sem justo</a></li>
                    <li><a href="index.html">semper</a></li>
                    <li><a href="index.html">magna sed purus</a></li>
                    <li><a href="index.html">tincidunt</a></li>
                </ul>

            </div>

            <div class="col3center">
                <h2>Sed purus</h2>
                <ul>
                    <li><a href="index.html">consequat molestie</a></li>
                    <li><a href="index.html">sem justo</a></li>
                    <li><a href="index.html">semper</a></li>
                    <li><a href="index.html">magna sed purus</a></li>
                    <li><a href="index.html">tincidunt</a></li>
                </ul>
            </div>

            <div class="col3">
                <h2>Praesent</h2>
                <ul>
                    <li><a href="index.html">consequat molestie</a></li>
                    <li><a href="index.html">sem justo</a></li>
                    <li><a href="index.html">semper</a></li>
                    <li><a href="index.html">magna sed purus</a></li>
                    <li><a href="index.html">tincidunt</a></li>
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

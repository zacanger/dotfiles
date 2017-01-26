import markdown
import codecs
import sys

md = markdown.Markdown()

html_header = '''
<!doctype html><html lang="en"><head>
<title></title>
<link href="github.css" rel="stylesheet" type="text/css" />
</head>
<body>
<div class="markdown-body">
'''

html_footer = '''
</div></body></html>
'''

def convert(file_name):
  # input file (*.md)
  md_file = codecs.open(file_name,encoding='utf-8',mode="r")
  code = markdown.markdown(md_file.read(), extensions=['gfm'])

  # output file (input.md.html)
  html_file = codecs.open(file_name+".html",encoding='utf-8',mode="w")
  html_file.write(html_header + code + html_footer)

if __name__ == "__main__":
  args = sys.argv
  if len(args) == 1:
    print("specify *.md file name from command line.")
  else:
    convert(args[1])

"""
Author:Sridarshan Shetty
twitter:http://twitter.com/sridarshan
email:sridarshan1@gmail.com
"""
import getpass,sys,pycurl,formats
username=getpass.getuser()
def validate(format):
	if formats.known_formats.has_key(format):
		return formats.known_formats[format]
	else:
		return "plain"
def uploadText(text,username,format):
	c = pycurl.Curl()
	values = [("paste_code", text),("paste_name",username)]
	if format!="plain":
		values.append(("paste_format",format))
	c.setopt(c.URL, "http://pastebin.com/api_public.php")
	c.setopt(c.HTTPPOST,  values)
	try:
		c.perform()
	except pycurl.error:
		print "Check your internet connection mate";
		return
	print " "
	c.close()
def getFormat(filename):
	if filename.count("/")!=0:
		temp=filename.count("/")
		filename=filename.split("/")[temp]
	if filename.count(".")==0:
		return "plain"
	temp=filename.count(".")
	format=filename.split(".")[temp]
	format=validate(format)
	
	return format
		
def main():
	if len(sys.argv)==1:
		print "Please specify the name of the file to be pasted\nSyntax : pastebin <name_of_the_file>"
		return
	filename=sys.argv[1]
	try:
		file=open(filename,"r")
		content=file.read()
		format=getFormat(file.name)
		uploadText(content,username,format)
	except IOError:
		print filename+ " doesn't exist in the current directory"
if __name__=="__main__":main()


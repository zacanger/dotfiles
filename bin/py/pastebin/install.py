"""
Author:Sridarshan Shetty
twitter:http://twitter.com/sridarshan
email:sridarshan1@gmail.com
"""
import getpass,os
file=open("/home/"+getpass.getuser()+"/.bashrc","a")
file.write("\n")
file.write("alias pastebin=\"python "+os.getcwd()+"/pastebin.py\"")
file.close() 

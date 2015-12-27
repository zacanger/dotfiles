#!/usr/bin/env python 
'''
http://ubuntuforums.org/showthread.php?t=1154940&highlight=get_dependencies
'''

import sys 
from subprocess import Popen,PIPE,STDOUT 


__usage__=''' 
compute_total_pkg_size.py emacs 
''' 

pkg=sys.argv[1] 


def report_lines(alist,max_len,vdiv,hline): 
    ''' 
    alist is a list of tuples 
    report_lines returns a list of strings 
    ''' 
    result=[] 
    svs=' '+vdiv+' ' 
    for row in alist: 
        if row[0]=='-': 
            line_string=hline 
        else: 
            data_justified=[str(elt).rjust(num) for elt,num in zip(row,max_len)] 
            data_svs=svs.join(data_justified) 
            line_list=[vdiv,data_svs,vdiv] 
            line_string=' '.join(line_list) 
        result.append(line_string) 
    return result 

def report_table(alist,corner='+',hdiv='-',vdiv='|',header=True): 
    max_len=max_col_len(alist) 
    hline_l=[corner, 
             corner.join([hdiv.ljust(max_num+2,hdiv)  
                          for max_num in max_len]), 
             corner] 
    hline=''.join(hline_l) 
    result=report_lines(alist,max_len,vdiv,hline) 
    if header: 
        new_result=[hline,result[0],hline,] 
        new_result.extend(result[1:]) 
    else: 
        new_result=[hline,] 
        new_result.extend(result) 
    new_result.append(hline) 
    result='\n'.join(new_result)+'\n' 
    return result 

def max_col_len(alist): 
    return [max([len(str(elt)) for elt in column]) for column in zip(*alist)] 

def find_installed(): 
    ''' 
    Returns a list of all the packages installed on the computer 
    ''' 
    proc=Popen("dpkg --get-selections | awk '/install/{print $1}'",  
               shell=True, stdout=PIPE, stderr=open('/dev/null'),) 
    return proc.communicate()[0].split() 

def get_size(pkg): 
    ''' 
    Returns (download size, installed size) in KiB 
    ''' 
    cmd='apt-cache show %s'%pkg 
    proc=Popen(cmd, shell=True, stdout=PIPE, ) 
    size=0 
    install_size=0 
    for line in proc.communicate()[0].split('\n'): 
        if line.startswith('Size: '): 
            size=line.split()[-1] 
        elif line.startswith('Installed-Size: '): 
            install_size=line.split()[-1] 
    return (int(size)/1024,int(install_size)) 

def get_dependencies(pkg): 
    ''' 
    Returns all the (recursive) dependencies of a package 
    ''' 
    cmd='apt-rdepends -s=DEPENDS %s'%pkg 
    proc=Popen(cmd, shell=True, stdout=PIPE, ) 
    return proc.communicate()[0].strip().split('\n') 
     
deps=get_dependencies(pkg) 
installed_packages=find_installed() 
needed_packages=list(set(deps)-set(installed_packages)) 
(sizes_dep,sizes_dep_installed)=zip(*[get_size(pkg) for pkg in deps]) 
(sizes_needed,sizes_needed_installed)=zip(*[get_size(pkg) for pkg in needed_packages]) 
data=[('Package (*=needed)','Download size (KiB)','Installed size (KiB)')] 
for apkg,size,install_size in zip(deps,sizes_dep,sizes_dep_installed): 
    if apkg in needed_packages: 
        data.append(('%s *'%apkg,size,install_size)) 
    else: 
        data.append((apkg,size,install_size)) 
print(report_table(data)) 

data=[('','Sizes (KiB)')] 
data.append(('Total download size',sum(sizes_dep))) 
data.append(('Total installed size',sum(sizes_dep_installed))) 
data.append(('Total download size needed',sum(sizes_needed))) 
data.append(('Total installed size needed',sum(sizes_needed_installed))) 
print(report_table(data))  

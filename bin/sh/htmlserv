##########uploading files##################
servefile -u <directory> #default port is 8080

#Using WGET to upload all png files in a directory
for i in *.png;do wget --post-file="$i" "http://localhost:8080/$i" -O- -q;done

#change port and usename and password
servefile -u ./ -p 9876 -a bob:linux

#######Download Files/Directory List#######
servefile -l
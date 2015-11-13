Instead of tail -f use
less +F *filename*

This will open less on a file in watch mode and typing CTRL + c will stop the
watch and default into normal less. To start watching the file again, just type
F.

history | awk '{a[$4]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head

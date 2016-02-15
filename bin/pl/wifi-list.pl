#!/bin/sh

if [ $# -lt 1 ]; then
	echo "usage: $(basename $0) INTERFACE" >&2
	exit 1
fi

iwlist "$1" scan | awk '
	BEGIN {
		c[0]  = "C";   a[0] = "Address";
		q[0]  = "Q";   s[0] = "ESSID";
		l[0]  = "L";   e[0] = -1;
		k[-1] = "Enc"; k[0] = "None"; k[1] = "WEP";
		k[3]  = "WPA"; k[5] = "WPA2"; k[7] = "WPA+WPA2";
	}
	$1 == "Cell" {
		a[++n] = $5;
	}
	$1 ~ "^Channel:" {
		split($1, t, ":");
		c[n] = t[2];
	}
	$1 ~ "^Quality=" {
		split($1, t, "=");
		q[n] = t[2];
		split($3, t, "=");
		l[n] = t[2];
	}
	$1 ~ "^ESSID:" {
		split($0, t, "\"");
		s[n] = t[2]
	}
	$0 ~ "Encryption key:on" {
		e[n] = 1;
	}
	$0 ~ "IE: WPA" {
		e[n] += 2;
	}
	$0 ~ "IEEE 802.11i/WPA2" {
		e[n] += 4;
	}
	END {
		if (n > 0) {
			for (i = 0; i <= n; i++) {
				printf("%-17s  %2s  %5s  %3s  %-8s  %s\n",
				       a[i], c[i], q[i], l[i], k[int(e[i])], s[i]);
			}
		}
	}'


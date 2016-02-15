#!/bin/bash

# Check your public routable IP address using ipinfo.io service
# The script first checks if the service can be accessed using the host command
# If the service is not accessible the script fails with an error code

command -v curl >/dev/null 2>&1 || { echo "Curl program not found. Please install it and try again"; exit 1; }
command -v host >/dev/null 2>&1 || { echo "Host program not found. Please install it and try again"; exit 1; }
host ipinfo.io >/dev/null 2>&1 \
&& curl -f ipinfo.io/ip \
|| exit 1

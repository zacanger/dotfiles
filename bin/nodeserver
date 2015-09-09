#!/bin/bash

nodeserver() {
    # Get port (if specified)
    local port="${1:-8000}"

    # Open in the browser
    open "http://localhost:${port}/"
    
    # Start HTTP Server
    http-server -p ${port}
}
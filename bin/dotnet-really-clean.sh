#!/bin/sh

dotnet clean
find . -name bin -type d -exec rm -r {} \;
find . -name obj -type d -exec rm -r {} \;

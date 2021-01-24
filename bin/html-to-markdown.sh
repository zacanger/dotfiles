#!/usr/bin/env bash
set -e

for html in *; do
    pandoc "$html" -o "$html.md"
done

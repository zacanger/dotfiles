#!/usr/bin/env node

require('fs').createReadStream(process.argv[2]).pipe(process.stdout)


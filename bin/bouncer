#!/usr/bin/env node

/*
 * bouncer
 * https://github.com/3rd-party-bouncer/bouncer
 *
 * Licensed under the MIT license.
 */

'use strict';

var Bouncer = require( '..' );
var chalk   = require( 'chalk' );
var program = require( 'commander' );
var fs      = require( 'fs' );
var path    = require( 'path' );


function list( val ) {
  return val.split( ',' );
}

program
  .version( require( '../package.json' ).version )
  .description( 'Track your 3rd parties the easy way' )
  .option( '-a, --allowed-domains <allowed>', 'Comma separated list of allowed 3rd party domains', list )
  .option( '-d, --debug', 'Enable verbose debug output' )
  .option( '-k, --key <key>', 'Set api key' )
  .option( '-l, --location <location>', 'Location of agent you want to run' )
  .option( '-o, --output <output>', 'Destingation of result output' )
  .option( '-r, --runs <runs>', 'Number of runs to evaluate loading times [ 1 ]' )
  .option( '-s, --server <server>', 'Webpagetest server you want to use [ www.webpagetest.org ]' )
  .option( '-u, --url <url>', 'Url you want to bounce (required)' )
  .on( '--help', function() {
    console.log( '  Example:' );
    console.log( '    $ bouncer --url www.some.url --allowed-domains www.some.url --key xxx --server xx.compute-1.amazonaws.com --output ./result.json' );
  } )
  .parse( process.argv );

var bouncer = new Bouncer( {
  allowedDomains : program.allowedDomains,
  key            : program.key,
  location       : program.location,
  runs           : program.runs,
  server         : program.server,
  url            : program.url
} );

bouncer.on( 'bouncer:error', function( error ) {
  console.log( chalk.red( '( ︶︿︶) ERROR: ' ) +  error );
} );

bouncer.on( 'bouncer:msg', function( msg ) {
  console.log( chalk.yellow( ' (╯°□°)╯  MSG: ' ) + msg );
} );

if ( program.debug ) {
  bouncer.on( 'bouncer:debug', function( msg ) {
    console.log( chalk.cyan( '  ಠ_ಠ   DEBUG: ' ) + msg );
  } );
}

bouncer.run( function( err, data ) {
  if ( err ) {
    throw err;
  }

  console.log( chalk.green( '(╯°□°)╯ ' ) + 'Bouncer finished!' );

  if ( program.output ) {
    var outputPath = path.resolve( program.output );

    fs.writeFileSync( outputPath, JSON.stringify( data ) );
    console.log( chalk.green( '(╯°□°)╯ ' ) + 'Written result to ' + chalk.green( outputPath ) );
  }
} );


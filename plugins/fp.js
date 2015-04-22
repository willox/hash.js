var request		= require( "request" );
var xml2js 		= require( "xml2js" );
var entities 	= new ( require( "html-entities" ).AllHtmlEntities );

var lastPostTime = 0;
var readyToGo = false;
var handledPosts = {};

// Setup our threads table
db.run( "CREATE TABLE IF NOT EXISTS threads ( id INTEGER PRIMARY KEY AUTOINCREMENT, thread TEXT UNIQUE )" );

function IntToBase62( i ) {

	var digits = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	var buf = [];

	do {

		var m = i % 62;
		buf.unshift( digits.charAt( m ) );

		i = Math.floor( i / 62 );

	} while ( i > 0 );

	return buf.join( "" );

}

function HandlePosts( posts ) {

	// Handle newer posts first
	for ( var i = posts.length - 1; i >= 0; i-- ) {

		var post = posts[ i ][ "$" ]

		lastPostTime = Math.max( post.date, lastPostTime );

		var html = entities.decode( post.html );

		// Read out some data badly
		var title = html.match(/href='showthread.*?>(.*?)</); title = title && title[1];
		var postID = html.match(/href='showthread\.php(.*?)&p=([0-9]+)/); postID = postID && postID[2];

		if ( !title || !postID || !readyToGo )
			continue;

		if ( handledPosts[ postID ] )
			continue;

		handledPosts[ postID ] = true;

		// We need a new scope for our title and postID values
		( function( title, postID ) {

			db.all( "SELECT thread FROM threads", function( err, rows ) {

				for ( var i = 0; i < rows.length; i++ ) {

					var lowerTitle = title.toLowerCase();

					if ( lowerTitle.indexOf( rows[i].thread.toLowerCase() ) != -1 ) {

						console.log( postID, IntToBase62( postID ) );
						bot.sendMessage( rows[i].thread + " - http://fcpn.ch/" + IntToBase62( postID ) );
						break;

					}

				}

			} );

		} )( title, postID );

	}

	readyToGo = true; // We ignore the first set of posts

}

function OnTicker( error, res, body ) {

	if ( error ) {
		console.trace( error );
		return;
	}

	xml2js.parseString( body, function( err, res ) {

		// Facepunch is dodgy
		if ( err )
			return; 

		if ( !res || !res.newposts || !res.newposts.post )
			return;

		HandlePosts( res.newposts.post );

	} );

}

function RequestTicker() {

	var options = {
		qs: {
			aj:			1,
			lasttime:	lastPostTime
		}
	}

	request( "http://facepunch.com/fp_ticker.php", options, OnTicker );

}

setInterval( RequestTicker, 2500 );

// Commands for controlling what threads we want

bot.registerCommand( "fplist", function() {
	
	db.all( "SELECT id, thread FROM threads", function( err, rows ) {

		var data = "Listening for:";

		if ( rows.length == 0 )
			data += " nothing.";
		else
			data += "\n";

		for ( var i = 0; i < rows.length; i++ ) {
			data += rows[i].id + " - " + rows[i].thread + "\n";
		}

		bot.sendMessage( data );

	} );

} );

bot.registerCommand( "fpadd", function( name, steamID, args, argstr ) {

	db.run( "INSERT INTO threads ( thread ) VALUES( ? )", argstr, function() {
		// We don't want to error if inserting a duplicate (let it fail silently who gives a shit)
	} );

} );

bot.registerCommand( "fpremove", function( name, steamID, args, argstr ) {

	db.run( "DELETE FROM threads WHERE id = ? OR thread = ?", argstr, argstr );

} );

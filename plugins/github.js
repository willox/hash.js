var config 	= require( "../config" );
var github 	= require( "../lib/github" )( config.GitHub );
var gitio 	= require( "../lib/gitio" );
var request = require( "request" );
var last = null;


github.on( "data", function( notification ) {

	github.markAsRead();

	var notificationTime = new Date( notification.updated_at )
	var currentTime = new Date()

	// Only show notifications if less than 3 minutes old
	if ( ( ( currentTime - notificationTime ) / 1e3 | 0 ) > 180 )
		return true;

	var url = notification.subject.url;

	// Ignore duplicate notifications made between 2s
	if ( last == url )
		return;

	last = url;

	setTimeout( function() {
		last = null;
	}, 2000 );

	var options = {
		headers: {
			"User-Agent": "Node-JS"
		}
	};
	
	bot.emit( "GithubUpdate", notification );

	request( notification.subject.url, options, function( error, req, body ) {

		if ( error ) {
			console.trace( error );
			return;
		}

		var obj = JSON.parse( body );

		var url = obj.html_url;

		// Shortern the URL
		gitio( url, function( err, shortUrl ) {

			if ( err )
				bot.sendMessage( notification.subject.title + "\n" + url );
			else
				bot.sendMessage( notification.subject.title + " - " + shortUrl );

		} );

	} );

} );

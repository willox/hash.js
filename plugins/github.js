var config 	= require( "../config" );
var github 	= require( "../lib/github" )( config.GitHub );
var gitio 	= require( "../lib/gitio" );
var https 	= require( "https" );

var repositories = {
	"garrysmod-issues": true,
	"garrysmod-requests": true,
	"garrysmod": true
}

var last = null;


github.on( "data", function( notification ) {

	github.markAsRead();

	var repo = repositories[ notification.repository.name ]

	// We don't want notifications about this repo
	if ( repo == undefined )
		return true;

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

	https.get( {
		host: "api.github.com",
		path: url,
		method: "GET",
		headers: {"User-Agent": "Node-JS"}
	}, function( res ) {

		var buf = [];

		res.on( "data", function( chunk ) {
			buf.push( chunk );
		} );

		res.on( "end", function() {

			buf = buf.join( "" );

			var obj = JSON.parse( buf );

			url = obj.html_url;

			// Shortern the URL
			gitio( url, function( err, shortUrl ) {

				if ( err )
					bot.sendMessage( notification.subject.title + "\n" + url );
				else
					bot.sendMessage( notification.subject.title + " - " + shortUrl );

			} );

		} );

	} );

} );
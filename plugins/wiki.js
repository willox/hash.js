var http = require( "http" );

var methods = {};

//
// Populate our Wiki knowledge
//
http.get( {
	hostname: "wiki.garrysmod.com",
	port: 80,
	path: "/api.php?action=query&list=allpages&aplimit=5000&format=json"
}, function( res ) {

	var buf = [];

	res.on( "data", function( chunk ) {
		buf.push( chunk );
	} );

	res.on( "end", function() {

		buf = buf.join( "" );

		var pages = JSON.parse( buf );

		if ( !pages || !pages.query || !pages.query.allpages )
			return;

		pages = pages.query.allpages;

		for ( var i = 0; i < pages.length; i++ ) {

			var title = pages[ i ].title;

			var match = title.match( /(.*?)\/(.*)/ );

			if ( !match )
				continue;

			var	namespace	= match[ 1 ],
				method		= match[ 2 ];

			var fullName = namespace + "." + method;

			if ( namespace == "Global" ) {
				fullName = method;
			}

			var airyMethod = fullName + "( ... )";
			var slimMethod = fullName + "(...)";

			methods[ airyMethod ] = namespace + "/" + method;
			methods[ slimMethod ] = namespace + "/" + method;

		}

	} );

} );

bot.on( "Message", function( name, steamID, msg ) {
	
	var matches = msg.match( /(\S*)\( ?\.\.\. ?\)/g );

	if ( !matches )
		return;

	for ( var i = 0; i < matches.length; i++ ) {

		var match = matches[ i ];

		if ( methods.hasOwnProperty( match ) )
			bot.sendMessage( "http://wiki.garrysmod.com/page/" + methods[ match ] );

	}

} );

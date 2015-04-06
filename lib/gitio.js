var qs		= require( "querystring" );
var http	= require( "http" );

module.exports = function( address, callback ) {

	var post_data = qs.stringify( {
		url: address
	} );

	var post_options = {
		host: "git.io",
		port: 80,
		method: "POST",
		path: "/",
		headers: {
			"Content-Type": "application/x-www-form-urlencoded",
			"Content-Length": post_data.length
		}
	};

	var req = http.request( post_options, function( res ) {

		res.resume(); // Ensure we consume data

		res.on( "end", function() {

			if ( res.headers.location )
				return callback( null, res.headers.location );

			return callback( new Error( "HTTP Error", res.headers.status ), null );

		} );

	} );

	req.write( post_data );
	req.end();

};

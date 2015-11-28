bot.on( "Message", function( name, steamID, msg, group ) {
	
	var res = /\bskid[^ ]*\b/.exec( msg );
	if ( res )
		bot.sendMessage( res[0] + "*", group );

} );

bot.on( "Message", function( name, steamID, msg ) {
	
	if ( /\bskid(die|s)?\b/.test( msg ) )
		bot.sendMessage( "lamer*" );

} );

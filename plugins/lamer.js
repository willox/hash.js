bot.on( "Message", function( name, steamID, msg, group ) {
	
	if ( /\bskid(die|s)?\b/.test( msg ) )
		bot.sendMessage( "lamer*", group );

} );

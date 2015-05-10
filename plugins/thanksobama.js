bot.on( "Message", function( name, steamID, msg, group ) {

	if ( /\b(?:thanks|ty)\s(?:hash\b|#(?:(?=\s)|$))/i.test( msg ) )
		bot.sendMessage( "You're welcome.", group );

} );

bot.on( "Message", function( name, steamID, msg ) {

	if ( /\b(thanks|ty) (#|hash)\b/i.test( msg ) )
		bot.sendMessage( "You're welcome." );

} );

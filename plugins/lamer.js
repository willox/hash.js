bot.on( "Message", function( name, steamID, msg, group ) {
	
	var res = /\bskid([^ ]*)\b/i.exec( msg );
	if ( res )
		bot.sendMessage( "lamer" + res[1] + "*", group );

} );

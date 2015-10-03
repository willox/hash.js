db.run( "CREATE TABLE IF NOT EXISTS limited ( user TEXT PRIMARY KEY )", function() {

	db.get( "SELECT user FROM limited", function( err, row ) {

		if ( err )
			throw err;

		if ( row )
			bot.setLimited( row.user, true );

	} );


} );

bot.registerCommand( "limit", function( name, steamID, args, argstr, group ) {

	if ( !bot.isAdmin( steamID ) )
		return;

	if ( !argstr.match("^[0-9]+$") ) {
		bot.sendMessage( "Argument must be the users SteamID64.", group );
		return;
	}

	bot.setLimited( argstr, true );

	db.run( "INSERT INTO limited VALUES ( ? )", argstr, function( err ) {
		// Ignore errors
	} )

}, "[ADMIN] Limit a user from using the bot. [Takes a SID64]" );

bot.registerCommand( "unlimit", function( name, steamID, _, argstr ) {

	if ( !bot.isAdmin( steamID ) )
		return;

	bot.setLimited( argstr, false );

	db.run( "DELETE FROM limited WHERE user = ?", argstr );

}, "[ADMIN] Remove a user from the limit list. [Takes a SID64]" );

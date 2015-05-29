db.run( "CREATE TABLE IF NOT EXISTS limited ( user TEXT PRIMARY KEY )", function() {

	db.get( "SELECT user FROM limited", function( err, row ) {

		if ( err )
			throw err;

		if ( row )
			bot.setLimited( row.user, true );

	} );


} );

bot.registerCommand( "limit", function( name, steamID, _, argstr ) {

	if ( !bot.isAdmin( steamID ) )
		return;

	bot.setLimited( argstr, true );

	db.run( "INSERT INTO limited VALUES ( ? )", argstr )

} );

bot.registerCommand( "unlimit", function( name, steamID, _, argstr ) {

	if ( !bot.isAdmin( steamID ) )
		return;

	bot.setLimited( argstr, false );

	db.run( "DELETE FROM limited WHERE user = ?", argstr );

} );

db.run( "CREATE TABLE IF NOT EXISTS memories ( id INTEGER PRIMARY KEY AUTOINCREMENT, memory TEXT UNIQUE )" );

var last_id = null;
var last_msg = null;
var silent = true;

bot.on( "Message", function( name, steamID, msg ) {

	if ( msg == "^" && last_msg ) {
		db.run( "INSERT INTO memories ( memory ) VALUES ( ? )", last_msg, function( err ) {

			last_id = this.lastID

		} );

		return;
	}

	if ( msg == "v" && last_id ) {
		db.run( "DELETE FROM memories WHERE id = ?", last_id );

		return;
	}
	
	last_msg = name + ": " + msg;
	silent = false;

} );

function Spout() {

	if ( silent )
		return;

	db.get( "SELECT id, memory FROM memories ORDER BY RANDOM() LIMIT 1", function( err, row ) {

		if ( !err && row ) {
			last_id = row.id;
			last_msg = row.memory;
			
			bot.sendMessage( row.memory );
		}

	} );

	silent = true;
	
}

// setInterval( Spout, 36 * 1000 * 60 ); // Every 36 minutes
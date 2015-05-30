// Database //

db.run( "CREATE TABLE IF NOT EXISTS last_seen(\
  user TEXT PRIMARY KEY, \
  name TEXT, \
  time TEXT )" );

// Util //

var minute = 60;
var hour = 60 * 60;
var day = 60 * 60 * 24;
var week = 60 * 60 * 24 * 7;
var month = 60 * 60 * 24 * 30;
var year = 60 * 60 * 24 * 365

function plur( num, suffix ) {
	num = Math.floor( num );
	return num == 1 ? num + suffix : num + suffix + "s";
}

function niceTimeSpan( seconds ) {
	if ( seconds > year )
		return plur( seconds / year, " year" );
	else if ( seconds > month )
		return plur( seconds / month, " month" );
	else if ( seconds > week )
		return plur( seconds / week, " week" );
	else if ( seconds > day )
		return plur( seconds / day, " day" );
	else if ( seconds > hour )
		return plur( seconds / hour, " hour" );
	else if ( seconds > minute )
		return plur( seconds / minute, " minute" );
	else
		return plur( seconds, " second" );
}

function getLastSeenMsg( name, cur_name, sid, time ) {
	var msg = cur_name + " (" + sid + ") was last seen ";
	msg += niceTimeSpan( ( new Date() - new Date( time ) ) / 1000 );
	msg += " ago";
	if ( name && name != cur_name )
		msg += " as " + name;
	msg += ".";

	return msg;
}

// Event //

bot.on( "UserConnected", function( name, sid, group ) {
	db.get( "SELECT name, time FROM last_seen WHERE user = ?",
	  sid,
	  function( err, row ) {

		if ( !err && row ) {
			// Visited Before

			var elapsed = ( new Date() - new Date( row.time ) ) / 1000;
			if ( elapsed >= (2*day) ) {
				bot.sendMessage( getLastSeenMsg( row.name, name, sid, row.time ), group );
			}

			db.run( "UPDATE last_seen \
			  SET time = ?, name = ? WHERE user = ?",
			  new Date().toString(), name, sid );

		} else {
			// New friend!

			bot.sendMessage( name + " has joined chat for the first time!", group );

			db.run( "INSERT INTO last_seen \
			  ( user, name, time ) VALUES ( ?, ?, ? )",
			  sid, name, new Date().toString() );

		}

	} );
} );

bot.on( "UserDisconnected", function( name, sid ) {

	db.run( "UPDATE last_seen \
	  SET time = ?, name = ? WHERE user = ?",
	  new Date().toString(), name, sid );

} );

// Command //

bot.registerCommand( "lastseen", function( name, steamID, _, arg_str, group ) {

    var _ref;

	db.all( "SELECT user, name, time FROM last_seen \
	  WHERE name LIKE ? OR user = ? \
	  ORDER BY name LIMIT 11",
	  "%" + arg_str + "%",
	  arg_str,
	  function( err, rows ) {

		if ( err ) {
			console.error( err );
			return bot.sendMessage( "Error!", group );
		}

		if ( rows.length == 0 )
			return bot.sendMessage( "Nobody found with the name '" + arg_str
			  + "'.", group );

		var output = "";

		if ( rows.length == 11 ) {
			output += "More than 10 entries! Some entries have been omitted.\n";
			rows.pop();
		}

		for ( var x = 0; x < 10; x++ )
			if ( rows[x] != null ) {
				var row = rows[x];

				if ( bot.Client.chatRooms[ bot.GroupID ][ row.user ] != null )
					output += row.name + " is in the chat right now!";
				else
					output += getLastSeenMsg( null, row.name, row.user, row.time ) + "\n";
			}

		bot.sendMessage( output, group );

	} );

}, "Returns the last time a user was seen in the group chat by name or username." );

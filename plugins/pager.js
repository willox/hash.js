// Notifies a user via PM when a string is mentioned in chat.

db.run( "CREATE TABLE IF NOT EXISTS pager_strings(\
 substring TEXT PRIMARY KEY,\
 steamid UNSIGNED INT )", [], function( err, a, b ) {
	console.log( this, err, a, b );
 }
);

bot.registerCommand( ".addpager", function( name, _, _, arg_str, group ) {



}, "Adds a string to monitor for in the group chat and be paged when said." );

bot.registerCommand( ".rmpager", function( name, _, _, arg_str, group ) {



}, "Remove an existing string from the monitor." );

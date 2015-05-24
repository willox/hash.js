// Notifies a user via PM when a string is mentioned in chat.

/*db.run( "CREATE TABLE IF NOT EXISTS pager_strings(\
 substring TEXT PRIMARY KEY,\
 steamid UNSIGNED INT )", [], function( err, a, b ) {
	//console.log( this, err, a, b );
 }
);*/

bot.on( "TextMessage", function( username, steamid, message, groupid ) {
    //console.log("TextMessage ", username, steamid, message, groupid);
} );

bot.registerCommand( "pageradd", function( name, _, _, arg_str, group ) {

}, "Adds a string to monitor for in the group chat and be paged when said." );


bot.registerCommand( "pagerrm", function( name, _, _, arg_str, group ) {

}, "Remove an existing string from the monitor." );


bot.registerCommand( "pagerls", function( name, _, _, arg_str, group ) {

}, "List existing strings that are being monitored." );


bot.registerCommand( "pagersetting", function( name, _, _, arg_str, group ) {

}, "Set/get settings for the pager. [Use `.pagersetting help` for more info." );

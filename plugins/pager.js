// Notifies a user via PM when a string is mentioned in chat.
var config = require("../config");

db.run( "CREATE TABLE IF NOT EXISTS pager_phrases (steamid VARCHAR(22),\
        phrase VARCHAR(32), PRIMARY KEY (steamid, phrase))"
);
db.run( "CREATE TABLE IF NOT EXISTS pager_settings (steamid VARCHAR(22),\
        key VARCHAR(32), valuetype CHAR(1), value VARCHAR(32),\
        PRIMARY KEY (steamid, key))"
);

function TryPageUser( targetsid, matched, message, speaker ) {
    var chatroom = bot.Client.chatRooms[config.Group]
    if ( chatroom && !chatroom[targetsid] ){
        bot.sendMessage( speaker + ": " + message, targetsid )
    }
}

bot.on( "TextMessage", function( username, steamid, message, groupid ) {

    db.each( "SELECT steamid, phrase FROM pager_phrases WHERE instr((?), phrase)",
    [ message || "" ],
    function( error, row ) {
        if ( row ){
            TryPageUser( row.steamid, row.phrase, message, username );
        }
    } );

} );

bot.registerCommand( "pageradd", function( name, steamid, args, argstr, group ) {

    if ( argstr == "" ) {
        // help
    } else {
        bot.addFriend( steamid );
        db.run( "INSERT OR IGNORE INTO pager_phrases VALUES ((?), (?))",
        [ steamid, argstr ] );
    }

}, "Adds a string to monitor for in the group chat and be paged when said." );


bot.registerCommand( "pagerrm", function( name, steamid, args, argstr, group ) {

    var phraseid = 1;
    db.each( "SELECT steamid, phrase FROM pager_phrases WHERE steamid=(?)",
    [ steamid ],
    function( error, row ) {
        if ( args[0] == phraseid ) {
            db.run( "DELETE FROM pager_phrases WHERE steamid=(?) AND phrase=(?)",
            [ steamid, row.phrase ] );
        }
        phraseid++;
    } );

}, "Remove an existing string from the monitor." );


bot.registerCommand( "pagerls", function( name, steamid, args, argstr, group ) {

    var phraseid = 1;
    var message  = "Current Pager Phrases:\n";

    db.each( "SELECT phrase FROM pager_phrases WHERE steamid=(?)",
    [ steamid ],
    function( error, row ) {
        message += phraseid + " - " + row.phrase + "\n";
        phraseid++;
    },
    function( error, numrows ) {
        if ( numrows < 1 ) {
            message += "No phrases added. Use .pageradd [phrase] to add some.";
        }
        bot.sendMessage( message, group );
    } );

}, "List existing strings that are being monitored." );


bot.registerCommand( "pagersetting", function( name, steamid, args, argstr, group ) {
    // TODO
}, "Set/get settings for the pager. [Use `.pagersetting help` for more info." );

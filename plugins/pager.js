// Notifies a user via PM when a string is mentioned in chat.
var config = require("../config");
var lastactive = {} // Object store for the last time a user did something

var defaultsettings = {
    notifywhenpresent: {
        default:  false,
        helptext: "Should you be paged when a phrase is matched and you're in the group chat."
    },
    notifyawaytime: {
        default:  0,
        helptext: "Only notify (when in the group chat) after X seconds of inactivity. [0 to disable]."
    }
}

db.run( "CREATE TABLE IF NOT EXISTS pager_phrases (steamid VARCHAR(22),\
        phrase VARCHAR(32), PRIMARY KEY (steamid, phrase))"
);

db.run( "CREATE TABLE IF NOT EXISTS pager_settings (steamid VARCHAR(22),\
        key VARCHAR(32), valuetype CHAR(1), value VARCHAR(32),\
        PRIMARY KEY (steamid, key))"
);

// Remove settings that don't have a member in the defaultsettings object.
var removerows = [];
db.each( "SELECT steamid, key, valuetype, value FROM pager_settings",
    function( error, row ) {
        if ( row && !defaultsettings[ row.key ] ) {
            db.run( "DELETE FROM pager_settings WHERE\
                steamid=(?) AND key=(?) AND valuetype=(?) AND value=(?)",
                [ row.steamid, row.key, row.valuetype, row.value ]
            );
            console.log( "Removed unsupported setting from DB: ", row );
        }
    }
);


// Updates the lastactive object when a user does something
function UserPerformedAction( steamid ) {
    var epoch = Math.floor((new Date).getTime()/1000);
    lastactive[steamid] = epoch;
}

// Returns a kv object where the keys are the setting name and values as their corresponding value and datatype
// Takes a kv object with the key as the setting name and the value as another object with these members:
//     datatype: "char"  // The datatype of the corresponding value. "s" for string, "n" for number, "b" for bool.
//     value:    "value" // The value of the setting as a string.
// Will return a default value for any settings not specified in the usersettings object.
function ParsePagerSettings( usersettings ) {
    var settings = {};

    for ( var key in defaultsettings ) {
        if ( defaultsettings.hasOwnProperty( key ) ) {
            settings[key] = defaultsettings[key].default;
        }
    }

    for ( var key in usersettings || {} ) {
        if ( usersettings.hasOwnProperty( key ) ) {
            var valueinfo = usersettings[key];
            var datatype  = valueinfo.datatype;
            var value     = valueinfo.value;

            switch( datatype.toLowerCase() ) {
                case "s":
                    value = value.toString();
                    break;
                case "n":
                    value = Number(value) || 0;
                    break;
                case "b":
                    value = value.toString().toLowerCase();
                    value = value[0] == "t" ? true : false;
                    break;
                default:
                    value = value.toString();
                    break;
            }

            settings[key] = value;
        }
    }

    return settings;
}

// Tries to notify a user when a monitored phrase was said.
// This will go through the user's settings to make sure the user wants
// to be notified under the current circumstances.
function TryPageUser( targetsid, matched, message, speaker ) {
    var chatroom = bot.Client.chatRooms[config.Group]

    if ( chatroom ) {
        var usersettings = {}
        db.each( "SELECT steamid, key, valuetype, value FROM pager_settings WHERE steamid=(?)",
            [ targetsid ],           // Parameters
            function( error, row ) { // Row callback
                if ( row ) {
                    usersettings[row.key] = {
                        datatype: row.valuetype,
                        value:    row.value
                    }
                }
            },
            function( error, numrows ) { // Completion callback
                var settings = ParsePagerSettings( usersettings );

                if ( settings.notifywhenpresent && chatroom[targetsid] ) {
                    // User is in the channel but still wants to be paged
                    if ( settings.notifyawaytime == 0 ) {
                        bot.sendMessage( speaker + ": " + message, targetsid );
                    } else {
                        var cooldown = settings.notifyawaytime;
                        var nextpage = lastactive[targetsid] + cooldown
                        if ( nextpage <= Math.floor((new Date).getTime()/1000) ) {
                            bot.sendMessage( speaker + ": " + message, targetsid );
                        }
                    }
                } else if ( !chatroom[targetsid] ) {
                    bot.sendMessage( speaker + ": " + message, targetsid )
                }
            }
        );
    }
}

bot.Client.on( "message", function( group, msg, type, user ) {

    UserPerformedAction( user );

} );

bot.on( "UserConnected", function( name, steamID ) {

    UserPerformedAction( steamID );

} );

bot.on( "TextMessage", function( username, steamid, message, groupid ) {

    var notifications = {}
    db.each( "SELECT steamid, phrase FROM pager_phrases WHERE instr((?), phrase)",
        [ message || "" ],       // Parameters
        function( error, row ) { // Row callback
            if ( row ) {
                notifications[row.steamid] = {
                    phrase:   row.phrase,
                    message:  message,
                    username: username
                }
            }
        },
        function( error, numrows ) { // Completion callback
            for ( var key in notifications ) {
                if ( notifications.hasOwnProperty( key ) ) {
                    var info = notifications[key];
                    TryPageUser( key, info.phrase, info.message, info.username );
                }
            }
        }
    );

} );

bot.registerCommand( "pageradd", function( name, steamid, args, argstr, group ) {

    if ( argstr == "" ) {
        bot.sendMessage( "Use `.pageradd [phrase or word]` to add a notification string.", group );
        return

    } else {
        var matchphrase = "";
        db.each( "SELECT phrase FROM pager_phrases WHERE steamid=(?) AND instr((?), phrase)",
            [ steamid, argstr ],    // Parameters
            function( error, row ){ // Row callback
                if ( row && row.phrase ) {
                    matchphrase = row.phrase;
                }
            },
            function( error, numrows ){ // Completion callback
                if ( numrows < 1 ) {    // This phrase doesn't contain another substring phrase
                    bot.addFriend( steamid );
                    db.run( "INSERT OR IGNORE INTO pager_phrases VALUES ((?), (?))",
                    [ steamid, argstr ] );
                } else {
                    var message = "The phrase \"" + argstr + "\" matches the already existing phrase ";
                    message += "\"" + matchphrase + "\".";
                    bot.sendMessage( message, group )
                }
            }
        );
    }

}, "Adds a string to monitor for in the group chat and be paged when said." );


bot.registerCommand( "pagerrm", function( name, steamid, args, argstr, group ) {

    if (args.length < 1) {
        var lscommand = bot.Commands["pagerls"];
        if (lscommand && lscommand.callback) {
            bot.sendMessage( "Use `.pagerrm [number]` to remove a pager string.", group );
            lscommand.callback.call( this, name, steamid, args, argstr, group );
            return
        }
    }

    var phraseid = 1;
    db.each( "SELECT steamid, phrase FROM pager_phrases WHERE steamid=(?)",
        [ steamid ],             // Parameters
        function( error, row ) { // Row callback
            if ( args[0] == phraseid ) {
                db.run( "DELETE FROM pager_phrases WHERE steamid=(?) AND phrase=(?)",
                [ steamid, row.phrase ] );
            }
            phraseid++;
        }
    );

}, "Remove an existing string from the monitor." );


bot.registerCommand( "pagerls", function( name, steamid, args, argstr, group ) {

    var phraseid = 1;
    var userinfo = bot.Client.users[steamid];
    var username = userinfo ? userinfo.playerName : steamid.toString();
    var message  = "Current Pager Phrases for " + username + ":\n";

    db.each( "SELECT phrase FROM pager_phrases WHERE steamid=(?)",
        [ steamid ],             // Parameters
        function( error, row ) { // Row callback
            message += phraseid + " - " + row.phrase + "\n";
            phraseid++;
        },
        function( error, numrows ) { // Completion callback
            if ( numrows < 1 ) {
                message += "No phrases added. Use .pageradd [phrase] to add some.";
            }
            bot.sendMessage( message, group );
        }
    );

}, "List existing strings that are being monitored." );


bot.registerCommand( "pagersetting", function( name, steamid, args, argstr, group ) {
    var arg1 = args[0];

    if ( arg1 == "list" ) {
        var usersettings = {};
        db.each( "SELECT steamid, key, valuetype, value FROM pager_settings WHERE steamid=(?)",
            [ steamid ],             // Parameters
            function( error, row ) { // Row callback
                if ( row ) {
                    usersettings[row.key] = {
                        datatype: row.valuetype,
                        value:    row.value
                    }
                }
            },
            function( error, numrows ) { // Completion callback
                var settings = ParsePagerSettings( usersettings );
                var userinfo = bot.Client.users[steamid];
                var username = userinfo ? userinfo.playerName : steamid.toString();
                var message  = "Current Pager Settings for " + username + ":\n";

                for ( var key in settings ) {
                    if ( settings.hasOwnProperty( key ) ) {
                        message += "\t" + key + " = " + settings[key].toString();
                        message += " : [Default: " + defaultsettings[key].default.toString() + "]";
                        message += " " + defaultsettings[key].helptext + "\n";
                    }
                }

                bot.sendMessage( message, group );
            }
        );

    } else if ( arg1 == "get" ) {
        if ( args.length < 2 ) {
            bot.sendMessage( "You must specify a key. `.pagersetting get [key]`", group );
            return
        }

        var key = args[1];
        if ( !defaultsettings[key] ) {
            var message = "\"" + key + "\" isn't a valid setting. ";
            message += "Use `.pagersetting list` for a list of valid settings";
            bot.sendMessage( message, group );
            return;
        }

        var usersettings = {};
        db.each( "SELECT steamid, key, valuetype, value FROM pager_settings WHERE steamid=(?) AND key=(?)",
            [ steamid, key ],        // Parameters
            function( error, row ) { // Row callback
                if ( row ) {
                    usersettings[row.key] = {
                        datatype: row.valuetype,
                        value:    row.value
                    }
                }
            },
            function( error, numrows ) { // Completion callback
                var settings = ParsePagerSettings( usersettings );
                if ( settings[key] ) {
                    bot.sendMessage( key + " = " + settings[key].toString() );
                }
            }
        );

    } else if ( arg1 == "set" ) {
        if ( args.length < 2 ) {
            bot.sendMessage( "You must specify a key. `.pagersetting set [key] [value]`", group );
            return
        }
        var key   = args[1];
        var value = args[2];

        if ( !defaultsettings[key] ) {
            var message = "\"" + key + "\" isn't a valid setting. ";
            message += "Use `.pagersetting list` for a list of valid settings";
            bot.sendMessage( message, group );
            return;
        }
        var datatype = typeof(defaultsettings[key].default);
        datatype = datatype ? datatype[0] : "s";

        if ( !value ) { // Set to default when no value specified
            value = defaultsettings[key].default;
        }

        db.run( "INSERT OR REPLACE INTO pager_settings VALUES ((?), (?), (?), (?))",
            [ steamid, key, datatype, value ] // Parameters
        );

    } else {
        var message = "Pager Commands:\n"
        message += "\t.pagersetting list              : Return all availible options for the pager system.\n";
        message += "\t.pagersetting get [key]         : Get the value of the current option by [key].\n";
        message += "\t.pagersetting set [key] [value] : Set the option [key] to [value] or default if [value] not specified.\n";
        bot.sendMessage( message, group )
    }

}, "Set/get settings for the pager. [Use `.pagersetting help` for more info." );

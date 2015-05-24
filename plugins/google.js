bot.on( "Message", function( name, steamID, msg, group ) {
        if ( /\bxD?\b/.test( msg ) && steamID == "76561198093185405")
                bot.kick(steamID);
} );

bot.registerCommand( "google", function( name, steamID, _, arg_str ) {
        bot.sendMessage("http://google.com/?q=" + encodeURIComponent(arg_str));
}, "Gives you a google link with message as the query." );

bot.on( "Message", function( name, steamID, msg, group ) {
        if ( /\bxD?\b/.test( msg ) && steamID == "76561198093185405")
                bot.kick(steamID);
} );
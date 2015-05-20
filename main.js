var config = require( "./config" );

//
// Connection Handler
//

bot.on( "Connected", function() {

	this.setStatus( "Online" );
	this.setChat( config.Group );

} );


//
// Default Command Functions
//

function commandlist(name, steamID, args, argstr, group) {

	var helptext = "Current Commands:\n";
	for ( var key in this.Commands ) {
		if (this.Commands.hasOwnProperty(key)) {
			var cmdinfo = this.Commands[key];
			var cmdhelp = cmdinfo.helptext;

			helptext += "\t." + key;
			if ( cmdhelp ) {
				helptext += " : " + cmdhelp;
			}
			helptext += "\n";
		}
	}
	// TODO: Send multiple messages if helptext exceeds steam message limit
	bot.sendMessage(helptext, steamID);
	if (steamID != group) {
		bot.sendMessage( "I have private messaged you the commands " + name + "." );
	}

}

//
// Default Commands
//

bot.registerCommand( "update", function( name, steamID ) {

	if ( bot.isAdmin( steamID ) )
		process.exit( 1 );

}, "[ADMIN] Forces the bot to rejoin the group chat." );

bot.registerCommand( "add", function( name, steamID ) {

	bot.addFriend( steamID );

}, "Makes the bot send you a friend request." );

bot.registerCommand( "chat", function( name, steamID ) {

	var index = bot.Listeners.indexOf( steamID );

	if ( index == -1 ) {

		bot.Listeners.push( steamID );
		bot.sendMessage( name + " entered chat." );

	} else {

		bot.sendMessage( name + " disconnected." );
		bot.Listeners.splice( index, 1 );

	}

}, "Join the group chat using the bot as a middleman." );

bot.registerCommand( "help", commandlist, "This help text" );
bot.registerCommand( "commands", commandlist, "This help text" );

//
// CLI Output
//

function print( str ) {

	console.log( str.replace( /[\x00-\x09]/g, "" ) );

}

bot.on( "Connected", function() {
	print( "Connected." );
} );

bot.on( "Disconnected", function() {
	print( "Lost Connection." );
} );

bot.on( "Message", function( name, steamID, msg ) {
	print( name + ": " + msg );
} );


bot.on( "UserConnected", function( name, steamID ) {
	print( name + " (" + steamID + ") connected." );
} );


bot.on( "UserDisconnected", function( name, steamID ) {
	print( name + " (" + steamID + ") disconnected." );
} );


bot.on( "UserKicked", function( target, _, actor ) {
	print( target + " was kicked by " + actor + "." );
} );


bot.on( "UserBanned", function( target, _, actor ) {
	print( target + " was banned by " + actor + "." );
} );


//
// Init connection!
//

bot.connect( config.User, config.Pass ); // Here we go!

var config         = require( "./config" );
var sortedcommands = [] // Array of all the commands sorted alphabetically

function randomInt(min, max) {
    max = max || 1;
    min = min || 0;

    Math.seed = (Math.seed * 9301 + 49297) % 233280;
    var rnd = Math.seed / 233280;

    return min + rnd * (max - min);
}

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

	// Only populate the sortedcommands array once.
	if ( sortedcommands.length < 1 ) {
		// Copy the command data into the array for sorting
		for ( var key in this.Commands ) {
			if (this.Commands.hasOwnProperty(key)) { // Ignore inherited members
				var cmdinfo = this.Commands[key];
				var cmdhelp = cmdinfo.helptext;

				sortedcommands.push({command: key, helptext: cmdhelp});
			}
		}

		// Sort the commands alphabetically
		sortedcommands.sort(function(a, b){
			a = a.command.toLowerCase();
			b = b.command.toLowerCase();
			switch ( a == b ? 0 : a < b ){
				case 0:
					return 0;
					break;
				case true:
					return -1;
					break;
				case false:
					return 1;
					break;
				default:
					return 0;
					break;
			}
		});
	}

	var helptext = "Current Commands:\n";
	for ( var key in sortedcommands ) {
		var commandinfo = sortedcommands[key];

		helptext += "\t." + commandinfo.command;
		if ( commandinfo.helptext ) {
			helptext += " : " + commandinfo.helptext;
		}
		helptext += "\n";
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
		Math.seed = steamID;
		var ip = randomInt(20, 240) + "." + randomInt(20, 240) + "." + randomInt(20, 240) + "." + randomInt(20, 240);
		bot.sendMessage( name + " entered chat. (IP: " + ip + ")", undefined, undefined, true );
		bot.emit( "UserConnected", name, steamID, bot.GroupID );

	} else {

		bot.sendMessage( name + " disconnected.", undefined, undefined, true );
		bot.Listeners.splice( index, 1 );
		bot.emit( "UserDisconnected", name, steamID, bot.GroupID );

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

bot.on( "Message", function( name, steamID, msg, group ) {
	if ( steamID == group ) {
		print( "[PM Received From] " + name + " [" + steamID + "]: " + msg );
	} else {
		print( "[Group Chat] " + name + " [" + steamID + "]: " + msg ); // TODO: Group name
	}
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

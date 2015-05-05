var config = require( "./config" );

//
// Connection Handler
//

bot.on( "Connected", function() {

	this.setStatus( "Online" );
	this.setChat( config.Group );
	
} );


//
// Default Commands
//

bot.registerCommand( "update", function( name, steamID ) {

	if ( bot.isAdmin( steamID ) )
		process.exit( 1 ); 

} );

bot.registerCommand( "add", function( name, steamID ) {

	bot.addFriend( steamID );

} );

bot.registerCommand( "chat", function( name, steamID ) {

	var index = bot.Listeners.indexOf( steamID );

	if ( index == -1 ) {

		bot.Listeners.push( steamID );
		bot.sendMessage( "Joined group chat.", steamID );
		bot.sendMessage( name + " entered chat." );

	} else {

		bot.Listeners.splice( index, 1 );
		bot.sendMessage( "Left group chat.", steamID );
		bot.sendMessage( name + " disconnected." );

	}

} );

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

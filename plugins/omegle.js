var omegle = new ( require( "../lib/omegle" ).Client );

var connected = false;

function Connect(tags) {

	bot.sendMessage( "Connecting to Omegle." );

	omegle.start(tags, function( e ) {

		if ( e )
			return;

		connected = true;

	} );

}

function Disconnect() {

	bot.sendMessage( "Disconnected from Omegle." );

	omegle.disconnect();
	connected = false;

}

omegle.on( "connected", function() {

	bot.sendMessage( "Stranger connected." );

} );

omegle.on( "gotMessage", function( msg ) {

	bot.sendMessage( "Stranger: " + msg );

} );

omegle.on( "strangerDisconnected", function() {

	bot.sendMessage( "Stranger disconnected." );
	Disconnect();

} );

bot.on( "Message", function( name, steamID, msg ) {

	if ( connected )
		omegle.send( name + ": " + msg );

} );

bot.registerCommand( "omegle", function( name, steamID, args ) {

	if ( !bot.isAdmin( steamID ) )
		return;

	if ( connected )
		Disconnect();
	else
		Connect(args);

}, "[ADMIN] Connect the group chat to a random omegle user." );

var omegle = new ( require( "../lib/omegle" ).Client );

var connected = false;

function Connect(tags) {

	bot.sendMessage( "Connecting to Omegle.", undefined, undefined, true );

	omegle.start(tags, function( e ) {

		if ( e )
			return;

		connected = true;

	} );

}

function Disconnect() {

	bot.sendMessage( "Disconnected from Omegle.", undefined, undefined, true );

	omegle.disconnect();
	connected = false;

}

omegle.on( "connected", function() {

	bot.sendMessage( "Stranger connected.", undefined, undefined, true );

} );

omegle.on( "gotMessage", function( msg ) {

	bot.sendMessage( "Stranger: " + msg, undefined, undefined, true );

} );

omegle.on( "strangerDisconnected", function() {

	bot.sendMessage( "Stranger disconnected.", undefined, undefined, true );
	Disconnect();

} );

bot.on( "Message", function( name, steamID, msg ) {

	if ( connected )
		omegle.send( name + ": " + msg );

} );

bot.on( "UserConnected", function( name ) {

	if ( connected )
		omegle.send( name + " connected." );
	
});

bot.on( "UserDisconnected", function( name ) {

	if ( connected )
		omegle.send( name + " disconnected." );
	
});

bot.on( "OutgoingPrint", function( msg ) {
	
	if ( connected )
		omegle.send( "#: " + msg );
		
});

bot.registerCommand( "omegle", function( name, steamID, args ) {

	if ( !bot.isAdmin( steamID ) )
		return;

	if ( connected )
		Disconnect();
	else
		Connect(args);

}, "[ADMIN] Connect the group chat to a random omegle user." );

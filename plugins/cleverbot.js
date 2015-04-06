var cleverbot = new ( require( "cleverbot-node" ) );
var busy = false;

var phrases = [
	"hello",
	"hey",
	"hi",
	"what's",
	"how",
	"where"
];

bot.on( "Message", OnMessage );

function ShouldReply( msg ) {

	// Don't reply if we are already replying
	if ( busy )
		return false;

	// 25% chance to reply if first word is a defined phrase
	var firstWordLower = msg.toLowerCase().split( " " )[ 0 ];

	if ( phrases.indexOf( firstWordLower ) != -1 )
		return Math.random() > 0.75;

	// 3% chance by default
	return Math.random() > 0.985;

}

function OnMessage( name, steamID, msg ) {

	if ( !ShouldReply( msg ) )
		return;

	busy = true;

	cleverbot.write( msg, function( res ) {

		if ( res && res.message )
			bot.sendMessage( res.message );

		busy = false;

	} );

}

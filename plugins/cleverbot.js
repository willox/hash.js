var cleverbot = new ( require( "cleverbot-node" ) );
var busy = false;
var excited = false;

var phrases = [
	"hello",
	"hey",
	"hi",
	"what's",
	"how",
	"where"
];

var botNames = ["hash","#","bot","emneknagg"];
var botNameLength = botNames.length;

bot.on( "Message", OnMessage );

function ShouldReply( msg ) {

	// Don't reply if we are already replying
	if ( busy )
		return false;

	// 90% chance to reply if the bot's name is spoken.
	///Loop through the names of the bot

	for(i=0; i != botNameLength; i++) {
		//if one of the words is equal to an entry in botNames

		if(msg.toLowerCase().indexOf(botNames[i]) != -1) {

			//Make the bot speak 90% of the time
			return Math.random() > 0.10;
		}
	}

	// 10% chance to reply if excited
	if ( excited )
		return Math.random() > 0.90;

	// 25% chance to reply if first word is a defined phrase
	var firstWordLower = msg.toLowerCase().split( " " )[ 0 ];

	if ( phrases.indexOf( firstWordLower ) != -1 )
		return Math.random() > 0.75;

	// 3% chance by default
	return Math.random() > 0.96;

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

bot.registerCommand( "excite", function() {

	if(excited == true) {
		excited = false;

		bot.sendMessage("Excited: false");
	}
	else {
		excited = true;

		bot.sendMessage("Excited: true");
	}

});

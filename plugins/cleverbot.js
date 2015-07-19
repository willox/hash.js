var config = require( "../config.js" );
var cleverbot = new ( require( "cleverbot" ) )( config.CleverBotUser, config.CleverBotKey );
var busy = false;
var excited = false;

var phrases = [
	"hello",
	"hey",
	"hi"
];

var lastMessage = 0;

cleverbot.setNick( "Hash" );
cleverbot.create( function( err, session ) {

	if ( err )
		return;

	bot.on( "Message", OnMessage );

	function ShouldReply( msg ) {

		// Don't reply if we are already replying
		if ( busy )
			return false;

		// 0.5 messages per minute
		if ( lastMessage + 120000 > Date.now() )
			return false;
		
		// 80% chance to reply if the bot's name is spoken.
		if ( msg.match( /\bHash\b/i ) )
			return Math.random() > 0.20;

		// 10% chance to reply if excited
		if ( excited )
			return Math.random() > 0.90;

		// 10% chance to reply if first word is a defined phrase
		var firstWordLower = msg.toLowerCase().split( " " )[ 0 ];

		if ( phrases.indexOf( firstWordLower ) != -1 )
			return Math.random() > 0.9;

		// 1% chance by default
		return Math.random() > 0.99;

	}

	function OnMessage( name, steamID, msg, group ) {

		if ( !ShouldReply( msg ) )
			return;

		busy = true;

		// Translate name from Hash to Cleverbot
		msg = msg.replace( /\bHash\b/ig, "Cleverbot" );

		lastMessage = Date.now();

		cleverbot.ask( msg, function( err, res ) {

			if ( err )
				return;

			// Translate name from Cleverbot to Hash
			res = res.replace( /\bCleverbot\b/ig, "Hash" );

			bot.sendMessage( res, group );

			busy = false;

		} );

	}


} );

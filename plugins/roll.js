// Returns a random integer between 1 and max
function randInt( max ) {
	return Math.floor( Math.random() * ( max - 1 ) ) + 1;
}

bot.registerCommand( "roll", function( name, _, _, arg_str ) {

	if ( /(\d+)?d\d+/.test( arg_str ) ) {

		var match = arg_str.match( /(\d+)?d(\d+)/ );
		var num = match[1]
		  ? Math.max( Math.min( parseInt( match[1] ), 10 ), 1 )
		  : 1;
		var max = parseInt( match[2] );

		var results = [];
		for ( var x = 0; x < num; x++ )
			results[ x ] = randInt( max );

		var msg = name + " rolls ";
		msg += num == 1 ? "a" : num;
		msg += " d" + max;
		msg += num == 1 ? "" : "s";
		msg += ": " + results.join( ", " );

		bot.sendMessage( msg );

	} else {
		// Just roll d20
		bot.sendMessage( name + " rolls a d20: " + randInt( 20 ) )
	}

} );

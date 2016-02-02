function randInt( max ) {
    return Math.floor( Math.random() * (max || 1) ) + 1;
}

bot.registerCommand( "roll", function( name, _, _, arg_str, group ) {

	if ( /(\d+)?d\d+/.test( arg_str ) ) {
		var match = arg_str.match( /(\d+)?d(\d+)/ );
		var num = match[1]
		  ? Math.max( Math.min( parseInt( match[1] ), 10 ), 1 ) // Clamp number of die to 10
		  : 1;
		var max = parseInt( match[2] );

		var results = [];
		for ( var x = 0; x < num; x++ ) // Roll each die and store result
			results[ x ] = randInt( max );

		var msg = name + " rolls ";
		msg += num == 1 ? "a" : num;
		msg += " d" + max;
		msg += num == 1 ? "" : "s";
		msg += ": " + results.join( ", " );

		bot.sendMessage( msg, group );
	} else {
		// Just roll d20
		bot.sendMessage( name + " rolls a d20: " + randInt( 20 ), group )
	}

}, "Rolls N dice with N sides. [Example: .roll 2d6]" );

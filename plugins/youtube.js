var request     = require('request');

var String_Prototype_Repeat_Is_NonStandard = [
	"✩✩✩✩✩",
	"★✩✩✩✩",
	"★★✩✩✩",
	"★★★✩✩",
	"★★★★✩",
	"★★★★★"
];

bot.on( "Message", function( name, steamID, msg, group ) {
	
	var match = msg.match( /(youtube\.com\/watch\?v=|youtu\.be\/)([A-Z0-9-_]+)/i );

	if ( !match )
		return;

	request( "http://gdata.youtube.com/feeds/api/videos/" + match[2] + "?alt=json", function( error, response, body ) {

		if ( error )
			return; // Fuck Node

		var data = JSON.parse( body );

		if ( !data.entry || !data.entry.gd$rating || !data.entry.title || !data.entry.title.$t )
			return; // Fuck YouTube
		
		var entry = data.entry;

		var starCount = Math.round( entry.gd$rating.average );

		bot.sendMessage( "YouTube: " + entry.title.$t + " [" + String_Prototype_Repeat_Is_NonStandard[ starCount ] + "]", group );

	} );
} );
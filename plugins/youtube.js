var request     = require('request');
var key = "AIzaSyA8OmKcw2DMNkJicyCJ0vqvf90xgeH52zE";

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

	request( "https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&prettyPrint=false&maxResults=1&key=" + key + "&id=" + match[2], function( error, response, body ) {

		if ( error )
			return; // Fuck Node

		var data = JSON.parse( body );

		if ( !data.items || !data.items[0] || !data.items[0].snippet || !data.items[0].statistics || !data.items[0].statistics.likeCount || !data.items[0].statistics.dislikeCount || !data.items[0].snippet.title )
			return; // Fuck YouTube

		var entry = data.entry;

		var starCount = Math.round( 5 * (data.items[0].statistics.likeCount/(data.items[0].statistics.likeCount + data.items[0].statistics.dislikeCount)) );

		bot.sendMessage( "YouTube: " + data.items[0].snippet.title + " [" + String_Prototype_Repeat_Is_NonStandard[ starCount ] + "]", group );

	} );
} );

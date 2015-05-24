var child_process	= require( "child_process" );
var request			= require( "request" );
var http			= require( "http" );
var crc32           = require( "buffer-crc32" ); // TODO: Find a hardware crc that's xplatform
var EOF				= "\x00";
var lua				= null;
var cmdbuf			= null;
var processing		= null;
var userpackets     = {} // Lookup object for user submitted code. Matches crc -> code info
var usernames       = {} // Table of steamid64 to the users name

function Init() {
	lua = child_process.spawn( "lua", [ "init.lua" ], {
		cwd: __dirname + "/lua"
	} );

	cmdbuf     = [];
	processing = false;

	lua.stdout.on( "data", OnStdOut );
	lua.stderr.on( "data", function( data ) {
		console.log("[Lua STDERR] " + data);
	} );

	QueueCommand("require 'autorun'", true, true);
}

function QueueCommand( cmd, sandbox, showerror, steamid, groupid ) {

	if ( cmd ) {
		if ( cmd[0] == "]" ) {
			showerror = true
			cmd = cmd.substring(1)
		}

		if (steamid && groupid) { // Only calculate CRC on non-internal code
			var epoch  = (new Date).getTime(); // `seed` the crc32 with epoch
			var cmdcrc = crc32.signed( epoch + cmd );
			// The chance of a collision is really low, but still possible.
			// TODO?: Check for collisions and re-crc the command?
		}

		cmdbuf.push( {
			command:       cmd,
			crc:           cmdcrc    || 0,
			sandbox:       sandbox   != null ? sandbox   : true,
			showerrors:    showerror != null ? showerror : true,
			steamid:       steamid   != null ? steamid   : 0,
			groupid:       groupid   != null ? groupid   : 0
		} );
	}

}

function CreateHeader( cmd ) {
	var header = "["

	if ( cmd && typeof( cmd ) == "object" ) {

		header += cmd.crc.toString()        + ":";
		header += cmd.sandbox.toString()    + ":";
		header += cmd.showerrors.toString() + ":";
		header += cmd.steamid.toString()    + ":";
		header += cmd.groupid.toString();

	}

	return header + "]\n"
}

function ParsePacket( data ) {
	var packet = {}

	if ( data[0] != "[" ) { // No header, dump to stdout
		console.log( "Packet received with no header! \"" + data + "\"" );
		packet.crc  = 0;
		packet.data = data;

	} else {
		var parsed = /^\[(.*):(.)\]([^]*)/gm.exec(data); // '.' doesn't match newlines...
		if (!parsed) {
			console.log ( "ParsePacket regex failed on data: \"" + data + "\"" );
			return packet
		}

		packet.crc   = Number(parsed[1]);
		packet.islua = parsed[2] == "1" ? true : false;
		packet.data  = parsed[3];
	}

	return packet;
}

function ProcessCommand() {

	if ( processing )
		return;

	var cmd = cmdbuf.shift();
	if ( !cmd )
		return;

	processing = true;

	if (userpackets[cmd.crc]) { // Hopefully this will never happen...
		console.log( "The CRC " + cmd.crc + " is not unique!\n", cmd );
	}

	if (cmd.crc != 0)
		userpackets[cmd.crc] = cmd;

	lua.stdin.write( CreateHeader( cmd ) + cmd.command + EOF + "\n" );

}

setInterval( ProcessCommand, 10 );

function LuaQuote( str ) {

	return "\"" + str.replace( /.|\r|\n/gm, function( c ) {

		switch ( c ) {

			case "\"":
			case "\\":
			case "\n":
				return "\\" + c;

			case "\r":
				return "\\r";
			case "\0":
				return "\\0";

		}

		return c;

	} ) + "\"";
}

function QueueHook( event, args ) {

	var buf = [ "hook.Call(", LuaQuote( event ) ];

	if ( args && args.length > 0 ) {


		for ( var i = 0; i < args.length; i++ ) {

			buf.push( "," );
			buf.push( LuaQuote( args[ i ] ) );

		}

	}

	buf.push( ")" );

	QueueCommand( buf.join( "" ), true, true );

}

function Require( path ) {

	QueueCommand( "require(" + LuaQuote( path ) + ")", true, true );

}

setInterval( function() {

	QueueHook( "Tick" );

	QueueCommand( "timer.Tick()", true, true );

}, 500 );

setInterval( function() {

	QueueCommand( "cookie.Save()", false, true );

}, 30000 );


var buf = [];

bot.on( "Message", function( name, steamID, msg, group ) {
	usernames[steamID] = name;

	QueueCommand( "SetSandboxedSteamID( " + steamID + " )", false, true );

	QueueHook( "Message", [ name, steamID, msg ] );

	QueueCommand( msg.replace( EOF, "\\x00" ), true, msg[0] == "]", steamID, group );
} );

bot.on( "UserConnected", function( name, steamID ) {
	usernames[steamID] = name;

	QueueHook( "Connected", [ name, steamID ] );
} );


bot.on( "UserDisconnected", function( name, steamID ) {
	QueueHook( "Disconnected", [ name, steamID ] );
} );

function OnStdOut( data ) {

	//
	// Handle multiple packets in a single chunk, or less
	//
	data = data.toString();

	var datas = data.split( EOF );

	buf.push( datas[ 0 ] );

	// Loop through all of our datas, except the last (unfinished) one
	for ( var i = 0; i < datas.length - 1; i++ ) {

		// Reconstruct our string
		buf = buf.join( "" );

		// Filter out unwanted shit
		buf = buf.replace( /\0/g, "\\0" );
		buf = buf.replace( /\t/g, "    " );

		// Ignore empty packets
		if ( buf.trim().length > 0 ) {
			var packet  = ParsePacket( buf );
			var crc     = packet.crc;
			var islua   = packet.islua;
			var info    = userpackets[crc];
			var showerr = info && info.showerrors || false;

			if ( packet.data && (islua || !islua && showerr) ) {
				bot.sendMessage( packet.data + "\n", info ? info.groupid : null );
			}

			if (crc != 0) {
				var steamid  = info ? info.steamid || 0  : 0;
				var groupid  = info ? info.groupid || 0  : 0;
				var message  = info ? info.command || "" : "";
				var username = usernames[steamid] || steamid.toString();
				if (islua) {
					bot.emit(  "LuaMessage", username, steamid, message, groupid );
					QueueHook( "LuaMessage",  [ username, steamid, message ] );
				} else {
					bot.emit(  "TextMessage", username, steamid, message, groupid );
					QueueHook( "TextMessage", [ username, steamid, message ] );
				}
			}

			userpackets[crc] = null;
		}

		buf = [ datas[ i + 1 ] ];
	}

	// We've received our packet. Prepare the next command!
	if ( buf.length == 1 && buf[0].length == 0 ){
		processing = false;
	}

}

bot.registerCommand( "restart", function() {

	lua.kill();
	Init();

}, "Restarts the Lua engine." );

Init();

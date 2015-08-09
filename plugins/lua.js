var child_process	= require( "child_process" );
var blacklisted     = require( "../config" ).HTTPBlacklist;
var request			= require( "request" );
var http			= require( "http" );
var dns             = require( "dns" );
var url             = require( "url" );
var crc32           = require( "buffer-crc32" ); // TODO: Find a hardware crc that's xplatform
var EOF				= "\x00";
var lua				= null;
var cmdbuf			= null;
var processing		= null;
var userpackets     = {}; // Lookup object for user submitted code. Matches crc -> code info

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

		if (steamid) { // Only calculate CRC on non-internal code
			var mtime  = (new Date).getTime(); // seed the crc32 with the epoch in milliseconds
			var cmdcrc = crc32.signed( mtime + cmd );
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
		var parsed = /^\[(.*?[^\\]),(.*?[^\\]):(.+?)\]([\s\S]*)$/m.exec(data); // '.' doesn't match newlines...
		if (!parsed) {
			console.log ( "ParsePacket regex failed on data: \"" + data + "\"" );
			return packet
		}
		parsed[2] = parsed[2].replace(/\\:/g, ":");
		parsed[1] = parsed[1].replace(/\\,/g, ",");
		packet.type = parsed[1];
		if(packet.type == "Lua")
		{
			packet.crc   = Number(parsed[2]);
			packet.islua = parsed[3] == "1" ? true : false;
			packet.data  = parsed[4];
		}
		else if(packet.type == "SimpleTimer")
		{
			packet.callbackid      = Number(parsed[2]);
			packet.callbackdelayms = Number(parsed[3]) * 1000;
		}
		else if(packet.type == "Timer")
		{
			packet.callbackid      = parsed[2];
			packet.callbackdelayms = Number(parsed[3]) * 1000;
			packet.callbackreps    = Number(parsed[4]);
		}
		else if(packet.type == "HTTP")
		{
		    packet.url = parsed[2];
		    packet.id = Number(parsed[3]);
			packet.steamid = parsed[4];
		}
		else
		{
			console.log("ParsePacket unknown type received: " + packet.type);
		}
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
				return "\\x00";

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

	QueueCommand( "cookie.Save()", false, true );

}, 30000 );

bot.on( "Message", function( name, steamID, msg, group ) {

	if ( steamID == group && !bot.isAdmin( steamID ) ) { // Only admins can PM the bot code
		return;
	}

	QueueCommand( "SetLastExecutedSteamID( " + steamID + " )", false, true );

	QueueHook( "Message", [ name, steamID, msg ] );

	QueueCommand( msg.replace( EOF, "\\x00" ), true, msg[0] == "]", steamID, group );

} );

bot.on( "UserConnected", function( name, steamID ) {

	QueueHook( "Connected", [ name, steamID ] );

} );


bot.on( "UserDisconnected", function( name, steamID ) {
	QueueHook( "Disconnected", [ name, steamID ] );
} );

var buf = [];
var timers = {};
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
			if(packet.type == "Lua")
			{
				var crc     = packet.crc;
				var islua   = packet.islua;
				var info    = userpackets[crc];
				var showerr = info ? info.showerrors : true;

				if ( packet.data && (islua || !islua && showerr) ) {
					bot.sendMessage( packet.data, info ? info.groupid : null );
				}

				if (crc != 0) {
					var steamid  = info ? info.steamid || 0  : 0;
					var groupid  = info ? info.groupid || 0  : 0;
					var message  = info ? info.command || "" : "";
					var userinfo = bot.Client.users[steamid];
					var username = userinfo ? userinfo.playerName : steamid.toString();
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
			else if(packet.type == "SimpleTimer")
			{
				setTimeout(function(packet)
				{
					QueueCommand("SimpleTimerCallback( " + packet.callbackid + " )", false, false);

				}, packet.callbackdelayms, packet);

			}
			else if(packet.type == "Timer")
			{
				if(timers[packet.callbackid])
				{
					clearInterval(timers[packet.callbackid]);
				}

				if(packet.callbackreps != -1)
				{
					var i = 0;
					timers[packet.callbackid] = setInterval(function(packet)
					{
						QueueCommand("TimerCallback( " + LuaQuote(packet.callbackid) + ", " +
							(packet.callbackreps != 0 && i > packet.callbackreps ? "true" : "false") + " )", false, false);

						if(packet.callbackreps != 0 && i > packet.callbackreps)
						{
							clearInterval(timers[packet.callbackid]);
						}
						i++;

					}, packet.callbackdelayms, packet);
				}
			}
			else if(packet.type == "HTTP")
			{
				
				var steamid = packet.steamid;
				
				var userinfo = bot.Client.users[steamid];
				var username = userinfo ? userinfo.playerName : steamid;
				
				
								
				console.log(username + " [" + steamid.toString() + "] HTTP request: " + packet.url)
				
				var parsed = url.parse(packet.url);
				
				var id = packet.id;
				
				if(!parsed)
					QueueCommand("HTTPCallback( " + id + ", 0, '', " + LuaQuote("Domain unresolved") + ")", false, true);
				
				else if(parsed.auth && parsed.auth !== "")
					QueueCommand("HTTPCallback( " + id + ", 0, '', " + LuaQuote("Auth rejected") + ")", false, true); // TROLLED
					
				else if(parsed.protocol !== "http:" && parsed.protocol !== "https:")
					QueueCommand("HTTPCallback( " + id + ", 0, '', " + LuaQuote("Invalid protocol") + ")", false, true);
				
				else if(!parsed.hostname || blacklisted.indexOf(parsed.hostname) > -1)
					QueueCommand("HTTPCallback( " + id + ", 0, '', " + LuaQuote("Hostname blacklisted") + ")", false, true);
				
				else 
				{
					var id = packet.id;
					var http_url = packet.url;
					var packet = packet;
					dns.lookup(parsed.hostname, function(err, addr, fam)
					{
						if(err)
						{
							QueueCommand("HTTPCallback( " + id + ", 0, '', " + LuaQuote(err.toString()) + ")", false, true);
							return;
						}
						
						if(blacklisted.indexOf(addr) > -1)
							QueueCommand("HTTPCallback( " + id + ", 0, '', " + LuaQuote("IP blacklisted") + ")", false, true);
							
						else
						    setTimeout(function(id, http_url)
						    {
						        request(http_url, function(err, status, body)
						        {
						            if(err)
						            {
						                QueueCommand("HTTPCallback( " + id + ", 0, '', " + LuaQuote(err.toString()) + ")", false, true);
						                return;
						            }
						            
						            QueueCommand("HTTPCallback(" + id + ", " + status.statusCode + ", " + LuaQuote(body) + ")", false, true);
						            
						        });
						    }, 1, id, http_url);
						
					});
				}
			    
			}

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
	for (var k in timers)
	{
		clearInterval(timers[k]);
		timers[k] = undefined;
	}
	Init();

}, "Restarts the Lua engine." );

Init();

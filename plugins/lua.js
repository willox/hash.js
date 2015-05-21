var child_process	= require( "child_process" );
var request			= require( "request" );
var EOF				= "\x00";
var http			= require( "http" );
var lua				= null;
var cmdbuf			= null;
var processing		= null;

function Init() {
	lua = child_process.spawn( "lua", [ "init.lua" ], {
		cwd: __dirname + "/lua"
	} );

	cmdbuf = [];
	QueueCommand( "require 'autorun'", true, false );
	processing = false;

	lua.stdout.on( "data", OnStdOut );
	lua.stderr.on( "data", function( data ) {
		console.log("[Lua STDERR] " + data);
	} );
}

function QueueCommand( cmd, sandboxed, suppress_errors ) {

	if ( suppress_errors )
		cmd = "Y" + cmd
	else
		cmd = "N" + cmd

	if ( sandboxed )
		cmd = "S" + cmd
	else
		cmd = "T" + cmd

	cmdbuf.push( cmd );

}

function ProcessCommand() {

	if ( processing )
		return;

	var cmd = cmdbuf.shift();
	if ( !cmd )
		return;

	processing = true;

	lua.stdin.write( cmd.length.toString() );
	lua.stdin.write( cmd );
	lua.stdin.write( "\n" );

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

	QueueCommand( buf.join( "" ), true, false );

}

function Require( path ) {

	QueueCommand( "require(" + LuaQuote( path ) + ")", true, false );

}

setInterval( function() {

	QueueHook( "Tick" );

	QueueCommand( "timer.Tick()", true, false );

}, 500 );

setInterval( function() {

	QueueCommand( "cookie.Save()", true, false );

}, 30000 );


var buf = [];

bot.on( "Message", function( name, steamID, msg, group ) {

	if ( steamID == group )
		return; // Don't allow Lua to be ran outside of the group chat

	var suppress_errors = true;

	if  ( msg.substr( 0, 1 ) == "]" ) {
		msg = msg.substr( 1 );
		suppress_errors = false;
	}

	QueueCommand( "SetSandboxedSteamID( " + steamID + " )", false, false );

	QueueHook( "Message", [ name, steamID, msg ] );

	QueueCommand( msg.replace( EOF, "\\x00" ), true, suppress_errors );

} );

bot.on( "UserConnected", function( name, steamID ) {
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
		if ( buf.trim().length > 0 )
			bot.sendMessage( buf );

		buf = [ datas[ i + 1 ] ];
	}

	// We've received our packet. Prepare the next command!
	if ( buf.length == 1 && buf[0].length == 0 )
		processing = false;

}

bot.registerCommand( "restart", function() {

	lua.kill();
	Init();

}, "Restarts the Lua engine." );

Init();

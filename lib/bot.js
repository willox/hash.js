var steam = require( "steam" );
var events = require( "events" );
var util = require( "util" );
var fs = require( "fs" );

var config = require("../config");


function Bot() {

	events.EventEmitter.call( this );

	var self = this;

	self.Client = new steam.SteamClient();
	self.Commands = {};
	self.Connected = false;
	self.MessageQueue = [];

	self.Client.on( "loggedOn", function() {
		self.Connected = true;

		self.emit( "Connected" );

		config.Admins.forEach( function( admin ) {
			self.Client.addFriend( admin );
		} );
	} );

	self.Client.on( "sentry", function( sentry ) {
		fs.writeFileSync( config.Sentry, sentry );
	} );

	self.Client.on( "loggedOff", function() {
		self.Connected = false;
		self.emit( "Disconnected" );
	} );

	self.Client.on( "error", function( e ) {

		self.Connected = false;

		console.trace( e );

		self.emit( "error", e );

	} );

	self.Client.on( "chatEnter", function( group, response ) {

		if ( response == steam.EChatRoomEnterResponse.Success ) {

			for ( var i = 0; i < self.MessageQueue.length; i++ ) {
				self.sendMessage( self.MessageQueue[ i ] );
			}

			self.MessageQueue = [];

		}

	} );

	self.Client.on( "chatMsg", function( group, msg, type, user ) {

		var name = self.Client.users[ user ] && self.Client.users[ user ] . playerName || "Unknown";

		var cmd = msg.match(/^\.(\S+)/); cmd = cmd && cmd[1];
		var args; ( args = msg.split( /\s+/ ) ).shift()
		var argstr = msg.match( /^\.\S+\s+([\s\S]+)/ ); argstr = argstr && argstr[1] || "";

		if ( !cmd )
			return self.emit( "Message", name, user, msg );

		var cmd_callback = self.Commands.hasOwnProperty( cmd ) && self.Commands[ cmd ];

		if ( !cmd_callback )
			return self.sendMessage( "Unknown command '" + cmd + "'." );

		cmd_callback.call( self, name, user, args, argstr );

	} );

	self.Client.on( "chatStateChange", function( state, target, group, actor ) {

		var target_name = self.Client.users[ target ] && self.Client.users[ target ] . playerName || "Unknown";
		var actor_name = self.Client.users[ actor ] && self.Client.users[ actor ] . playerName || "Unknown";

		switch ( state ) {

			case steam.EChatMemberStateChange.Kicked:

				if ( target == self.Client.steamID )
					self.SetChat( self.GroupID );
				else
					self.emit( "UserKicked", target_name, target, actor_name, actor );

				break;

			case steam.EChatMemberStateChange.Banned:

				if ( target != self.Client.steamID )
					self.emit( "UserBanned", target_name, target, actor_name, actor );

				break;

			case steam.EChatMemberStateChange.Entered:
				self.emit( "UserConnected", target_name, target );
				break;

			case steam.EChatMemberStateChange.Left:
			case steam.EChatMemberStateChange.Disconnected:
				self.emit( "UserDisconnected", target_name, target );
				break;

		}

	} );

	self.Client.on( "tradeProposed", function( trade, user ) {

		self.Client.respondToTrade( trade, self.isAdmin( user ) );

	} );

}

util.inherits(Bot, events.EventEmitter);


Bot.prototype.connect = function( user, pass ) {

	this.User = user;
	this.Pass = pass;

	this.Client.logOn( {
		accountName:	this.User,
		password:		this.Pass,
		authCode:		config.Auth,
		shaSentryfile:	( fs.existsSync( config.Sentry ) ? fs.readFileSync( config.Sentry ) : undefined )
	} );

}

Bot.prototype.disconnect = function() {

	this.Client.logOff();

}

Bot.prototype.setName = function( name ) {

	this.Client.setPersonaName( name );

}

Bot.prototype.setStatus = function( status ) {

	switch ( status ) {

		case "Online":
			this.Client.setPersonaState( steam.EPersonaState.Online )
			break;

		case "Busy":
			this.Client.setPersonaState( steam.EPersonaState.Busy )
			break;

		case "Away":
			this.Client.setPersonaState( steam.EPersonaState.Away )
			break;

		case "Offline":
			this.Client.setPersonaState( steam.EPersonaState.Offline )
			break;

	}

}

Bot.prototype.setChat = function( group ) {

	if ( this.GroupID && this.GroupID != group ) {

		this.GroupID = undefined;
		this.Client.leaveChat( this.GroupID );

	}

	this.GroupID = group;
	this.Client.joinChat( this.GroupID );

}

Bot.prototype.sendMessage = function( msg ) {

	if ( this.Connected )
		this.Client.sendMessage( this.GroupID, msg.substr( 0, 2000 ) );
	else
		this.MessageQueue.push( msg );

	msg = msg.replace( /[\x00-\x09]/g, "" );
	console.log( "me: " + msg );

}

Bot.prototype.registerCommand = function( cmd, callback ) {

	this.Commands[ cmd ] = callback;

}

Bot.prototype.removeAllCommands = function() {

	this.Commands = {};

}

Bot.prototype.isAdmin = function( steamID ) {

	return config.Admins.indexOf( steamID ) > -1;

}

module.exports = function() {

	return new Bot();

};
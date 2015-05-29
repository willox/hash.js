var steam = require( "steam" );
var events = require( "events" );
var util = require( "util" );
var fs = require( "fs" );

var config = require("../config");


function Bot() {

	events.EventEmitter.call( this );

	var self = this;

	self.Client = new steam.SteamClient();
	self.Limited = [];
	self.Commands = {};
	self.Connected = false;
	self.MessageQueue = [];
	self.Listeners = [];

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

				var msgData = self.MessageQueue[ i ];

				self.sendMessage( msgData.msg, msgData.recipient );
			}

			self.MessageQueue = [];

		}

	} );

	self.Client.on( "message", function( group, msg, type, user ) {

		if ( type != steam.EChatEntryType.ChatMsg )
			return;

		user = user || group;

		if ( self.isLimited( user ) )
			return;

		var name = self.Client.users[ user ] && self.Client.users[ user ].playerName || "Unknown";

		// Forward to listeners if this is a group message
		if ( group != user ) {

			self.Listeners.forEach( function( listener ) {

				if ( user == listener )
					return;

				self.sendMessage( "<" + name + "> " + msg, listener );

			} );

		}

		// Forward to group if this is a listener message
		if ( group == user && self.Listeners.indexOf( user ) != -1 ) {

			self.sendMessage( name + ": " + msg, self.GroupID, user );
			group = this.GroupID; // Megahack

		}

		var cmd = msg.match(/^\.(\S+)/); cmd = cmd && cmd[1];
		var args; ( args = msg.split( /\s+/ ) ).shift()
		var argstr = msg.match( /^\.\S+\s+([\s\S]+)/ ); argstr = argstr && argstr[1] || "";

		if ( !cmd )
			return self.emit( "Message", name, user, msg, group );

		var cmd_info = self.Commands.hasOwnProperty( cmd ) && self.Commands[ cmd ];
		var cmd_callback = cmd_info.callback;

		if ( !cmd_callback )
			return self.sendMessage( "Unknown command '" + cmd + "'.", group );

		cmd_callback.call( self, name, user, args, argstr, group );

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
				self.emit( "UserConnected", target_name, target, group );
				break;

			case steam.EChatMemberStateChange.Left:
			case steam.EChatMemberStateChange.Disconnected:
				self.emit( "UserDisconnected", target_name, target, group );
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

Bot.prototype.addFriend = function( user ) {

	this.Client.addFriend( user );

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

Bot.prototype.sendMessage = function( msg, recipient, sender ) {

	var self = this;

	if ( !this.Connected ) {

		this.MessageQueue.push( {
			msg: msg,
			recipient: recipient
		} );

		return
	}

	recipient = recipient || this.GroupID;

	if ( recipient == this.GroupID ) {

		this.Listeners.forEach( function( listener ) {

			if ( listener == sender )
				return;

			self.Client.sendMessage( listener, msg.substr( 0, 2000 ) );

		} );

	}

	this.Client.sendMessage( recipient || this.GroupID, msg.substr( 0, 2000 ) );

	msg = msg.replace( /[\x00-\x09]/g, "" );


	var userinfo   = this.Client.users[recipient];
	var targetname = userinfo ? userinfo.playerName : recipient.toString();
	if ( !targetname ) { // Group chat
		// TODO: Waiting for this PR to merge https://github.com/seishun/node-steam/pull/102
		// Currently there is no way to get a group name from its groupid
		// For now we'll just print the groupid as a string...
	}

	console.log( "me -> " + targetname + ": " + msg );

}

Bot.prototype.registerCommand = function( cmd, callback, helptext ) {

	this.Commands[ cmd ] = {
		callback: callback,
		helptext: helptext
	};

}

Bot.prototype.removeAllCommands = function() {

	this.Commands = {};

}

Bot.prototype.isAdmin = function( steamID ) {

	return config.Admins.indexOf( steamID ) > -1;

}

Bot.prototype.isLimited = function( steamID ) {

	return this.Limited.indexOf( steamID ) > -1;

}

Bot.prototype.setLimited = function( steamID, isLimited ) {

	if ( isLimited )
		this.Limited.push( steamID )
	else if ( this.isLimited( steamID ) )
		this.Limited.splice( this.Limited.indexOf( steamID ), 1 );

}

Bot.prototype.kick = function(steamID) {

        this.Client.kick(this.GroupID, steamID);

}

module.exports = function() {

	return new Bot();

};

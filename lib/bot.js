var steam = require( "steam" );
var SteamTrade = require("steam-trade");
var SteamTradeOffers = require("steam-tradeoffers");
var getSteamAPIKey = require("steam-web-api-key");
var events = require( "events" );
var util = require( "util" );
var fs = require( "fs" );

var config = require("../config");


function Bot() {

	events.EventEmitter.call( this );

	var self = this;

	self.Client = new steam.SteamClient();
	self.Trade = new SteamTrade();
	self.TradeOffers = new SteamTradeOffers();
	self.SessionID = "";
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

			self.sendMessage( name + ": " + msg, self.GroupID, user, true );
			group = this.GroupID; // Megahack

		}

		var cmd = msg.match(/^\.(\S+)/); cmd = cmd && cmd[1];
		var args; ( args = msg.split( /\s+/ ) ).shift()
		var argstr = msg.match( /^\.\S+\s+([\s\S]+)/ ); argstr = argstr && argstr[1] || "";

		if ( !cmd )
			return self.emit( "Message", name, user, msg, group );

		if ( group == user ) { // PMd a command
			console.log( "[PM Received From] " + name + " [" + user + "]: " + msg );
		} else { // Command in group chat
			console.log( "[Group Chat] " + name + ": " + msg ); // TODO: Group name
		}

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

	self.Client.on( "chatInvite", function( group, name, patron ) {
		if ( self.isAdmin( patron ) )
			self.Client.joinChat( group );
	} );

	function getWebLogOnHandler( sessionID ) {

		return function( cookies ) {

			getSteamAPIKey( {

				sessionID: sessionID,
				webCookie: cookies

			}, function( err, webAPIKey ) {

				if ( err )
					console.trace( err );

				self.TradeOffers.setup( {

					sessionID: sessionID,
					webCookie: cookies,
					APIKey: webAPIKey

				} );

			} );


			cookies.forEach( function( cookie ) {

				self.Trade.setCookie( cookie );

			} );

		}

	}

	self.Client.on( "webSessionID", function( sessionID ) {

		self.Trade.sessionID = sessionID;
		self.SessionID = sessionID;

		self.Client.webLogOn( getWebLogOnHandler( sessionID ) );

	} );

	self.Client.on( "tradeProposed", function( trade, user ) {

		// Accept all trades and let steam-trade do the actual work
		self.Client.respondToTrade( trade, config.AcceptItems );

	} );

	self.Client.on( "tradeOffers", function( count ) {

		if ( count > 0 ) {

			// This is for trade offers
			self.TradeOffers.getOffers( {

				get_received_offers: 1,
				active_only: 1,
				time_historical_cutoff: Math.round(Date.now() / 1000)

			}, function( error, body ) {

				if ( error ) {

					console.trace( error );

				} else if ( body && body.response && body.response.trade_offers_received ) {

					body.response.trade_offers_received.forEach( function( offer ) {

						// Ensure that the bot is set to accept items, and the partner is not requesting items from the bot
						if ( config.AcceptItems && offer.items_to_give == undefined ) {

							self.TradeOffers.acceptOffer( { tradeOfferId: offer.tradeofferid } );

							self.TradeOffers.getItems( { tradeId: offer.tradeid }, function( error, items ) {

								if ( error ) {

									console.trace( error );

								} else {

									var itemNames = items.map( function( obj ) {

										return obj.name;

									} );

									self.sendMessage( self.Client.users[ offer.steamid_other ].playerName + " just donated the following items: " + itemNames.join(", ") );

								}

							} );

						} else {

							self.TradeOffers.declineOffer( { tradeOfferId: offer.tradeofferid } );

						}

					} )

				}

			} );

		}

	} );

	self.Client.on( "sessionStart", function( user ) {

		self.Trade.open( user );

	} );

	self.Trade.on( "error", function( e ) {

		console.trace( e );

		// Attempt to recover from error
		self.Client.webLogOn( getWebLogOnHandler( self.SessionID ) );

		self.Trade.open( self.Trade.tradePartnerSteamID );

	} );

	self.Trade.on( "ready", function() {

		self.Trade.ready( function() {

			self.Trade.confirm();

		} );

	} );

	self.Trade.on( "end", function( status, getItems ) {

		// This only works for trades without trade offers
		if ( status === "complete" && self.Trade.tradePartnerSteamID && self.Client.users[ self.Trade.tradePartnerSteamID ] ) {

			getItems( function( items ) {

				var itemNames = items.map( function( obj ) {

					return obj.name;

				} );

				self.sendMessage( self.Client.users[ self.Trade.tradePartnerSteamID ].playerName + " just donated the following items: " + itemNames.join(", ") );

			} );

		}

	} );

}

util.inherits(Bot, events.EventEmitter);


Bot.prototype.connect = function( user, pass ) {

	this.User = user;

	this.Client.logOn( {
		accountName:	this.User,
		password:		pass,
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

var hacking = false;

Bot.prototype.sendMessage = function( msg, recipient, sender, hack ) {

	msg = msg.replace(/\x00/g, "\\x00");
	msg = msg.substring(0, 2047);

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

		if ( !hack && !hacking ) {
			hacking = true;
				this.emit( "OutgoingPrint", msg );
			hacking = false;
		}

		this.Listeners.forEach( function( listener ) {

			if ( listener == sender )
				return;

			self.Client.sendMessage( listener, msg.substr( 0, 2000 ) );

		} );

	}

	this.Client.sendMessage( recipient || this.GroupID, msg.substr( 0, 2000 ) );

	msg = msg.replace( /[\x00-\x09]/g, "" );


	var userinfo   = this.Client.users[recipient];
	var targetname = userinfo ? userinfo.playerName : undefined;
	if ( !targetname ) { // Group message
		// TODO: Lookup groupid -> group name
		targetname = "Group Chat";
	} else { // PM
		targetname = "[PM] " + targetname;
	}

	console.log( "me -> " + targetname + " [" + recipient.toString() + "]: " + msg );

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

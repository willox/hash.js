var client = require( "../lib/omegle" ).Client;

var clients = {};

function Connect(which, tags) {

	bot.sendMessage( "Connecting to Omegle '" + which.omegleid + "'" );

	which.connecting = true;

	which.start( tags, function( e ) {

		if ( e )
			return;

	} );

}

function Disconnect(which) {

	if ( !(which.connected || which.connecting) ) 
		return;
	bot.sendMessage( "Disconnected from Omegle '" + which.omegleid + "'" );

	which.disconnect();

	which.connected = false;
	which.connecting = false;

}

function CreateNewOmegle(id)
{
	
	var which = new client();
	
	which.omegleid = id;
	which.queue = [];

	which.on( "connected", function() {
		
	
		this.connected = true;
		this.connecting = false;

		bot.sendMessage( "Stranger connected on '" + this.omegleid + "'" );
		
		for ( var k in clients ) 
			if ( k != this.omegleid && (this.mitm && this.mitm == clients[k].mitm || true) ) 
			{
				if ( clients[k].queue )
				{
					
					var q;
					while ( q = clients[k].queue.shift() )
						this.send ( q );
					
				}
			}

	} );
	
	which.on( "event", function(event)
	{
		
		console.log(event);
		
	});

	which.on( "gotMessage", function( msg ) {

		bot.sendMessage( ( this.mitm ? "(MITM #" + this.mitm + ") " : "" ) + "Stranger " + this.omegleid + ": " + msg );
		
		for ( var k in clients ) 
			if ( k != this.omegleid && (this.mitm && this.mitm == clients[k].mitm || true) ) 
			{
				if ( clients[k].connected )
				{
					clients[k].send ( msg );
				}
				else 
				{
					this.queue.push(msg);
				}
			}
	} );

	which.on( "strangerDisconnected", function() {
		
		for ( var k in clients )
			if( this.mitm && clients[k].mitm && clients[k].mitm == this.mitm )
				Disconnect ( clients[k] );
		
		Disconnect(this);

	} );
	
	return which;
	
}

bot.on( "Message", function( name, steamID, msg ) {

	for(var k in clients)
		if ( clients[k].connected && !clients[k].mitm ) 
			clients[k].send( name + ": " + msg );

} );

var allowed_keys = {
	
	'mitm': true,
	'proxy_port': true,
	'proxy_ip': true,
	
}

bot.registerCommand( "omegle", function( name, steamID, args ) {

	if ( !bot.isAdmin( steamID ) )
		return;
		
	if ( args.length < 2 )
		return;
		
	var command = args.shift();
	
	var id = args.shift();
	
	switch(command)
	{
		
		case "create":
		
			if(id == "all")
			{
				bot.sendMessage("Not allowed!");
				break;
			}
		
			clients[id] = CreateNewOmegle(id);
			
			bot.sendMessage( "Created omegle " + id );
			
			break;
			
		case "reset":
			
			if ( id == "all" )
				for ( var k in clients )
				{
					
					Disconnect(clients[k]);
					
					clients[k] = null;
					
				}
			else if ( clients[id] )
			{
				Disconnect( clients[id] );
				clients[id] = null;
			}
			break;
			
		case "start":
			if ( id == "all" )
				for ( var k in clients )
				{
					
					Connect ( clients[k], args );
					
				}
				
			else if ( clients[id] )
				Connect ( clients[id], args );
				
			break;
			
		case "stop":
		
			if ( id == "all" )
				for ( var k in clients )
				{
					
					Disconnect ( clients[k] );
					
				}
			
			else if ( clients[id] )
				Disconnect ( clients[id] );
			
			break;
			
		case "set":
			
			if(args.length < 2) break;
			
			var key = args.shift();
			
			if(!allowed_keys[key])
			{
				
				bot.sendMessage("Not allowed.");
				
				break;
				
			}
				
			var value = args.shift();
			
			if ( id == "all" )
				for ( var k in clients )
				{
					
					clients[k][key] = value;
					
				}
			
			else if ( clients[id] )
				clients[id][key] = value;
				
			break;
			
		default:
		
			bot.sendMessage("Unknown subcommand.");
			break;
			
	}

}, "[ADMIN] Connect the group chat to a random omegle user." );

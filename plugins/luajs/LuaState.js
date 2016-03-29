"use strict";
const EventEmitter = require("events");
const child_process = require("child_process");
const fs            = require("fs");
const crc32         = require("buffer-crc32");
const EOF           = "\x00";


const LuaState = class LuaState extends EventEmitter
{
    constructor(emitter)
    {
        super();
        this.emitter = emitter;

        // build packets

        var directories = fs.readdirSync(__dirname + "/packets");

        this.packetTypes = {};

        for (let file of directories)
        {

            if (!fs.statSync(__dirname + "/packets/" + file).isFile())
                continue;

            this.packetTypes[file.substring(0, file.length - 3)] = require("./packets/" + file);

        }

        setInterval(()=>this.processCommand(), 10);


    }

    emit()
    {

        super.emit.apply(this, arguments);
        if (this.emitter)
            this.emitter.emit.apply(this.emitter, arguments);

    }

    restart()
    {


        this.pendingKill = true;
        this.queueCommand("SendKillNotif()", false);

        for (let type in this.packetTypes)
            if (this.packetTypes[type].clean)
                this.packetTypes[type].clean(this);

        setTimeout(() => {
            if (this.pendingKill) // it hasn't killed, someone might have infinite looped it somehow
            {
    	        console.log("KillNotif took too long to be received, force restarting.");
                this.inst.kill();
                this.start();
            }
        }, 2500);
    }

    start()
    {
    	this.inst = child_process.spawn(config.LuaBin || "lua", [ "init.lua" ], {
    		cwd: __dirname + "/../lua",
    		uid: config.LuaBinUID
    	});

    	this.cmdbuf     = [];
        this.packets    = "";

    	this.inst.stdout.on("data", (data) => this.onStdOut(data));
    	this.inst.stderr.on("data", (data) => {
            this.emit("error", data);
    	});

        this.queueCommand("require 'autorun'", true, true);

        this.userpackets = {};

        return this;
    }

    queueCommand(cmd, sandbox, showerror, steamid, groupid)
    {
    	if (!cmd)
            return;

		if (cmd[0] == "]")
        {
			showerror = true
			cmd = cmd.substring(1)
		}

		if (steamid) // Only calculate CRC on non-internal code
        {
			var mtime  = (new Date).getTime(); // seed the crc32 with the epoch in milliseconds
			var cmdcrc = crc32.signed( mtime + cmd );
			// The chance of a collision is really low, but still possible.
			// TODO?: Check for collisions and re-crc the command?
		}

		this.cmdbuf.push({
			command:       cmd,
			crc:           cmdcrc    || 0,
			sandbox:       sandbox   != null ? sandbox   : true,
			showerrors:    showerror != null ? showerror : true,
			steamid:       steamid   != null ? steamid   : 0,
			groupid:       groupid   != null ? groupid   : 0
		});
    }

    createHeader(cmd)
    {
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

    queueHook(event, args) {

    	var buf = ["HookCall(", this.luaQuote(event)];

    	if (args && args.length > 0) {


    		for (var i = 0; i < args.length; i++) {

    			buf.push(",");
    			buf.push(this.luaQuote(args[i]));

    		}

    	}

    	buf.push(")");

    	this.queueCommand(buf.join(""), false, true);

    }

    luaQuote(str)
    {
    	return "\"" + str.replace(/.|\r|\n/gm, function( c ) {

    		switch ( c )
            {
    			case "\"":
    			case "\\":
    			case "\n":
                case "\r":
    				return "\\" + c;

    			case "\0":
    				return "\\x00";
    		}

    		return c;

    	}) + "\"";
    }

    parsePacket()
    {
    	var packet = {}

    	// TypeNa\\m\,e,data\
    	// data
    	//

    	// this has Typename = TypeNa\m,e and data = data
    	// data
    	var parsed = /^((?:\\\\|\\,|(?!\\)(?!,)[^])*?),((?:\\\\|\\:|(?!\\)(?!\:)[^])*):([^]*)$/.exec(this.packets);
    	// '.' doesn't match newlines...
    	if (!parsed)
        {
    		return false;
    	}
        this.packets = parsed[3];
    	parsed[1] = parsed[1].replace(/\\\\/g, "\\").replace(/\\,/g, ",");
    	parsed[2] = parsed[2].replace(/\\\\/g, "\\").replace(/\\:/g, ":");
    	packet.type = parsed[1];
    	packet.raw = parsed[2];

        var constructor = this.packetTypes[packet.type];

        if (!constructor)
        {
            console.log("ParsePacket received unknown packet type '" + packet.type + "'")
            return;
        }

        packet = new constructor(packet.raw);

    	return packet;

    }

    processCommand()
    {
    	var cmd = this.cmdbuf.shift();
    	if (!cmd)
    		return;

    	if (this.userpackets[cmd.crc]) // Hopefully this will never happen...
    		console.log("The CRC " + cmd.crc + " is not unique!\n", cmd);

    	if (cmd.crc != 0)
    		this.userpackets[cmd.crc] = cmd;

    	this.inst.stdin.write(this.createHeader(cmd) + cmd.command + EOF + "\n");
    }

    onStdOut(data)
    {
        this.packets += data.toString();
        let packet;
        while(packet = this.parsePacket())
            packet.process(this);
    }
}

module.exports = LuaState;

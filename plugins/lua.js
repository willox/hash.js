"use strict";
var dns             = require("dns");
var url             = require("url");
const LuaState      = require("./luajs/LuaState.js");
const lua           = new LuaState(bot);
lua.start();
lua.on("LuaLog", console.log);
lua.on("error", console.log);


bot.on( "Message", function(name, steamID, msg, group)
{

	if (steamID == group) // This is a PM
		if (!config.AllowLuaPM && !bot.isAdmin(steamID)) // Only allow admin to PM Lua code if config var unset
			return;

	lua.queueCommand("SetLastExecutedSteamID(" + steamID + ")", false, true);

	lua.queueHook("Message", [name, steamID, msg]);

	lua.queueCommand(msg, true, msg[0] == "]", steamID, group);

});

bot.on("UserConnected", (name, steamID) =>
	lua.queueHook("Connected", [name, steamID])
);


bot.on("UserDisconnected", (name, steamID) =>
	QueueHook("Disconnected", [name, steamID])
);


bot.on( "FPThreadUpdate", ( title, postID ) =>
	lua.queueHook("FPThreadUpdate", [title, postID])
);


bot.on("GithubUpdate", (notification) =>
	lua.queueHook("GithubUpdate", [
		notification.repository.full_name,
		notification.subject.title,
		notification.subject.latest_comment_url
	])
);

lua.on("LuaPacket", (packet) => {
	var crc     = packet.crc;
	var islua   = packet.isLua;
	var info    = lua.userpackets[crc];
	var showerr = info ? info.showerrors : true;

	if (packet.data && (islua || !islua && showerr)) {
		bot.sendMessage(packet.data, info ? info.groupid : null);
	}

	if (crc != 0) {
		var steamid  = info ? info.steamid || 0  : 0;
		var groupid  = info ? info.groupid || 0  : 0;
		var message  = info ? info.command || "" : "";
		var userinfo = bot.Client.users[steamid];
		var username = userinfo && userinfo.playerName || steamid.toString();
		if (islua) {
			bot.emit("LuaMessage", username, steamid, message, groupid);
			lua.queueHook("LuaMessage", [username, steamid, message]);
		} else {
			bot.emit("TextMessage", username, steamid, message, groupid);
			lua.queueHook("TextMessage", [username, steamid, message]);
		}
	}

	lua.userpackets[crc] = null;
});


bot.registerCommand("restart", () => lua.restart(), "Restarts the Lua engine.");

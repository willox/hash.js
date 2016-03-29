
local tostring    = require "stostring"
local scall       = require "scall"
local callbacks = {}

local i = 1;

local function CreateHTTPPacket( url, id )
	return "HTTP,"..tostring(id)..";"..GetLastExecutedSteamID()..";"..
	       PacketSafe(url)..":";
end

function HTTPCallback ( id, code, body, err )

    if (not callbacks[id]) then
        return;
    end

    local callback = callbacks[id]

    callbacks[id] = nil

    local s, e = scall(callback, code, body, err)

    if ( not s ) then
        print( "error in http callback '"..id.."' "..e);
    end

end


local function HTTP ( url, callback )

	assert( type(url) == "string",
        "bad argument #1 to 'HTTP' (string expected, got " .. type( url ) .. ")",
         2
    )

	assert(url:len() >= 1,
		"bad argument #1 to 'HTTP' (string len is zero)"
	);

    callbacks[i] = callback

    writepacket ( CreateHTTPPacket ( url, i ) )

    i = i + 1;

end

return {
    Fetch = HTTP,
}

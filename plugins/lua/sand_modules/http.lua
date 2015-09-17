
local tostring    = require "stostring"
local scall       = require "scall"
local callbacks = {}

local i = 1;

local function CreateHTTPPacket( url, id )
	local header = HEADERSTART .. "HTTP," ..
		PacketSafe(url, 2) .. ":" .. tostring(id) .. HEADEREND ..
		GetLastExecutedSteamID( )
	return header
end

function HTTPCallback ( id, code, body, err )

    if ( not callbacks[id] ) then
        return;
    end

    local callback = callbacks[id]

    callbacks[id] = nil

    callback ( code, body, err )

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
    writepacket ( EOF )

    i = i + 1;

end

return {
    Fetch = HTTP,
}

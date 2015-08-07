ENV = {}

require "superstring"

local tostring    = require "stostring"
local scall		  = require "scall"
EOF               = "\x00"
HEADERSTART       = '['
HEADEREND         = ']'
writepacket       = io.write

-- Redefine io.write/print to save output to a per-user buffer for PMs.
-- See g_write in liolib.c
local stdoutbuf = ""
function io.write( ... )
	local args  = { ... }

	stdoutbuf = stdoutbuf .. table.concat( args )
end

-- See luaB_print in lbaselib.c
function print( ... )
	local args  = { ... }

	for k, v in pairs(args) do
		v = tostring(v)
		stdoutbuf = stdoutbuf .. v .. "\t"
	end

	stdoutbuf = stdoutbuf .. "\n"
end

require "env"
require "user_modules/gmod_defines"

function ParseHeader(data)
	local header = {}
	data = data:sub( 2, -2 ) -- Remove the header markers

	local headers = string.Explode( ":", data )
	if ( #headers ~= 5 ) then
		io.stderr:write( "ParseHeader called with invalid data: \"" .. data .. "\"\n" )
		io.stderr:flush()
	else
		header.crc       = tonumber(headers[1]) or 0
		header.sandbox   = headers[2] and headers[2]:sub(1, 1):lower() == "t" or false
		header.showerror = headers[3] and headers[3]:sub(1, 1):lower() == "t" or false
		header.steamid   = tonumber(headers[4]) or 0
		header.groupid   = tonumber(headers[5]) or 0
	end

	return header
end

function CreatePacket( crc, data, validlua )
	local header = HEADERSTART .. "Lua," .. tostring(crc) .. ":"
	header = header .. (validlua and "1" or "0") .. HEADEREND
	data = string.gsub(data, "\x00", "")
	return header .. tostring(data)
end

::start::
stdoutbuf = ""

--
-- Indicate that we are ready to receive a packet
--
writepacket( EOF ); io.flush()

--
-- Read until EOF marker
--
local expectheader = true  -- Should the next line read be the code header
local header       = nil   -- The header metadata for this code
local code         = ""    -- The string of code to execute
local codecrc      = 0     -- The CRC of the code and epoch seed. Used in the return packet.
local showerror    = false -- Should any error data be returned to the user
local sandboxcode  = true  -- Should this code run in our sandbox
local steamid      = 0     -- STEAM64 of the user that executed this, 0 if internal.
local groupid      = 0     -- Group ID that this code originated from. User SID if PM.
while( true ) do
	local data  = io.read() -- Read single line
	
	--io.stderr:write(data);

	if ( expectheader ) then
		if ( data:sub( 1, 1 ) == HEADERSTART and data:sub( -1 ) == HEADEREND ) then
			header       = ParseHeader(data)
			showerror    = header.showerror == true -- Default to false
			sandboxcode  = header.sandbox   ~= false -- Default to true
			steamid      = header.steamid   or 0
			groupid      = header.groupid   or 0
			codecrc      = header.crc       or 0
			expectheader = false
		else
			io.stderr:write( "io.read expected header, got \"" .. data .. "\" instead!\n" )
			io.stderr:flush()
		end
	else
		if ( data:sub( -1 ) == EOF ) then
			code = code .. data:sub( 0, -2 ) -- Remove the EOF
			break
		else
			code = code .. data .. "\n" -- Put the newline back
		end
	end
end

-- Returns true if this call is not being executed by a user
function IsInternal()
	return (steamid == 0) and (groupid == 0)
end

-- Return true if this code is being executed inside the sandbox
function IsSandboxed()
	return sandboxcode
end

-- Set the environment to the sandbox
local LOAD_ENV  = ENV
local CALL_FUNC = scall

-- Use the un-sandboxed the environment if the header says so
if ( not IsSandboxed() ) then
	--io.stderr:write("no sandbox: \"" .. code .. "\"\n"); io.stderr:flush();
	LOAD_ENV  = _ENV
	CALL_FUNC = pcall
end

--
-- Try our code with "return " prepended first
--
local f, err = load( "return " .. code, "eval", "t", LOAD_ENV )

if err then
	f, err = load( code, "eval", "t", LOAD_ENV )
end
--
-- We've been passed invalid Lua
--
if err then
	writepacket( CreatePacket( codecrc, err, false ) )
	io.flush()

	goto start
end

--
-- Try to run our function
--
local ret = { CALL_FUNC( f ) }

local success, err = ret[ 1 ], ret[ 2 ]

--
-- Our function has failed
--
if not success then
	writepacket( CreatePacket( codecrc, err, false ) )
	io.flush()

	goto start
end

--
-- Remove scall success success bool
--
table.remove( ret, 1 )

if ( #ret > 0 ) then -- Code returned something

	-- Transform our ret values in to strings
	for k, v in ipairs( ret ) do
		ret[ k ] = tostring( v )
	end

	local data = table.concat( ret, "\t" )
	writepacket( CreatePacket( codecrc, stdoutbuf .. data, true ) )

else -- Code returned nil, check if its `return lol` 'valid' or actually lua.

	local isphrase = code:match( "^[%w ]+$" ) -- Match alphanumeric and space
	if ( isphrase ) then
		writepacket( CreatePacket( codecrc, stdoutbuf, false ) )
	else
		writepacket( CreatePacket( codecrc, stdoutbuf, true ) )
	end

end
io.flush()

--
-- repeat
---
goto start

ENV = {}

require "superstring"

local tostring	= require "stostring"
local scall		= require "scall"
local EOF       = "\x00"

require "env"

local last_header

function GetLastHeader()

	return last_header
	
end
::start::

--
-- Indicate that we are ready to receive a packet
--
io.write( EOF ); io.flush()

--
-- Read until EOF marker
--
local code = ""
while( true ) do
	local data  = io.read() -- Read single line

	if ( string.sub(data, -1) == EOF ) then
		code = code .. string.sub(data, 0, -2) -- Remove the EOF
		break
	else
		code = code .. data .. "\n" -- Put the newline back
	end
end

--
-- Only display errors if the code starts with "]"
--
local silent_error = true

last_header = code:sub( 1, 3 )
code = code:sub( 4 )

local LOAD_ENV  = ENV
local CALL_FUNC = scall

if ( last_header == "JS!" ) then
	LOAD_ENV = _ENV
	CALL_FUNC = pcall
end



if code:sub( 1, 1 ) == "]" then

	code = code:sub( 2 )
	silent_error = false

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

	if not silent_error then
		io.write( err )
	end

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

	if not silent_error then
		io.write( tostring( err ) )
	end

	goto start

end

--
-- Remove scall success success bool
--
table.remove( ret, 1 )

--
-- Transform our ret values in to strings
--
for k, v in ipairs( ret ) do

	ret[ k ] = tostring( v )

end

io.write( table.concat( ret, "\t" ) )

--
-- repl
---
goto start

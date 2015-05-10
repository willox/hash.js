ENV = {}

require "superstring"

local tostring	= require "stostring"
local scall		= require "scall"

require "env"

::start::

--
-- Indicate that we are ready to receive a packet
--
io.write( "\n\x1A" ); io.flush()

--
-- Read until EOF
--
local code = io.read "a"

--
-- Only display errors if the code starts with "]"
--
local silent_error = true

if code:sub( 1, 1 ) == "]" then

	code = code:sub( 2 )
	silent_error = false
	
end

--
-- Try our code with "return " prepended first
--
local f, err = load( "return " .. code, "eval", "t", ENV )

if err then
	f, err = load( code, "eval", "t", ENV )
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
local ret = { scall( f ) }

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

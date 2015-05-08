require "superstring"

ENV = require "env"

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
-- Only display errors if the code starts with ">"
--
local silent_error = true

if code:sub( 1, 1 ) == ">" then

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

local thread	= coroutine.create( f )
local start		= os.clock()

--
-- Install our execution time limiter
--
debug.sethook( thread, function()

	if os.clock() > start + 0.5 then

		error( "maximum execution time exceeded", 2 )

	end

end, "", 128 )

--
-- Try to run our function
--
local ret = { pcall( coroutine.resume, thread ) }

local success, err = ret[ 2 ], ret[ 3 ]

if not success then

	if not silent_error then
		io.write( err )
	end

	goto start

end

--
-- Remove pcall success and coroutine success bools
--
table.remove( ret, 1 )
table.remove( ret, 1 )

--
-- Transform our ret values in to strings
--
for k, v in ipairs( ret ) do

	local success, v = pcall( tostring, v )

	if not success then

		if not silent_error then
			io.write( v )
		end

		goto start

	end

	ret[ k ] = v

end

local out = table.concat( ret, "\t" )

if not silent_error and code:gsub("[\r\n]$", ""):gsub("^['\"]", ""):gsub("['\"]$", "") == out then
	goto start
end

io.write( out )

--
-- repl
---
goto start

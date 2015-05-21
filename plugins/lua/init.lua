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
-- Read code from stdin
-- Input is preceded by two chars
-- The first char is "S" or "T", S = sandboxed, T = trusted
-- The second char is "Y" or "N", Y = show errors, N = don't
--
local packet = io.read( io.read "n" or 0 ) or "YY\0"

local CODE_SANDBOX, CODE_SUPPRESS, CODE = packet:match "(.)(.)(.*)"

CODE_SANDBOX	= CODE_SANDBOX	== "S"
CODE_SUPPRESS	= CODE_SUPPRESS	== "Y"

--
-- If the code is sandboxed, it must used scall and the sandboxed environment
--
local CODE_ENV		= _ENV
local CODE_CALL		= pcall

if CODE_SANDBOX then
	CODE_ENV	= ENV
	CODE_CALL	= scall
end

--
-- Try our code with "return " prepended first
--
local f, err = load( "return " .. CODE, "eval", "t", CODE_ENV )

if err then
	f, err = load( CODE, "eval", "t", CODE_ENV )
end

--
-- We've been passed invalid Lua
--
if err then

	if not CODE_SUPPRESS then
		io.write( err )
	end

	goto start

end

--
-- Try to run our function
--
local ret = { CODE_CALL( f ) }

local success, err = ret[ 1 ], ret[ 2 ]

--
-- Our function has failed
--
if not success then

	if not CODE_SUPPRESS then
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

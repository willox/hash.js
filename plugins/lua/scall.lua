
local tostring;

local function scall( f, ... )

	local start		= os.clock()
	local thread	= coroutine.create( f )

	--
	-- Install our execution time limiter
	--
	debug.sethook( thread, function()

		if os.clock() > start + 2 then
			
			error( "maximum execution time exceeded", 2 )

		end

	end, "", 128 )

	--
	-- Try to run our function
	--
	local ret = { pcall( coroutine.resume, thread, ... ) }

	local success, err = ret[ 1 ] and ret[ 2 ], ret[ 1 ] and ret[ 3 ] or ret [ 2 ]

	if not success then

		return false, tostring(err)

	end


	return true, table.unpack( ret, 3 )

end

package.loaded.scall = scall

tostring             = require"stostring" -- circular dependancy

return scall

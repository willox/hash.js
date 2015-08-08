
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

	end, "", 512 )

	--
	-- Try to run our function
	--
	local ret = { pcall( coroutine.resume, thread, ... ) }
	
	
	
	local success, err
	
	if ( coroutine.status( thread ) == "dead" ) then 
		
		success, err = ret[ 1 ] and ret[ 2 ], ret[ 1 ] and ret[ 3 ] or ret [ 2 ]
		
	else
		
		success, err = false, tostring( ret[ 3 ] )
		
	end

	if not success then

		return false, tostring(err)

	end


	return true, table.unpack( ret, 3 )

end

package.loaded.scall = scall

tostring             = require"stostring" -- circular dependancy

return scall

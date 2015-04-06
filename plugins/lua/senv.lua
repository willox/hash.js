local function CreateSecureEnvironment()

	local function ProtectTable( tab )

		local ret = {}

		-- Copy new variables in to our table
		-- Tables are also protected
		for k, v in pairs( tab ) do

			if not getmetatable( v ) and type( v ) == "table" then

				ret[ k ] = ProtectTable( tab[ k ] )

			else

				ret[ k ] = tab[ k ]

			end

		end

		local meta			= {}
		meta.__index		= ret
		meta.__metatable	= FAKE_META

		function meta:__newindex( k, v )

			if rawget( ret, k, v ) then
				return
			end

			rawset( self, k, v )

		end

		function meta:__pairs()

			local t = {}

			for k, v in next, self, nil do
				t[ k ] = v
			end

			for k, v in pairs( meta.__index ) do
				t[ k ] = v
			end

			return next, t, nil

		end

		return setmetatable( {}, meta ), meta

	end

	local INDEX = {
		_VERSION			= _VERSION,
		assert				= assert,
		collectgarbage		= collectgarbage,
		error				= error,
		getmetatable		= getmetatable,
		ipairs				= ipairs,
		next				= next,
		pairs				= pairs,
		pcall				= pcall,
		print				= print,
		rawequal			= rawequal,
		select				= select,
		setmetatable		= setmetatable,
		tonumber			= tonumber,
		tostring			= tostring,
		type				= type,
		xpcall				= xpcall,

		cookie				= cookie,
		coroutine			= coroutine,
		hook				= hook,
		math				= math,
		string				= string,
		table				= table,
		timer				= timer,
		utf8				= utf8,

		io					= {
								write	= function( ... )
											io.write( ... )
										end
		},

		os					= {
								time	= os.time,
								clock	= os.clock
		}
	}

	function INDEX.load( chunk, chunkname )

		return load( chunk, chunkname, "t", ENV )

	end

	return ProtectTable( INDEX )

end

return CreateSecureEnvironment
local types = require "./serialize/types"

local encoders = {

	boolean = function( v )
		return string.pack( ">B", v and 1 or 0 )
	end,

	number = function( v )
		return string.pack( ">n", v )
	end,

	integer = function( v )
		return string.pack( ">j", v )
	end,

	string = function( v )
		return string.pack( ">s4", v )
	end

}

local function serialize( t )

	local tabArray, tabAssoc = {}, {}
	local valArray, valAssoc = {}, {}

	local function populateDictionary( v )

		if type( v ) == "table" then

			if not tabAssoc[ v ] then

				table.insert( tabArray, v )
				tabAssoc[ v ] = #tabArray

				for k, v in pairs( v ) do

					populateDictionary( k )
					populateDictionary( v )

				end

			end

		else

			if not valAssoc[ v ] then

				table.insert( valArray, v )
				valAssoc[ v ] = #valArray				

			end

		end

	end

	populateDictionary( t )

	local outBuf = {}

	--
	-- Write value data to output
	--
	for k, v in ipairs( valArray ) do

		local vType = type( v )

		if math.type( v ) == "integer" then
			vType = "integer"
		end

		if not encoders[ vType ] then
			error( "attempt to write unsupported type (" .. vType .. ")", 2 )
		end

		table.insert( outBuf, string.pack( ">B", types[ vType ] ) )
		table.insert( outBuf, encoders[ vType ]( v ) )

	end

	--
	-- Type of 0 signals end of value-set
	--
	table.insert( outBuf, string.pack( ">B", 0 ) )

	--
	-- Write table data to output
	--
	table.insert( outBuf, string.pack( ">j", #tabArray ) )

	for k, v in ipairs( tabArray ) do

		for k, v in pairs( v ) do

			--
			-- Write key data
			--
			if type( k ) ~= "table" then

				table.insert( outBuf, string.pack( ">B", 1 ) )
				table.insert( outBuf, string.pack( ">j", valAssoc[ k ] ) )

			else

				table.insert( outBuf, string.pack( ">B", 2 ) )
				table.insert( outBuf, string.pack( ">j", tabAssoc[ k ] ) )

			end

			--
			-- Write value data
			--
			if type( v ) ~= "table" then

				table.insert( outBuf, string.pack( ">B", 1 ) )
				table.insert( outBuf, string.pack( ">j", valAssoc[ v ] ) )

			else

				table.insert( outBuf, string.pack( ">B", 2 ) )
				table.insert( outBuf, string.pack( ">j", tabAssoc[ v ] ) )

			end

		end

		--
		-- Data-Type of 0 signals end of table
		--
		table.insert( outBuf, string.pack( ">B", 0 ) )

	end

	return table.concat( outBuf )

end

return serialize

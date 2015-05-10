local types = require "./serialize/types"
local ENV	= require "env"

local decoders = {

	boolean = function( data, pos )

		local v, nPos = string.unpack( ">B", data, pos )

		return v == 1, nPos

	end,

	number = function( data, pos )
		return string.unpack( ">n", data, pos )
	end,

	integer = function( data, pos )
		return string.unpack( ">j", data, pos )
	end,

	string = function( data, pos )
		return string.unpack( ">s4", data, pos )
	end,

	["function"] = function( data, pos )

		local v, nPos = string.unpack( ">s4", data, pos )

		return ( load( v, "serialized", "b", ENV ) ), nPos

	end

}

local function deserialize( data )

	local pos = 1

	local valArray, tabArray = {}, {}

	--
	-- Read in values to dictionary
	--
	for i = 1, math.huge do

		local vType, nPos = string.unpack( ">B", data, pos ); pos = nPos

		--
		-- Type of 0 indicates end of value-set
		--
		if vType == 0 then
			break
		end

		if not types[ vType ] then
			error( "attempt to decode invalid type (" .. vType .. ")", 2 )
		end

		vType = types[ vType ]

		local v, nPos = decoders[ vType ]( data, pos ); pos = nPos

		valArray[ i ] = v

	end

	--
	-- Read in tables to dioctionary
	--
	local tCount, tPos = string.unpack( ">j", data, pos ); pos = tPos

	--
	-- Create initial tables ready for any out-of-order references
	--
	for i = 1, tCount do
		tabArray[ i ] = {}
	end

	for i = 1, tCount do

		local tab = tabArray[ i ]

		for i = 1, math.huge do

			--
			-- Read key data
			--
			local kDataType, nPos = string.unpack( ">B", data, pos ); pos = nPos

			--
			-- Key Data-Type of 0 indicates end of table
			--
			if kDataType == 0 then
				break
			end

			local kVal = nil
			local kKey, nPos = string.unpack( ">j", data, pos ); pos = nPos

			if kDataType == 1 then
				kVal = valArray[ kKey ]
			else
				kVal = tabArray[ kKey ]
			end

			--
			-- Read value data
			--
			local vDataType, nPos = string.unpack( ">B", data, pos ); pos = nPos

			local vVal = nil
			local vKey, nPos = string.unpack( ">j", data, pos ); pos = nPos

			if vDataType == 1 then
				vVal = valArray[ vKey ]
			else
				vVal = tabArray[ vKey ]
			end

			tab[ kVal ] = vVal

		end

	end

	return tabArray[ 1 ]

end

return deserialize

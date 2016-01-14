local types = require "./serialize/types"

-- with: 4.4840000
-- without: 4.5080000
local pack   = string.pack
local concat = table.concat;
local unpack = table.unpack;
local type   = type;


local encoders = {

	boolean = function( v )
		return ">B", v and 1 or 0
	end,

	float = function( v )
		return ">n", v
	end,

	integer = function( v )
		return ">j", v
	end,

	string = function( v )
		return ">s4", v
	end,

	["function"] = function( v )
		local success, data = pcall( string.dump, v )

		return ">s4", success and data or string.dump( function() end )
	end

}

local function serialize( t )
	local FormatTable = { }
	local ArgTable = { }

	local tabArray, tabAssoc = {}, {}
	local valArray, valAssoc = {}, {}

	local TabLength, ValLength = 1, 1;

	local function populateDictionary( v )

		if type( v ) == "table" then

			if not tabAssoc[ v ] then
				tabArray[ TabLength ] = v
				tabAssoc[ v ] = TabLength
				TabLength = TabLength + 1

				-- use next so we don't infinite loop from __pairs
				for k, v in next, v, nil do
					populateDictionary( k )
					populateDictionary( v )
				end
			end

		else

			if not valAssoc[ v ] then
				valArray[ ValLength ] = v
				valAssoc[ v ] = ValLength;

				ValLength = ValLength + 1;
			end

		end

	end

	populateDictionary( t )

	--
	-- Write value data to output
	--
	for k = 1, #valArray do
		local v = valArray[k]
		local vType = math.type( v ) or type( v )

		if not encoders[ vType ] then
			error( "attempt to write unsupported type (" .. vType .. ")", 2 )
		end

		k = k * 2

		FormatTable[ k - 1 ],
		ArgTable[ k - 1 ],
		FormatTable[ k ],
		ArgTable[ k ] = ">B", types[vType], encoders[ vType ]( v )
	end



	--
	-- Type of 0 signals end of value-set
	--
	FormatTable[ #FormatTable + 1 ],
	ArgTable[ #ArgTable + 1 ] = ">B", 0

	--
	-- Write table data to output
	--
	FormatTable[ #FormatTable + 1 ],
	ArgTable[ #ArgTable + 1 ] = ">j", #tabArray

	local TableLength = #FormatTable + 1

	for k, v in ipairs( tabArray ) do

		-- use next so we don't infinite loop from __pairs

		for k, v in next, v, nil do

			FormatTable[ TableLength ],
			FormatTable[ TableLength + 1 ],
			FormatTable[ TableLength + 2 ],
			FormatTable[ TableLength + 3 ] = ">B", ">j", ">B", ">j"

			--
			-- Write key data
			--

			if type( k ) ~= "table" then
				ArgTable[ TableLength ],
				ArgTable[ TableLength + 1 ] = 1, valAssoc[ k ]
			else
				ArgTable[ TableLength ],
				ArgTable[ TableLength + 1 ] = 2, tabAssoc[ k ]
			end

			--
			-- Write value data
			--
			if type( v ) ~= "table" then
				ArgTable[ TableLength + 2 ],
				ArgTable[ TableLength + 3 ] = 1, valAssoc[ v ]
			else
				ArgTable[ TableLength + 2 ],
				ArgTable[ TableLength + 3 ] = 2, tabAssoc[ v ]
			end

			TableLength = TableLength + 4

		end

		--
		-- Data-Type of 0 signals end of table
		--

		FormatTable[ TableLength ], ArgTable[ TableLength ] = ">B", 0

		TableLength = TableLength + 1

	end
	TableLength = TableLength - 1

	local dat = {}

	local step = 2048;
	for i = 1, TableLength - step + 1, step do
		dat[ (i - 1) / step + 1 ] = pack(
			concat( FormatTable, "", i, i + step - 1 ),
			unpack( ArgTable, i, i + step - 1 )
		)
	end

	local next = #dat * step + 1

	dat[ #dat + 1 ] = pack(

		concat( FormatTable, "", next, TableLength),
		unpack( ArgTable, next, TableLength )

	)

	dat = table.concat(dat)

	return dat
end

return serialize

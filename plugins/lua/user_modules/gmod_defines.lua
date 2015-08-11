local pattern_escape_replacements = {
	["("] = "%(",
	[")"] = "%)",
	["."] = "%.",
	["%"] = "%%",
	["+"] = "%+",
	["-"] = "%-",
	["*"] = "%*",
	["?"] = "%?",
	["["] = "%[",
	["]"] = "%]",
	["^"] = "%^",
	["$"] = "%$",
	["\0"] = "%z"
}

function string.PatternSafe( str )
	return ( str:gsub( ".", pattern_escape_replacements ) )
end

function string.ToTable ( str )
	local tbl = {}

	for i = 1, string.len( str ) do
		tbl[i] = string.sub( str, i, i )
	end

	return tbl
end

local totable = string.ToTable
local string_sub = string.sub
local string_gsub = string.gsub
local string_gmatch = string.gmatch
function string.Explode(separator, str, withpattern)
	if (separator == "") then return totable( str ) end

	local ret = {}
	local index, lastPosition = 1, 1

	-- Escape all magic characters in separator
	if not withpattern then separator = separator:PatternSafe() end

	-- Find the parts
	for startPosition, endPosition in string_gmatch( str, "()" .. separator.."()" ) do
		ret[index] = string_sub( str, lastPosition, startPosition - 1 )
		index = index + 1

		-- Keep track of the position
		lastPosition = endPosition
	end

	-- Add last part by using the position we stored
	ret[index] = string_sub( str, lastPosition)
	return ret
end

function table.Random(tbl)
    local count = 0
    for _,_ in pairs(tbl) do count = count + 1 end
    local i = 1
    local rk = math.random(1, count)
    for k,v in pairs(tbl) do
        if i == rk then return v, k end
        i = i + 1
    end
end

function table.Count(t)
    local size = 0
    for k in pairs(t) do
        size = size + 1
    end
    return size
end

function table.Copy( t, lookup_table )
	if ( t == nil ) then return nil end

	local copy = {}
	setmetatable( copy, getmetatable( t ) or {} )
	for i, v in pairs( t ) do
		if ( type(v) ~= "table" ) then
			copy[ i ] = v
		else
			lookup_table = lookup_table or {}
			lookup_table[ t ] = copy
			if ( lookup_table[ v ] ) then
				copy[ i ] = lookup_table[ v ] -- we already copied this table. reuse the copy.
			else
				copy[ i ] = table.Copy( v, lookup_table ) -- not yet copied. copy it.
			end
		end
	end
	return copy
end

function table.Empty( tab )
	for k, v in pairs( tab ) do
		tab[ k ] = nil
	end
end

function table.Merge( dest, source )
	for k, v in pairs( source ) do
		if ( type( v ) == "table" and type( dest[ k ] ) == "table" ) then
			-- don't overwrite one table with another
			-- instead merge them recurisvely
			table.Merge( dest[ k ], v )
		else
			dest[ k ] = v
		end
	end
	return dest
end

function table.Add( dest, source )
	-- At least one of them needs to be a table or this whole thing will fall on its ass
	if ( type( source ) ~= "table" ) then return dest end
	if ( type( dest ) ~= "table" ) then dest = {} end

	for k, v in pairs( source ) do
		table.insert( dest, v )
	end
	return dest
end

function table.ClearKeys( Table, bSaveKey )
	local OutTable = {}

	for k, v in pairs( Table ) do
		if ( bSaveKey ) then
			v.__key = k
		end
		table.insert( OutTable, v )
	end
	return OutTable
end

function table.GetKeys( tab )
	local keys = {}
	local id = 1

	for k, v in pairs( tab ) do
		keys[ id ] = k
		id = id + 1
	end
	return keys
end

function table.Reverse( tbl )
	local len = #tbl
	local ret = {}

	for i = len, 1, -1 do
		ret[ len - i + 1 ] = tbl[ i ]
	end
	return ret
end

function table.IsSequential( t )
	local i = 1
	for key, value in pairs( t ) do
		if ( not tonumber( i ) or key ~= i ) then return false end
		i = i + 1
	end
	return true
end

local function MakeTable( t, nice, indent, done )
	local str    = ""
	local done   = done or {}
	local indent = indent or 0
	local idt    = ""
	if nice then idt = string.rep( "\t", indent ) end
	local nl, tab = "", ""
	if ( nice ) then nl, tab = "\n", "\t" end

	local sequential = table.IsSequential( t )

	for key, value in pairs( t ) do
		str = str .. idt .. tab .. tab
		if not sequential then
			if type( key ) == "number" or type( key ) == "boolean" then
				key = "[" .. tostring( key ) .. "]" .. tab .. "="
			else
				key = tostring( key ) .. tab .. "="
			end
		else
			key = ""
		end

		if ( type( value ) == "table" and not done[ value ] ) then
			done [ value ] = true
			str = str .. key .. tab .. "{" .. nl .. MakeTable( value, nice, indent + 1, done )
			str = str .. idt .. tab .. tab .. tab .. tab .."},".. nl
		else
			if ( type( value ) == "string" ) then
				value = '"' .. tostring( value ) .. '"'
			elseif ( type( value ) == "Vector" ) then
				value = "Vector(" .. value.x .. "," .. value.y .. "," .. value.z .. ")"
			elseif ( type( value ) == "Angle" ) then
				value = "Angle(" .. value.pitch .. "," .. value.yaw .. "," .. value.roll .. ")"
			else
				value = tostring( value )
			end
			str = str .. key .. tab .. value .. "," .. nl
		end
	end
	return str
end

function table.ToString( t, n, nice )
	local nl, tab  = "", ""
	if ( nice ) then nl, tab = "\n", "\t" end

	local str = ""
	if ( n ) then str = n .. tab .. "=" .. tab end
	return str .. "{" .. nl .. MakeTable( t, nice ) .. "}"
end

function PrintTable( t, indent, done )
	done = done or {}
	indent = indent or 0
	local keys = table.GetKeys( t )

	table.sort( keys, function( a, b )
		if ( type( a ) == "number" and type( b ) == "number" ) then return a < b end
		return tostring( a ) < tostring( b )
	end )

	for i = 1, #keys do
		key = keys[ i ]
		value = t[ key ]
		io.write( string.rep( "\t", indent ) )

		if  ( type( value ) == "table" and not done[ value ] ) then
			done[ value ] = true
			io.write( tostring( key ) .. ":" .. "\n" )
			PrintTable( value, indent + 2, done )
		else
			io.write( tostring( key ) .. "\t=\t" )
			io.write( tostring( value ) .. "\n" )
		end
	end
end

util = util or {};


local Polynomial = 0xEDB88320;
local lookup = {};
for i = 0, 0xFF do
	local crc = i;
	for j = 0, 7 do
		crc = (crc >> 1) ~ ((crc & 1) * Polynomial);
	end
	lookup[i] = crc;
end
local function dw(x) return x & 0xFFFFFFFF; end

function util.CRC(stuff)
	
	stuff = tostring(stuff);
	
	local crc = dw(~0);
	for i = 1, stuff:len() do
		crc = (crc >> 8) ~ lookup[((crc & 0xFF) ~ stuff:byte(i,i))];
	end
	
	return dw(~crc);

end

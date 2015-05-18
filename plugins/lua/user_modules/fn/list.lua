f         = f    or {}
f.mt      = f.mt or {}
f.mt.list = f.mt.list or {}

f.list = function (t)
	t = t or {}
	
	local list = { array = {} }
	setmetatable (list, f.mt.list)
	
	for i = 1, #t do
		list [i] = t [i]
	end
	
	return list
end

f.map    = function (mapF, r, ...)        mapF    = f.toFunction (mapF)    if mapF == print then print (f.concat (f.map (tostring, r), ", ")) return end local rr = f.list () for i = 1, #r do rr [i] = mapF (r [i], ...) end return rr end
f.filter = function (filterF, r, ...)     filterF = f.toFunction (filterF) local rr = f.list () for i = 1, #r do if filterF (r [i], ...) then rr [#rr + 1] = r [i] end end return rr end
f.foldr  = function (x0, binaryF, r, ...) binaryF = f.toFunction (binaryF) for i = #r, 1, -1 do x0 = binaryF (r [i], x0, ...) end return x0 end
f.foldl  = function (x0, binaryF, r, ...) binaryF = f.toFunction (binaryF) for i = 1, #r     do x0 = binaryF (x0, r [i], ...) end return x0 end
f.range  = function (x0, x1, dx) dx = dx or 1 local r = f.list () for i = x0, x1, dx do r [#r + 1] = i end return r end
f.rep    = function (v, n) local r = f.list () for i = 1, n do r [i] = v end return r end
f.sum    = function (r) return foldr (0, f.add, r) end
f.prod   = function (r) return foldr (1, f.mul, r) end

f.keys   = function (t) local r = f.list () for k, _ in pairs (t) do r [#r + 1] = k end return r end
f.values = function (t) local r = f.list () for _, v in pairs (t) do r [#r + 1] = v end return r end

f.mt.list.__index = {}
f.mt.list.__len          = function (self) return #self.array end
f.mt.list.__pairs        = function (self) return pairs (self.array) end
f.mt.list.methods = {}
f.mt.list.methods.map    = function (r, mapF, ...)        return f.map    (mapF, r, ...)      end
f.mt.list.methods.filter = function (r, filterF, ...)     return f.filter (filterF, r, ...)      end
f.mt.list.methods.foldr  = function (r, binaryF, x0, ...) return f.foldr  (x0, binaryF, r, ...) end
f.mt.list.methods.foldl  = function (r, binaryF, x0, ...) return f.foldl  (x0, binaryF, r, ...) end
f.mt.list.methods.sum    = f.sum
f.mt.list.methods.prod   = f.prod
f.mt.list.methods.concat = f.concat

f.mt.list.__index = function (self, k)
	if f.mt.list.methods [k] then
		return f.mt.list.methods [k]
	elseif type (k) == "number" then
		return self.array [k]
	elseif type (k) == "table" then
		return f.list (k):map (self)
	end
end

f.mt.list.__newindex = function (self, k, v)
	if type (k) == "number" then
		self.array [k] = v
	elseif type (k) == "table" then
		if type (v) == "table" then
			for i = 1, #k do
				self [k [i]] = v [i]
			end
		else
			for i = 1, #k do
				self [k [i]] = v
			end
		end
	end
end

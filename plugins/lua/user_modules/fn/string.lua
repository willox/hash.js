String = function (s)
	local t = { s = s }
	
	setmetatable (t,
		{
			__len = function (self) return #self.s end,
			__tostring = function (self) return self.s end,
			__index = function (self, k)
				if string [k] then
					return function (self, ...)
						return string [k] (self.s, ...)
					end
				end
				if type (k) == "number" then
					return string.sub (self.s, k, k)
				elseif type (k) == "table" then
					local t = {}
					for i = 1, #k do
						t [#t + 1] = string.sub (self.s, k [i], k [i])
					end
					return table.concat (t)
				end
			end
		}
	)
	return t
end
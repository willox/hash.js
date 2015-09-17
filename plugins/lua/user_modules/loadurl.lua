function lurl(url, callback)
	http.Fetch(url, function(_, b)
		local out = {load(b)()}
		if callback then
			callback(table.unpack(out))
		end
	end)
end

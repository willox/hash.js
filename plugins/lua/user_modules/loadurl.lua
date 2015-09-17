function lurl(url, callback)
	http.Fetch(url, function(code, body, err)
		if (code == 200) then
			local out = {load(body)()}
			if callback then
				callback(table.unpack(out))
			end
		end
	end)
end

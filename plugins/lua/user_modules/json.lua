lurl("http://regex.info/code/JSON.lua", function(JSON)
	json = {AUTHOR_NOTE = JSON.AUTHOR_NOTE, _obj = JSON}
	function json.encode(tab, etc, options)
		return JSON:encode(tab, etc, options)
	end
	function json.encode_pretty(tab, etc, options)
		return JSON:encode_pretty(tab, etc, options)
	end
	function json.decode(str, etc)
		return JSON:decode(str, etc)
	end
end)

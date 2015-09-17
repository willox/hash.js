function lurl(url, callback)
	http.Fetch(url, function(_, b)
		local out = {load(b)()}
		if callback then
			callback(table.unpack(out))
		end
	end)
end

require "json"
require "sed"
require "gmod_defines"
require "messagestats"
require "fn"
require "vectors"
require "http_codes"
require "algo"
require "imagereply"
require "yt"

hook.StopPersist()

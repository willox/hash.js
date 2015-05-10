local CircularBuffer = require ("circularbuffer")

local sed = {}
sed.messages = CircularBuffer (20)

hook.Add ("Message", "sed",
	function (name, communityId, message)
		local a, b = string.match (message, "^s/(.*)/(.*)/$")
		if a then
			for i = 1, sed.messages:getSize () do
				local message = sed.messages:get (-i)
				if not message then break end
				
				if string.find (message.message, a) then
					local newMessage = string.gsub (message.message, a, b)
					print (message.name .. ": " .. newMessage)
					sed.messages:add ({ name = message.name, communityId = message.communityId, message = newMessage })
					break
				end
			end
		else
			sed.messages:add ({ name = name, communityId = communityId, message = message })
		end
	end
)
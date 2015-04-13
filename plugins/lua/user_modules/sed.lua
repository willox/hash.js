local CircularBuffer = require ("circularbuffer")

sed = sed or {}
sed.messages = CircularBuffer (20)

local persistent = false

local function Handle (name, communityId, message)

		local p, a, b = string.match (message, "^([sp])/(.*)/(.*)/$")

		if a then
			if p == "p" then
				persistent = message
			end

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

			if persistent then
				return Handle (name, communityId, persistent)
			end
		end

end

hook.Add ("Message", "sed", Handle)
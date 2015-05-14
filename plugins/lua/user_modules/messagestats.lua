hook.Add("Message", "Lengthometer", function(name,id, text) 
	cookie.texts = cookie.texts or {} 
	cookie.texts[#cookie.texts + 1] = text:len() 
end)
stats = {};

function stats.MeanLength()
	local max = 0;
	for i = 1, #cookie.texts do 
		max = max + cookie.texts[i];
	end
	return max / #cookie.texts;
end
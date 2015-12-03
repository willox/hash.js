local new_cookie = cookie.GetProtected"texts"

if ( not new_cookie.transitioned ) then

	for k,v in pairs(cookie.texts or {}) do
		new_cookie[k] = v
	end

	cookie.texts = nil
	new_cookie.transitioned = true

end

local cookie = new_cookie

cookie.mean = cookie.mean or 0;
cookie.tracked = cookie.tracked or 0;
cookie.totallen = cookie.totallen or 0;
cookie.ids = cookie.ids or {};
cookie.cocks = cookie.cocks or 0

local function add(stmd, len)
	local mean = cookie.mean;
	local amt = cookie.tracked;

	mean = (mean * (amt / (amt + 1))) + len / (amt + 1);
	amt = amt + 1;

	cookie.tracked = amt;
	cookie.mean = mean;


	local total = cookie.totallen;

	for k,v in pairs(cookie.ids) do
		v.len = v.len * (total / (total + len));
	end
	cookie.ids[stmd] = cookie.ids[stmd] or {};

	cookie.ids[stmd].len = (cookie.ids[stmd].len or 0) + len / (total + len);

	cookie.totallen = cookie.totallen + len;
end

hook.Add("Message", "Lengthometer", function(name,id, text)
	add(id, text:len());

	text:gsub("cock", function()
		cookie.cocks = cookie.cocks + 1
	end )
end)

stats = stats or {};

function stats.MeanLength() return cookie.mean end

function stats.TotalCharsSent(id)
	if(id) then
		local info = cookie.ids[tostring(id)];
		if(not info) then return; end
		return info.len * cookie.totallen;
	end
	return cookie.totallen;
end

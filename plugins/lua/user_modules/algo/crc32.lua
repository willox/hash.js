
algo = algo or {};

function algo.CRC32(stuff)

	local Polynomial = 0xEDB88320;
	local lookup = {};
	for i = 0, 0xFF do
		local crc = i;
		for j = 0, 7 do
			crc = (crc >> 1) ~ ((crc & 1) * Polynomial);
		end
		lookup[i] = crc;
	end
	local function dw(x) return x & 0xFFFFFFFF; end
	local poly = 0xEDB88320;
	local crc = dw(~0);
	for i = 1, stuff:len() do
		crc = (crc >> 8) ~ lookup[((crc & 0xFF) ~ stuff:sub(i,i):byte())];
	end
	
	return dw(~crc);

end
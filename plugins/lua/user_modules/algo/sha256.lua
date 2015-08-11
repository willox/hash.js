local function bt(x) return x & 0xFF; end
local function dw(x) return x & 0xFFFFFFFF; end

local function ROTLEFT(a,b) return dw((a<<b) | (a >> (32-b))); end
local function ROTRIGHT(a,b) return dw((a>>b) | (a<<(32-b))) end
local function CH(x,y,z) return (x & y) ~ (~x & z); end
local function MAJ(x,y,z) return ((x&y) ~ (x&z)) ~ (y&z); end
local function EP0(x) return ROTRIGHT(x,2) ~ ROTRIGHT(x,13) ~ ROTRIGHT(x,22); end
local function EP1(x) return ROTRIGHT(x,6) ~ ROTRIGHT(x,11) ~ ROTRIGHT(x,25); end
local function SIG0(x) return ROTRIGHT(x,7) ~ ROTRIGHT(x,18) ~ (x>>3); end
local function SIG1(x) return ROTRIGHT(x,17) ~ ROTRIGHT(x,19) ~ (x>>10); end

local k = {
   0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
   0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
   0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
   0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
   0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
   0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
   0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
   0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
};

local function sha256_transform(ctx, data)
	
	local a,b,c,d,e,f,g,h,i,j,t1,t2;
	local m = {};
	
	for i = 0, 15 do
		local j = i*4;
	
		m[i] = dw((data[j] << 24) | (data[j+1] << 16) | (data[j+2] << 8) | data[j+3]);
	
	end
	
	for i = 16, 63 do 
		m[i] = dw(SIG1(m[i-2]) + m[i-7] + dw(SIG0(m[i-15])) + m[i-16]);
	end
	
	a = ctx.state[0];
	b = ctx.state[1];
	c = ctx.state[2];
	d = ctx.state[3];
	e = ctx.state[4];
	f = ctx.state[5];
	g = ctx.state[6];
	h = ctx.state[7];
	
	for i = 0, 63 do
		t1 = dw(h + dw(EP1(e)) + dw(CH(e,f,g)) + k[i+1] + m[i]);
		t2 = dw(EP0(a)) + dw(MAJ(a,b,c));
		h = g;
		g = f;
		f = e;
		e = dw(d + t1);
		d = c;
		c = b;
		b = a;
		a = dw(t1 + t2);
	end
	
	ctx.state[0] = dw(ctx.state[0] + a);
	ctx.state[1] = dw(ctx.state[1] + b);
	ctx.state[2] = dw(ctx.state[2] + c);
	ctx.state[3] = dw(ctx.state[3] + d);
	ctx.state[4] = dw(ctx.state[4] + e);
	ctx.state[5] = dw(ctx.state[5] + f);
	ctx.state[6] = dw(ctx.state[6] + g);
	ctx.state[7] = dw(ctx.state[7] + h);
end

local function sha256_init()
	local ctx = {bitlen = {}, state = {}, data = {}};
	ctx.datalen = 0;
	ctx.bitlen[0] = 0;
	ctx.bitlen[1] = 0;
	ctx.state[0] = 0x6a09e667;
	ctx.state[1] = 0xbb67ae85;
	ctx.state[2] = 0x3c6ef372;
	ctx.state[3] = 0xa54ff53a;
	ctx.state[4] = 0x510e527f;
	ctx.state[5] = 0x9b05688c;
	ctx.state[6] = 0x1f83d9ab;
	ctx.state[7] = 0x5be0cd19;
	return ctx;
end

local sfunction sha256_update(ctx, data)
	
	local len = data:len();
	
	local t, i;
	
	for i = 0, len - 1 do
		
		ctx.data[ctx.datalen] = bt(data:byte(i+1,i+1));
		ctx.datalen = ctx.datalen + 1;
		if(ctx.datalen == 64) then
		
			sha256_transform(ctx, ctx.data);
			ctx.bitlen[0] = ctx.bitlen[0] + 512;
			if(ctx.bitlen[0] ~= dw(ctx.bitlen[0])) then
				ctx.bitlen[0] = dw(ctx.bitlen[0]);
				ctx.bitlen[1] = ctx.bitlen[1] + 1;
			end
			ctx.datalen = 0;
			
		end
		
	end
	
end

local function sha256_final(ctx)

	local i;
	
	i = ctx.datalen;
	
	if(ctx.datalen < 56) then
		ctx.data[i] = 0x80;
		i = i + 1;
		while(i < 56) do
			ctx.data[i] = 0;
			i = i + 1;
		end
	else
		ctx.data[i] = 0x80;
		i = i + 1;
		while(i < 64) do
			ctx.data[i] = 0;
			i = i + 1;
		end
		sha256_transform(ctx, ctx.data);
		for i = 0, 55 do
			ctx.data[i] = 0;
		end
	end
	
	ctx.bitlen[0] = ctx.bitlen[0] + ctx.datalen * 8;
	if(ctx.bitlen[0] ~= dw(ctx.bitlen[0])) then
		ctx.bitlen[0] = dw(ctx.bitlen[0]);
		ctx.bitlen[1] = ctx.bitlen[1] + 1;
	end
	ctx.data[63] = bt(ctx.bitlen[0]);
	ctx.data[62] = bt(ctx.bitlen[0] >> 8);
	ctx.data[61] = bt(ctx.bitlen[0] >> 16);
	ctx.data[60] = bt(ctx.bitlen[0] >> 24);
	
	ctx.data[59] = bt(ctx.bitlen[1]);
	ctx.data[58] = bt(ctx.bitlen[1] >> 8); 
	ctx.data[57] = bt(ctx.bitlen[1] >> 16);  
	ctx.data[56] = bt(ctx.bitlen[1] >> 24); 

	
	sha256_transform(ctx,ctx.data);
	
	local hash = {};
	for i = 0, 3 do
		hash[i] = (dw(ctx.state[0]) >> (24-i*8)) & 0xFF;
		hash[i+4] = (dw(ctx.state[1]) >> (24-i*8)) & 0xFF;
		hash[i+8] = (dw(ctx.state[2]) >> (24-i*8)) & 0xFF;
		hash[i+12] = (dw(ctx.state[3]) >> (24-i*8)) & 0xFF;
		hash[i+16] = (dw(ctx.state[4]) >> (24-i*8)) & 0xFF;
		hash[i+20] = (dw(ctx.state[5]) >> (24-i*8)) & 0xFF;
		hash[i+24] = (dw(ctx.state[6]) >> (24-i*8)) & 0xFF;
		hash[i+28] = (dw(ctx.state[7]) >> (24-i*8)) & 0xFF;
	end
	local ret = ("%02X"):rep(32):format(hash[0], hash[1], hash[2], hash[3], hash[4], hash[5], 
		hash[6], hash[7], hash[8], hash[9], hash[10], hash[11], hash[12], hash[13], hash[14], hash[15], 
		hash[16], hash[17], hash[18], hash[19], hash[20], hash[21], hash[22], hash[23], hash[24], hash[25], 
		hash[26], hash[27], hash[28], hash[29], hash[30], hash[31]
	);
	return ret;
end

algo = algo or {}

function algo.SHA256(stuff)

	local c = sha256_init();
	sha256_update(c, stuff);
	return sha256_final(c);
	
end

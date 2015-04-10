(getmetatable"" or {}).__index = function(self,k)
	if(type(k) == "number") then return self:sub(k,k); end
	return string[k];
end

local function print() end

local MEMORY_SIZE = 7; -- bytes of each ram of node

local eax, ecx, edx, ebx, esp, ebp, esi, edi, eflags = 0, 1, 2, 3, 4, 5, 6, 7, 8;
local ax, cx, dx, bx, sp, bp, si, di, flags = 0, 1, 2, 3, 4, 5, 6, 7, 8;
local al, cl, dl, bl, ah, ch, dh, bh = 0, 1, 2, 3, 4, 5, 6, 7;

_cf, _pf, _af, _zf, _sf, _tf, _if, _df, _of, _iopl, _nt =
	0, 1<<1, 1<<3, 1<<5, 1<<6, 1<<7, 1<<8, 1<<9, 1<<10, 1<<11, 1<<13
local regs = {
	--[[
	data = {
		[eax] = 0,
		[ecx] = 0,
		[edx] = 0,
		[ebx] = 0,
		[esp] = 0,
		[ebp] = 0,
		[esi] = 0,
		[edi] = 0,
	}
	]]--
	--[[ these get copied automagically ]]--
	eip = 0,
	idtr = 0,
};

function regs:get8(which)
	assert(which >= 0 and which < 8);
	return self.data[which] & 0xFF;
end

function regs:get16(which)
	assert(which >= 0 and which < 8);
	return self.data[which] & 0xFFFF;
end

function regs:get32(which)
	assert(which >= 0 and which < 8);
	return self.data[which] & 0xFFFFFFFF;
end

function regs:mov32(which, data)
	assert(which >= 0 and which < 8);
	self.data[which] = data & 0xFFFFFFFF;
end

function regs:mov16(which, data)
	assert(which >= 0 and which < 8);
	self.data[which] = data & 0xFFFF;
end

function regs:mov8(which, data)
	assert(which >= 0 and which < 8);
	self.data[which] = data & 0xFF;
end

function regs:flagset(which)
	return (self.data[eflags] & which) == which
end

function regs:setflag(which, val);
	if(val) then
		self.data[eflags] = self.data[eflags] | which;
	else
		self.data[eflags] = self.data[eflags] & ~which;
	end
end

function regs:push(data)
	assert(type(data) == "number");
	local stack = self.inst:get32(esp);
	self.inst:setmemory(stack, self.inst:str32(data));
	self.inst:mov32(esp, stack - 4);
end

function regs:pop()
	local stack = self:get32(esp);
	self:mov32(esp, stack + 4);
	return self.inst:uint32(self.inst:readmemory(stack + 4, 4));
end

local data = {};

function data:uint32(str)
	if(type(str) == "number") then return str; end
	
	local b1, b2, b3, b4 = 
		str[1]:byte(), str[2]:byte(), str[3]:byte(), str[4]:byte();
	
	return b1 | (b2 << 8) | (b3 << 16) | (b4 << 24);
end

function data:int32(str)
	if(type(str) == "number") then return str; end
	
	local ret = self:uint32(str);
	if((ret & (1<<31)) ~= 0) then
		ret = (ret & ~(1<<31)) - 0x80000000;
	end
end

function data:uint16(str)
	if(type(str) == "number") then return str; end
	
	local b1, b2 = 
		str[1]:byte(), str[2]:byte();
	
	return b1 | (b2 << 8);
end

function data:int16(str)
	if(type(str) == "number") then return str; end
	
	local ret = self:uint32(str);
	if((ret & (1<<15)) ~= 0) then
		ret = (ret & ~(1<<15)) - 0x8000;
	end
end

function data:uint8(str)
	if(type(str) == "number") then return str; end
	
	local b1 =
		str[1]:byte();
	
	return b1
end

function data:int8(str)
	if(type(str) == "number") then return str; end
	
	local ret = self:uint8(str);
	if((ret & (1<<7)) ~= 0) then
		ret = (ret & ~(1<<7)) - 0x80;
	end
	return ret;
end

function data:reg2(str)
	local num = self:uint8(str);
	return num & 7, (num & 56) >> 3
end

function data:reg1(str)
	local num = self:uint8(str);
	return num & 7;
end

function data:str8(data)
	return string.char(data)
end

function data:str16(data)
	local string_char = string.char;
	return 
		string_char(data & 0xFF)..string_char((data & 0xFF00) >> 8);
end

function data:str32(data)
	local string_char = string.char;
	return 
		string_char(data & 0xFF)..string_char((data & 0xFF00) >> 8)..
			string_char((data & 0xFF0000) >> 16)..string_char((data & 0xFF000000) >> 24);
end


local inst = {};

function inst:mov8(which, dat)
	self.regs:mov8(which, self.data:uint8(dat));
end

function inst:mov16(which, dat)
	self.regs:mov16(which, self.data:uint16(dat));
end

function inst:mov32(which, dat)
	self.regs:mov32(which, self.data:uint32(dat));
end

function inst:get8(which)
	return self.regs:get8(which);
end

function inst:get16(which)
	return self.regs:get16(which);
end

function inst:get32(which)
	return self.regs:get32(which);
end

function inst:reg2(data)
	return self.data:reg2(data);
end

function inst:reg1(data)
	return self.data:reg1(data);
end

function inst:readmemory(addr, size)
	
	assert(math.type(addr) == "integer");
	assert(math.type(size) == "integer" and size > 0);
	local ret = "";
	local off = addr % MEMORY_SIZE;
	addr = addr // MEMORY_SIZE;
	for i = 1, size do
		if((i+off) % MEMORY_SIZE == 0) then addr = addr + 1; end
		i = i - 1;
		local mem = self.memory[addr];
		ret = ret..string.char(mem >> ((MEMORY_SIZE - 1)*8-((i+off) % MEMORY_SIZE)*8) & 0xFF);
	end
	return ret;
end

function inst:setmemory(addr, set)
	assert(math.type(addr) == "integer");
	assert(type(set) == "string");
	local ret = "";
	local off = addr % MEMORY_SIZE;
	addr = addr // MEMORY_SIZE;
	for i = 0, set:len() - 1 do
		if((i+1+off) % MEMORY_SIZE == 0) then addr = addr + 1; end
		local mem = self.memory[addr];
		local shift = ((MEMORY_SIZE-1)*8-((i+off) % MEMORY_SIZE)*8);
		self.memory[addr] = mem & ~(0xFF<<shift)
			| set[i + 1]:byte() << shift;
	end
end

function inst:str32(data)
	return self.data:str32(data);
end

function inst:str16(data)
	return self.data:str16(data);
end

function inst:str8(data)
	return self.data:str8(data);
end

function inst:getint(n)
	assert(n >= 0 and n < 1024);
	return self:readmemory(self.regs.idtr + 4*n, 4);
end

function inst:setint(n, addr)
	assert(n >= 0 and n < 1024);
	return self:setmemory(self.regs.idtr + 4*n, addr, 4);
end

function inst:int(n)
	self:seteip(self:getint(n));
end

function inst:uint8(data)
	return self.data:uint8(data);
end

function inst:int8(data)
	return self.data:int8(data);
end

function inst:uint16(data)
	return self.data:uint16(data);
end

function inst:int16(data)
	return self.data:int16(data);
end

function inst:uint32(data)
	return self.data:uint32(data);
end

function inst:int32(data)
	return self.data:int32(data);
end

function inst:flagset(which)
	return self.regs:flagset(which);
end

function inst:setflag(which, val)
	return self.regs:setflag(which, val);
end

function inst:seteip(which)
	assert(type(which) == "number");
	self.regs.eip = which & 0xFFFFFFFF;
end

function inst:cmp(result, bits)
	self:setflag(_cf, result > 0);
	self:setflag(_of, result > 0x7FFFFFFF or result < -0x7FFFFFFF);
	self:setflag(_zf, result == 0);
	
	local bits_set = 0;
	for i = 0, bits-1 do
		if((result & (1<<i)) ~= 0) then bits_set = bits_set + 1; end
	end
	
	self:setflag(_pf, (bits_set % 2) == 0);
	
	self:setflag(_sf, (result & (1<<(bits-1))) ~= 0);
	
	-- todo: set _af
end

function inst:bitcmp(result, bits)
	self:setflag(_cf, 0);
	self:setflag(_of, 0);
	
	self:setflag(_zf, result == 0);
	
	local bits_set = 0;
	for i = 0, bits-1 do
		if((result & (1<<i)) ~= 0) then bits_set = bits_set + 1; end
	end
	
	self:setflag(_pf, (bits_set % 2) == 0);
	
end

function inst:eip()
	return self.regs.eip;
end

function inst:push(data)
	self.regs:push(data);
end

function inst:pop()
	return self.regs:pop();
end

function inst:eax()
	return self:get32(eax);
end
function inst:ecx()
	return self:get32(ecx);
end
function inst:edx()
	return self:get32(edx);
end
function inst:ebx()
	return self:get32(ebx);
end
function inst:ebp()
	return self:get32(ebp);
end
function inst:edi()
	return self:get32(edi);
end
function inst:esi()
	return self:get32(esi);
end
function inst:esp()
	return self:get32(esp);
end

inst.opcodes = {};


function NewInstance(ram)
	-- 128 kb
	local _inst = { ram = ram or 128*1024, memory = {}, };
	
	for i = 0, (_inst.ram / MEMORY_SIZE) - 1 do
		_inst.memory[i] = 0;
	end
	
	local _regs = {stack = {}};
	_inst.regs = _regs;
	_regs.inst = _inst;
	
	for k,v in next, regs do
		_regs[k] = v;
	end
	
	_regs.data = {
		[eax] = 0,
		[ecx] = 0,
		[edx] = 0,
		[ebx] = 0,
		[esp] = 2*1024,
		[ebp] = 2*1024,
		[esi] = 0,
		[edi] = 0,
		[eflags] = 0,
	};
	_inst.data = data;
	
	for k,v in next, inst do
		_inst[k] = v;
	end
	
	return _inst;
end

local FUNCTION = 1;
local ARGSIZE  = 2;
local NAME     = 3;
local LEN      = 4;
local EXT      = 5;

function AddOpcode(name, opcode, argsize, func, ext)
	local len = opcode:len();
	local current_table = inst.opcodes;
	for i = 1, len - 1 do
		local next_table = current_table[opcode[i]];
		if(not next_table) then
			next_table = {};
			current_table[opcode[i]] = next_table;
		end
		current_table = next_table;
	end
	
	current_table[opcode[-1]] = current_table[opcode[-1]] or {
		[FUNCTION] = func, 
		[ARGSIZE]  = argsize,
		[NAME]     = name,
		[LEN]      = len,
		[EXT]      = ext ~= nil,
		extensions = {},
	};
	if(ext) then
		current_table[opcode[-1]].extensions[ext] = {
			[FUNCTION] = func,
			[ARGSIZE]  = argsize,
			[NAME]     = name,
			[LEN]      = len,
			[EXT]      = ext,
		};
	end
end

local function RunCode(inst, bytes, offset)
	local start = offset;
	local current_table = inst.opcodes;
	while(type(current_table[FUNCTION]) ~= "function") do
		if(type(current_table) == "nil") then error("invalid code"); end
		current_table = current_table[bytes[offset]];
		offset = offset + 1;
	end
	
	if(current_table[EXT]) then
		current_table = current_table.extensions[bytes[offset]:byte() >> 3 & 7];
	end
	
	inst:seteip(offset + current_table[ARGSIZE]);
	
	local func = current_table[FUNCTION];
	local args = bytes:sub(offset, offset + current_table[ARGSIZE] - 1);
	print(current_table[NAME]);
	func(inst, bytes:sub(start, start + offset - 1), args);
end

if(dofile) then
	dofile"opcodes.lua";
else
	require"x86/opcodes";
end

function inst:run(bytes)
	self:seteip(1);
	local code = bytes;
	local code_len = code:len();
	
	while(self:eip() > 0 and self:eip() <= code_len) do
		RunCode(self, code, self:eip());
	end
	return self;
end

x86 = NewInstance(); 
x86:run"\xE8\x02\x00\x00\x00\xEB\x01\xC3"

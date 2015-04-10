

--[[-------
    add
-------]]--

AddOpcode("add", "\x00", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov8(which, inst:get8(which) + inst:get8(with));
	
	inst:cmp(inst:get8(whwere), 8);
end);

AddOpcode("add", "\x01", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov32(which, inst:get32(which) + inst:get32(with));
	
	inst:cmp(inst:get32(which), 32);
end);

AddOpcode("add", "\x02", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov8(which, inst:get8(which) + inst:get8(with));
	
	inst:cmp(inst:get8(which), 8);
end);

AddOpcode("add", "\x03", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov32(which, inst:get32(which) + inst:get32(with));
	
	inst:cmp(inst:get32(which), 32);
end);

AddOpcode("add", "\x04", 1, function(inst, op, args)
	inst:mov8(al, inst:uint8(args));
	inst:cmp(inst:get8(al), 8);
end);

AddOpcode("add", "\x05", 4, function(inst, op, args)
	inst:mov8(eax, inst:uint32(args));
	inst:cmp(inst:get32(eax), 32);
end);

AddOpcode("add", "\x82", 2, function(inst, op, args)
	local which = inst:reg1(args[1]);
	inst:mov8(which, inst:get8(which) + inst:uint8(args[2]));
	inst:cmp(inst:get8(which), 8);
end, 0);

AddOpcode("add", "\x83", 2, function(inst, op, args)
	local which = inst:reg1(args[1]);
	inst:mov32(which, inst:get32(which) + inst:uint8(args[2]));
	inst:cmp(inst:get32(which), 32);
end, 0);

--[[------
    or
------]]--

AddOpcode("or", "\x08", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov8(which, inst:get8(which) | inst:get8(with));
end);

AddOpcode("or", "\x09", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov32(which, inst:get32(which) | inst:get32(with));
end);

AddOpcode("or", "\x0A", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov8(which, inst:get8(which) | inst:get8(with));
end);

AddOpcode("or", "\x0B", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov32(which, inst:get32(which) | inst:get32(with));
end);

AddOpcode("or", "\x0C", 1, function(inst, op, args)
	inst:mov8(al, inst:get8(al) | inst:uint8(args));
end);

AddOpcode("or", "\x0D", 4, function(inst, op, args)
	inst:mov32(eax, inst:get32(eax) | inst:uint32(args));
end);

AddOpcode("or", "\x82", 2, function(inst, op, args)
	local which = inst:reg1(args[1]);
	inst:mov8(which, inst:get8(which) | inst:uint8(args[2]));
end, 1);

AddOpcode("or", "\x83", 2, function(inst, op, args)
	local which = inst:reg1(args[1]);
	inst:mov32(which, inst:get32(which) | inst:uint8(args[2]));
end, 1);



--[[-------
    and
-------]]--

AddOpcode("and", "\x20", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov8(which, inst:get8(which) & inst:get8(with));
	
	inst:bitcmp(inst:get8(which), 8);
end);

AddOpcode("and", "\x21", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov32(which, inst:get32(which) & inst:get32(with));
	
	inst:bitcmp(inst:get32(which), 32);
end);

AddOpcode("and", "\x22", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov8(which, inst:get8(which) & inst:get8(with));
	
	inst:bitcmp(inst:get8(which), 8);
end);

AddOpcode("and", "\x23", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov32(which, inst:get32(which) & inst:get32(with));
	
	inst:bitcmp(inst:get32(which), 32);
end);

AddOpcode("and", "\x24", 1, function(inst, op, args)
	inst:mov8(al, inst:get8(al) & inst:uint8(args));
	
	inst:bitcmp(inst:get8(which), 8);
end);

AddOpcode("and", "\x25", 4, function(inst, op, args)
	inst:mov32(eax, inst:get32(eax) & inst:uint32(args));
	
	inst:bitcmp(inst:get32(which), 32);
end);

AddOpcode("and", "\x82", 2, function(inst, op, args)
	local which = inst:reg1(args[1]);
	inst:mov8(which, inst:get8(which) & inst:uint8(args[2]));
	
	inst:bitcmp(inst:get8(which), 8);
end, 4);

AddOpcode("and", "\x83", 2, function(inst, op, args)
	local which = inst:reg1(args[1]);
	inst:mov32(which, inst:get32(which) & inst:uint8(args[2]));
	
	inst:bitcmp(inst:get32(which), 32);
end, 4);


--[[-------
    sub
-------]]--

AddOpcode("sub", "\x28", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov8(which, inst:get8(which) - inst:get8(with));
	
	inst:cmp(inst:get8(which), 8);
end);

AddOpcode("sub", "\x29", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov32(which, inst:get32(which) - inst:get32(with));
	
	inst:cmp(inst:get32(which), 32);
end);

AddOpcode("sub", "\x2A", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov8(which, inst:get8(which) - inst:get8(with));
	
	inst:cmp(inst:get8(which), 8);
end);

AddOpcode("sub", "\x2B", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov32(which, inst:get32(which) - inst:get32(with));
	
	inst:cmp(inst:get32(which), 32);
end);

AddOpcode("sub", "\x2C", 1, function(inst, op, args)
	inst:mov8(al, inst:get8(al) - inst:uint8(args));
	
	inst:cmp(inst:get8(al), 8);
end);

AddOpcode("sub", "\x2D", 4, function(inst, op, args)
	inst:mov32(eax, inst:get32(eax) - inst:uint32(args));
	
	inst:cmp(inst:get32(eax), 32);
end);

AddOpcode("sub", "\x82", 2, function(inst, op, args)
	local which = inst:reg1(args[1]);
	
	inst:mov8(which, inst:get8(which) - inst:uint8(args[2]));
	
	inst:cmp(inst:get8(which), 8);
end, 5);

AddOpcode("sub", "\x83", 2, function(inst, op, args)
	local which = inst:reg1(args[1]);
	
	inst:mov32(which, inst:get32(which) - inst:uint8(args[2]));
	
	inst:cmp(inst:get32(which), 32);
end, 5);

--[[-------
    xor
-------]]--

AddOpcode("xor", "\x30", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov8(which, inst:get8(which) ~ inst:get8(with));
	
	inst:bitcmp(inst:get8(which), 8);
end);

AddOpcode("xor", "\x31", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov32(which, inst:get32(which) ~ inst:get32(with));
	
	inst:bitcmp(inst:get32(which), 32);
end);

AddOpcode("xor", "\x32", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov8(which, inst:get8(which) ~ inst:get8(with));
	
	inst:bitcmp(inst:get8(which), 8);
end);

AddOpcode("xor", "\x33", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov32(which, inst:get32(which) ~ inst:get32(with));
	
	inst:bitcmp(inst:get32(which), 32);
end);

AddOpcode("xor", "\x34", 1, function(inst, op, args)
	inst:mov8(al, inst:get8(al) ~ inst:uint8(args));
	
	inst:bitcmp(inst:get8(al), 8);
end);

AddOpcode("xor", "\x35", 4, function(inst, op, args)
	inst:mov32(eax, inst:get32(eax) ~ inst:uint32(args));
	
	inst:bitcmp(inst:get32(eax), 32);
end);

AddOpcode("xor", "\x82", 2, function(inst, op, args)
	local which = inst:reg1(args[1]);
	inst:mov8(which, inst:get8(which) ~ inst:uint8(args[2]));
	
	inst:bitcmp(inst:get8(which), 8);
end, 6);

AddOpcode("xor", "\x83", 2, function(inst, op, args)
	local which = inst:reg1(args[1]);
	inst:mov32(which, inst:get32(which) ~ inst:uint8(args[2]));
	
	inst:bitcmp(inst:get32(which), 32);
end, 6);

--[[-------
    cmp
-------]]--

AddOpcode("cmp", "\x38", 1, function(inst, op, args)
	local r1, r2 = inst:reg2(args[1]);
	local v1, v2 = 
		inst:get8(r1), inst:get8(r2);
	local result = v1 - v2;
	inst:cmp(result, 8);
end);

AddOpcode("cmp", "\x39", 1, function(inst, op, args)
	local r1, r2 = inst:reg2(args[1]);
	local v1, v2 = 
		inst:get32(r1), inst:get32(r2);
	local result = v1 - v2;
	inst:cmp(result, 32);
end);

AddOpcode("cmp", "\x3A", 1, function(inst, op, args)
	local r1, r2 = inst:reg2(args[1]);
	local v1, v2 = 
		inst:get8(r1), inst:get8(r2);
	local result = v1 - v2;
	inst:cmp(result, 8);
end);

AddOpcode("cmp", "\x3B", 1, function(inst, op, args)
	local r1, r2 = inst:reg2(args[1]);
	local v1, v2 = 
		inst:get32(r1), inst:get32(r2);
	local result = v1 - v2;
	inst:cmp(result, 32);
end);

AddOpcode("cmp", "\x3C", 2, function(inst, op, args)
	local v1, v2 = 
		inst:get8(al), inst:uint8(args[2]);
	local result = v1 - v2;
	inst:cmp(result, 8);
end);

AddOpcode("cmp", "\x3D", 4, function(inst, op, args)
	local v1, v2 = 
		inst:get32(eax), inst:uint32(args);
	local result = v1 - v2;
	inst:cmp(result, 32);
end);

AddOpcode("cmp", "\x83", 2, function(inst, op, args)
	local r1 = inst:reg1(args[1]);
	local v1, v2 = 
		inst:get32(r1), inst:uint8(args[2]);
	local result = v1 - v2;
	inst:cmp(result, 32);
end, 7);



AddOpcode("jmp", "\xE9", 4, function(inst, op, args)
	inst:seteip(inst:int32(args) + inst:eip());
end);

AddOpcode("jmp", "\xEB", 1, function(inst, op, args)
	inst:seteip(inst:int8(args[1]) + inst:eip());
end);

AddOpcode("jo", "\x70", 1, function(inst, op, args)
	if(inst:flagset(_of)) then
		inst:seteip(inst:int8(args[1]) + inst:eip());
	end
end);
AddOpcode("jno", "\x71", 1, function(inst, op, args)
	if(not inst:flagset(_of)) then
		inst:seteip(inst:int8(args[1]) + inst:eip());
	end
end);
AddOpcode("jc", "\x72", 1, function(inst, op, args)
	if(inst:flagset(_cf)) then
		inst:seteip(inst:int8(args[1]) + inst:eip());
	end
end);
AddOpcode("jnc", "\x73", 1, function(inst, op, args)
	if(not inst:flagset(_cf)) then
		inst:seteip(inst:int8(args[1]) + inst:eip());
	end
end);
AddOpcode("jz", "\x74", 1, function(inst, op, args)
	if(inst:flagset(_zf)) then
		inst:seteip(inst:int8(args[1]) + inst:eip());
	end
end);
AddOpcode("jnz", "\x75", 1, function(inst, op, args)
	if(not inst:flagset(_zf)) then
		inst:seteip(inst:int8(args[1]) + inst:eip());
	end
end);
AddOpcode("jna", "\x76", 1, function(inst, op, args)
	if(not inst:flagset(_af)) then
		inst:seteip(inst:int8(args[1]) + inst:eip());
	end
end);
AddOpcode("ja", "\x77", 1, function(inst, op, args)
	if(inst:flagset(_af)) then
		inst:seteip(inst:int8(args[1]) + inst:eip());
	end
end);
AddOpcode("js", "\x78", 1, function(inst, op, args)
	if(inst:flagset(_sf)) then
		inst:seteip(inst:int8(args[1]) + inst:eip());
	end
end);
AddOpcode("jna", "\x79", 1, function(inst, op, args)
	if(not inst:flagset(_sf)) then
		inst:seteip(inst:int8(args[1]) + inst:eip());
	end
end);
AddOpcode("jp", "\x7A", 1, function(inst, op, args)
	if(inst:flagset(_pf)) then
		inst:seteip(inst:int8(args[1]) + inst:eip());
	end
end);
AddOpcode("jnp", "\x7B", 1, function(inst, op, args)
	if(not inst:flagset(_pf)) then
		inst:seteip(inst:int8(args[1]) + inst:eip());
	end
end);
AddOpcode("jp", "\x7A", 1, function(inst, op, args)
	if(inst:flagset(_pf)) then
		inst:seteip(inst:int8(args[1]) + inst:eip());
	end
end);
AddOpcode("jl", "\x7C", 1, function(inst, op, args)
	if(inst:flagset(_sf) ~= inst:flagset(_of)) then
		inst:seteip(inst:int8(args[1]) + inst:eip());
	end
end);
AddOpcode("jnl", "\x7D", 1, function(inst, op, args)
	if(inst:flagset(_sf) == inst:flagset(_of)) then
		inst:seteip(inst:int8(args[1]) + inst:eip());
	end
end);
AddOpcode("jle", "\x7E", 1, function(inst, op, args)
	if(inst:flagset(_of) or inst:flagset(_sf) ~= inst:flagset(_of)) then
		inst:seteip(inst:int8(args[1]) + inst:eip());
	end
end);
AddOpcode("jnle", "\x7F", 1, function(inst, op, args)
	if(not inst:flagset(_of) and inst:flagset(_sf) == inst:flagset(_of)) then
		inst:seteip(inst:int8(args[1]) + inst:eip());
	end
end);

--[[-------
    8op
-------]]--

AddOpcode("add", "\x80", 2, function(inst, op, args)
	local which = inst:reg1(args[1]);
	inst:set8(which, inst:get8(which) + inst:uint8(args[2]));
	inst:cmp(inst:get8(which), 8);
end, 0);

AddOpcode("or", "\x80", 2, function(inst, op, args)
	local which = inst:reg1(args[1]);
	inst:set8(which, inst:get8(which) | inst:uint8(args[2]));
end, 1);

AddOpcode("and", "\x80", 2, function(inst, op, args)
	local which = inst:reg1(args[1]);
	inst:set8(which, inst:get8(which) & inst:uint8(args[2]));
end, 4);

AddOpcode("sub", "\x80", 2, function(inst, op, args)
	local which = inst:reg1(args[1]);
	
	inst:set8(which, inst:get8(which) - inst:uint8(args[2]));
	
	inst:cmp(inst:get8(which), 8);
end, 5);

AddOpcode("xor", "\x80", 2, function(inst, op, args)
	local which = inst:reg1(args[1]);
	
	inst:set8(which, inst:get8(which) ~ inst:uint8(args[2]));
	
	inst:bitcmp(inst:get8(which), 8);
end, 6);

AddOpcode("cmp", "\x80", 2, function(inst, op, args)
	local which = inst:reg1(args[1]);
	local result = inst:get8(which) - inst:uint8(args[2]);
	inst:cmp(result, 8);
end, 7);


--[[--------
    32op
--------]]--

AddOpcode("add", "\x81", 5, function(inst, op, args)
	local which = inst:reg1(args[1]);
	inst:set8(which, inst:get32(which) + inst:uint32(args[2]));
	inst:cmp(inst:get8(which), 8);
end, 0);

AddOpcode("or", "\x81", 5, function(inst, op, args)
	local which = inst:reg1(args[1]);
	inst:set8(which, inst:get32(which) | inst:uint32(args[2]));
end, 1);

AddOpcode("and", "\x81", 5, function(inst, op, args)
	local which = inst:reg1(args[1]);
	inst:set8(which, inst:get32(which) & inst:uint32(args[2]));
end, 4);

AddOpcode("sub", "\x81", 5, function(inst, op, args)
	local which = inst:reg1(args[1]);
	
	inst:set8(which, inst:get32(which) - inst:uint32(args[2]));
	
	inst:cmp(inst:get8(which), 8);
end, 5);

AddOpcode("xor", "\x81", 5, function(inst, op, args)
	local which = inst:reg1(args[1]);
	
	inst:set8(which, inst:get32(which) ~ inst:uint32(args[2]));
	
	inst:cmp(inst:get8(which), 8);
end, 6);

AddOpcode("cmp", "\x81", 5, function(inst, op, args)
	local which = inst:reg1(args[1]);
	local result = inst:get32(which) - inst:uint32(args[2]);
	inst:cmp(result, 32);
end, 7);

--[[-------
    mov
-------]]--

AddOpcode("mov", "\x88", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov8(which, inst:get8(with));
end);

AddOpcode("mov", "\x89", 1, function(inst, op, args)
	local which, with = inst:reg2(args);
	
	inst:mov32(which, inst:get32(with));
end);


for i = 0, 7 do
	AddOpcode("inc", string.char(0x40 + i), 1, function(inst, op, args)
		inst:mov32(i, inst:get32(i) + 1);
	end);
end

for i = 0, 7 do
	AddOpcode("dec", string.char(0x48 + i), 1, function(inst, op, args)
		inst:mov32(i, inst:get32(i) - 1);
	end);
end

for i = 0, 7 do
	AddOpcode("push", string.char(0x50 + i), 0, function(inst, op, args)
		inst:push(inst:get32(i));
	end);
end

for i = 0, 7 do
	AddOpcode("pop", string.char(0x58 + i), 0, function(inst, op, args)
		inst:mov32(i, inst:pop() & 0xFFFFFFFF);
	end);
end

AddOpcode("pushad", "\x60", 0, function(inst, op, args)
	for i = 0, 7 do
		inst:push(inst:get32(i));
	end
end);

AddOpcode("popad", "\x61", 0, function(inst, op, args)
	for i = 7, 0, -1 do
		inst:mov32(i, inst:pop());
	end
end);

AddOpcode("push", "\x68", 4, function(inst, op, args)
	inst:push(inst:uint32(args));
end);

AddOpcode("imul", "\x69", 5, function(inst, op, args)
	local which, with = inst:reg2(args[1]);
	inst:mov32(which, inst:get32(with) * inst:int32(args:sub(1)));
end);

AddOpcode("imul", "\x6B", 5, function(inst, op, args)
	local which, with = inst:reg2(args[1]);
	inst:mov32(which, inst:get32(with) * inst:int8(args[2]));
end);

AddOpcode("int3", "\xCC", 0, function(inst, op, args)
	inst:int(3);
end);

AddOpcode("int", "\xCD", 0, function(inst, op, args)
	inst:int(inst:int8(args[1]));
end);

for i = 0, 7 do
	AddOpcode("mov", string.char(0xB0 + i), 1, function(inst, op, args)
		inst:mov8(i, inst.data:uint8(args));
	end);
end

for i = 0, 7 do
	AddOpcode("mov", string.char(0xB8 + i), 4, function(inst, op, args)
		inst:mov32(i, inst.data:uint32(args));
	end);
end

AddOpcode("mov", "\xC6", 2, function(inst, op, args)
	local which = inst:reg1(args[1]);
	
	inst:setmemory(inst:get32(which), args[2]);
end, 0);

AddOpcode("mov", "\x8A", 1, function(inst, op, args)
	local which, from = 
		inst:reg2(args[1]);
	
	inst:mov8(which, inst:readmemory(inst:get32(from), 1));
end);


AddOpcode("mov", "\xA0", 4, function(inst, op, args)
	inst:mov8(al, inst:readmemory(inst:uint32(args), 1));
end);

AddOpcode("mov", "\xA1", 4, function(inst, op, args)
	inst:mov32(eax, inst:uint32(args));
end);

AddOpcode("mov", "\xA2", 4, function(inst, op, args)
	inst:setmemory(inst:uint32(args), inst:str8(inst:get8(al)));
end);

AddOpcode("mov", "\xA3", 4, function(inst, op, args)
	inst:setmemory(inst:uint32(args), inst:str32(inst:get32(al)));
end);


AddOpcode("retn", "\xC2", 2, function(inst, op, args)
	inst:seteip(inst:pop());
	for i = 1, inst:uint16(args), 4 do
		inst:pop();
	end
end);

AddOpcode("retn", "\xC3", 0, function(inst, op, args)
	inst:seteip(inst:pop());
end);

AddOpcode("call", "\xE8", 4, function(inst, op, args)
	inst:push(inst:eip() + 5);
	inst:seteip(inst:uint32(args) + inst:eip() + 5);
end);

AddOpcode("call", "\xFF", 1, function(inst, op, args)
	local which = inst:reg1(args[1]);
	inst:push(inst:eip() + 2);
	print(which);
	inst:seteip(inst:get32(which) + 1);
end, 2);



AddOpcode("sidt", "\x0F\x01", 1, function(inst, op, args)
	-- this is WRONG!!
	
	local where = inst:reg1(args);
	local addr = inst:get32(where);
	inst.regs.idtr = addr;
end, 1);


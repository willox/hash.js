"use strict";
const LuaMessage = class LuaMessage
{

    get regex()
    {
        return /^([^])([^]+?);([^]*)$/;
    }

    constructor(raw)
    {
        let parsed = this.regex.exec(raw);

        this.isLua = parsed[1] == "1";
        this.crc = parsed[2];
        this.data = parsed[3];
    }

    toString()
    {
        return LuaMessage.name;
    }

    process(lua)
    {

        lua.emit("LuaPacket", this);

    }

}

module.exports = LuaMessage;

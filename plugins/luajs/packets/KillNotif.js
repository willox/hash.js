"use strict";
const KillNotif = class KillNotif
{

    get regex()
    {
        return /^$/;
    }

    constructor(raw)
    {
        let parsed = this.regex.exec(raw);
    }

    toString()
    {
        return KillNotif.name;
    }

    process(lua)
    {
        if (lua.pendingKill)
            lua.restart();
        lua.pendingKill = false;
    }

}

module.exports = KillNotif;

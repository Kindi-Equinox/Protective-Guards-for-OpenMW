local self = require("openmw.self")
local ai = require("openmw.interfaces").AI
local types = require("openmw.types")
local time = require("openmw_aux.time")
local aux_util = require("openmw_aux.util")
local nearby = require("openmw.nearby")
local core = require("openmw.core")
local util = require("openmw.util")
local I = require("openmw.interfaces")

return {
    engineHandlers = {
    },
    eventHandlers = {
        ProtectiveGuards_alertGuard_eqnx = function(attacker)
            --causes this NPC to attack the attacker
            if not types.Actor.canMove(self) or not attacker:isValid() then
                return
            end
            ai.startPackage({type = "Combat", target = attacker})
        end,
    },
}

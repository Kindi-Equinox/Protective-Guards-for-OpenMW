local self = require("openmw.self")
local nearby = require("openmw.nearby")
local time = require("openmw_aux.time")
local ai = require("openmw.interfaces").AI
local core = require("openmw.core")
local types = require("openmw.types")
local aux_util = require("openmw_aux.util")
local async = require("openmw.async")

local function scanIfAttackingActor()
    local myCombatTarget = ai.getActiveTarget("Combat")
    if myCombatTarget and myCombatTarget.type == types.Player then
        myCombatTarget:sendEvent("ProtectiveGuards_thisActorIsAttackedBy", {
            actor = self
        })
    end
    async:newUnsavableSimulationTimer(math.random() + 0.5, scanIfAttackingActor)
end

scanIfAttackingActor()

local I = require("openmw.interfaces")
local ui = require("openmw.ui")
local util = require("openmw.util")
local types = require("openmw.types")
local nearby = require("openmw.nearby")
local aux_util = require("openmw_aux.util")
local core = require("openmw.core")
local time = require("openmw_aux.time")
local storage = require("openmw.storage")
local self = require("openmw.self")
local bL = require("scripts/protective_guards_for_omw/blacklistedareas")
local section = storage.playerSection("Settings_PGFOMW_Options_Key_KINDI")

local function messageBox(_, ...)
    ui.showMessage(tostring(_):format(...))
end

local pursuit_for_omw = false

local function searchGuardsAdjacentCells(attacker, classes)
    local nearbyDoors =
    aux_util.mapFilter(
        nearby.doors,
        function(door)
            return types.Door.isTeleport(door) and (door.position - self.position):length() < 2000
        end
    )

    for _, door in pairs(nearbyDoors) do
        core.sendGlobalEvent("ProtectiveGuards_searchGuards_eqnx", { door, attacker, classes })
    end
end

return {
    engineHandlers = {},
    eventHandlers = {
        ProtectiveGuards_thisActorIsAttackedBy = function(e)
            if not section:get("Mod Status") then
                return
            end
            if bL[self.cell.name] then
                return
            end

            -- because criminals don't deserve help
            -- replace it later with a proper function instead of this 'hack'
            if types.Actor.inventory(self):countOf("PG_TrigCrime") > 0 then
                return
            end

            -- because guards hates werewolf in morrowind (only available v0.49)
            if types.NPC.isWerewolf and types.NPC.isWerewolf(self) then
                return
            end

            local classes = section:get("Search Guard of Class"):lower()

            local guards =
            aux_util.mapFilter(
                nearby.actors,
                function(actor)
                    return actor ~= self.object and actor.type == types.NPC and
                        classes:find(types.NPC.record(actor).class:lower())
                end
            )

            local distCheckInterior = section:get("Search Guard Distance Interiors")
            local distCheckExterior = section:get("Search Guard Distance Exteriors")

            for _, actor in pairs(guards) do
                if (actor.position - self.position):length() <
                    (self.cell.isExterior and distCheckExterior or distCheckInterior)
                then
                    actor:sendEvent("ProtectiveGuards_alertGuard_eqnx", e.actor)
                    if storage.playerSection("Settings_PGFOMW_ZDebug_Key_KINDI"):get("Debug") then
                        messageBox(
                            "%s of %s class from %s attacks %s",
                            types.NPC.record(actor).name,
                            types.NPC.record(actor).class,
                            actor.cell.name,
                            types.NPC.record(e.actor).name
                        )
                    end
                end
            end

            if section:get("Search Guard In Nearby Adjacent Cells") and pursuit_for_omw then
                searchGuardsAdjacentCells(e.actor, classes)
            end
        end,
        Pursuit_IsInstalled_eqnx = function(e)
            pursuit_for_omw = e.isInstalled
            if pursuit_for_omw then
                print("Pursuit and Protective Guards interaction established")
                -- ui.showMessage("Pursuit and Protective Guards interaction established")
            end
        end
    }
}

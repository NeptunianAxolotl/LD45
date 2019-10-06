local components = {}

components.booster = require("components/booster")
components.tractor_wheel = require("components/tractor_wheel")
components.laser_prism = require("components/laser_prism")
components.player = require("components/player")
components.girder = require("components/girder")
components.asteroid1 = require("components/asteroid 1")
components.asteroid2 = require("components/asteroid 2")
components.ship_debris1 = require("components/ship debris 1")
components.push_missile = require("components/push_missile")
components.push_missile_debris = require("components/push_missile debris")

components.command_module = require("components/command_module")
components.gun = require("components/gun")
components.ion_engine = require("components/ion_engine")
components.laser_battery = require("components/laser_battery")
components.navigation = require("components/navigation")
components.displacer = require("components/displacer")
components.debris_burner = require("components/debris_burner")

-- Post processing
local compList = {}
for name, def in pairs(components) do
    def.name = name
    def.maxHealth = def.maxHealth or 420
    def.walkRadius = def.walkRadius or 34
    if name ~= "player" and not def.isGirder then
        compList[#compList + 1] = def
    end
end

return {components, compList}
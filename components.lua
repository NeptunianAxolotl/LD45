local components = {}

components.booster = require("components/booster")
components.tractor_wheel = require("components/tractor_wheel")
components.laser_prism = require("components/laser_prism")
components.player = require("components/player")
components.girder1 = require("components/girder 1")
components.asteroid1 = require("components/asteroid 1")
components.ship_debris1 = require("components/ship debris 1")
components.command_module = require("components/command_module")

-- Post processing
local compList = {}
for name, def in pairs(components) do
    def.name = name
    compList[#compList + 1] = def
end

return {components, compList}
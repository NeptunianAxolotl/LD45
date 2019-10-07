local components = {}

components.booster = require("components/booster")
components.tractor_wheel = require("components/tractor_wheel")
components.laser_prism = require("components/laser_prism")
components.player = require("components/player")
components.girder = require("components/girder")
components.asteroid1 = require("components/asteroid_1")
components.asteroid2 = require("components/asteroid_2")
components.asteroid3 = require("components/asteroid_3")
components.asteroidsmall1 = require("components/asteroid_small_1")
components.asteroidsmall2 = require("components/asteroid_small_2")
components.asteroidsmall3 = require("components/asteroid_small_3")
components.ship_debris1 = require("components/ship_debris_1")
components.ship_debris2 = require("components/ship_debris_2")
components.push_missile = require("components/push_missile")
components.push_missile_debris = require("components/push_missile_debris")
components.red_rocket = require("components/red_rocket")
components.gyro = require("components/gyro")

components.command_module = require("components/command_module")
components.gun = require("components/gun")
components.ion_engine = require("components/ion_engine")
components.laser_battery = require("components/laser_battery")
components.navigation = require("components/navigation")
components.displacer = require("components/displacer")
components.debris_burner = require("components/debris_burner")
components.warp_drive = require("components/warp_drive")
components.console = require("components/console")

-- Post processing
local compList = {}
for name, def in pairs(components) do
    def.name = name
    if not def.maxHealth then
        print("Missing maxHealth for", def.name)
    end
    if not def.walkRadius then
        print("Missing walkRadius for", def.name)
    end

    if name ~= "player" and name ~= "push_missile_debris" and name ~= "command_module" and not def.isGirder then
        compList[#compList + 1] = def
    end
end

return {components, compList}
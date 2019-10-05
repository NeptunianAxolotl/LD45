local components = {}

components.booster = require("components/booster")
components.tractor_wheel = require("components/tractor_wheel")
components.player = require("components/player")

-- Post processing
local compList = {}
for name, def in pairs(components) do
    def.defName = name
    compList[#compList + 1] = def
end

return {components, compList}
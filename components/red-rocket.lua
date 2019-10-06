
local FORCE = 1500

local conf = {
    imageOff = "images/red-rocket-off.png",
    imageOn = "images/red-rocket-on.png",
    imageOrigin = {670, 500},
    imageScale = {0.6, 0.6},
    activationOrigin = {-20, 0},
    shapeCoords = {26,0, 15,16, 15,-16, -14,-26, -26,-14, -26,14, -14,26},
    density = 8,
    text =
    {
        pos = {5.5, 5},
        rotation = math.pi/2,
        scale = {1.5, 1.5},
        color = {0.8,0.1,0.1,1},
    },
    holdActivate = true,
    onFunction = function (self, body, activeX, activeY, activeAngle)
        activeAngle = activeAngle - math.pi*0.5
        local fx, fy = FORCE*math.cos(activeAngle), FORCE*math.sin(activeAngle)
        body:applyForce(fx, fy, activeX, activeY)
    end,
}

return conf
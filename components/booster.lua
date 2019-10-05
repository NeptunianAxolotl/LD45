
local FORCE = 1200

local conf = {
    imageOff = "images/booster.png",
    imageOn = "images/booster on.png",
    imageOrigin = {670, 500},
    imageScale = {0.1, 0.1},
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
        local fx, fy = FORCE*math.cos(activeAngle), FORCE*math.sin(activeAngle)
        body:applyForce(fx, fy, activeX, activeY)
    end,
}

return conf

local FORCE = 180

local conf = {
    imageOff = "images/Girder 1.png",
    imageOn = "images/Girder 1.png",
    imageOrigin = {670, 500},
    imageScale = {0.04, 0.04},
    activationOrigin = {0, 0},
    shapeCoords = {25,0, 10,10, 10,-18, -38,-15, -38,15},
    mass = 20,
    name = "player",
    onFunction = function (self, body, activeX, activeY, activeAngle)
        local fx, fy = FORCE*math.cos(activeAngle), FORCE*math.sin(activeAngle)
        body:applyForce(fx, fy, activeX, activeY)
    end,
}

return conf
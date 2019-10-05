
local FORCE = 180

local conf = {
    imageOff = "images/laser_prism.png",
    imageOn = "images/laser_prism.png",
    imageOrigin = {32, 22},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    circleShapeRadius = 32,
    mass = 20,
    name = "laser_prism",
    onFunction = function (self, body, activeX, activeY, activeAngle)
        local fx, fy = FORCE*math.cos(activeAngle), FORCE*math.sin(activeAngle)
        body:applyForce(fx, fy, activeX, activeY)
    end,
}

return conf
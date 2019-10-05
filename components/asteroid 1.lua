
local FORCE = 180

local conf = {
    imageOff = "images/asteroid 1.png",
    imageOn = "images/asteroid 1.png",
    imageOrigin = {500, 500},
    imageScale = {0.1, 0.1},
    activationOrigin = {0, 0},
    circleShapeRadius = 25,
    mass = 20,
    name = "tractor_wheel",
	-- angular velocity here; tractor wheel is always rotating in game 
    onFunction = function (self, body, activeX, activeY, activeAngle)
        local fx, fy = FORCE*math.cos(activeAngle), FORCE*math.sin(activeAngle)
        body:applyForce(fx, fy, activeX, activeY)
    end,
}

return conf
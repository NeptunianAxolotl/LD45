
local FORCE = 180

local conf = {
    imageOff = "images/tractor_wheel.png",
    imageOn = "images/tractor_wheel.png",
    imageOrigin = {32, 32},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    shapeCoords = {20, 20, 20, -20, -20, -20, -20, 20},
    mass = 20,
    name = "tractor_wheel",
	-- angular velocity here; tractor wheel is always rotating in game 
    onFunction = function (self, body, activeX, activeY, activeAngle)
        local fx, fy = FORCE*math.cos(activeAngle), FORCE*math.sin(activeAngle)
        body:applyForce(fx, fy, activeX, activeY)
    end,
}

return conf
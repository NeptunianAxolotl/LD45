
local FORCE = 4200

local conf = {
    imageOff = "images/push_missile/push_missile_unused.png",
	imageBetween = "images/push_missile/push_missile_launch.png",
    imageOn = "images/push_missile/push_missile_firing.png",
    imageOrigin = {30, 95},
    imageScale = {0.5, 0.5},
    activationOrigin = {0, 40},
    shapeCoords = {15,-35, 7,-44, -7,-44, -15,-35, -15,21, -16,26, 16,26, 15,21},
    density = 1,
    text =
    {
        pos = {5, 0},
        rotation = math.pi/2,
        scale = {1,1},
        color = {0.8,0.1,0.1,1},
    },
    holdActivate = true,
    onFunction = function (self, body, activeX, activeY, activeAngle)
        local fx, fy = -FORCE*math.sin(activeAngle), FORCE*math.cos(activeAngle)
        body:applyForce(fx, fy, activeX, activeY)
    end,
}

return conf
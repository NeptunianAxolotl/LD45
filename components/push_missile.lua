
local FORCE = 20000

local conf = {
    imageOff = "images/push_missile/push_missile_unused.png",
	imageBetween = "images/push_missile/push_missile_launch.png",
    imageOn = "images/push_missile/push_missile_firing.png",
    imageOrigin = {30, 95},
    imageScale = {0.5, 0.5},
    activationOrigin = {0, 26},
    shapeCoords = {15,-35, 7,-44, -7,-44, -15,-35, -15,21, -16,26, 16,26, 15,21},
    walkRadius = 55,
    maxHealth = 220,
    humanName = "a solid fuel booster",
    density = 10,
    text =
    {
        pos = {5, 0},
        rotation = math.pi/2,
        scale = {1,1},
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
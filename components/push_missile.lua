
local FORCE = 180

local conf = {
    imageOff = "images/push_missile/push_missile_unused.png",
	imageBetween = "images/push_missile/push_missile_launch.png"
    imageOn = "images/push_missile/push_missile_firing.png",
    imageOrigin = {30, 89},
    imageScale = {1, 1},
    activationOrigin = {-20, 0},
    shapeCoords = {30,59, 22,80, 0,89, -22,80, -30,59, -30,-33, -25,-47, -11,-55, 11,-55, 25,-47, 30,-33},
    density = 1,
    name = "push_missile",
    text =
    {
        pos = {5, 0},
        rotation = math.pi/2,
        scale = {1,1},
        color = {0.8,0.1,0.1,1},
    },
    onFunction = function (self, body, activeX, activeY, activeAngle)
        local fx, fy = FORCE*math.cos(activeAngle), FORCE*math.sin(activeAngle)
        body:applyForce(fx, fy, activeX, activeY)
    end,
}

return conf
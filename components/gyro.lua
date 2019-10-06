local MIN_DISTANCE = 700
local FORCE = 1600

local conf = {
    imageOff = "images/gyro.png",
    imageOrigin = {33, 43},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    circleShapeRadius = 49,
    holdActivate = true,
    density = 1,
    text =
    {
        pos = {5.5, 5},
        rotation = math.pi/2,
        scale = {1.5, 1.5},
        color = {0.1,0.6,0.1,1},
    },
   
}

return conf
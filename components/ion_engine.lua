
local FORCE = 500

local conf = {
    imageOff = "images/ion engine 1.png",
    imageOn = "images/ion engine on 1.png",
    imageDmg = {"images/ion engine damage","images/ion engine damage 2"},
    imageOrigin = {560, 537},
    imageScale = {0.05, 0.05},
    activationOrigin = {-20, 0},
    shapeCoords = {7,17, 7,-17, -7,-17, -7,17},
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
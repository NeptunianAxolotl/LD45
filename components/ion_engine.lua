
local FORCE = 1200

local conf = {
    imageOff = "images/ion engine 1.png",
    imageOn = "images/ion engine on 1.png",
    imageDmg = {"images/ion engine damage.png","images/ion engine damage 2.png"},
    imageOrigin = {560, 537},
    imageScale = {0.05, 0.05},
    activationOrigin = {-20, 0},
    shapeCoords = {7,17, 7,-17, -7,-17, -7,17},
    walkRadius = 30,
    maxHealth = 240,
    density = 5,
    humanName = "an ion engine",
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0.8, 0.6, 0.2, 0.1)
    end,
    text =
    {
        pos = {5.5, 5},
        rotation = math.pi/2,
        scale = {1, 1},
        color = {0.8,0.1,0.1,1},
    },
    holdActivate = true,
    onFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)
        local fx, fy = FORCE*math.cos(activeAngle), FORCE*math.sin(activeAngle)
        body:applyForce(fx, fy, activeX, activeY)
    end,
}

return conf
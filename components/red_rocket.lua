
local FORCE = 16000

local conf = {
    imageOff = "images/red-rocket-off.png",
    imageOn = "images/red-rocket-on.png",
    imageOrigin = {500, 600},
    imageScale = {0.35, 0.35},
    activationOrigin = {0, 66},
    shapeCoords = {0, -106.75, 38.5, -47.25, 54.25, 35.7, 36.75, 66.5, -36.75, 66.5, -54.25, 35.7, -38.5, -47.25},
    walkRadius = 70,
    maxHealth = 2200,
    humanName = "a large rocket",
    density = 6,
    text =
    {
        pos = {5.5, 5},
        rotation = math.pi/2,
        scale = {1.5, 1.5},
        color = {0.8,0.1,0.1,1},
    },
    holdActivate = true,
    onFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)
        activeAngle = activeAngle - math.pi*0.5
        local fx, fy = FORCE*math.cos(activeAngle), FORCE*math.sin(activeAngle)
        body:applyForce(fx, fy, activeX, activeY)
    end,
}

return conf
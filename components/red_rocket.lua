
local FORCE = 16000

local conf = {
    imageOff = "images/red-rocket-off.png",
    imageOn = "images/red-rocket-on.png",
    imageOrigin = {500, 600},
    imageScale = {0.35, 0.35}, 
    activationOrigin = {0, 66},
    shapeCoords = {0, -106.75, 38.5, -47.25, 54.25, 35.7, 36.75, 66.5, -36.75, 66.5, -54.25, 35.7, -38.5, -47.25},
    walkRadius = 70,
    maxHealth = 1800,
    scaleMax = 1,
    scaleMin = 0.6,
    humanName = "a large red rocket.",
    isPropulsion = true,
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0, 0.02, 0.08, 0.15)
    end,
    density = 6,
    text =
    {
        pos = {5.5, 5},
        rotation = math.pi/2,
        scale = {1, 1},
        color = {0.8,0.1,0.1,1},
    },
    holdActivate = true,
    onFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)
        activeAngle = activeAngle - math.pi*0.5
        local fx, fy = comp.scaleFactor*FORCE*math.cos(activeAngle), comp.scaleFactor*FORCE*math.sin(activeAngle)
        body:applyForce(fx, fy, activeX, activeY)
        audioSystem.playSound("redrocket", comp.index)
    end,
}

return conf
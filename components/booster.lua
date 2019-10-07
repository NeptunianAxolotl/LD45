
local FORCE = 2300

local conf = {
    imageOff = "images/booster.png",
    imageOn = "images/booster on.png",
    imageDmg = {"images/booster damage.png","images/booster damage 2.png"},
    imageOrigin = {670, 500},
    imageScale = {0.1, 0.1},
    activationOrigin = {-20, 0},
    shapeCoords = {26,0, 15,16, 15,-16, -14,-26, -26,-14, -26,14, -14,26},
    walkRadius = 35,
    density = 4,
    maxHealth = 700,
    humanName = "a booster",
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0.4, 0.4, 0.4, 0.2)
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
        audioSystem.playSound("booster", comp.index)
    end,
}

return conf
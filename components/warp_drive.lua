
local FORCE = 30000

local conf = {
    imageOff = "images/warpdriveoff.png",
    imageOn = "images/warpdriveon.png",
    imageAnimateOnFrames = 8,
    imageOrigin = {500, 500},
    imageScale = {0.2, 0.2},
    activationOrigin = {-52, 0},
    circleShapeRadius = 52,
    walkRadius = 42,
    maxHealth = 800,
    humanName = "a warp drive",
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 20, 0, 0.12, 0.03)
    end,
    density = 12,
    text =
    {
        pos = {-15.5, 40},
        rotation = -math.pi*0.3,
        scale = {1, 1},
        color = {0.2,0.2,1,1},
    },
    holdActivate = true,
    onFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)
        local fx, fy = FORCE*math.cos(activeAngle), FORCE*math.sin(activeAngle)
        body:applyForce(fx, fy, activeX, activeY)
        audioSystem.playSound("booster", comp.index)
    end,
}

return conf
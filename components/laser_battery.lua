local SCALE = 1.8

local conf = {
    imageOff = "Images/laserbattery.png",
    imageOn = "Images/laserbatteryon.png",
    imageDmg = {"Images/laserbatterybreak1.png","Images/laserbatterybreak2.png"},
    imageAnimateOnFrames = 7,
    imageFrameDuration = 0.1,
    imageOrigin = {480, 480},
    imageScale = {SCALE*0.1, SCALE*0.1},
    activationOrigin = {0, 0},
    shapeCoords = { SCALE*33,SCALE*19, SCALE*33,SCALE*-19, SCALE*-33,SCALE*-19, SCALE*-33,SCALE*19},
    walkRadius = 42,
    maxHealth = 300,
    humanName = "a warp battery!",
    alwaysOn = true,
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0, 0, 0.002, 0.04)
    end,
    onFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)
        -- do nothing
    end,
    density = 2,
}

return conf
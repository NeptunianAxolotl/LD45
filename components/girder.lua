local conf = {
    imageOff = "Images/girder 1.png",
    imageOn = "Images/girder 1.png",
    imageOrigin = {500, 500},
    imageScale = {0.06, 0.06},
    activationOrigin = {0, 0},
    shapeCoords = { 30,8, 30,-8, -30,-8, -30,8},
    walkRadius = 28,
    maxHealth = 120,
    density = 0.2,
    humanName = "a girder",
    getOccurrence = function (dist)
        return 1
    end,
    isGirder = true,
    girderReach = 30,
}

return conf
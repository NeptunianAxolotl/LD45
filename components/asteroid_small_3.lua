local conf = {
    imageOff = "images/asteroid_r3.png",
    imageOn = "images/asteroid_r3.png",
    imageOrigin = {111, 86},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    shapeCoords = { -111,-56, -51,-86, 81,-62, 111,0, 111,39, 34,86, -4,86, -111,30},
    walkRadius = 35,
    maxHealth = 500,
    scaleMax = 0.6,
    scaleMin = 0.12,
    density = 1,
    noAttach = true,
    noSelect = true,
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0.1, 0.2, 0.22, 0.25)
    end,
}

return conf
local conf = {
    imageOff = "Images/asteroid_r3.png",
    imageOn = "Images/asteroid_r3.png",
    imageOrigin = {111, 86},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    shapeCoords = { -111,-56, -51,-86, 81,-62, 111,0, 111,39, 34,86, -4,86, -111,30},
    walkRadius = 35,
    maxHealth = 600,
    scaleMax = 1.2,
    scaleMin = 0.5,
    density = 1,
    noAttach = true,
    noSelect = true,
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0.001, 0.02, 0.08, 0.09)
    end,
}

return conf
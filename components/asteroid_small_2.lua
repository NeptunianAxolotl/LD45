local conf = {
    imageOff = "Images/asteroid_r2.png",
    imageOn = "Images/asteroid_r2.png",
    imageOrigin = {113, 88},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    shapeCoords = {90, -86, 111, -43, 107, 34, 85, 76, 32, 79, -97, 46, -108, -13, -79, -68},
    walkRadius = 35,
    maxHealth = 600,
    scaleMax = 0.6,
    scaleMin = 0.12,
    density = 1,
    noAttach = true,
    noSelect = true,
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0.15, 0.2, 0.22, 0.26)
    end,
}

return conf
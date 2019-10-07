local conf = {
    imageOff = "images/asteroid_r2.png",
    imageOn = "images/asteroid_r2.png",
    imageOrigin = {113, 88},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    shapeCoords = {90, -86, 111, -43, 107, 34, 85, 76, 32, 79, -97, 46, -108, -13, -79, -68},
    walkRadius = 35,
    maxHealth = 550,
    scaleMax = 0.6,
    scaleMin = 0.02,
    density = 1,
    noAttach = true,
    noSelect = true,
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0.1, 0.2, 0.22, 0.25)
    end,
}

return conf
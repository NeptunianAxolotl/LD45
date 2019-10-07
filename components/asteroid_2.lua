local conf = {
    imageOff = "images/asteroid_r2.png",
    imageOn = "images/asteroid_r2.png",
    imageOrigin = {113, 88},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    shapeCoords = {90, -86, 111, -43, 107, 34, 85, 76, 32, 79, -97, 46, -108, -13, -79, -68},
    walkRadius = 35,
    maxHealth = 600,
    scaleMax = 1.2,
    scaleMin = 0.5,
    density = 1,
    humanName = "a space rock",
    noAttach = true,
    noSelect = true,
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0.001, 0.02, 0.08, 0.09)
    end,
}

return conf
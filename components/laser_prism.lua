local conf = {
    imageOff = "images/laser_prism.png",
    imageOn = "images/laser_prism.png",
    imageOrigin = {32, 22},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    shapeCoords = {32,-12, 20,-22, -20,-22, -32,-12, 0,22},
    walkRadius = 45,
    maxHealth = 320,
    humanName = "a laser prism",
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0, 0.01, 0.1, 0.1)
    end,
    density = 1,
}

return conf
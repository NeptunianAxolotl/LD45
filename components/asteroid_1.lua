local conf = {
    imageOff = "images/asteroid_r1.png",
    imageOn = "images/asteroid_r1.png",
    imageOrigin = {120, 111},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    shapeCoords = {-20, -108, 54, -98, 114, -26, 107, 73, 32, 110, -112, 64, -117, -1, -85, -57},
    walkRadius = 35,
    maxHealth = 500,
    scaleMax = 1.2,
    scaleMin = 0.5,
    density = 1,
    humanName = "an asteroid",
    noAttach = true,
    noSelect = true,
    getOccurence = function (dist)
        return 1
    end,
}

return conf
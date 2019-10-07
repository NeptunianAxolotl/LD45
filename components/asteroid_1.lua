local conf = {
    imageOff = "Images/asteroid_r1.png",
    imageOn = "Images/asteroid_r1.png",
    imageDmg = {"Images/asteroid_r1_dmg1.png","Images/asteroid_r1_dmg1.png"},
    imageOrigin = {120, 111},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    shapeCoords = {-20, -108, 54, -98, 114, -26, 107, 73, 32, 110, -112, 64, -117, -1, -85, -57},
    walkRadius = 35,
    maxHealth = 600,
    scaleMax = 1.3,
    scaleMin = 0.4,
    density = 1,
    humanName = "an asteroid",
    noAttach = true,
    noSelect = true,
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0.001, 0.03, 0.09, 0.12)
    end,
}

return conf
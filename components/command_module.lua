local conf = {
    imageOff = "Images/command module.png",
    imageOn = "Images/command module.png",
    imageDmg = {"Images/command module damage.png","Images/command module damage 2.png"},
    imageOrigin = {598, 466},
    imageScale = {0.1, 0.1},
    activationOrigin = {0, 0},
	shapeCoords = { 21,20, 32,13, 32,-13, 21,-20, -21,-20, -32,-13, -32,13, -21,20 },
    walkRadius = 40,
    maxHealth = 320,
    scaleMax = 1.1,
    scaleMin = 0.8,
    density = 1,
    humanName = "a command module.",
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0.25, 0.2, 0.07, 0.03)
    end,
}

return conf
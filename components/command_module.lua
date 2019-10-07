local conf = {
    imageOff = "images/command module.png",
    imageOn = "images/command module.png",
    imageDmg = {"images/command module damage.png","images/command module damage 2.png"},
    imageOrigin = {598, 466},
    imageScale = {0.1, 0.1},
    activationOrigin = {0, 0},
	shapeCoords = { 21,20, 32,13, 32,-13, 21,-20, -21,-20, -32,-13, -32,13, -21,20 },
    walkRadius = 40,
    maxHealth = 200,
    density = 1,
    humanName = "a command module",
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0.25, 0.2, 0.07, 0.03)
    end,
}

return conf
local conf = {
    imageOff = "images/console.png",
    imageOn = "images/command module.png",
    imageDmg = {"images/consolebreak1.png","images/consolebreak2.png"},
    imageOrigin = {500, 500},
    imageScale = {0.1, 0.1},
    activationOrigin = {0, 0},
	shapeCoords = { -40,-12.5, -32.5,-20, 32.5,-20, 40,-12.5, 40,12.5, 32.5,20, -32.5,20, -40,12.5 },
    walkRadius = 40,
    maxHealth = 320,
    scaleMax = 1.1,
    scaleMin = 0.8,
    density = 1,
    humanName = "a console for the warp engine",
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0.25, 0.2, 0.07, 0.03)
    end,
}

return conf
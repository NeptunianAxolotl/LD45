local conf = {
    imageOff = "images/debrisburner.png",
    imageOn = "images/debrisburneron.png",
    imageDmg = {"images/debrisburnerbreak1.png","images/debrisburnerbreak2.png"},
    imageOrigin = {500, 700},
    imageScale = {0.1, 0.1},
    activationOrigin = {0, 0},
    shapeCoords = {-38,-30, 38,-30, 38,20, -38,20},
    walkRadius = 45,
    maxHealth = 320,
    density = 2,
    humanName = "some burner debris",
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0, 0, 0.05, 0.05)
    end,
    text =
    {
        pos = {-5, 5},
        rotation = 0,
        scale = {1, 1},
        color = {0.8,0.1,0.1,1},
    },
}

return conf
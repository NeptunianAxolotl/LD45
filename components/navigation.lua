local conf = {
    imageOff = "images/navigation.png",
    imageOn = "images/navigationon.png",
    imageDmg = {"images/navigationbreak1.png","images/navigationbreak2.png"},
    imageOrigin = {500, 500},
    imageScale = {0.1, 0.1},
    activationOrigin = {0, 0},
    circleShapeRadius = 25,
    walkRadius = 32,
    maxHealth = 400,
    density = 1,
    humanName = "a navigation module",
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0, 0.05, 0.1, 0.05)
    end,
    text =
    {
        pos = {0, 0},
        rotation = 0,
        scale = {1, 1},
        color = {0.8,0.1,0.1,1},
    },
}

return conf
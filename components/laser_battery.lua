local conf = {
    imageOff = "images/laserbattery.png",
    imageOn = "images/laserbattery.png",
    imageDmg = {"images/laserbatterybreak1.png","images/laserbatterybreak2.png"},
    imageOrigin = {480, 480},
    imageScale = {0.1, 0.1},
    activationOrigin = {0, 0},
    shapeCoords = { 33,19, 33,-19, -33,-19, -33,19},
    walkRadius = 42,
    maxHealth = 300,
    humanName = "a laser battery",
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0, 0, 0.01, 0.03)
    end,
    density = 1,
}

return conf
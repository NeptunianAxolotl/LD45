local conf = {
    imageOff = "Images/push_missile/push_missile_launch_debris.png",
    imageOn = "Images/push_missile/push_missile_launch_debris.png",
    imageOrigin = {30, 17.5},
    imageScale = {0.5, 0.5},
    activationOrigin = {0, 0},
    shapeCoords = { 15,8, -15,8, -15,-8, 15,-8},
    walkRadius = 22,
    maxHealth = 80,
    humanName = "some missile debris",
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0.4, 0.3, 0.1, 0.05)
    end,
    density = 1,
}

return conf
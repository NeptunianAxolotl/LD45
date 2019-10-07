local conf = {
    imageOff = "images/player.png",
    imageOn = "images/player on.png",
    imageOrigin = {470, 450},
    imageScale = {0.1, 0.1},
    activationOrigin = {0, 0},
    shapeCoords = {33,0, 26,21, 26,-21, -24,-10, -24,10},
    walkRadius = 30,
    maxHealth = 1000,
    density = 15,
    phaseSpeedMult = 4,
    getOccurrence = function (dist)
        return 1
    end,
}

return conf
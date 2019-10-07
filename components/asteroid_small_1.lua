local conf = {
    imageOff = "images/asteroid_r1.png",
    imageOn = "images/asteroid_r1.png",
    imageOrigin = {120, 111},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    shapeCoords = {-20, -108, 54, -98, 114, -26, 107, 73, 32, 110, -112, 64, -117, -1, -85, -57},
    walkRadius = 35,
    maxHealth = 400,
    scaleMax = 0.6,
    scaleMin = 0.15,
    density = 1,
    noAttach = true,
    noSelect = true,
    getOccurrnce = function (dist)
        if dist < 4000 then
            return 0
        elseif dist < 15000 then
            return 0.2
        elseif dist < 60000 then
            return 0.4
        else
            return 0.2
        end
    end,
}

return conf
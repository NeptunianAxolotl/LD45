local conf = {
    imageOff = "images/asteroid_r3.png",
    imageOn = "images/asteroid_r3.png",
    imageOrigin = {111, 86},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    shapeCoords = { -111,-56, -51,-86, 81,-62, 111,0, 111,39, 34,86, -4,86, -111,30},
    walkRadius = 35,
    maxHealth = 500,
    scaleMax = 0.6,
    scaleMin = 0.15,
    density = 1,
    noAttach = true,
    noSelect = true,
    getOccurence = function (dist)
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
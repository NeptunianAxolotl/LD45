local conf = {
    imageOff = "images/asteroid_r3.png",
    imageOn = "images/asteroid_r3.png",
    imageOrigin = {111, 86},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    shapeCoords = { -111,-56, -51,-86, 81,-62, 111,0, 111,39, 34,86, -4,86, -111,30},
    walkRadius = 35,
    maxHealth = 550,
    scaleMax = 1.2,
    scaleMin = 0.5,
    density = 1,
    noAttach = true,
    noSelect = true,
    getOccurrnce = function (dist)
        if dist < 20000 then
            return 0
        elseif dist < 30000 then
            return 0.1
        elseif dist < 70000 then
            return 0.3
        else
            return 0
        end
    end,
}

return conf
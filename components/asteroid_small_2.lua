local conf = {
    imageOff = "images/asteroid_r2.png",
    imageOn = "images/asteroid_r2.png",
    imageOrigin = {113, 88},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    shapeCoords = {90, -86, 111, -43, 107, 34, 85, 76, 32, 79, -97, 46, -108, -13, -79, -68},
    walkRadius = 35,
    maxHealth = 550,
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
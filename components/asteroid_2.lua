local conf = {
    imageOff = "images/asteroid_r2.png",
    imageOn = "images/asteroid_r2.png",
    imageOrigin = {113, 88},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    shapeCoords = {90, -86, 111, -43, 107, 34, 85, 76, 32, 79, -97, 46, -108, -13, -79, -68},
    walkRadius = 35,
    maxHealth = 550,
    scaleMax = 1.2,
    scaleMin = 0.5,
    density = 1,
    humanName = "a space rock",
    noAttach = true,
    noSelect = true,
    getOccurrnce = function (dist)
        if dist < 8000 then
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
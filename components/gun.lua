local conf = {
    imageOff = "images/gun.png",
    imageOn = "images/gun.png",
    imageOrigin = {600, 420},
    imageScale = {0.2, 0.2},
    activationOrigin = {0, 0},
    shapeCoords = { 45,5, 45,-5, -50,-5, -50,5},
    walkRadius = 50,
    maxHealth = 220,
    humanName = "a gun",
    getOccurence = function (dist)
        if dist < 15000 then
            return 0
        elseif dist < 70000 then
            return 0.2
        else
            return 0.1
        end
    end,
    density = 1,
}

return conf
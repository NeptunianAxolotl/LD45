local conf = {
    imageOff = "images/laser_prism.png",
    imageOn = "images/laser_prism.png",
    imageOrigin = {32, 22},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    shapeCoords = {32,-12, 20,-22, -20,-22, -32,-12, 0,22},
    walkRadius = 45,
    maxHealth = 250,
    humanName = "a laser prism",
    getOccurrence = function (dist)
        if dist < 20000 then
            return 0
        elseif dist < 70000 then
            return 0.1
        else
            return 0.05
        end
    end,
    density = 1,
}

return conf
local conf = {
    imageOff = "images/command module.png",
    imageOn = "images/command module.png",
    imageDmg = {"images/command module damage.png","images/command module damage 2.png"},
    imageOrigin = {598, 466},
    imageScale = {0.1, 0.1},
    activationOrigin = {0, 0},
	shapeCoords = { 21,20, 32,13, 32,-13, 21,-20, -21,-20, -32,-13, -32,13, -21,20 },
    walkRadius = 40,
    maxHealth = 200,
    density = 1,
    humanName = "a command module",
    getOccurrence = function (dist)
        if dist < 40000 then
            return 0
        elseif dist < 70000 then
            return 0.2
        else
            return 0.1
        end
    end,
}

return conf
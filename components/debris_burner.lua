local conf = {
    imageOff = "images/debrisburner.png",
    imageOn = "images/debrisburneron.png",
    imageDmg = {"images/debrisburnerbreak1.png","images/debrisburnerbreak2.png"},
    imageOrigin = {500, 700},
    imageScale = {0.1, 0.1},
    activationOrigin = {0, 0},
    shapeCoords = {-38,-30, 38,-30, 38,20, -38,20},
    walkRadius = 45,
    maxHealth = 320,
    density = 2,
    humanName = "some burner debris",
    getOccurence = function (dist)
        if dist < 10000 then
            return 0
        elseif dist < 30000 then
            return 0.2
        elseif dist < 60000 then
            return 0.4
        else
            return 0.2
        end
    end,
    text =
    {
        pos = {-5, 5},
        rotation = 0,
        scale = {1, 1},
        color = {0.8,0.1,0.1,1},
    },
}

return conf
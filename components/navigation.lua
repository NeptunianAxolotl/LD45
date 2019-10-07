local conf = {
    imageOff = "images/navigation.png",
    imageOn = "images/navigationon.png",
    imageDmg = {"images/navigationbreak1.png","images/navigationbreak2.png"},
    imageOrigin = {500, 500},
    imageScale = {0.1, 0.1},
    activationOrigin = {0, 0},
    circleShapeRadius = 25,
    walkRadius = 32,
    maxHealth = 400,
    density = 1,
    humanName = "a radar module",
    getOccurrnce = function (dist)
        if dist < 40000 then
            return 0
        elseif dist < 70000 then
            return 0.2
        else
            return 0.1
        end
    end,
    text =
    {
        pos = {0, 0},
        rotation = 0,
        scale = {1, 1},
        color = {0.8,0.1,0.1,1},
    },
}

return conf
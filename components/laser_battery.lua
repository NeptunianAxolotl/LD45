local conf = {
    imageOff = "images/laserbattery.png",
    imageOn = "images/laserbattery.png",
    imageDmg = {"images/laserbatterybreak1.png","images/laserbatterybreak2.png"},
    imageOrigin = {480, 480},
    imageScale = {0.1, 0.1},
    activationOrigin = {0, 0},
    shapeCoords = { 33,19, 33,-19, -33,-19, -33,19},
    walkRadius = 42,
    maxHealth = 180,
    humanName = "a laser battery",
    getOccurrence = function (dist)
        if dist < 15000 then
            return 0
        elseif dist < 70000 then
            return 0.4
        else
            return 0.2
        end
    end,
    density = 1,
}

return conf
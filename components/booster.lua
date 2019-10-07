
local FORCE = 2200

local conf = {
    imageOff = "images/booster.png",
    imageOn = "images/booster on.png",
    imageDmg = {"images/booster damage.png","images/booster damage 2.png"},
    imageOrigin = {670, 500},
    imageScale = {0.1, 0.1},
    activationOrigin = {-20, 0},
    shapeCoords = {26,0, 15,16, 15,-16, -14,-26, -26,-14, -26,14, -14,26},
    walkRadius = 35,
    density = 7,
    maxHealth = 700,
    humanName = "a booster",
    getOccurrnce = function (dist)
        if dist < 5000 then
            return 0
        elseif dist < 20000 then
            return 0.1
        elseif dist < 40000 then
            return 0.5
        else
            return 0
        end
    end,
    text =
    {
        pos = {5.5, 5},
        rotation = math.pi/2,
        scale = {1, 1},
        color = {0.8,0.1,0.1,1},
    },
    holdActivate = true,
    onFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)
        local fx, fy = FORCE*math.cos(activeAngle), FORCE*math.sin(activeAngle)
        body:applyForce(fx, fy, activeX, activeY)
    end,
}

return conf
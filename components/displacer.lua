local POWER = 3

local conf = {
    imageOff = "images/displacer.png",
    imageOn = "images/displaceron.png",
    imageDmg = {"images/displacerbreak1.png","images/displacerbreak2.png"},
    imageOrigin = {500, 550},
    imageScale = {0.1, 0.1},
    activationOrigin = {0, 0},
    shapeCoords = {-30,-15, 30,-15, 30,5, 12.5,15, -12.5,15, -30,5},
    walkRadius = 40,
    maxHealth = 400,
    density = 1,
    humanName = "a displacer",
    text =
    {
        pos = {-5, 5},
        rotation = 0,
        scale = {1, 1},
        color = {0.8,0.1,0.1,1},
    },
    toggleActivate = true,
    onFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)
        util.AddPhaseRadius(player.guy, activeX, activeY, 700, dt*POWER)
        if player.ship then
            util.AddPhaseRadius(player.ship, activeX, activeY, 700, dt*POWER)
        end
    end,
}

return conf
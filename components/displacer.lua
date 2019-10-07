local POWER = 5

local conf = {
    imageOff = "images/displacer.png",
    imageOn = "images/displaceron.png",
    imageDmg = {"images/displacerbreak1.png","images/displacerbreak2.png"},
    imageOrigin = {500, 550},
    imageScale = {0.2, 0.2},
    activationOrigin = {0, 0},
    shapeCoords = {-60,-20, 60,-20, 60,10, 25,30, -25,30, -60,10},
    walkRadius = 40,
    maxHealth = 400,
    density = 1,
    onSound = "displacer_on",
    offSound = "displacer_off",
    humanName = "a phase displacement device",
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0, 0, 0.01, 0.03)
    end,
    text =
    {
        pos = {-5, 5},
        rotation = 0,
        scale = {1, 1},
        color = {0.8,0.1,0.1,1},
    },
    toggleActivate = true,
    onFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)
        util.AddPhaseRadius(player.guy, activeX, activeY, 400, dt*POWER)
        if player.ship then
            util.AddPhaseRadius(player.ship, activeX, activeY, 400, dt*POWER)
        end
    end,
}

return conf
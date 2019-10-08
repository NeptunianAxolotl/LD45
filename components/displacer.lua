local POWER = 5

local conf = {
    imageOff = "Images/displacer.png",
    imageOn = "Images/displaceron.png",
    imageDmg = {"Images/displacerbreak1.png","Images/displacerbreak2.png"},
    imageAnimateOnFrames = 4,
    imageFrameDuration = 0.1,
    imageOrigin = {500, 550},
    imageScale = {0.2, 0.2},
    activationOrigin = {0, 0},
    shapeCoords = {-60,-20, 60,-20, 60,10, 25,30, -25,30, -60,10},
    walkRadius = 40,
    maxHealth = 400,
    density = 1,
    onSound = "displacer_on",
    offSound = "displacer_off",
    humanName = "a warp displacer!",
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0, 0.01, 0.025, 0.03)
    end,
    text =
    {
        pos = {19, 30},
        rotation = math.pi,
        scale = {1, 1},
        color = {1,1,1,1},
    },
    toggleActivate = true,
    onFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)
        local winTimer = util.GetWinTimerProgress(player)
        if winTimer then
            comp.activated = true
        end
        util.AddPhaseRadius(player.guy, activeX, activeY, 400, dt*POWER)
        if player.ship then
            util.AddPhaseRadius(player.ship, activeX, activeY, 400, dt*POWER)
        end
    end,
    offFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)
        local winTimer = util.GetWinTimerProgress(player)
        if winTimer then
            comp.activated = true
        end
    end,
}

return conf
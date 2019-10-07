local conf = {
    imageOff = "images/console.png",
    imageOn = "images/consoleon.png",
    imageDmg = {"images/consolebreak1.png","images/consolebreak2.png"},
    imageAnimateOnFrames = 6,
    imageFrameDuration = 0.1,
    imageOrigin = {500, 500},
    imageScale = {0.1, 0.1},
    activationOrigin = {0, 0},
	shapeCoords = { -40,-12.5, -32.5,-20, 32.5,-20, 40,-12.5, 40,12.5, 32.5,20, -32.5,20, -40,12.5 },
    walkRadius = 42,
    maxHealth = 420,
    humanName = "a navigation console",
    density = 2,
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0, 0, 0.008, 0.03)
    end,
    text =
    {
        pos = {5.5, 11},
        rotation = 0,
        scale = {1, 1},
        color = {0.8,0.1,0.1,1},
    },
    holdActivate = true,
    onFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)
        -- Maybe win the game
    end,
}

return conf
local conf = {
    imageOff = "images/navigationon.png",
    imageOn = "images/navigationon.png",
    imageDmg = {"images/navigationbreak1.png","images/navigationbreak2.png"},
    imageExtra = {"images/navigationpointer.png"},
    imageOrigin = {500, 500},
    imageScale = {0.15, 0.15},
    activationOrigin = {0, 0},
    circleShapeRadius = 37.5,
    walkRadius = 32,
    maxHealth = 400,
    density = 2,
    humanName = "a scanner",
    alwaysOn = true,
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0, 0.18, 0.15, 0.12)
    end,
    onFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)
        if not player.closestObjX then
            comp.extraAngle = util.Angle(activeX, activeY)
            return
        end
        comp.extraAngle = util.Angle(player.closestObjX - activeX, player.closestObjY - activeY)
    end,
}

return conf
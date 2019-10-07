local conf = {
    imageOff = "Images/navigationon.png",
    imageOn = "Images/navigationon.png",
    imageDmg = {"Images/navigationbreak1.png","Images/navigationbreak2.png"},
    imageExtra = {"Images/navigationpointer.png"},
    imageOrigin = {500, 500},
    imageScale = {0.15, 0.15},
    activationOrigin = {0, 0},
    circleShapeRadius = 37.5,
    walkRadius = 32,
    maxHealth = 400,
    density = 2,
    humanName = "a scanner.",
    alwaysOn = true,
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0, 0.14, 0.15, 0.12)
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
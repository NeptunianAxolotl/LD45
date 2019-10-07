local FORCE = -1700

local conf = {
    imageOff = "images/gun.png",
    imageOn = "images/gun.png",
    imageOrigin = {500, 415},
    imageScale = {0.2, 0.2},
    activationOrigin = {46, 0},
    shapeCoords = { 20,8, 20,-8, -30,-8, -30,8},
    walkRadius = 50,
    maxHealth = 220,
    humanName = "a gun",
    getOccurrnce = function (dist)
        if dist < 15000 then
            return 0
        elseif dist < 70000 then
            return 0.2
        else
            return 0.1
        end
    end,
    density = 1,
    text =
    {
        pos = {5.5, 0},
        rotation = math.pi/2,
        scale = {1, 1},
        color = {0.8,0.1,0.1,1},
    },
    holdActivate = true,
    onFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt, world)
        comp.reloadTime = (comp.reloadTime or 0) - dt
        if comp.reloadTime > 0 then
            return
        end

        local vx, vy = body:getLinearVelocityFromWorldPoint(activeX, activeY)
        util.FireBullet(world, body, activeX, activeY, activeAngle, vx, vy)
        comp.reloadTime = 0.16

        local fx, fy = FORCE*math.cos(activeAngle), FORCE*math.sin(activeAngle)
        body:applyForce(fx, fy, activeX, activeY)
    end,
}

return conf
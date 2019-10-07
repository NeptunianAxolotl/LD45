local FORCE = -900
local DAMAGE = 130
local SHOT_SPEED = 1400
local LIFE = 2

local conf = {
    imageOff = "Images/gun.png",
    imageOn = "Images/gun.png",
    imageOrigin = {500, 415},
    imageScale = {0.2, 0.2},
    activationOrigin = {46, 0},
    shapeCoords = { 20,8, 20,-8, -30,-8, -30,8},
    walkRadius = 50,
    maxHealth = 360,
    humanName = "a blaster.",
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0.13, 0.17, 0.19, 0.2)
    end,
    density = 2,
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
        util.FireBullet(world, body, activeX, activeY, activeAngle, vx, vy, DAMAGE, SHOT_SPEED, LIFE)
        comp.reloadTime = 0.16

        local fx, fy = FORCE*math.cos(activeAngle), FORCE*math.sin(activeAngle)
        body:applyForce(fx, fy, activeX, activeY)
    end,
}

return conf
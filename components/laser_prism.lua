local FORCE = -1700
local DAMAGE = 90
local SPEED = 380
local LIFE = 4

local conf = {
    imageOff = "images/laser_prism.png",
    imageOn = "images/laser_prism.png",
    imageOrigin = {500, 500},
    imageScale = {0.064, 0.048},
    activationOrigin = {0, 0},
    shapeCoords = {32,-12, 20,-22, -20,-22, -32,-12, 0,22},
    walkRadius = 45,
    maxHealth = 200,
    humanName = "a laser prism",
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0, 0.04, 0.12, 0.20)
    end,
    density = 1,
    onDeathFunc = function(world, comp, ship)
        local x, y = ship.body:getWorldPoint(comp.xOff, comp.yOff)

        local vx, vy = ship.body:getLinearVelocityFromWorldPoint(x, y)
        local sep = 2*math.pi/12
        local angle = math.random()*sep

        for i = 1, 10 do
            util.FireBullet(world, ship.body, x, y, angle + i*sep, vx, vy, DAMAGE, SPEED, LIFE, 50)
        end
    end,
}

return conf
local MIN_DISTANCE = 700
local FORCE = 1600

local conf = {
    imageOn = "images/gyro.png",
    imageOff = "images/gyro.png",
    imageOrigin = {63, 56},
    imageScale = {0.8, 0.8},
    activationOrigin = {0, 0},
    circleShapeRadius = 35,
    toggleActivate = true,
    maxHealth = 200,
    walkRadius = 20,
    density = 1,
    text =
    {
        pos = {10, 10},
        rotation = math.pi/2,
        scale = {1.3, 1.3},
        color = {0,0,0,1},
    },
    onFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)
        comp.power = (comp.power or 0) + 0.6*dt
        if comp.power > 1 then
            comp.power = 1
        end
        comp.drawAngle = ((comp.drawAngle or 0) + dt*5*comp.power)%(math.pi*2)
    end,
    offFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)
        comp.power = (comp.power or 0) - 0.6*dt
        if comp.power < 0 then
            comp.power = 0
        end
        comp.drawAngle = ((comp.drawAngle or 0) + dt*5*comp.power)%(math.pi*2)
    end,
   
}

return conf
local FORCE = 2000000
local CHANGE_SPEED = 3.4

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
    scaleMax = 1,
    scaleMin = 0.3,
    humanName = "a gyroscopic stabiliser",
    density = 1,
    text =
    {
        pos = {4, 8},
        rotation = 0,
        scale = {1.3, 1.3},
        color = {0,0,0,1},
    },
    onFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)
        local angularVelocity = body:getAngularVelocity()
        
        comp.power = (comp.power or 0) + math.tanh(-angularVelocity*6)*CHANGE_SPEED*dt
        if comp.power < -1 then
            comp.power = -1
        end
        if comp.power > 1 then
            comp.power = 1
        end
        body:applyTorque(comp.scaleFactor*FORCE*comp.power)
        comp.drawAngle = ((comp.drawAngle or 0) + dt*5*comp.power)%(math.pi*2)
    end,
    offFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)
        if not comp.power then
            return
        end
        if comp.power > 0 then
            comp.power = comp.power - CHANGE_SPEED*dt
            if comp.power < 0 then
                comp.power = 0
            end
            body:applyTorque(comp.scaleFactor*FORCE*comp.power)
        elseif comp.power < 0 then
            comp.power = comp.power + CHANGE_SPEED*dt
            if comp.power > 0 then
                comp.power = 0
            end
            body:applyTorque(FORCE*comp.power)
        end
        comp.drawAngle = ((comp.drawAngle or 0) + dt*5*comp.power)%(math.pi*2)
    end,
   
}

return conf
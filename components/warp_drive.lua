local FORCE = 40000
local GYRO_FORCE = 400000
local CHANGE_SPEED = 3.4

local conf = {
    imageOff = "Images/warpdriveoff.png",
    imageOn = "Images/warpdriveon.png",
    imageAnimateOnFrames = 8,
    imageFrameDuration = 0.1,
    imageOrigin = {500, 500},
    imageScale = {0.2, 0.2},
    activationOrigin = {-52, 0},
    circleShapeRadius = 52,
    walkRadius = 42,
    maxHealth = 800,
    humanName = "a warp drive!",
    isPropulsion = true,
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0, 0.001, 0.02, 0.04)
    end,
    density = 12,
    text =
    {
        pos = {-2,2},
        rotation = -math.pi*0.5,
        scale = {1, 1},
        color = {0.2,0.3,1,1},
    },
    holdActivate = true,
    
    onFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)
        local winTimer = util.GetWinTimerProgress(player)
        if winTimer and winTimer > 1 then
            comp.activated = true
            util.WarpWinPower(comp, body, activeX, activeY, activeAngle, junkList, player, dt)
            return
        end

        local angularVelocity = body:getAngularVelocity()
        
        comp.power = (comp.power or 0) + math.tanh(-angularVelocity*10)*CHANGE_SPEED*dt
        if comp.power < -1 then
            comp.power = -1
        end
        if comp.power > 1 then
            comp.power = 1
        end
        body:applyTorque(comp.scaleFactor*GYRO_FORCE*comp.power)
        comp.drawAngle = ((comp.drawAngle or 0) + dt*angularVelocity)%(math.pi*2)
        activeAngle = activeAngle + comp.drawAngle

        local fx, fy = FORCE*math.cos(activeAngle), FORCE*math.sin(activeAngle)
        body:applyForce(fx, fy, activeX, activeY)
        audioSystem.playSound("redrocket", comp.index)
    end,
    offFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)
        local winTimer = util.GetWinTimerProgress(player)
        if winTimer and winTimer > 1 then
            comp.activated = true
            util.WarpWinPower(comp, body, activeX, activeY, activeAngle, junkList, player, dt)
            return
        end

        if not comp.power then
            return
        end
        if comp.power > 0 then
            comp.power = comp.power - CHANGE_SPEED*dt
            if comp.power < 0 then
                comp.power = 0
            end
            body:applyTorque(comp.scaleFactor*GYRO_FORCE*comp.power)
        elseif comp.power < 0 then
            comp.power = comp.power + CHANGE_SPEED*dt
            if comp.power > 0 then
                comp.power = 0
            end
            body:applyTorque(GYRO_FORCE*comp.power)
        end
    end,
}

return conf
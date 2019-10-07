local MIN_DISTANCE = 700
local FORCE = 2400

local conf = {
    imageOff = "Images/tractor_wheel.png",
    imageOn = "Images/tractor_wheel_on.png",
    imageOrigin = {32, 32},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    circleShapeRadius = 32,
    walkRadius = 40,
    maxHealth = 500,
    toggleActivate = true,
    scaleMax = 1.6,
    scaleMin = 0.5,
    humanName = "a tractor beam.",
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0.04, 0.14, 0.16, 0.2)
    end,
    density = 1,
    text =
    {
        pos = {5.5, 5},
        rotation = math.pi/2,
        scale = {1, 1},
        color = {0.1,0.6,0.1,1},
    },
    --drawables = {},
    -- angular velocity here; tractor wheel is always rotating in game
    
    onFunction = function (comp, body, activeX, activeY, activeAngle, junkList, player, dt)

        if junkList then
            local nearestJunk
            local nearestDist
            for _, junk in pairs(junkList) do
                local junkX, junkY = junk.body:getX(), junk.body:getY()

                local distance = util.Dist(activeX, activeY, junkX, junkY)
                if (distance < MIN_DISTANCE) and ((not nearestDist) or (distance < nearestDist)) then
                    nearestDist = distance
                    nearestJunk = junk
                end
            end

            if not nearestJunk then
                comp.aimX = false
                comp.aimY = false
                return
            end
            
            comp.swankSpeed = comp.swankSpeed or ((math.random() > 0.5 and 7) or -7)
            comp.drawAngle = ((comp.drawAngle or (math.random()*2*math.pi)) + dt*comp.swankSpeed)%(2*math.pi)

            local ax, ay = util.ToCart(comp.drawAngle + activeAngle, comp.scaleFactor*20)
            ax, ay = ax + activeX, ay + activeY

            local jx, jy = nearestJunk.body:getX(), nearestJunk.body:getY()
            local forceAngle = util.Angle(jx - ax, jy - ay)

            local forceMult = math.tanh((nearestDist - 260)*0.01)
            if forceMult > 0 then
                forceMult = forceMult*0.8
            end

            local fx, fy = comp.scaleFactor*forceMult*FORCE*math.cos(forceAngle), forceMult*FORCE*math.sin(forceAngle)
            nearestJunk.body:applyForce(-fx, -fy, ax, ay)
            body:applyForce(fx, fy, ax, ay)
            
            comp.emitX = ax
            comp.emitY = ay
            comp.aimX = jx
            comp.aimY = jy
            
            audioSystem.playSound("tractor", comp.index)
            
            return
        end

        comp.aimX = false
        comp.aimY = false
    end
}

return conf
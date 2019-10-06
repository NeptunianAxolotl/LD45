local MIN_DISTANCE = 700
local FORCE = 2400

local conf = {
    imageOff = "images/tractor_wheel.png",
    imageOn = "images/tractor_wheel_on.png",
    imageOrigin = {32, 32},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    circleShapeRadius = 32,
    walkRadius = 40,
    maxHealth = 900,
    toggleActivate = true,
    humanName = "a tractor beam",
    density = 1,
    text =
    {
        pos = {5.5, 5},
        rotation = math.pi/2,
        scale = {1.5, 1.5},
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
            comp.swankAngle = ((comp.swankAngle or (math.random()*2*math.pi)) + dt*comp.swankSpeed)%(2*math.pi)
            local ax, ay = util.ToCart(comp.swankAngle + activeAngle, 20)
            ax, ay = ax + activeX, ay + activeY

            local jx, jy = nearestJunk.body:getX(), nearestJunk.body:getY()
            local forceAngle = util.Angle(jx - ax, jy - ay)

            local forceMult = math.tanh((nearestDist - 260)*0.01)
            if forceMult > 0 then
                forceMult = forceMult*0.8
            end

            local fx, fy = forceMult*FORCE*math.cos(forceAngle), forceMult*FORCE*math.sin(forceAngle)
            nearestJunk.body:applyForce(-fx, -fy, ax, ay)
            body:applyForce(fx, fy, ax, ay)
            
            comp.emitX = ax
            comp.emitY = ay
            comp.aimX = jx
            comp.aimY = jy
            return
        end

        comp.aimX = false
        comp.aimY = false
    end
}

return conf
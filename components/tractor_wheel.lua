local FORCE = 3000

local conf = {
    imageOff = "images/tractor_wheel.png",
    imageOn = "images/tractor_wheel_on.png",
    imageOrigin = {32, 32},
    imageScale = {1, 1},
    activationOrigin = {0, 0},
    circleShapeRadius = 32,
    activated = false,
    density = 1,
    text =
    {
        pos = {5.5, 5},
        rotation = math.pi/2,
        scale = {1.5, 1.5},
        color = {0.1,0.6,0.1,1},
    },
    drawables = {},
    -- angular velocity here; tractor wheel is always rotating in game
    
    toggleActivate = true,
    onFunction = function (self, body, activeX, activeY, angle, junkList, player)
        local distance
        
        local minDistance
        local minDistBody
        
        if junkList then
            for i, junk in ipairs(junkList) do
                distance = util.Dist(activeX, activeY, junk.body:getX(), junk.body:getY())
                
                if (not minDistance) or (distance < minDistance) then
                    minDistance = distance
                    minDistBody = junk
                end
            end

            if not minDistBody then
                return
            end
            
            local jx, jy = minDistBody.body:getX(), minDistBody.body:getY()
            local activeAngle = util.Angle(jx - activeX, jy - activeY)
            local fx, fy = FORCE*math.cos(activeAngle), FORCE*math.sin(activeAngle)
            minDistBody.body:applyForce(fx, fy, activeX, activeY)
            
            local object = {}
            object.type = "tractorbeam"
            object.x = activeX
            object.y = activeY
            object.x2 = minDistBody.body:getX()
            object.y2 = minDistBody.body:getY()
            
            drawables = {}
            drawables[#drawables + 1] = object
        end
    end,
}

return conf
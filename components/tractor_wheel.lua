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
        local _body
        
        local minDistance
        local minDistBody
        
        if junkList then
            for i = 1, #junkList do
                _body = junkList[i]
                
                print(junkList[i])
                distance = Dist(activeX, activeY, junkList[i]:getX(), junkList[i]:getY())
                
                if distance < minDistance then
                    minDistance = distance
                    minDistBody = _body
                end
            end
            
            print("tractorbeam")
            
            local activeAngle = minDistBody:getAngles(activeX, activeY)
            local fx, fy = FORCE*math.cos(activeAngle), FORCE*math.sin(activeAngle)
            minDistBody:applyForce(fx, fy, activeX, activeY)
            
            local object = {}
            object.type = "tractorbeam"
            object.x = activeX
            object.y = activeY
            object.x2 = minDistBody:getX()
            object.y2 = minDistBody:getY()
            
            drawables[#drawables + 1] = object
        end
    end,
}

return conf
local ps
local world
local playerShape
local junkList = {}

local shipPart

local function boundedIntersection(x1, y1, x2, y2, x3, y3, x4, y4)
	
	local denominator = ((x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4))
	if denominator == 0 then
		return false
	end
	local first = ((x1 - x3)*(y3 - y4) - (y1 - y3)*(x3 - x4))/denominator
	local second = -1*((x1 - x2)*(y1 - y3) - (y1 - y2)*(x1 - x3))/denominator
	
	if first < 0 or first > 1 or (second < 0 or second > 1) then
		return false
	end
	
	local px = x1 + first*(x2 - x1)
	local py = y1 + first*(y2 - y1)
	
	return {px, py}
end

local function intersection (x1, y1, x2, y2, x3, y3, x4, y4)
  local d = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
  local a = x1 * y2 - y1 * x2
  local b = x3 * y4 - y3 * x4
  local x = (a * (x3 - x4) - (x1 - x2) * b) / d
  local y = (a * (y3 - y4) - (y1 - y2) * b) / d
  return x, y
end

local function getAngles(self, sourceX, sourceY)
    local angles = {}
    
    for i = 1, #self / 2 do
        angles[#angles + 1] = math.atan2(sourceY - self[2 * i], sourceX - self[(2 * i) - 1])
    end
    
    return angles
end

local function distance (x1, y1, x2, y2)
      local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )    
end


function paintShadows (bodyList, lightSource, minDistance)
    
    --bodies
    for i = 1, #bodyList do
        fixtures = bodyList[i]:getFixtures()
        
        --fixtures
        for j = 1, #fixtures do
            
            local shadowPoints = {}
            
            local shape = fixtures[j]:getShape()
            
            --points for fixture
            local points = {shape:getPoints()}
            local _points = {junkList[i]:getWorldPoints(points[1], points[2], points[3], points[4], points[5], points[6], points[7], points[8])}
            
            for i = 1, #_points / 2 do
                if distance(_points[2 * i - 1], _points[2 * i], lightSource.x, lightSource.y) < minDistance then
                    goto continue
                end
            end
            
            local angles = getAngles(_points, lightSource.x, lightSource.y)
            local compAngles = {}
            
            for i = 1, #angles do
                compAngles[i] = angles[i]
            end
            
            table.sort(angles)
            
            minAngle = angles[1]
            maxAngle = angles[#angles]
            
            local maxAngleNo = 0
            local minAngleNo = 0
            
            for i = 1, #angles do
                if compAngles[i] == minAngle then
                    minAngleNo = i
                end
                
                if compAngles[i] == maxAngle then
                    maxAngleNo = i
                end
                
            end

            edgePoints = {}
            edgePoints[1] = _points[(2 * minAngleNo) - 1]
            edgePoints[2] = _points[2 * minAngleNo]
            edgePoints[3] = _points[(2 * maxAngleNo) - 1]
            edgePoints[4] = _points[2 * maxAngleNo]
            
            shadowPoints[1] = edgePoints[3]
            shadowPoints[2] = edgePoints[4]
            shadowPoints[3] = edgePoints[1]
            shadowPoints[4] = edgePoints[2]

            --draw lines tracing from shape edges
            for i = 1, 2 do
                --project line to edge of screen
                --top or bottom?
                local angle = math.atan2(lightSource.y - edgePoints[2 * i], lightSource.x - edgePoints[(2 * i) - 1])
                
                if angle > 0 and angle < math.pi then
                    --top
                    intersectX, intersectY = intersection(lightSource.x, lightSource.y, edgePoints[(2 * i) - 1], edgePoints[2 * i], 0, 0, winWidth, 0)
                
                elseif angle < 0 and angle > - math.pi then
                    --bottom
                    intersectX, intersectY = intersection(lightSource.x, lightSource.y, edgePoints[(2 * i) - 1], edgePoints[2 * i], 0, winHeight, winWidth, winHeight)
                    
                else
                    --direct horizontal, skip this step and move to left or right
                    if angle == 0 then
                        --right
                        intersectX, intersectY = intersection(lightSource.x, lightSource.y, edgePoints[(2 * i) - 1], edgePoints[2 * i], winWidth, 0, winWidth, winHeight)
                    else
                        --left
                        intersectX, intersectY = intersection(lightSource.x, lightSource.y, edgePoints[(2 * i) - 1], edgePoints[2 * i], 0, 0, 0, winHeight)
                        
                    end     
                end
                     
                if intersectX < 0 then
                    --left
                    intersectX, intersectY = intersection(lightSource.x, lightSource.y, edgePoints[(2 * i) - 1], edgePoints[2 * i], 0, 0, 0, winHeight)
                        
                elseif intersectX > winWidth then
                    --right
                    intersectX, intersectY = intersection(lightSource.x, lightSource.y, edgePoints[(2 * i) - 1], edgePoints[2 * i], winWidth, 0, winWidth, winHeight)
                    
                end
                
                love.graphics.line(intersectX, intersectY, edgePoints[(2 * i) - 1], edgePoints[2 * i])
                
                shadowPoints[3 + (2 * i)] = intersectX
                shadowPoints[4 + (2 * i)] = intersectY
            end    
            
            --draw the shadow shape  
            love.graphics.polygon("fill", shadowPoints)
            
            --love.graphics.line(edgePoints[1], edgePoints[2], edgePoints[3], edgePoints[4])
            

        end

        -- retrieve two lines adjacent to those lines that do intersect the shape, at the outside
        -- create a shape bounded by the screen edge, the two outer lines, and the 'back half' of the shape
        -- colour this shape in
        -- overlay this shape as an effect on graphics present in this area
        
        ::continue::
    
    end
    
    
end


function love.draw()
    for i = 1, #junkList do
        local junk = junkList[i]
        love.graphics.draw(shipPart, junk:getX(), junk:getY(), junk:getAngle(), 0.1, 0.1, 400, 300)
    end
    
    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("fill", circle.x, circle.y, circle.radius)
    
    winWidth  = love.graphics:getWidth()
    winHeight = love.graphics:getHeight() 
    
    love.graphics.setColor(0,0,0,0.8)
    
    paintShadows(junkList, circle, 200)
    
    love.graphics.setColor(1, 1, 1)
end

local function SetupWorld()
    world = love.physics.newWorld(0, 0, true) -- Last argument is whether sleep is allowed.
    playerShape = love.physics.newBody(world, 0, 0, "dynamic")

    for i = 1, 20 do
        local junk = love.physics.newBody(world, math.random()*1000 - 500, math.random()*1000 - 500, "dynamic")
        love.physics.newFixture(junk, love.physics.newPolygonShape(-25, -24, 25, -10, 25, 10, -25, 24), 1)

        junk:setAngle(math.random()*2*math.pi)
        junk:setLinearVelocity(math.random()*4, math.random()*4)
        junk:setAngularVelocity(math.random()*2*math.pi)
        junkList[#junkList + 1] = junk
    end
end
 
function love.load()
    circle = {}
    circle.x = 600
    circle.y = 600
    circle.radius = 10
    
    shipPart = love.graphics.newImage('images/ship.png')

    SetupWorld()
end

function love.update(dt)
    world:update(dt)
    
    local speed = 300
    
    if love.keyboard.isDown("left") then
        circle.x = circle.x - speed * dt
    elseif love.keyboard.isDown("right") then
        circle.x = circle.x + speed * dt
    elseif love.keyboard.isDown("up") then
        circle.y = circle.y - speed * dt
    elseif love.keyboard.isDown("down") then
        circle.y = circle.y + speed * dt
    end
    
    
end

function love.mousemoved( x, y, dx, dy, istouch )
    --ps:moveTo(x,y)
end

function love.mousereleased( x, y, button, istouch, presses)
end

--[=[
- parallax (background stars, flashing points, small local celestial bodies?)
- light source intersection - engine flame, local light source (just basic one-colour shading)



]=]--

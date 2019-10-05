local ps
local world
local playerShape
local junkList = {}

local shipPart

local function GetBoundedLineIntersection(x1, y1, x2, y2, x3, y3, x4, y4)
	
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

function love.draw()
    for i = 1, #junkList do
        local junk = junkList[i]
        love.graphics.draw(shipPart, junk:getX(), junk:getY(), junk:getAngle(), 0.1, 0.1, 400, 300)
    end
    
    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("fill", circle.x, circle.y, circle.radius)
    
    --bodies
    for i = 1, #junkList do
        fixtures = junkList[i]:getFixtures()
        
        --fixtures
        for j = 1, #fixtures do
            local shape = fixtures[j]:getShape()
            
            --points for fixture
            local points = {shape:getPoints()}
            local _points = {junkList[i]:getWorldPoints(points[1], points[2], points[3], points[4], points[5], points[6], points[7], points[8])}
            
            --duplicate first point to after last point
            _points[9] = _points[1]
            _points[10] = _points[2]
            
            pointsToRemove = {}
            
            -- check whether light source lines intesect with shape lines
            print('loop')
            for l = 4, 1, -1 do
                for e = (#_points/2-1), 1, -1 do
                    print(#_points)
                    print("l e",l,e)
                    if GetBoundedLineIntersection(
                        _points[(2 * l) - 1],
                        _points[2 * l],
                        circle.x + circle.radius / 2,
                        circle.y + circle.radius / 2,
                        _points[(2 * e) - 1],
                        _points[2 * e],
                        _points[2 * (e + 1) - 1],
                        _points[2 * (e+1)]
                    ) == false then
                        --if yes, remove points from list
                        table.insert(pointsToRemove, (2*l) - 1)
                        table.insert(pointsToRemove, 2*l)
                    end
                    print("l, i",l, i)
                end
            end
            
            for i = 1, #pointsToRemove do
                table.remove(_points, pointsToRemove[i])
            end
            
            pointsToRemove = nil
            
            --draw lines between remaining points (unless there's only one point, in which case do nothing)
            if #points < 3 then
                --print('only one point')
            else
                --print ('more than one point')
                --draw shape outlines
                for s = 1, #_points / 2 do
                    --print('inside loop')
                    if _points[(2 * s) - 1] ~= nil and _points[2 * s] ~= nil and _points[(2 * (s + 1)) - 1] ~= nil and _points[2 * (s+1)] then
                        love.graphics.line(_points[(2 * s) - 1], _points[2 * s], _points[(2 * (s + 1)) - 1], _points[2 * (s+1)])
                    end
                    
                    
                    --print(_points[(2 * s) - 1])
                    --print(_points[2 * s])
                    --print(_points[(2 * (s + 1)) - 1])
                    --print(_points[2 * (s+1)])
                    
                    
                end

                --draw lines pointing from light source to each vertex
                for k = 1, #_points / 2 do
                    love.graphics.line(_points[(2 * k) - 1], _points[2 * k], circle.x + circle.radius / 2, circle.y + circle.radius / 2)
                end
            end
            
            

            

            
            
        end

        -- retrieve two lines adjacent to those lines that do intersect the shape, at the outside
        -- create a shape bounded by the screen edge, the two outer lines, and the 'back half' of the shape
        -- colour this shape in
        -- overlay this shape as an effect on graphics present in this area
    
        --print(x1 .. ', ' .. y1 .. '; ' .. x2 .. ', ' .. y2 .. '.')
    end
    

    
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

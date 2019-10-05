local ps
local world
local playerShape
local junkList = {}

local shipPart
function love.draw()
    for i = 1, #junkList do
        local junk = junkList[i]
        love.graphics.draw(shipPart, junk:getX(), junk:getY(), junk:getAngle(), 0.1, 0.1, 400, 300)
    end
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

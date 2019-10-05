local ps
function love.load()
    ps = love.graphics.newParticleSystem(love.graphics.newImage('Ho.png'), 100000)
    ps:setParticleLifetime(2, 5)
    ps:setEmissionRate(5000)
    ps:setSizeVariation(1)
    ps:setLinearAcceleration(-200, -200, 200, 200)
    ps:setRotation(0,2)
    ps:setColors(1, 1, 1, 1, 1, 1, 1, 0)
end

function love.draw()
    love.graphics.draw(ps, 0, 0)
end
 
function love.update(dt)
    ps:update(dt)
end

function love.mousemoved( x, y, dx, dy, istouch )
    ps:moveTo(x,y)
end

function love.mousereleased( x, y, button, istouch, presses)
    if ps:isPaused() then
        ps:start()
    else
        ps:pause()
    end
end

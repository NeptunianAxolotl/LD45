local ps
local world
local player
local junkList = {}

local compConfig = require("components")

local shipPart 

local function SetupWorld()
    world = love.physics.newWorld(0, 0, true) -- Last argument is whether sleep is allowed.

    for i = 1, 20 do
        local junk = love.physics.newBody(world, math.random()*1000 - 500, math.random()*1000 - 500, "dynamic")
        love.physics.newFixture(junk, love.physics.newPolygonShape(-25, -24, 25, -10, 25, 10, -25, 24), 1)

        junk:setAngle(math.random()*2*math.pi)
        junk:setLinearVelocity(math.random()*4, math.random()*4)
        junk:setAngularVelocity(math.random()*2*math.pi)
        junkList[#junkList + 1] = junk
    end
end

local function SetupComponent(body, compDefName, params)
    local comp = {}
    comp.def = compConfig[compDefName]
    comp.shape = love.physics.newPolygonShape(unpack(comp.def.shapeCoords))
    comp.fixture = love.physics.newFixture(body, comp.shape, 1)

    comp.activeKey = params.activeKey

    return comp
end

local function SetupPlayer()
    local body = love.physics.newBody(world, 0, 0, "dynamic")
    body:setAngularVelocity(0.8)

    local components = {}
    components[1] = SetupComponent(body, "booster", {activeKey = 'w'})

    return {
        body = body,
        components = components,
    }
end
 
local function LoadComponentResources()
    for name, def in pairs(compConfig) do
        def.imageOff = love.graphics.newImage(def.imageOff)
        def.imageOn = love.graphics.newImage(def.imageOn)
    end
end

function love.load()
    shipPart = love.graphics.newImage('images/ship.png')

    LoadComponentResources()

    SetupWorld()
    player = SetupPlayer()
end

local function DrawShip(ship)
    for i = 1, #ship.components do
        local comp = ship.components[i]
        love.graphics.draw(comp.def.imageOff, ship.body:getX(), ship.body:getY(), ship.body:getAngle(), 
            comp.def.imageScale[1], comp.def.imageScale[2], comp.def.imageOrigin[1], comp.def.imageOrigin[2])
    end

    love.graphics.draw(shipPart, ship.body:getX(), ship.body:getY(), ship.body:getAngle(), 0.02, 0.02, 400, 300)
end

local function ShipToWorld(body, shape, offX, offY)
    return body:getX() + offX, body:getY() + offY, body:getAngle()
end

local function UpdateInput(ship)
    for i = 1, #ship.components do
        local comp = ship.components[i]
        if love.keyboard.isDown(comp.activeKey) then
            local activeX, activeY, activeAngle = ShipToWorld(ship.body, comp.shape, comp.def.activationOrigin[1], comp.def.activationOrigin[2])
            comp.def:onFunction(ship.body, activeX, activeY, activeAngle)
        end
    end
end

function love.update(dt)
    UpdateInput(player)

    world:update(dt)
end

function love.draw()
    local winWidth  = love.graphics:getWidth()
    local winHeight = love.graphics:getHeight()

    local px, py = player.body:getX(), player.body:getY()
    love.graphics.push()
    love.graphics.translate(winWidth/2 - px, winHeight/2 - py)
    -- Worldspace

    for i = 1, #junkList do
        local junk = junkList[i]
        love.graphics.draw(shipPart, junk:getX(), junk:getY(), junk:getAngle(), 0.1, 0.1, 400, 300)
    end

    DrawShip(player)
    
    love.graphics.pop()
    -- UI space
end


function love.mousemoved( x, y, dx, dy, istouch )
    --ps:moveTo(x,y)
end

function love.mousereleased( x, y, button, istouch, presses)
end

local ps
local world
local player
local junkList = {}

local compConfig, compConfigList = unpack(require("components"))

local shipPart 

local debugHitboxKey = 'm'
local debugEnabled = false

local function GetRandomComponent()
    local num = math.random(1, #compConfigList)
    return compConfigList[num].defName
end

local function SetupComponent(body, compDefName, params)
    params = params or {}
    local comp = {}
    comp.def = compConfig[compDefName]
    if comp.def.circleShapeRadius then
        comp.shape = love.physics.newCircleShape(0, 0, comp.def.circleShapeRadius)
    else
        comp.shape = love.physics.newPolygonShape(unpack(comp.def.shapeCoords))
    end
    comp.fixture = love.physics.newFixture(body, comp.shape, 1)

    comp.activeKey = params.activeKey

    return comp
end

local function SetupWorld()
    world = love.physics.newWorld(0, 0, true) -- Last argument is whether sleep is allowed.

    for i = 1, 20 do
        local junk = love.physics.newBody(world, math.random()*1000 - 500, math.random()*1000 - 500, "dynamic")

        local comp = SetupComponent(junk, GetRandomComponent())
        junk:setAngle(math.random()*2*math.pi)
        junk:setLinearVelocity(math.random()*4, math.random()*4)
        junk:setAngularVelocity(math.random()*2*math.pi)
        junkList[#junkList + 1] = {
            body = junk,
            components = {comp}
        }
    end
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

local function DrawDebug()
    love.graphics.setColor(1,0,0,1)
    local bodies = world:getBodies()
    for i = 1, #bodies do
        local fixtures = bodies[i]:getFixtures()
        for j = 1, #fixtures do
            local shape = fixtures[j]:getShape()
            local shapeType = shape:getType()
            if shapeType == "polygon" then
                local points = {bodies[i]:getWorldPoints(shape:getPoints())}
                love.graphics.polygon("line", points)
            elseif shapeType == "circle" then
                local x, y = bodies[i]:getWorldPoint(shape:getPoint())
                love.graphics.circle("line", x, y, shape:getRadius())
            end
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function love.draw()
    local winWidth  = love.graphics:getWidth()
    local winHeight = love.graphics:getHeight()

    local px, py = player.body:getX(), player.body:getY()
    love.graphics.push()
    love.graphics.translate(winWidth/2 - px, winHeight/2 - py)
    -- Worldspace

    for i = 1, #junkList do
        DrawShip(junkList[i])
    end

    DrawShip(player)

    if debugEnabled then
        DrawDebug()
    end
    
    love.graphics.pop()
    -- UI space
end


function love.mousemoved( x, y, dx, dy, istouch )
    --ps:moveTo(x,y)
end

function love.mousereleased( x, y, button, istouch, presses)
end

function love.keypressed(key, scancode, isRepeat)
    if key == debugHitboxKey and not isRepeat then
        debugEnabled = not debugEnabled
    end
end

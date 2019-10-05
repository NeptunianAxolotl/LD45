local ps
local world
local player
local junkList = {}

local compConfig, compConfigList = unpack(require("components"))

local shipPart 

local debugHitboxKey = 'm'
local debugEnabled = false

local starfield = require("starfield")

local function GetRandomComponent()
    local num = math.random(1, #compConfigList)
    return compConfigList[num].defName
end

local function RotateVector(x, y, angle)
	return x*math.cos(angle) - y*math.sin(angle), x*math.sin(angle) + y*math.cos(angle)
end

local function SetupComponent(body, compDefName, params)
    params = params or {}
    local comp = {}
    comp.def = compConfig[compDefName]

    comp.xOff = params.xOff or 0
    comp.yOff = params.yOff or 0
    comp.angle = params.angle or 0

    local xOff, yOff, angle = comp.xOff, comp.yOff, comp.angle
    if comp.def.circleShapeRadius then
        comp.shape = love.physics.newCircleShape(xOff, yOff, comp.def.circleShapeRadius)
    else
        local coords = comp.def.shapeCoords
        local modCoords = {}
        print("angle", angle)
        for i = 1, #coords, 2 do
            local cx, cy = RotateVector(coords[i], coords[i + 1], angle)
            cx, cy = cx + xOff, cy + yOff
            modCoords[#modCoords + 1] = cx
            modCoords[#modCoords + 1] = cy
        end
        comp.shape = love.physics.newPolygonShape(unpack(modCoords))
    end
    comp.fixture = love.physics.newFixture(body, comp.shape, 1)

    comp.activeKey = params.activeKey
    if params.fixtureData then
       comp.fixture:setUserData(params.fixtureData)
    end

    return comp
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

local function DrawShip(ship)
    for i = 1, #ship.components do
        local comp = ship.components[i]
        love.graphics.draw(comp.def.imageOff, ship.body:getX(), ship.body:getY(), ship.body:getAngle(), 
            comp.def.imageScale[1], comp.def.imageScale[2], comp.def.imageOrigin[1], comp.def.imageOrigin[2])
    end

    if debugEnabled then
        love.graphics.draw(shipPart, ship.body:getX(), ship.body:getY(), ship.body:getAngle(), 0.02, 0.02, 400, 300)
    end
end

function love.draw()
    local winWidth  = love.graphics:getWidth()
    local winHeight = love.graphics:getHeight()

    local px, py = player.body:getX(), player.body:getY()
    love.graphics.push()
    
    local stars = starfield.locations(px, py)
    love.graphics.points(stars)
    
    love.graphics.translate(winWidth/2 - px, winHeight/2 - py)
    -- Worldspace
    for _, junk in pairs(junkList) do
        DrawShip(junk)
    end

    DrawShip(player)

    if debugEnabled then
        DrawDebug()
    end
    
    love.graphics.pop()
    -- UI space
end


function love.mousemoved(x, y, dx, dy, istouch )
    --ps:moveTo(x,y)
end

function love.mousereleased(x, y, button, istouch, presses)
end

function love.keypressed(key, scancode, isRepeat)
    if key == debugHitboxKey and not isRepeat then
        debugEnabled = not debugEnabled
    end
end

local function LoadComponentResources()
    for name, def in pairs(compConfig) do
        def.imageOff = love.graphics.newImage(def.imageOff)
        def.imageOn = love.graphics.newImage(def.imageOn)
    end
end

--------------------------------------------------
-- Colisions
--------------------------------------------------

local collisionToAdd

local function beginContact(a, b, coll)
    local aData, bData = a:getUserData() or {}, b:getUserData() or {}
    if aData.isPlayer == bData.isPlayer then
        return
    end
    playerFixture = (aData.isPlayer and a) or b
    otherFixture  = (bData.isPlayer and a) or b

    collisionToAdd = collisionToAdd or {}
    collisionToAdd[#collisionToAdd + 1] = {playerFixture, otherFixture}
end

local function endContact(a, b, coll)

end

local function preSolve(a, b, coll)

end

local function postSolve(a, b, coll,  normalimpulse, tangentimpulse)

end

--------------------------------------------------
-- Update
--------------------------------------------------

local function DoMerge(playerFixture, otherFixture)
    if otherFixture:isDestroyed() then
        return
    end

    local otherData = otherFixture:getUserData()
    if not otherData.junkIndex then
        return
    end
    local junk = junkList[otherData.junkIndex]

    local junkBody = junk.body
    local playerBody = playerFixture:getBody()

    for i = 1, #junk.components do
        local comp = junk.components[i]
        local xOff, yOff = playerBody:getLocalPoint(junkBody:getWorldPoint(comp.xOff, comp.yOff))

        local angle = junkBody:getAngle() - playerBody:getAngle() + comp.angle

        SetupComponent(playerBody, otherData.compDefName, {
                activeKey = 'w',
                fixtureData = {isPlayer = true, compDefName = compDefName},
                xOff = xOff,
                yOff = yOff,
                angle = angle,
            }
        )
    end
    
    otherFixture:getBody():destroy()
    junkList[otherData.junkIndex] = nil
end

local function ProcessCollisions()
    for i = 1, #collisionToAdd do
        local playerFixture, otherFixture = collisionToAdd[i][1], collisionToAdd[i][2]
        DoMerge(playerFixture, otherFixture)
    end
    collisionToAdd = false
end

function love.update(dt)
    UpdateInput(player)
    world:update(0.033)
    if collisionToAdd then
        ProcessCollisions()
    end
end

--------------------------------------------------
-- Loading
--------------------------------------------------

local function SetupWorld()
    world = love.physics.newWorld(0, 0, true) -- Last argument is whether sleep is allowed.
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    for i = 1, 20 do
        local junk = love.physics.newBody(world, math.random()*1000 - 500, math.random()*1000 - 500, "dynamic")

        local compDefName = GetRandomComponent()
        local comp = SetupComponent(junk, compDefName, {fixtureData = {junkIndex = i, compDefName = compDefName}})
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
    components[1] = SetupComponent(body, "booster", {activeKey = 'w', fixtureData = {isPlayer = true, compDefName = compDefName}})

    return {
        body = body,
        components = components,
    }
end

function love.load()
    shipPart = love.graphics.newImage('images/ship.png')

    LoadComponentResources()

    SetupWorld()
    player = SetupPlayer()
end

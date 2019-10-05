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
    return compConfigList[num].name
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
        for i = 1, #coords, 2 do
            local cx, cy = RotateVector(coords[i], coords[i + 1], angle)
            cx, cy = cx + xOff, cy + yOff
            modCoords[#modCoords + 1] = cx
            modCoords[#modCoords + 1] = cy
        end
        comp.shape = love.physics.newPolygonShape(unpack(modCoords))
    end
    comp.fixture = love.physics.newFixture(body, comp.shape, comp.def.density)

    comp.activeKey = params.activeKey
    local fixtureData = params.fixtureData or {}
    fixtureData.noAttach = comp.def.noAttach
    comp.fixture:setUserData(fixtureData)

    return comp
end

local function UpdateInput(ship)
    for i = 1, #ship.components do
        local comp = ship.components[i]
        if comp.def.onFunction and love.keyboard.isDown(comp.activeKey) then
            local ox, oy = ship.body:getWorldPoint(comp.xOff, comp.yOff)
            local vx, vy = comp.def.activationOrigin[1], comp.def.activationOrigin[2]
            local angle = ship.body:getAngle() + comp.angle
            vx, vy = RotateVector(vx, vy, ship.body:getAngle() + comp.angle)
            comp.def:onFunction(ship.body, ox + vx, oy + vy, angle)
        end
    end
end

local function DrawShipVectors(ship)
    for i = 1, #ship.components do
        local comp = ship.components[i]
        local ox, oy = ship.body:getWorldPoint(comp.xOff, comp.yOff)
        local vx, vy = comp.def.activationOrigin[1], comp.def.activationOrigin[2]
        local angle = ship.body:getAngle() + comp.angle
        vx, vy = RotateVector(vx, vy, ship.body:getAngle() + comp.angle)
        local dx, dy = ox + vx, oy + vy
        love.graphics.line(dx, dy, dx + 20*math.cos(angle), dy + 20*math.sin(angle))
        love.graphics.circle("line", dx, dy, 10)
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

    DrawShipVectors(player)

    love.graphics.setColor(1, 1, 1, 1)
end

local function DrawShip(ship)
    for i = 1, #ship.components do
        local comp = ship.components[i]
        local dx, dy = ship.body:getWorldPoint(comp.xOff, comp.yOff)
        love.graphics.draw(comp.def.imageOff, dx, dy, ship.body:getAngle() + comp.angle, 
            comp.def.imageScale[1], comp.def.imageScale[2], comp.def.imageOrigin[1], comp.def.imageOrigin[2])

        if comp.activeKey ~= nil and comp.def.onFunction ~= nil then
            local textDef = comp.def.text

            love.graphics.setColor(unpack(comp.def.text.color))
            love.graphics.print(comp.activeKey, dx, dy, ship.body:getAngle() + comp.angle + textDef.rotation, textDef.scale[1], textDef.scale[2], textDef.pos[1], textDef.pos[2])
            love.graphics.setColor(1,1,1,1)
        end
    end

    if debugEnabled then
        love.graphics.draw(shipPart, ship.body:getX(), ship.body:getY(), ship.body:getAngle(), 0.02, 0.02, 400, 300)
    end
end

local cameraX, cameraY = 0, 0
local smoothCameraFactor = 0.25
local function UpdateCameraPos()
    local px, py = player.body:getWorldCenter()
    cameraX = (1 - smoothCameraFactor)*cameraX + smoothCameraFactor*px
    cameraY = (1 - smoothCameraFactor)*cameraY + smoothCameraFactor*py

    return cameraX, cameraY
end

function love.draw()
    local winWidth  = love.graphics:getWidth()
    local winHeight = love.graphics:getHeight()

    love.graphics.push()
    
    local cx, cy = UpdateCameraPos()
    local stars = starfield.locations(cx, cy)
    love.graphics.points(stars)
    
    love.graphics.translate(winWidth/2 - cx, winHeight/2 - cy)
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
    if aData.noAttach or bData.noAttach then
        return
    end
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

        player.components[#player.components + 1] = SetupComponent(playerBody, otherData.compDefName, {
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

local function MakeJunk(index)
    local junk = love.physics.newBody(world, math.random()*1000 - 500, math.random()*1000 - 500, "dynamic")

    local compDefName = GetRandomComponent()
    local comp = SetupComponent(junk, compDefName, {fixtureData = {junkIndex = index, compDefName = compDefName}})
    junk:setAngle(math.random()*2*math.pi)
    junk:setLinearVelocity(math.random()*4, math.random()*4)
    junk:setAngularVelocity(math.random()*2*math.pi)
    junkList[#junkList + 1] = {
        body = junk,
        components = {comp}
    }
end

local function SetupWorld()
    world = love.physics.newWorld(0, 0, true) -- Last argument is whether sleep is allowed.
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    for i = 1, 20 do
        MakeJunk(i)
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
    math.randomseed(os.clock())
    shipPart = love.graphics.newImage('images/ship.png')

    LoadComponentResources()

    SetupWorld()
    player = SetupPlayer()
end

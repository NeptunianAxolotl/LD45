local cameraX, cameraY = 0, 0
local smoothCameraFactor = 0.25

local starfield = require("starfield")
local util = require("util")

local shipPart 

local function DrawShipVectors(ship)
    for i = 1, #ship.components do
        local comp = ship.components[i]
        local ox, oy = ship.body:getWorldPoint(comp.xOff, comp.yOff)
        local vx, vy = comp.def.activationOrigin[1], comp.def.activationOrigin[2]
        local angle = ship.body:getAngle() + comp.angle
        vx, vy = util.RotateVector(vx, vy, ship.body:getAngle() + comp.angle)
        local dx, dy = ox + vx, oy + vy
        love.graphics.line(dx, dy, dx + 20*math.cos(angle), dy + 20*math.sin(angle))
        love.graphics.circle("line", dx, dy, 10)
    end
end

local function DrawDebug(world, player)
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

        local image = (comp.activated and comp.def.imageOn) or comp.def.imageOff

        love.graphics.draw(image, dx, dy, ship.body:getAngle() + comp.angle, 
            comp.def.imageScale[1], comp.def.imageScale[2], comp.def.imageOrigin[1], comp.def.imageOrigin[2])

        if comp.def.text ~= nil and comp.isPlayer then
            local textDef = comp.def.text
            local keyName = comp.activeKey or "??"

            love.graphics.setColor(unpack(comp.def.text.color))
            love.graphics.print(string.upper(keyName), dx, dy, ship.body:getAngle() + comp.angle + textDef.rotation, textDef.scale[1], textDef.scale[2], textDef.pos[1], textDef.pos[2])
            love.graphics.setColor(1,1,1,1)
        end
    end

    if debugEnabled then
        love.graphics.draw(shipPart, ship.body:getX(), ship.body:getY(), ship.body:getAngle(), 0.02, 0.02, 400, 300)
    end
end

local function UpdateCameraPos(player)
    local px, py = player.body:getWorldCenter()
    cameraX = (1 - smoothCameraFactor)*cameraX + smoothCameraFactor*px
    cameraY = (1 - smoothCameraFactor)*cameraY + smoothCameraFactor*py

    return cameraX, cameraY
end

local externalFunc = {}

function externalFunc.draw(world, player, junkList, debugEnabled, needKeybind, setKeybind) 
    local winWidth  = love.graphics:getWidth()
    local winHeight = love.graphics:getHeight()

    love.graphics.push()

    local cx, cy = UpdateCameraPos(player)
    local stars = starfield.locations(cx, cy)
    love.graphics.points(stars)

    love.graphics.translate(winWidth/2 - cx, winHeight/2 - cy)
    -- Worldspace
    for _, junk in pairs(junkList) do
        DrawShip(junk)
    end

    DrawShip(player)

    if debugEnabled then
        DrawDebug(world, player)
    end

    love.graphics.pop()
    -- UI space

    if needKeybind and not setKeybind then
        love.graphics.print("Press space to set unbound component keys", 10, 10, 0, 2, 2)
    elseif setKeybind then
        love.graphics.print("Press any key to set a keybind", 10, 10, 0, 2, 2)
    end
end

local function LoadComponentResources()
    local compConfig, compConfigList = unpack(require("components"))
    for name, def in pairs(compConfig) do
        def.imageOff = love.graphics.newImage(def.imageOff)
        def.imageOn = love.graphics.newImage(def.imageOn)
    end
end

function externalFunc.load()
    shipPart = love.graphics.newImage('images/ship.png')
    LoadComponentResources()
end

return externalFunc

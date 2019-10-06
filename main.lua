local debugHitboxKey = 'm'
local debugEnabled = false

IterableMap = require("IterableMap")
util = require("util")

drawSystem = require("draw")
gameSystem = require("game")

local intro = true
local introTimer = 0

local world
local player = {
    guy = nil,
    ship = nil,
    setKeybind = false, 
    needKeybind = false,
    crawlSpeed = 5,
    girderAddDist = 60,
}

local junkList = {}
local junkIndex = 0

--------------------------------------------------
-- Draw
--------------------------------------------------

local lastDt = 0
function love.draw()
    if intro == true then
        
    end
    
    drawSystem.draw(world, player, junkList, debugEnabled, lastDt)
end

--------------------------------------------------
-- Input
--------------------------------------------------

function love.mousemoved(x, y, dx, dy, istouch )
    --ps:moveTo(x,y)
end

function love.mousereleased(x, y, button, istouch, presses)
end

function love.keypressed(key, scancode, isRepeat)
    if key == debugHitboxKey and not isRepeat then
        debugEnabled = not debugEnabled
    end

    if player.ship and player.needKeybind and player.onComponent then
        local comp = player.onComponent
        if comp and comp.def.text and not comp.activeKey and not isRepeat then
            comp.activeKey = key
            player.needKeybind = false
        end
    end

    gameSystem.KeyPressed(player, junkList, key, isRepeat)
end

local function MouseHitFunc(fixture)
    local fixtureData = fixture:getUserData()
    if fixtureData.junkIndex and not fixtureData.noSelect then
        -- Todo: point intersection
        if gameSystem.TestJunkClick(junkList[fixtureData.junkIndex]) then
            return false
        end
    end

    return true
end

function love.mousepressed(x, y, button, istouch, presses)
    --local mx, my = drawSystem.WindowSpaceToWorldSpace(x, y)
    -- clicking on junk
    --world:queryBoundingBox(mx - 2, my - 2, mx + 2, my + 2, MouseHitFunc)
end

--------------------------------------------------
-- Colisions
--------------------------------------------------

local function beginContact(a, b, coll)
    gameSystem.beginContact(a, b, coll)
end

local function endContact(a, b, coll)
end

local function preSolve(a, b, coll)
end

local function postSolve(a, b, coll,  normalimpulse, tangentimpulse)
    gameSystem.postSolve(a, b, coll,  normalimpulse, tangentimpulse)
end

--------------------------------------------------
-- Update
--------------------------------------------------

function love.update(dt)
    if intro == true then
        introTimer = introTimer + dt
        
        if introTimer > 5 then
        end
        
        if introTimer > 10 then
        end
        
        if introTimer > 15 then
        end
        
        if introTimer > 20 then
            introTimer = false
        end
    end
    
    lastDt = dt
    local px, py = (player.ship or player.guy).body:getWorldCenter()
    gameSystem.ExpandJunkspace(world, junkList, px, py)
    gameSystem.UpdateComponentActivation(player.ship, junkList, player, dt)

    local mx, my = drawSystem.WindowSpaceToWorldSpace(love.mouse.getX(), love.mouse.getY())
    gameSystem.UpdateMovePlayerGuy(player, mx, my)
    gameSystem.UpdatePlayerComponentAttributes(player)

    if dt < 0.4 then
        world:update(dt)
    end
    gameSystem.ProcessCollisions(world, player, junkList)
end

--------------------------------------------------
-- Loading
--------------------------------------------------

local function SetupWorld()
    world = love.physics.newWorld(0, 0, true) -- Last argument is whether sleep is allowed.
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

function love.load()
    math.randomseed(os.clock())
    --love.graphics.setFont(love.graphics.newFont('Resources/fonts/pixelsix00.ttf'))
    drawSystem.load()

    SetupWorld()

    player.guy = gameSystem.SetupPlayer(world, junkList)
end

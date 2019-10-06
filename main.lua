local debugHitboxKey = 'm'
local debugEnabled = false

IterableMap = require("IterableMap")
util = require("util")

SUPER_DEBUG_ENABLED = false

font = require("font")

drawSystem = require("draw")
gameSystem = require("game")
introSystem = require("intro")

local world
local player = {
    guy = nil,
    ship = nil,
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
    if not introSystem.drawIntro() then
        local winWidth  = love.graphics:getWidth()
        local winHeight = love.graphics:getHeight()
        
        winPoints = {}
        winPoints[1] = 0
        winPoints[2] = 0
        winPoints[3] = 0
        winPoints[4] = winHeight
        winPoints[5] = winWidth
        winPoints[6] = winHeight
        winPoints[7] = winWidth
        winPoints[8] = 0
        
        local introTimer = introSystem.getIntroTimer()
        local introCancel = introSystem.getIntroCancel()
        
        drawSystem.draw(world, player, junkList, debugEnabled, lastDt)

        if introTimer > introCancel + 2 and introTimer < introCancel + 3 then    
            love.graphics.setColor(0, 0, 0, math.min((1 - (introTimer - math.min(23, introCancel + 2)) / 1), 1))
            love.graphics.polygon("fill", winPoints)
            love.graphics.setColor(1,1,1)
        end
        
        drawSystem.drawConsole()
    end
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
local escPressed = false
function love.update(dt)
    if love.keyboard.isDown("escape") and escPressed == false then
        introSystem.setIntroCancel()
        escPressed = true
    end
    
    if not introSystem.updateIntro(dt) then
        lastDt = dt
        local px, py = (player.ship or player.guy).body:getWorldCenter()
        gameSystem.ExpandJunkspace(world, junkList, px, py)
        gameSystem.UpdateComponentActivation(player, junkList, player, dt)

        local mx, my = drawSystem.WindowSpaceToWorldSpace(love.mouse.getX(), love.mouse.getY())
        gameSystem.UpdateMovePlayerGuy(player, mx, my)
        gameSystem.UpdatePlayerComponentAttributes(player)

        if dt < 0.4 then
            world:update(dt)
        end
        gameSystem.ProcessCollisions(world, player, junkList)
    end
end

--------------------------------------------------
-- Loading
--------------------------------------------------

local function SetupWorld()
    world = love.physics.newWorld(0, 0, true) -- Last argument is whether sleep is allowed.
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

function love.load()
    if not introSystem.loadIntro() then    
        math.randomseed(os.clock())
        drawSystem.load()

        SetupWorld()

        player.guy = gameSystem.SetupPlayer(world, junkList)
    end
end

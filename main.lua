local debugHitboxKey = 'm'
local debugEnabled = false

IterableMap = require("IterableMap")
util = require("util")

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
        drawSystem.draw(world, player, junkList, debugEnabled, lastDt)
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
    if love.keyboard.isDown("escape") then
        introSystem.setIntro(false)
    end
    
    if not introSystem.updateIntro(dt) then
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
        --love.graphics.setFont(love.graphics.newFont('Resources/fonts/pixelsix00.ttf'))
        drawSystem.load()

        SetupWorld()

        player.guy = gameSystem.SetupPlayer(world, junkList)
    end
end
